variable "name" {
  type        = string
  description = "Basename for the AWS resources."
}

variable "apply_immediately" {
  type        = bool
  description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window"
  default     = false
}

variable "auto_minor_version_upgrade" {
  type        = bool
  description = "Enables automatic upgrades to new minor versions for brokers, as Apache releases the versions"
  default     = false
}

variable "deployment_mode" {
  type        = string
  description = "The deployment mode of the broker. Supported: SINGLE_INSTANCE and ACTIVE_STANDBY_MULTI_AZ"
  default     = "SINGLE_INSTANCE"
}

variable "engine_type" {
  type        = string
  description = "Type of broker engine."
  default     = "RabbitMQ"
}

variable "engine_version" {
  type        = string
  description = "The version of the broker engine. See https://docs.aws.amazon.com/amazon-mq/latest/developer-guide/broker-engine.html for more details"
  default     = "5.15.14"
}

variable "host_instance_type" {
  type        = string
  description = "The broker's instance type. e.g. mq.t2.micro or mq.m4.large"
  default     = "mq.t3.micro"
}

variable "publicly_accessible" {
  type        = bool
  description = "Whether to enable connections from applications outside of the VPC that hosts the broker's subnets"
  default     = false
}

variable "general_log_enabled" {
  type        = bool
  description = "Enables general logging via CloudWatch"
  default     = true
}

variable "audit_log_enabled" {
  type        = bool
  description = "Enables audit logging. User management action made using JMX or the ActiveMQ Web Console is logged"
  default     = true
}

variable "log_retention_in_days" {
  type        = number
  description = "Configure the general logs retention for CloudWatch log group."
  default     = 7
}

variable "maintenance_day_of_week" {
  type        = string
  description = "The maintenance day of the week. e.g. MONDAY, TUESDAY, or WEDNESDAY"
  default     = "SUNDAY"
}

variable "maintenance_time_of_day" {
  type        = string
  description = "The maintenance time, in 24-hour format. e.g. 02:00"
  default     = "03:00"
}

variable "maintenance_time_zone" {
  type        = string
  description = "The maintenance time zone, in either the Country/City format, or the UTC offset format. e.g. CET"
  default     = "UTC"
}

variable "mq_application_user" {
  type        = list(string)
  description = "Application username"
  default     = []
}

variable "mq_application_password" {
  type        = list(string)
  description = "Application password"
  default     = []
  sensitive   = true
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to create the broker in"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of VPC subnet IDs"
}

variable "broker_security_groups" {
  type        = list(string)
  default     = []
  description = "A list of IDs of Security Groups to associate the created resource with."
}
