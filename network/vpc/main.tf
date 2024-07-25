### VPC: VPC with public subnets
module "vpc" {
  source = "git@github.com:ambyint/aws-terraform-modules.git//network/public?ref=main"

  name = var.name
  cidr = var.cidr

  public_zones = var.public_zones
  public_base  = var.public_subnets_base
  public_bits  = var.public_subnets_bits
  public_tags  = var.public_subnets_tags

  vpc_tags = var.vpc_tags
  tags     = var.tags
}

### VPC Subnets: Private
module "private-subnets" {
  source  = "git@github.com:ambyint/aws-terraform-modules.git//network/subnets?ref=main"

  vpc_id   = module.vpc.id
  basename = "${var.name}-private"

  zones  = var.private_zones
  prefix = var.cidr
  bits   = var.private_subnets_bits
  base   = var.private_subnets_base

  route_tables = aws_route_table.private.*.id

  tags = merge(var.tags, var.private_subnets_tags, {
    Tier = "private"
  })
}

### VPC Subnets: Isolated
module "isolated-subnets" {
  source  = "git@github.com:ambyint/aws-terraform-modules.git//network/subnets?ref=main"

  vpc_id = module.vpc.id

  basename = "${var.name}-isolated"

  zones = var.isolated_zones
  base  = var.isolated_subnets_base
  bits  = var.isolated_subnets_bits

  prefix = var.cidr

  route_tables = [module.vpc.rt_default]

  tags = merge(var.tags, {
    Tier = "isolated"
  })
}

### Route Table: Private
resource "aws_route_table" "private" {
  count = length(var.private_zones)

  vpc_id = module.vpc.id
  tags = merge(var.tags, {
    Name = "${var.name}-private-rt-${count.index}"
    Tier = "private"
  })
}

# Elastic IP
resource "aws_eip" "natgw" {
  count = var.has_nat ? length(var.private_zones) : 0

  vpc = true

  tags = merge(var.tags, {
    Name = "${var.name}-natgw-eip-${count.index}"
    Tier = "private"
  })
}

# NAT Gateway itself
resource "aws_nat_gateway" "natgw" {
  count = var.has_nat ? length(var.private_zones) : 0

  subnet_id     = module.vpc.public_subnets.ids[count.index]
  allocation_id = aws_eip.natgw[count.index].id

  tags = merge(var.tags, {
    Name = "${var.name}-private-natgw-${count.index}"
    Tier = "private"
  })

  depends_on = [module.vpc]
}

# Route via NAT GW
resource "aws_route" "private-natgw" {
  count = var.has_nat ? length(var.private_zones) : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw[count.index].id
}
