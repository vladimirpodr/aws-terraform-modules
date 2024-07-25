### Variables
variable "capacity_type" {
  type    = string
  default = "ON_DEMAND"
}
variable "basename" { type = string }
variable "subnets" { type = list(string) }
variable "tags" { 
  type    = map(string)
  default = {}
}
variable "volume_type" {
  type    = string
  default = "gp2"
}
variable "device_name" {
  type    = string
  default = "/dev/xvda"
}
variable "disk_size" { type = number }
variable "kms_key_id" { type = string }
variable "desired_size" { type = number }
variable "max_size" { type = number }
variable "min_size" { type = number }
variable "cluster" {
  type = object({
    name                = string
    vpc_id              = string
    cluster_sg          = string
    sg_id               = string
    eks_internet_access = bool

    endpoint = string
    cadata   = string
  })
}

variable "instance_type" { type = string }
variable "instance_ami" { type = string }
variable "pool" { type = string }
variable "taint" { type = bool }
variable "az_count" {
  type    = number
  default = "3"
}

variable "node_group_full_name" {
  type    = string
  default = "nodeGroupFullName"
}
variable "node_group_name" {
  type    = string
  default = "nodeGroupName"
}

variable "asg_schedule_rules" {
  type    = list
  default = []
}
