locals {
  name = "ingress-nginx"

  argocd_gitops_config = {
    enable = true
  }
}
