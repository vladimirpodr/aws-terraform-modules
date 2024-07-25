variable "addon_context" {
  description = "Input configuration for the addon"
  type        = any
  default     = {}
}

variable "repositories" {
  description = "The map of repositories and secrets for ArgoCD to have access to private repositories."
  type        = map
  default     = {}
}
