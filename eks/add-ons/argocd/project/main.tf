
# ---------------------------------------------------------------------------------------------------------------------
# ArgoCD Project Bootstrapping (Helm)
# ---------------------------------------------------------------------------------------------------------------------
resource "helm_release" "argocd_project" {

  name      = "${var.project_name}-${var.environment}"
  chart     = "${path.module}/chart"
  version   = "1.0.0"
  namespace = "argocd"

  # Project Meta.
  set {
    name  = "name"
    value = "${var.project_name}-${var.environment}"
    type  = "string"
  }

  set {
    name  = "environment"
    value = var.environment
    type  = "string"
  }
}
