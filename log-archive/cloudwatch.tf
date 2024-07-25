resource "aws_cloudwatch_log_subscription_filter" "cw_subscription" {
  name            = "${var.name}-cw-firehose"
  role_arn        = aws_iam_role.cw_subscription.arn
  log_group_name  = var.log_group
  filter_pattern  = ""
  destination_arn = aws_kinesis_firehose_delivery_stream.firehose.arn
}