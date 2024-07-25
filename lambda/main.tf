locals {
  function_name = "${var.name}-lambda"
}

# Lambda execution role
resource "aws_iam_role" "main" {
  name = "${var.name}-role"

  assume_role_policy = <<-POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": "sts:AssumeRole",
          "Principal": { "Service": "lambda.amazonaws.com" }
        }
      ]
    }
    POLICY

  tags = merge(var.tags, {
    Name = "${var.name}-role"
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "main" {
  name = "/aws/lambda/${local.function_name}"

  retention_in_days = 30

  tags = merge(var.tags, {
    Name = local.function_name
  })
}

resource "aws_iam_policy" "main" {
  count = var.attach_policy ? 1 : 0

  name   = "${var.name}-policy"
  policy = var.policy

  tags = merge(var.tags, {
    Name = "${var.name}-policy"
  })
}

resource "aws_iam_role_policy_attachment" "main" {
  count = var.attach_policy ? 1 : 0

  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.main[0].arn
}

### Upload zip with lambda
resource "aws_lambda_function" "main" {
  function_name    = local.function_name
  description      = var.description
  role             = aws_iam_role.main.arn
  handler          = var.lambda_function_handler
  filename         = var.source_code_path
  source_code_hash = filebase64sha256(var.source_code_path)
  runtime          = var.runtime
  memory_size      = var.memory_size
  timeout          = var.timeout

  dynamic "environment" {
    for_each = length(keys(var.environment_variables)) == 0 ? [] : [true]
    content {
      variables = var.environment_variables
    }
  }

  dynamic "vpc_config" {
    for_each = var.vpc_subnet_ids != null && var.vpc_security_group_ids != null ? [true] : []
    content {
      security_group_ids = var.vpc_security_group_ids
      subnet_ids         = var.vpc_subnet_ids
    }
  }
}
