module "argocd" {
  count  = var.enable_argocd ? 1 : 0
  source = "./argocd/install"


  helm_config              = var.argocd_helm_config
  project_name             = var.project_name
  environment              = var.environment
  domain_name              = var.domain_name
  domain_certificate       = var.domain_certificate_arn
  lb_access_logs_s3_bucket = var.lb_access_logs_s3_bucket
  addon_context            = local.addon_context
  repositories             = var.argocd_repositories

  # SSO: OpenID Connect plus Google Groups using Dex
  enable_sso                     = var.argocd_enable_sso
  google_groups_json_secret_arn  = var.argocd_google_groups_json_secret_arn
  google_oauth_client_id         = var.argocd_google_oauth_client_id
  google_oauth_client_secret_arn = var.argocd_google_oauth_client_secret_arn
  google_oauth_admin_email       = var.argocd_google_oauth_admin_email
}

# NOTE: Due to the terraform "cycle dependecies" error we should create the namespace before creationg apps and service accounts for add-ons
resource "kubernetes_namespace_v1" "core" {
  metadata {
    name = local.add_ons_namespace
  }
}

# ArgoCD App of Apps Bootstrapping (Helm)
module "eks_add_ons_app_of_apps" {
  source = "./argocd/application"

  applications = {
    core = {
      # Add-ons source repo configuration
      repo_url = var.argocd_application.repo_url
      path     = var.argocd_application.path

      add_on_application = true
      auto_sync_policy   = "enabled"

      namespace = local.add_ons_namespace

      values = local.application_values
    }
  }
}

module "aws_efs_csi_driver" {
  count             = var.enable_aws_efs_csi_driver ? 1 : 0
  source            = "./aws-efs-csi-driver"
  addon_context     = local.addon_context
}

module "aws_load_balancer_controller" {
  count             = var.enable_aws_load_balancer_controller ? 1 : 0
  source            = "./aws-load-balancer-controller"
  addon_context     = local.addon_context
}

module "cluster_autoscaler" {
  source = "./cluster-autoscaler"

  count = var.enable_cluster_autoscaler ? 1 : 0

  addon_context = local.addon_context
}

module "datadog_agent" {
  source = "./datadog-agent"

  count = var.enable_datadog_agent ? 1 : 0

  addon_context      = local.addon_context
  api_key_secret_arn = var.datatdog_api_key_secret_arn
}

module "external_dns" {
  source = "./external-dns"

  count = var.enable_external_dns ? 1 : 0

  addon_context     = local.addon_context
  route53_zone_arns = var.external_dns_route53_zone_arns
}

# module "ingress_nginx" {
#   count             = var.enable_ingress_nginx ? 1 : 0
#   source            = "./ingress-nginx"
#   addon_context     = local.addon_context
# }

# module "karpenter" {
#   count                     = var.enable_karpenter ? 1 : 0
#   source                    = "./karpenter"
#   node_iam_instance_profile = var.karpenter_node_iam_instance_profile
#   addon_context             = local.addon_context
# }

module "keda" {
  count             = var.enable_keda ? 1 : 0
  source            = "./keda"
  addon_context     = local.addon_context

  keda_auth_kafka_credential_secret_arn    = var.keda_auth_kafka_credential_secret_arn
  keda_auth_rabbitmq_credential_secret_arn = var.keda_auth_rabbitmq_credential_secret_arn
}

module "metrics_server" {
  count             = var.enable_metrics_server ? 1 : 0
  source            = "./metrics-server"
  addon_context     = local.addon_context
}

# Secrets Store CSI Driver and AWS Key Management Service Provider
module "csi_secrets_store_provider_aws" {
  count             = var.enable_secrets_store_csi_driver_provider_aws ? 1 : 0
  source            = "./csi-secrets-store-provider-aws"
  addon_context     = local.addon_context
}

# FLUX v2
module "flux2" {
  count             = var.enable_flux2 ? 1 : 0
  source            = "./flux2"
  addon_context     = local.addon_context
  repositories      = var.argocd_repositories
}
