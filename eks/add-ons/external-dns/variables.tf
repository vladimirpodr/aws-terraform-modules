variable "route53_zone_arns" {
  description = "List of Route53 zones ARNs which external-dns will have access to create/manage records"
  type        = list(string)
  default     = []
}

variable "addon_context" {
  description = "Input configuration for the addon"
  type        = any
  default     = {}
}
