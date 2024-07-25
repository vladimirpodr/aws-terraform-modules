variable "name" {
  description = "The name prefix for AWS resources"
  type        = string
}

variable "project_name" {
  description = "Project name."
}

variable "environment" {
  description = "Project environment/account name."
}

variable "domain_name" {
  description = "The project domain name for AWS resources"
  type        = string
}

variable "domain_certificate_arn" {
  type = string
}

variable "eks_cluster_id" {
  description = "EKS Cluster Id"
  type        = string
}

variable "data_plane_wait_arn" {
  description = "Addon deployment will not proceed until this value is known. Set to node group/Fargate profile ARN to wait for data plane to be ready before provisioning addons"
  type        = string
  default     = ""
}

variable "eks_oidc_provider" {
  description = "The OpenID Connect identity provider (issuer URL without leading `https://`)"
  type        = string
  default     = null
}

variable "eks_cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
  type        = map(string)
  default     = {}
}

variable "lb_access_logs_s3_bucket" {
  type = string
}

#-----------CLUSTER AUTOSCALER-------------
variable "enable_cluster_autoscaler" {
  description = "Enable Cluster autoscaler add-on"
  type        = bool
  default     = false
}

#-----------External DNS ADDON-------------
variable "enable_external_dns" {
  description = "External DNS add-on"
  type        = bool
  default     = false
}

variable "external_dns_route53_zone_arns" {
  description = "List of Route53 zones ARNs which external-dns will have access to create/manage records"
  type        = list(string)
  default     = []
}

#-----------METRIC SERVER-------------
variable "enable_metrics_server" {
  description = "Enable metrics server add-on"
  type        = bool
  default     = false
}

#-----------AWS EFS CSI DRIVER ADDON-------------
variable "enable_aws_efs_csi_driver" {
  description = "Enable AWS EFS CSI driver add-on"
  type        = bool
  default     = false
}

#-----------AWS LB Ingress Controller-------------
variable "enable_aws_load_balancer_controller" {
  description = "Enable AWS Load Balancer Controller add-on"
  type        = bool
  default     = false
}

#-----------NGINX-------------
variable "enable_ingress_nginx" {
  description = "Enable Ingress Nginx add-on"
  type        = bool
  default     = false
}

#-----------ARGOCD ADDON-------------
variable "enable_argocd" {
  description = "Enable Argo CD Kubernetes add-on"
  type        = bool
  default     = false
}

variable "argocd_repositories" {
  description = "The map of repositories and secrets for ArgoCD to have access to private repositories."
  type        = map
  default     = {}
}

variable "argocd_helm_config" {
  description = "Argo CD Kubernetes add-on config"
  type        = any
  default     = {}
}

variable "argocd_application" {
  description = "Argo CD Application config to bootstrap the add-ons app of apps"
  type        = any
  default     = {}
}

variable "argocd_manage_add_ons" {
  description = "Enable managing add-on configuration via ArgoCD App of Apps"
  type        = bool
  default     = false
}

# SSO: OpenID Connect plus Google Groups using Dex
variable "argocd_enable_sso" {
  type    = bool
  default = false
}

variable "argocd_google_groups_json_secret_arn" {
  type    = string
  default = ""
}

variable "argocd_google_oauth_client_id" {
  type    = string
  default = ""
}

variable "argocd_google_oauth_client_secret_arn" {
  type    = string
  default = ""
}

variable "argocd_google_oauth_admin_email" {
  type    = string
  default = ""
}

#-----------KARPENTER ADDON-------------
variable "enable_karpenter" {
  description = "Enable Karpenter autoscaler add-on"
  type        = bool
  default     = false
}

variable "karpenter_node_iam_instance_profile" {
  description = "Karpenter Node IAM Instance profile id"
  type        = string
  default     = ""
}

#-----------KEDA ADDON-------------
variable "enable_keda" {
  description = "Enable KEDA Event-based autoscaler add-on"
  type        = bool
  default     = false
}

variable "keda_auth_kafka_credential_secret_arn" {
  description = "Kafka authorization credentials for KEDA."
  type        = string
  default     = ""
}

variable "keda_auth_rabbitmq_credential_secret_arn" {
  description = "RabbitMQ authorization credentials for KEDA."
  type        = string
  default     = ""
}

#-----------DATADOG AGENT ADDON-------------
variable "enable_datadog_agent" {
  description = "Enable Datadog Agent add-on"
  type        = bool
  default     = false
}

variable "datatdog_api_key_secret_arn" {
  description = "API key to configure Datadog Agent"
  type        = string
  default     = ""
}

#-----------AWS CSI Secrets Store Provider-------------
variable "enable_secrets_store_csi_driver_provider_aws" {
  type        = bool
  default     = false
  description = "Enable AWS CSI Secrets Store Provider"
}

#-----------FLUX v2-------------
variable "enable_flux2" {
  type        = bool
  default     = false
  description = "Enable FLUX v2"
}
