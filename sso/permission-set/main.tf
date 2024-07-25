
variable "name" { type = string }
variable "description" { type = string }
variable "policy_arn" { type = string }
variable "tags" { 
  type    = map(string)
  default = {}
}

data "aws_ssoadmin_instances" "main" {}

### Create permission sets
resource "aws_ssoadmin_permission_set" "main" {
  name         = var.name
  description  = var.description
  instance_arn = tolist(data.aws_ssoadmin_instances.main.arns)[0]

  session_duration = "PT8H"

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_ssoadmin_managed_policy_attachment" "main" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  managed_policy_arn = var.policy_arn
  permission_set_arn = aws_ssoadmin_permission_set.main.arn
}

output "permission_set_arn" {
  value = aws_ssoadmin_permission_set.main.arn
}