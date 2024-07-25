locals {
  default_argocd_application = {

    namespace          = "argocd"
    target_revision    = "HEAD"
    destination        = "https://kubernetes.default.svc"
    project            = "default"
    values             = {}
    value_file         = ""
    type               = "helm"
    add_on_application = false
    auto_sync_policy   = "disabled"
  }
}
