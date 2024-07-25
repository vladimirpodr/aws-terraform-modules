### Variables
variable "basename" { type = string }

variable "vpc_id" { type = string }

variable "zones" { type = list(string) }
variable "prefix" { type = string }
variable "bits" { default = 8 }
variable "base" { default = 0 }

variable "route_tables" { type = list(string) }

variable "tags" { default = {} }

### Subnets: One per AZ
resource "aws_subnet" "subnets" {
  count = length(var.zones)

  vpc_id     = var.vpc_id
  cidr_block = cidrsubnet(var.prefix, var.bits, var.base + count.index)

  availability_zone = var.zones[count.index]

  tags = merge(var.tags, {
    Name = "${var.basename}-subnet-${substr(var.zones[count.index], -1, 1)}"
  })
}

### Route Table Attachments
resource "aws_route_table_association" "subnets-rt" {
  count = length(var.zones)

  subnet_id      = aws_subnet.subnets[count.index].id
  route_table_id = element(var.route_tables, count.index)
}

### Outputs
output "ids" { value = aws_subnet.subnets[*].id }
output "azs" { value = { for s in aws_subnet.subnets : s.availability_zone => s.id } }

# vim:filetype=terraform ts=2 sw=2 et:
