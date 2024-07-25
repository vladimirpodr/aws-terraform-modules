### Variables
variable "cidr"  { type = string }
variable "name"  { type = string }

variable "tags" {
  type    = map(string)
  default = {}
}

variable "vpc_tags" {
  type    = map(string)
  default = {}
}

### VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true

  tags = merge(var.tags, var.vpc_tags, {
    Name = "${var.name}-vpc"
  })
}

### Default Route Table
resource "aws_default_route_table" "vpc" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  tags = merge(var.tags, {
    Name = "${var.name}-default-rt"
  })
}

### Default Security Group
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags, {
    Name = "${var.name}-default-sg"
  })
}

# Remediate security issue: Network ACLs should not allow ingress from 0.0.0.0/0 to port 22 or port 3389
resource "aws_network_acl_rule" "deny_ssh_ipv4" {
  network_acl_id  = aws_vpc.vpc.default_network_acl_id
  rule_number     = 50
  protocol        = "tcp"
  rule_action     = "deny"
  cidr_block      = "0.0.0.0/0"
  from_port       = 22
  to_port         = 22
}

resource "aws_network_acl_rule" "deny_ssh_ipv6" {
  network_acl_id  = aws_vpc.vpc.default_network_acl_id
  rule_number     = 51
  protocol        = "tcp"
  rule_action     = "deny"
  ipv6_cidr_block = "::/0"
  from_port       = 22
  to_port         = 22
}

resource "aws_network_acl_rule" "deny_rdp_ipv4" {
  network_acl_id  = aws_vpc.vpc.default_network_acl_id
  rule_number     = 52
  protocol        = "tcp"
  rule_action     = "deny"
  cidr_block      = "0.0.0.0/0"
  from_port       = 3389
  to_port         = 3389
}

resource "aws_network_acl_rule" "deny_rdp_ipv6" {
  network_acl_id  = aws_vpc.vpc.default_network_acl_id
  rule_number     = 53
  protocol        = "tcp"
  rule_action     = "deny"
  ipv6_cidr_block = "::/0"
  from_port       = 3389
  to_port         = 3389
}

### VPC Flow logs


### Outputs
output "id"         { value = aws_vpc.vpc.id }
output "name"       { value = var.name }
output "rt_default" { value = aws_vpc.vpc.default_route_table_id }
output "sg_default" { value = aws_default_security_group.default.id }

# vim:filetype=terraform ts=2 sw=2 et:
