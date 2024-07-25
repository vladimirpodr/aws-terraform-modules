variable "addon_context" {
  description = "Input configuration for the addon"
  type        = any
  default     = {}
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
