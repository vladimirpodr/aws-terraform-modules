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

# ---------------------------------------------------------------------------------------------------------------------
# SSO: OpenID Connect plus Google Groups using Dex
# ---------------------------------------------------------------------------------------------------------------------

data "aws_secretsmanager_secret" "argocd_google_groups_json" {
  count = var.enable_sso ? 1 : 0
  arn   = var.google_groups_json_secret_arn
}

data "aws_secretsmanager_secret_version" "argocd_google_groups_json" {
  count     = var.enable_sso ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.argocd_google_groups_json[0].id
}

data "aws_secretsmanager_secret" "argocd_google_oauth_client_secret" {
  count = var.enable_sso ? 1 : 0
  arn   = var.google_oauth_client_secret_arn
}

data "aws_secretsmanager_secret_version" "argocd_google_oauth_client_secret" {
  count     = var.enable_sso ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.argocd_google_oauth_client_secret[0].id
}
