output "broker_id" {
  value       = join("", aws_mq_broker.main.*.id)
  description = "AmazonMQ broker ID"
}

output "broker_arn" {
  value       = join("", aws_mq_broker.main.*.arn)
  description = "AmazonMQ broker ARN"
}

output "primary_console_url" {
  value       = try(aws_mq_broker.main.instances[0].console_url, "")
  description = "AmazonMQ active web console URL"
}

output "primary_amqps_endpoint" {
  value       = try(aws_mq_broker.main.instances[0].endpoints[0], "")
  description = "AmazonMQ primary SSL endpoint"
}

output "primary_ip_address" {
  value       = try(aws_mq_broker.main.instances[0].ip_address, "")
  description = "AmazonMQ primary IP address"
}

output "secondary_console_url" {
  value       = try(aws_mq_broker.main.instances[1].console_url, "")
  description = "AmazonMQ secondary web console URL"
}

output "secondary_amqps_endpoint" {
  value       = try(aws_mq_broker.main.instances[1].endpoints[0], "")
  description = "AmazonMQ secondary SSL endpoint"
}

output "secondary_ip_address" {
  value       = try(aws_mq_broker.main.instances[1].ip_address, "")
  description = "AmazonMQ secondary IP address"
}

output "application_username" {
  value       = local.mq_application_user
  description = "AmazonMQ application username"
}

output "application_password" {
  value       = local.mq_application_password
  description = "AmazonMQ application password"
  sensitive   = true
}
