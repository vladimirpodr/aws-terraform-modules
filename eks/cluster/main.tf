### Variables
variable "name" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}

variable "eks_version" { default = null }
variable "enable_irsa" {
  type        = bool
  default     = true
}
variable "enable_cluster_encryption" {
  type        = bool
  default     = false
}
variable "cluster_encryption_config" {
  type        = list(any)
  default     = []
}

variable "vpc_id" { type = string }
variable "subnets" { type = list(string) }

variable "connect_nodes" { default = false }

variable "endpoint_private_access" { default = true }
variable "endpoint_public_access" { default = false }
variable "public_access_cidrs" { default = ["0.0.0.0/0"] }
variable "cluster_logs_retention_in_days" {
  type        = number
  default     = 90
}

data "aws_caller_identity" "current" {}
data "aws_eks_cluster_auth" "main" {
  name = aws_eks_cluster.main.id
}

locals {
  eks_oidc_issuer_url  = var.enable_irsa ? replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "") : ""
}

### IAM Role: EKS Cluster Role
resource "aws_iam_role" "eks-cluster" {
  name = "${var.name}-role"

  assume_role_policy = <<-POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": "sts:AssumeRole",
          "Principal": { "Service": "eks.amazonaws.com" }
        }
      ]
    }
    POLICY

  tags = merge(var.tags, {
    Name = "${var.name}-role"
  })
}

# Attach default IAM policies
resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSClusterPolicy" {
  role = aws_iam_role.eks-cluster.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSServicePolicy" {
  role = aws_iam_role.eks-cluster.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource "aws_iam_policy" "cluster_encryption" {
  count = var.enable_cluster_encryption ? 1 : 0

  name        = "${var.name}-cluster-encryption-policy"
  description = "Cluster encryption policy to allow cluster role to utilize CMK provided"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ListGrants",
          "kms:DescribeKey",
        ]
        Effect   = "Allow"
        Resource = module.kms[0].key_arn
      },
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.name}-cluster-encryption-policy"
  })
}

resource "aws_iam_role_policy_attachment" "cluster_encryption" {
  count = var.enable_cluster_encryption ? 1 : 0

  policy_arn = aws_iam_policy.cluster_encryption[0].arn
  role       = aws_iam_role.eks-cluster.name
}

### Security Group: EKS control plane
resource "aws_security_group" "eks" {
  vpc_id = var.vpc_id
  name   = "${var.name}-sg"

  description = "Security Group for ${var.name} EKS Cluster"

  # Allow any egress
  egress {
    protocol  = "-1"
    from_port = 0
    to_port   = 0

    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-sg"
  })
}

### Security Group: Full access between all nodes
resource "aws_security_group" "nodes" {
  count  = var.connect_nodes ? 1 : 0
  vpc_id = var.vpc_id
  name   = "${var.name}-nodes-sg"

  description = "Full access between all nodes"

  # Allow any egress
  egress {
    protocol  = "-1"
    from_port = 0
    to_port   = 0

    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-nodes-sg"
  })
}

### Security Group Rule: Allow access between all nodes
resource "aws_security_group_rule" "fullaccess" {
  count = var.connect_nodes ? 1 : 0

  description = "Full access between all nodes in different node pools"

  security_group_id = aws_security_group.nodes[count.index].id

  type      = "ingress"
  protocol  = "-1"
  from_port = 0
  to_port   = 0

  source_security_group_id = aws_security_group.nodes[count.index].id
}

### EKS Cluster
resource "aws_eks_cluster" "main" {
  name = var.name

  version                   = var.eks_version
  role_arn                  = aws_iam_role.eks-cluster.arn
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.endpoint_public_access ? var.public_access_cidrs : null

    subnet_ids = var.subnets

    security_group_ids = [aws_security_group.eks.id]
  }

  dynamic "encryption_config" {
    for_each = toset(var.cluster_encryption_config)

    content {
      provider {
        key_arn = module.kms[0].key_arn
      }
      resources = encryption_config.value.resources
    }
  }

  # Ensure policies are attached to the role
  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSServicePolicy,
    aws_cloudwatch_log_group.main
  ]

  tags = merge(var.tags, {
    Name = var.name
  })
}

# Control plane logging
resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/eks/${var.name}/cluster"
  retention_in_days = var.cluster_logs_retention_in_days

  tags = merge(var.tags, {
    Name = "${var.name}-log-group"
  })
}

### Enable EKS IRSA
data "tls_certificate" "irsa" {
  count = var.enable_irsa ? 1 : 0

  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "irsa" {
  count = var.enable_irsa ? 1 : 0

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.irsa[0].certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer

  tags = merge(var.tags, {
    Name = "${var.name}-irsa-provider"
  })
}

# KMS Keys
module "kms" {
  source  = "git@github.com:ambyint/aws-terraform-modules.git//kms/"

  count = var.enable_cluster_encryption ? 1 : 0

  description             = coalesce("${var.name} cluster encryption key")
  deletion_window_in_days = 7
  enable_key_rotation     = true

  # Policy
  enable_default_policy     = true
  # key_administrators        = [data.aws_caller_identity.current.arn]
  key_users                 = [aws_iam_role.eks-cluster.arn]

  # Aliases
  aliases = ["eks/${var.name}"]

  tags = merge(var.tags, {
    Name = "${var.name}-kms-key"
  })
}

### Outputs
output "id" { value = aws_eks_cluster.main.id }

output "config" {
  value = {
    id                  = aws_eks_cluster.main.id
    name                = var.name
    vpc_id              = var.vpc_id
    sg_id               = aws_security_group.eks.id
    cluster_sg          = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id // generated by EKS
    eks_internet_access = aws_eks_cluster.main.vpc_config[0].endpoint_public_access

    version  = aws_eks_cluster.main.version
    endpoint = aws_eks_cluster.main.endpoint
    cadata   = aws_eks_cluster.main.certificate_authority[0].data

    oidc_provider_arn = var.enable_irsa ? "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.eks_oidc_issuer_url}" : ""
  }
}


output "role" {
  value = {
    name = aws_iam_role.eks-cluster.name
    arn  = aws_iam_role.eks-cluster.arn
  }
}

output "connect_nodes_sg" {
  value = var.connect_nodes ? aws_security_group.nodes.0.id : ""
}

output "openid_provider_url" { value = aws_eks_cluster.main.identity.0.oidc.0.issuer }

output "eks_token" { value = data.aws_eks_cluster_auth.main.token }

output "eks_subnets" { value = aws_eks_cluster.main.vpc_config[0].subnet_ids }
