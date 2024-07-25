locals {
  name = "metrics-server"

  argocd_gitops_config = {
    enable = true
  }
}
