### Variables
variable "name" { type = string }
variable "tags" { 
  type    = map(string)
  default = {}
}

variable "description" { type = string }

### Data source: Current AWS Region
data "aws_region" "current" {}

### Transit Gateway
resource "aws_ec2_transit_gateway" "main" {
  description = var.description

  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  tags = merge(var.tags, {
    Name = "${var.name}-tgw"
  })
}

### Transit Gateway: Association Route Table for spoke VPC attachments
resource "aws_ec2_transit_gateway_route_table" "association_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  
  tags = merge(var.tags, {
    Name = "${var.name}-tgw-rt-association"
  })
}

### Transit Gateway: Propagation Route Table for Egress VPC attachment
resource "aws_ec2_transit_gateway_route_table" "propagation_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = merge(var.tags, {
    Name = "${var.name}-tgw-rt-propagation"
  })
}

### Outputs
output "id" {
  value = aws_ec2_transit_gateway.main.id
}

output "arn" {
  value = aws_ec2_transit_gateway.main.arn
}

output "association_rt_id" {
  value = aws_ec2_transit_gateway_route_table.association_rt.id
}

output "propagation_rt_id" {
  value = aws_ec2_transit_gateway_route_table.propagation_rt.id
}