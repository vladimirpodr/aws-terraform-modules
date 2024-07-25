### Variables
# General parameters
variable "name" { type = string }
variable "cidr" { type = string }
variable "vpc_s3_endpoint_enable" { type = bool }
variable "vpc_ec2_endpoint_enable" {
  type    = bool
  default = true
}

# NAT
variable "has_nat" { default = true }

# Subnets parameters: availability zones to cover, base and bits
variable "public_zones" {
  type    = list(string)
  default = []
}
variable "private_zones" {
  type    = list(string)
  default = []
}
variable "isolated_zones" {
  type    = list(string)
  default = []
}
variable "public_subnets_base" { default = 0 }
variable "public_subnets_bits" { default = 8 }
variable "private_subnets_base" { default = 0 }
variable "private_subnets_bits" { default = 8 }
variable "isolated_subnets_base" { default = 0 }
variable "isolated_subnets_bits" { default = 8 }
# Tags for all resources
variable "tags" {
  type    = map(string)
  default = {}
}

# Additional tags to assign to VPC itself
variable "vpc_tags" {
  type    = map(string)
  default = {}
}

# Additional tags to assign to public and private subnets
variable "public_subnets_tags" {
  type    = map(string)
  default = {}
}

variable "private_subnets_tags" {
  type    = map(string)
  default = {}
}

# VPC Flow logs variables

variable "flow_logs_s3_enable" {
  description = "Enable the send of flow logs to S3"
  type        = bool
  default     = true
}

variable "vpc_flow_logs_bucket_arn" {
  description = "The ARN of the bucket to send flow logs to - source from logging state"
  type        = string
  default     = ""
}

variable "flow_logs_cloudwatch_enable" {
  description = "Enable the send of flow logs to CloudWatch"
  type        = bool
  default     = false
}

variable "flow_logs_cloudwatch_retention_in_days" {
  description = "The number of days to retain flow logs in CloudWatch"
  type        = number
  default     = 5
}
