data "aws_iam_policy_document" "main" {
  statement {
    effect = "Allow"

    resources = [
      "arn:aws:cloudwatch:*:${var.addon_context.aws_caller_identity_account_id}:metric-stream/*",
      "arn:aws:sqs:*:${var.addon_context.aws_caller_identity_account_id}:*",
    ]

    actions = [
      "cloudwatch:DescribeAlarmHistory",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:GetDashboard",
      "cloudwatch:GetInsightRuleReport",
      "cloudwatch:GetMetricStream",
      "cloudwatch:ListTagsForResource",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListDeadLetterSourceQueues",
      "sqs:ListQueueTags",
      "sqs:ReceiveMessage",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:DescribeAnomalyDetectors",
      "cloudwatch:DescribeInsightRules",
      "cloudwatch:GetMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:GetMetricWidgetImage",
      "cloudwatch:ListDashboards",
      "cloudwatch:ListMetrics",
      "cloudwatch:ListMetricStreams",
      "sqs:ListQueues",
    ]
  }
}

### KEDA Auth
# Kafka
data "aws_secretsmanager_secret" "kafka" {
  count = var.keda_auth_kafka_credential_secret_arn != "" ? 1 : 0

  arn = var.keda_auth_kafka_credential_secret_arn
}

data "aws_secretsmanager_secret_version" "kafka" {
  count = var.keda_auth_kafka_credential_secret_arn != "" ? 1 : 0

  secret_id = data.aws_secretsmanager_secret.kafka[0].id
}

# RabbitMQ
data "aws_secretsmanager_secret" "rabbitmq" {
  count = var.keda_auth_rabbitmq_credential_secret_arn != "" ? 1 : 0

  arn = var.keda_auth_rabbitmq_credential_secret_arn
}

data "aws_secretsmanager_secret_version" "rabbitmq" {
  count = var.keda_auth_rabbitmq_credential_secret_arn != "" ? 1 : 0

  secret_id = data.aws_secretsmanager_secret.rabbitmq[0].id
}
