output "version" {
  value = aws_lambda_function.main.version
}

output "arn" {
  description = "The Amazon Resource Name (ARN) identifying your Lambda Function."
  value       = aws_lambda_function.main.arn
}

output "role_id" {
  description = "Identifying your Lambda Function Execution Role."
  value       = aws_iam_role.main.id
}

output "role_arn" {
  description = "Identifying your Lambda Function Execution Role."
  value       = aws_iam_role.main.arn
}
