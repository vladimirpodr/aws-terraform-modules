resource "aws_kinesis_firehose_delivery_stream" "firehose" {
  name        = "${var.name}-firehose-s3"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose.arn
    bucket_arn = "arn:aws:s3:::${var.log_archive_bucket}"

    prefix              = "${data.aws_organizations_organization.current.id}/AWSLogs/${data.aws_caller_identity.current.account_id}/${var.log_source}/${data.aws_region.current.name}/!{timestamp:yyyy}/!{timestamp:MM}/!{timestamp:dd}/"
    error_output_prefix = "errors/${data.aws_organizations_organization.current.id}/AWSLogs/${data.aws_caller_identity.current.account_id}/${var.log_source}/${data.aws_region.current.name}/!{timestamp:yyyy}/!{timestamp:MM}/!{timestamp:dd}/!{firehose:error-output-type}/"

    buffer_size = 5
  }
}