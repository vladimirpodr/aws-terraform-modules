### Variables
variable "name" { type = string }
variable "tags" { 
  type    = map(string)
  default = {}
}

variable "vpc_id"      { default = "" }
variable "subnets"     { type = list(string) }
variable "port"        { default = 2049 }
variable "src_groups"  { default = {} }
variable "cidr_groups" { default = {} }

variable "encrypted" { default = true }
variable "kms_key_id" { 
  type    = string
  default = null 
}
variable "performance_mode" { type = string }
variable "provisioned_throughput_in_mibps" { default = 0 }
variable "throughput_mode" { type = string }