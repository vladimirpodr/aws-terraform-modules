# Tags for all resources
variable "name" { type = string }
variable "tags" { 
  type    = map(string)
  default = {}
}
variable "validity_period_hours" {
  default = "87600"
}
variable "subnets_assoc" {
  type = list(string)
}
variable "zone_names" { 
  type    = list(string)
  default = []
}
variable "domain_name" {}
variable "org_name" {}
variable "client_cidr_block" {}
variable "vpc_id" {}
variable "target_cidr" {}
variable "saml_provider_arn" {}
variable "ssp_saml_provider_arn" {}