# ---------------------------------------------------------------------------------------------------------------------
# GIT PAT secret
# ---------------------------------------------------------------------------------------------------------------------

data "aws_secretsmanager_secret" "git_secret" {
  for_each = { for k, v in var.repositories : k => v if try(v.git_secret_arn, null) != null }
  arn      = each.value.git_secret_arn
}

data "aws_secretsmanager_secret_version" "git_secret_version" {
  for_each  = { for k, v in var.repositories : k => v if try(v.git_secret_arn, null) != null }
  secret_id = data.aws_secretsmanager_secret.git_secret[each.key].id
}
