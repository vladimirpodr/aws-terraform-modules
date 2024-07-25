resource "aws_flow_log" "vpc_flow_logs" {
  count                = var.flow_logs_s3_enable ? 1 : 0
  vpc_id               = module.vpc.id
  traffic_type         = "ALL"
  log_destination      = "arn:aws:s3:::${var.vpc_flow_logs_bucket_arn}/${data.aws_organizations_organization.current.id}/"
  log_destination_type = "s3"
}

data "aws_iam_policy_document" "flow-log-trust-policy-document" {
  count = var.flow_logs_cloudwatch_enable ? 1 : 0
  statement {
    sid    = "flowLogsTrust"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "flow_log_role" {
  count              = var.flow_logs_cloudwatch_enable ? 1 : 0
  name               = "${var.name}-vpc-flow-logs-role"
  assume_role_policy = data.aws_iam_policy_document.flow-log-trust-policy-document[0].json
}

data "aws_iam_policy_document" "flow-log-actions-policy-document" {
  count = var.flow_logs_cloudwatch_enable ? 1 : 0
  statement {
    sid    = "allowPutVpcFlowLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "flow_logs_role_policy" {
  count  = var.flow_logs_cloudwatch_enable ? 1 : 0
  name   = "${var.name}-flow-logs-policy"
  policy = data.aws_iam_policy_document.flow-log-actions-policy-document[0].json
}

resource "aws_iam_role_policy_attachment" "flow_logs_policy_attachment" {
  count      = var.flow_logs_cloudwatch_enable ? 1 : 0
  role       = aws_iam_role.flow_log_role[0].name
  policy_arn = aws_iam_policy.flow_logs_role_policy[0].arn
}

resource "aws_flow_log" "cloud_watch_flow_logs" {
  count                = var.flow_logs_cloudwatch_enable ? 1 : 0
  vpc_id               = module.vpc.id
  traffic_type         = "ALL"
  log_destination      = aws_cloudwatch_log_group.log_group[0].arn
  log_destination_type = "cloud-watch-logs"
  iam_role_arn         = aws_iam_role.flow_log_role[0].arn
}

resource "aws_cloudwatch_log_group" "log_group" {
  count             = var.flow_logs_cloudwatch_enable ? 1 : 0
  name_prefix       = "vpc-flow-logs"
  retention_in_days = var.flow_logs_cloudwatch_retention_in_days
}
