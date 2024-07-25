# ---------------------------------------------------------------------------------------------------------------------
# Datadog API Key
# ---------------------------------------------------------------------------------------------------------------------

resource "kubernetes_secret" "datadog_api_key" {
  metadata {
    name      = local.datadog_api_key_secret_name
    namespace = var.addon_context.kubernetes_namespace
  }

  data = {
    api-key = data.aws_secretsmanager_secret_version.datadog_api_key.secret_string
  }
}