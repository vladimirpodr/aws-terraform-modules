variable "addon_context" {
  description = "Input configuration for the addon"
  type        = any
  default     = {}
}

variable "api_key_secret_arn" {
  type = string
}