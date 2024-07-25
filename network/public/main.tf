### Variables
variable "name" { type = string }
variable "cidr" { type = string }

# Public subnet parameters: availability zones to cover, base and bits
variable "public_zones" { type = list(string) }
variable "public_base"  { default = 0 }
variable "public_bits"  { default = 8 }

# Tags for all resources
variable "tags" { type = map(string) }

# Additional tags to assign to VPC and public subnets
variable "vpc_tags" { default = {} }

# Additional tags to assign to public subnets
variable "public_tags" { default = {} }

### VPC: Isolated VPC
module "vpc" {
  source = "git@github.com:ambyint/aws-terraform-modules.git//network/isolated?ref=main"

  name = var.name
  cidr = var.cidr

  tags     = var.tags
  vpc_tags = var.vpc_tags
}

### Route Table: Public
resource "aws_route_table" "public" {
  count = length(var.public_zones) != 0 ? 1 : 0

  vpc_id = module.vpc.id

  tags = merge(var.tags, {
    Name = "${var.name}-public-rt"
    Tier = "public"
  })
}

# Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = module.vpc.id

  tags = merge(var.tags, {
    Name = "${var.name}-public-igw"
    Tier = "public"
  })
}

# Route: Default via igw
resource "aws_route" "public-igw" {
  count = length(var.public_zones) != 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

### Subnets: Public subnets
module "public-subnets" {
  source = "git@github.com:ambyint/aws-terraform-modules.git//network/subnets?ref=main"

  vpc_id   = module.vpc.id
  basename = "${var.name}-public"

  zones  = var.public_zones
  prefix = var.cidr
  bits   = var.public_bits
  base   = var.public_base

  route_tables = aws_route_table.public[*].id

  tags = merge(var.tags, var.vpc_tags, var.public_tags, {
    Tier = "public"
  })
}

### Outputs
output "id"         { value = module.vpc.id }
output "name"       { value = module.vpc.name }

output "rt_default" { value = module.vpc.rt_default }
output "rt_public"  { value = aws_route_table.public[*].id }

output "sg_default" { value = module.vpc.sg_default }

output "public_subnets" {
  value = {
    ids = module.public-subnets.ids
    azs = module.public-subnets.azs
  }

  # Ensure that the result is not returned until IGW is attached
  # Required to add NAT Gateway
  depends_on = [aws_route.public-igw]
}

# vim:filetype=terraform ts=2 sw=2 et:
