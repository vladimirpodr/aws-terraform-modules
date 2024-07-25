# ---------------------------------------------------------------------------------------------------------------------
# Datadog API Key
# ---------------------------------------------------------------------------------------------------------------------

data "aws_secretsmanager_secret" "datadog_api_key" {
  arn = var.api_key_secret_arn
}

data "aws_secretsmanager_secret_version" "datadog_api_key" {
  secret_id = data.aws_secretsmanager_secret.datadog_api_key.id
}
