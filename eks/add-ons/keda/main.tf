resource "aws_iam_policy" "main" {
  description = "KEDA IAM role policy for SQS and CloudWatch"
  name        = "${local.name}-irsa-policy"
  policy      = data.aws_iam_policy_document.main.json
  tags        = var.addon_context.tags
}

module "irsa" {
  source  = "../irsa"

  name                              = local.name
  create_kubernetes_service_account = true
  kubernetes_namespace              = var.addon_context.kubernetes_namespace
  kubernetes_service_account        = local.service_account_name
  irsa_iam_policies                 = [aws_iam_policy.main.arn]
  eks_cluster_id                    = var.addon_context.eks_cluster_id
  eks_oidc_provider_arn             = var.addon_context.eks_oidc_provider_arn
}

### KEDA Auth
resource "kubernetes_secret" "kafka" {
  count = var.keda_auth_kafka_credential_secret_arn != "" ? 1 : 0

  metadata {
    name      = "keda-auth-kafka-credential-secret"
    namespace = var.addon_context.kubernetes_namespace
  }

  data = {
    "ca"       = jsondecode(data.aws_secretsmanager_secret_version.kafka[0].secret_string)["ca"]
    "password" = jsondecode(data.aws_secretsmanager_secret_version.kafka[0].secret_string)["password"]
    "sasl"     = jsondecode(data.aws_secretsmanager_secret_version.kafka[0].secret_string)["sasl"]
    "tls"      = jsondecode(data.aws_secretsmanager_secret_version.kafka[0].secret_string)["tls"]
    "username" = jsondecode(data.aws_secretsmanager_secret_version.kafka[0].secret_string)["username"]
  }
}

resource "kubernetes_manifest" "kafka_trigger_authentication" {
  count = var.keda_auth_kafka_credential_secret_arn != "" ? 1 : 0
  manifest = {
    "apiVersion" = "keda.sh/v1alpha1"
    "kind"       = "ClusterTriggerAuthentication"
    "metadata" = {
      "name"      = "keda-trigger-auth-kafka-credential"
    }
    "spec" = {
      "secretTargetRef" = [
        {
          "parameter" = "sasl"
          "name"      = "keda-auth-kafka-credential-secret"
          "key"       = "sasl"
        },
        {
          "parameter" = "username"
          "name"      = "keda-auth-kafka-credential-secret"
          "key"       = "username"
        },
        {
          "parameter" = "password"
          "name"      = "keda-auth-kafka-credential-secret"
          "key"       = "password"
        },
        {
          "parameter" = "tls"
          "name"      = "keda-auth-kafka-credential-secret"
          "key"       = "tls"
        },
        {
          "parameter" = "ca"
          "name"      = "keda-auth-kafka-credential-secret"
          "key"       = "ca"
        }
      ]
    }
  }
}
