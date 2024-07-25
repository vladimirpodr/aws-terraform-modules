variable "applications" {
  description = "ArgoCD Application config used to bootstrap a cluster."
  type        = any
  default     = {}
}
