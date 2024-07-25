locals {
  name                        = "datadog-agent"
  datadog_api_key_secret_name = "datadog-api-key"

  argocd_gitops_config = {
    enable               = true
    apiKeyExistingSecret = local.datadog_api_key_secret_name
  }
}