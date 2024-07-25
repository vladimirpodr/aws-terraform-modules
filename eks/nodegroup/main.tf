locals {
  node_group_full_name    = "${var.basename}-eks-${var.pool}-nodegroup"
  launch_template_version = try(aws_launch_template.nodes.default_version, "$Default")
  # Node labels and taints
  kubelet_args = (var.pool != "" && var.taint) ? " --register-with-taints dedicated=${var.pool}:NoSchedule" : ""
}

### IAM Role for Node Group
resource "aws_iam_role" "node-group" {
  name = "${local.node_group_full_name}-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })

  tags = merge(var.tags, {
    Name = "${local.node_group_full_name}-role"
  })
}

# Attach Policy to Node Groups Role
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node-group.name
}

# Attach Policy to Node Groups Role
resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node-group.name
}

# Attach Policy to Node Groups Role
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node-group.name
}

# Allow nodes to work with SSM
resource "aws_iam_role_policy_attachment" "node-AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.node-group.name
}

# Allow nodes to work with CloudWatch
resource "aws_iam_role_policy_attachment" "node-CloudWatchAgentServerPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.node-group.name
}

### Launch template for Node Group
resource "aws_launch_template" "nodes" {

  name                   = "${local.node_group_full_name}-lt"
  instance_type          = var.instance_type
  image_id               = var.instance_ami
  update_default_version = true

  user_data = base64encode(<<-EOF
  MIME-Version: 1.0
  Content-Type: multipart/mixed; boundary="/:/+++"

  --/:/+++
  Content-Type: text/x-shellscript; charset="us-ascii"
  #!/bin/bash
  set -ex

  B64_CLUSTER_CA=${var.cluster.cadata}
  API_SERVER_URL=${var.cluster.endpoint}
  /etc/eks/bootstrap.sh ${var.cluster.name} --b64-cluster-ca $B64_CLUSTER_CA --apiserver-endpoint $API_SERVER_URL \
  %{if local.kubelet_args != ""~}
       --kubelet-extra-args '${local.kubelet_args}' 
  %{endif~}
  --/:/+++--
  EOF
  )

  block_device_mappings {
    device_name = var.device_name

    ebs {
      volume_type           = var.volume_type
      volume_size           = var.disk_size
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = var.kms_key_id
    }
  }

  network_interfaces {
    security_groups = [var.cluster.cluster_sg]

    delete_on_termination       = true
    associate_public_ip_address = var.cluster.eks_internet_access
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_protocol_ipv6          = "enabled"
    instance_metadata_tags      = "enabled"
    http_put_response_hop_limit = 2
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, aws_iam_role.node-group.tags_all, {
      Name = local.node_group_full_name
    })
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = "${local.node_group_full_name}-lt"
  })
}

# EKS Node Group Profile
resource "aws_eks_node_group" "node-group-eks" {

  cluster_name    = var.cluster.name
  node_group_name = local.node_group_full_name
  node_role_arn   = aws_iam_role.node-group.arn
  subnet_ids      = var.subnets
  capacity_type   = var.capacity_type
  ami_type        = "CUSTOM"

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  launch_template {
    id      = aws_launch_template.nodes.id
    version = local.launch_template_version
  }

  ### Add labels to node
  labels = {
    "pool" = var.pool
  }

  tags = merge(var.tags, {
    Name = local.node_group_full_name
  })

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config[0].desired_size]
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

### Outputs
output "lt_id" { value = aws_launch_template.nodes.id }
output "node_role_arn" { value = aws_iam_role.node-group.arn }
output "node_role_name" { value = aws_iam_role.node-group.name }
output "node_group_id" { value = aws_eks_node_group.node-group-eks.id }
output "node_group_arn" { value = aws_eks_node_group.node-group-eks.arn }
