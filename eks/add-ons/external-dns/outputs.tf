output "argocd_gitops_config" {
  description = "Configuration used for managing the add-on with GitOps"
  value       = local.argocd_gitops_config
}
