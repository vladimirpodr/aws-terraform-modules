variable "addon_context" {
  description = "Input configuration for the addon"
  type = object({
    name                           = string
    aws_region_name                = string
    aws_caller_identity_account_id = string
    eks_cluster_id                 = string
    eks_oidc_provider_arn          = string
    kubernetes_namespace           = string
    tags                           = map(string)
  })
}
