locals {
  add_on    = "argo-cd"
  name      = "${var.addon_context.name}-${local.add_on}"
  namespace = "argocd"

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    name          = local.name
    project_name  = var.project_name
    environment   = var.environment
    domain_name   = var.domain_name
    certificate   = var.domain_certificate

    google_oauth_client_id   = var.google_oauth_client_id
    google_oauth_admin_email = var.google_oauth_admin_email

    lb_access_logs_s3_bucket = var.lb_access_logs_s3_bucket
  })]

  default_helm_config = {
    name             = local.add_on
    chart            = local.add_on
    repository       = "https://argoproj.github.io/argo-helm"
    version          = "5.4.2"
    namespace        = local.namespace
    timeout          = 1200
    create_namespace = true
    values           = local.default_helm_values
    description      = "The ArgoCD Helm Chart deployment configuration"
    wait             = false
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )
}
