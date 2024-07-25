
variable "account_id" { type = string }
variable "assignments" {
  type = map(string)
}
variable "permission_sets_arn" {
  type = map(object({
    permission_set_arn = string
}))
}

data "aws_ssoadmin_instances" "main" {}

data "aws_identitystore_group" "main" {
  for_each = var.assignments
  identity_store_id = tolist(data.aws_ssoadmin_instances.main.identity_store_ids)[0]

  filter {
    attribute_path  = "DisplayName"
    attribute_value = each.key
  }
}

resource "aws_ssoadmin_account_assignment" "main" {
  for_each = var.assignments

  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  permission_set_arn = var.permission_sets_arn[each.value].permission_set_arn

  principal_id   = data.aws_identitystore_group.main[each.key].group_id
  principal_type = "GROUP"

  target_id   = var.account_id
  target_type = "AWS_ACCOUNT"
}
