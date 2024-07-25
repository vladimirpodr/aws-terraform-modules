### Variables
variable "name" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}
variable "transit_gateway_id" { type = string }
variable "transit_gateway_association_rt_id" {
  type    = string
  default = ""
}
variable "transit_gateway_propagation_rt_id" {
  type    = string
  default = ""
}
variable "vpc_id"   { type = string }
variable "subnets"  { type = list(string) }
variable "vpc_route_tables" {
  type    = list(string)
  default = []
}
variable "vpc_route_peer_cidr" { type = string }

### Transit Gateway Attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  vpc_id     = var.vpc_id
  subnet_ids = var.subnets

  transit_gateway_id = var.transit_gateway_id

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = merge(var.tags, {
    Name = "${var.name}-tgwa"
  })

  lifecycle {
    ignore_changes = [
      # Ignore this changes
      # because this cannot be configured or perform drift detection with
      # Resource Access Manager shared EC2 Transit Gateways.
      transit_gateway_default_route_table_association,
      transit_gateway_default_route_table_propagation
    ]
  }
}

### VPC Route: to Transit Gateway Attachment
resource "aws_route" "vpc-tgw" {
  count = length(var.vpc_route_tables)

  # Getting element via [count.index] doesn't work here
  route_table_id = element(var.vpc_route_tables, count.index)

  destination_cidr_block = var.vpc_route_peer_cidr

  transit_gateway_id = var.transit_gateway_id
}

### Transit Gateway Route table for VPC attachment association
resource "aws_ec2_transit_gateway_route_table_association" "tgw_rt_association" {
  provider = aws.transit
  count    = var.transit_gateway_association_rt_id != "" ? 1 : 0

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.main.id
  transit_gateway_route_table_id = var.transit_gateway_association_rt_id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw_rt_propagation" {
  provider = aws.transit
  count    = var.transit_gateway_propagation_rt_id != "" ? 1 : 0

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.main.id
  transit_gateway_route_table_id = var.transit_gateway_propagation_rt_id
}

resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "main" {
  provider = aws.transit

  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.main.id

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = merge(var.tags, {
    Name = "${var.name}-tgwa"
  })
}

### Outputs
output "id" {
  value = aws_ec2_transit_gateway_vpc_attachment.main.id

  depends_on = [
    aws_route.vpc-tgw
  ]
}

# vim:filetype=terraform ts=2 sw=2 et:
