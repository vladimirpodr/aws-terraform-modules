# Tags for all resources
variable "name" { type = string }
variable "log_group" { type = string }
variable "log_archive_bucket" { type = string }
variable "log_source" { type = string }
variable "tags" { 
  type    = map(string)
  default = {}
}