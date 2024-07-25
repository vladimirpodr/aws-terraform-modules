variable "name" {
  type    = string
}

variable "project_name" {
  type    = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "enable_ebs_encryption_by_default" {
  type    = bool
  default = false
}

variable "enable_s3_account_public_access_block" {
  type    = bool
  default = false
}

variable "enable_iam_account_password_policy" {
  type    = bool
  default = false
}

variable "enable_s3_access_logs_s3_bucket" {
  type    = bool
  default = false
}

variable "enable_lb_access_logs_s3_bucket" {
  type    = bool
  default = false
}

variable "s3_bucket_replication_dest_account_id" {
  type    = string
  default = ""
}

variable "s3_bucket_replication_dest_account_name" {
  type    = string
  default = ""
}

variable "enable_organization_config_rule_lambda_assume_role" {
  type    = bool
  default = false
}

variable "organization_config_rule_lambda_role_arn" {
  type    = string
  default = ""
}

variable "enable_sh_aws_foundational_security_best_practices_standard" {
  type    = bool
  default = false
}
