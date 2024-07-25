variable "name" {}

variable "description" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "runtime" {
  type    = string
  default = "python3.7"
}

variable "memory_size" {
  type    = number
  default = 128
}

variable "timeout" {
  type    = number
  default = 10
}

variable "lambda_function_handler" {}
variable "source_code_path" {}
variable "environment_variables" {
  description = "A map that defines environment variables for the Lambda Function."
  type        = map(string)
  default     = {}
}

variable "vpc_subnet_ids" {
  description = "List of subnet ids when Lambda Function should run in the VPC. Usually private or intra subnets."
  type        = list(string)
  default     = null
}

variable "vpc_security_group_ids" {
  description = "List of security group ids when Lambda Function should run in the VPC."
  type        = list(string)
  default     = null
}

variable "attach_policy" {
  description = "Controls if lambda role should have  policy attached (set to `true` to use value of `policy`)"
  type        = bool
  default     = false
}

variable "policy" {
  description = "A valid lambda role policy JSON document"
  type        = string
  default     = null
}
