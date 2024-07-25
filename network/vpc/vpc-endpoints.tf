### VPC endpoints
# S3 endpoint
resource "aws_vpc_endpoint" "s3_endpoint" {
  count        = var.vpc_s3_endpoint_enable ? 1 : 0
  vpc_id       = module.vpc.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"

    tags = merge(var.tags, {
    Name = "${var.name}-s3-endpoint"
  })
}

resource "aws_vpc_endpoint_route_table_association" "s3_endpoint" {
  count           = var.vpc_s3_endpoint_enable == true ? length(aws_route_table.private.*.id) : 0
  route_table_id  = aws_route_table.private[count.index].id
  vpc_endpoint_id = aws_vpc_endpoint.s3_endpoint[0].id
}

# EC2 endpoint
resource "aws_vpc_endpoint" "ec2_endpoint" {
  count        = var.vpc_ec2_endpoint_enable ? 1 : 0
  vpc_id       = module.vpc.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.ec2"

  vpc_endpoint_type = "Interface"
  subnet_ids        = module.private-subnets.ids
  security_group_ids = [
    module.vpc.sg_default,
  ]

  tags = merge(var.tags, {
    Name = "${var.name}-ec2-endpoint"
  })
}