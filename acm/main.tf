### Variables
variable "name" { type = string }
variable "domain_name" { type = string }
variable "subject_alternative_names" { type = list(string) }
variable "route53_zone_id" {type = string }
variable "tags" { 
  type    = map(string)
  default = {}
}

locals {
  // Get distinct list of domains and SANs
  distinct_domain_names = distinct(concat([var.domain_name], [for s in var.subject_alternative_names : replace(s, "*.", "")]))

  validation_domains = [for k, v in aws_acm_certificate.cert.domain_validation_options : tomap(v) if contains(local.distinct_domain_names, replace(v.domain_name, "*.", ""))]
}

### SSL Certificate
resource "aws_acm_certificate" "cert" {
  domain_name = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  
  validation_method = "DNS"
  
  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = "${lower(var.name)}-${replace(var.domain_name, ".", "-")}-certificate"
  })
}

# Route53 record
resource "aws_route53_record" "validation" {
  count = length(local.distinct_domain_names) + 1 

  zone_id = var.route53_zone_id
  name    = element(local.validation_domains, count.index)["resource_record_name"]
  type    = element(local.validation_domains, count.index)["resource_record_type"]
  ttl     = 60

  records = [
    element(local.validation_domains, count.index)["resource_record_value"]
  ]

  allow_overwrite = true

  depends_on = [aws_acm_certificate.cert]
}

# Certificate validation
resource "aws_acm_certificate_validation" "this" {
  certificate_arn = aws_acm_certificate.cert.arn

  validation_record_fqdns = aws_route53_record.validation.*.fqdn
}

### Outputs
output "id" { value = aws_acm_certificate.cert.id }
output "arn" { value = aws_acm_certificate.cert.arn }

# vim:filetype=terraform ts=2 sw=2 et: