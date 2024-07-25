output "argocd_gitops_config" {
  description = "Configuration used for managing the add-on with ArgoCD"
  value = {
    enable             = true
    serviceAccountName = local.service_account_name
  }
}
