### Variables
variable "basename"    { type = string }

# List of the node pools
variable "pools" { type = list(string) }

# IAM Roles to map to kube users
variable "admin_role" { default = "" }
variable "power_user_role" { default = "" }
variable "read_only_role" { default = "" }

data "aws_caller_identity" "current" {}


resource "kubernetes_cluster_role_binding" "power_user" {
  metadata {
    name = "edit"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "edit"
  }
  subject {
    kind      = "Group"
    name      = "power-users"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_cluster_role_binding" "read_only" {
  metadata {
    name = "view"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view"
  }
  subject {
    kind      = "Group"
    name      = "read-only-users"
    api_group = "rbac.authorization.k8s.io"
  }
}

locals {
 
 # aws-auth contents
  map_roles = <<-AWSAUTH
        %{for pool in var.pools}
        - rolearn: arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.basename}-eks-${pool}-nodegroup-role
          username: system:node:{{EC2PrivateDNSName}}
          groups:
            - system:bootstrappers
            - system:nodes
        %{endfor}
        %{if var.admin_role != ""}
        - rolearn: arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.admin_role}
          username: AdministratorAccess:{{SessionName}}
          groups:
            - system:masters
        %{endif}
        %{if var.power_user_role != ""}
        - rolearn: arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.power_user_role}
          username: PowerUserAccess:{{SessionName}}
          groups:
            - system:power-users
        %{endif}
        %{if var.read_only_role != ""}
        - rolearn: arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.read_only_role}
          username: ReadOnlyAccess:{{SessionName}}
          groups:
            - system:read-only-users
        %{endif}
    AWSAUTH
}

resource "kubernetes_config_map" "eks_aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    "mapRoles" = local.map_roles  
  }
}

output "aws_auth_context" {
  value = local.map_roles
}
