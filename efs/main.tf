### Security Group
resource "aws_security_group" "main" {
  vpc_id = var.vpc_id

  name = "${var.name}-efs-sg"

  description = "Security Group for ${var.name} EFS"

  # No egress restrictions
  egress {
    protocol  = "-1"
    from_port = 0
    to_port   = 0

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-efs-sg"
  })
}

# Allow access from specified groups
resource "aws_security_group_rule" "sg-access" {
  for_each = var.src_groups

  security_group_id = aws_security_group.main.id

  type = "ingress"

  description = "Access from ${each.key}"

  protocol  = "tcp"
  from_port = var.port
  to_port   = var.port

  source_security_group_id = each.value
}

# Allow access from specified ips
resource "aws_security_group_rule" "cidr-access" {
  for_each = var.cidr_groups

  security_group_id = aws_security_group.main.id

  type = "ingress"

  description = "Access from ${each.key}"

  protocol  = "tcp"
  from_port = var.port
  to_port   = var.port

  cidr_blocks = [each.value]
}

### EFS
resource "aws_efs_file_system" "efs" {
  encrypted                       = var.encrypted
  kms_key_id                      = var.kms_key_id
  performance_mode                = var.performance_mode
  provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps
  throughput_mode                 = var.throughput_mode

  tags = merge(var.tags, {
    Name = "${var.name}-efs"
  })
}

resource "aws_efs_mount_target" "efs_mount_target" {
  count           = length(var.subnets)
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = var.subnets[count.index]
  security_groups = [aws_security_group.main.id]
}