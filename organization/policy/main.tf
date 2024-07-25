variable "basename" { type = string }
variable "policy" { type = string }
variable "policy_type" { type = string }
variable "attachment_target" { type = map }
variable "tags" { 
  type    = map(string)
  default = {}
}
resource "aws_organizations_policy" "main" {
  name = "${var.basename}-policy"
  type = var.policy_type

  content = var.policy

  tags = merge(var.tags, {
    Name = "${var.basename}-policy"
  })
}

resource "aws_organizations_policy_attachment" "main" {
  for_each  = var.attachment_target
  policy_id = aws_organizations_policy.main.id
  target_id = each.value.id
}