variable "helm_config" {
  description = "ArgoCD Helm Chart Config values"
  type        = any
  default     = {}
}

variable "repositories" {
  description = "The map of repositories and secrets for ArgoCD to have access to private repositories."
  type        = map
  default     = {}
}

variable "addon_context" {
  description = "Input configuration for the addon"
  type        = any
  default     = {}
}

variable "project_name" {
  description = "Project name."
}

variable "environment" {
  description = "Project environment/account name."
}

variable "domain_name" {
  description = "Domain name of the Route53 hosted zone to configure ArgoCD sub-domain name."
  type        = string
}

variable "domain_certificate" {
  type = string
}

variable "lb_access_logs_s3_bucket" {
  type = string
}

# ---------------------------------------------------------------------------------------------------------------------
# SSO: OpenID Connect plus Google Groups using Dex
# ---------------------------------------------------------------------------------------------------------------------

# SSO: OpenID Connect plus Google Groups using Dex
variable "enable_sso" {
  type    = bool
  default = false
}

variable "google_groups_json_secret_arn" {
  type    = string
  default = ""
}

variable "google_oauth_client_id" {
  type    = string
  default = ""
}

variable "google_oauth_client_secret_arn" {
  type    = string
  default = ""
}

variable "google_oauth_admin_email" {
  type    = string
  default = ""
}
