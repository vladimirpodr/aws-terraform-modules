# Provides a resource to manage whether default EBS encryption is enabled for your AWS account in the current AWS region.
resource "aws_ebs_encryption_by_default" "main" {
  count = var.enable_ebs_encryption_by_default ? 1 : 0

  enabled = true
}

# Manages S3 account-level Public Access Block configuration.
resource "aws_s3_account_public_access_block" "main" {
  count = var.enable_s3_account_public_access_block ? 1 : 0

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Manages Password Policy for the AWS Account.
resource "aws_iam_account_password_policy" "strict" {
  count = var.enable_iam_account_password_policy ? 1 : 0

  minimum_password_length        = 14
  max_password_age               = 90
  password_reuse_prevention      = 24
  hard_expiry                    = false
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
}

# Create buckets for S3 access logs and LB access logs
locals {
  lb_access_logs_bucket = "${var.name}-lb-access-logs-bucket"
  s3_access_logs_bucket = "${var.name}-s3-access-logs-bucket"

  lb_access_logs_replication_bucket = "${var.project_name}-${var.s3_bucket_replication_dest_account_name}-logging-lb-access-bucket"
  s3_access_logs_replication_bucket = "${var.project_name}-${var.s3_bucket_replication_dest_account_name}-logging-s3-access-bucket"
  replication_dest_account_id       = var.s3_bucket_replication_dest_account_id
}

module "s3_access_logs_s3_bucket" {
  source = "git@github.com:ambyint/aws-terraform-modules.git//s3?ref=main"

  count = var.enable_s3_access_logs_s3_bucket ? 1 : 0

  name          = local.s3_access_logs_bucket
  sse_algorithm = "AES256"

  attach_deny_insecure_transport_policy  = true
  attach_s3_access_log_delivery_policy   = true

  versioning = {
    status     = true
    mfa_delete = false
  }

  replication = {
    bucket          = local.s3_access_logs_replication_bucket
    dest_account_id = local.replication_dest_account_id
  }

  lifecycle_rules = [
    {
      id = "TransitionRule"

      transition = [
        {
          days          = 90
          storage_class = "STANDARD_IA"
        }
      ]

      expiration = {
        days = 180
      }

      noncurrent_version_transition = [
        {
          days          = 90
          storage_class = "STANDARD_IA"
        }
      ]

      noncurrent_version_expiration = {
        days = 180
      }
    }
  ]
}

module "lb_access_logs_s3_bucket" {
  source = "git@github.com:ambyint/aws-terraform-modules.git//s3?ref=main"

  count = var.enable_lb_access_logs_s3_bucket && var.enable_s3_access_logs_s3_bucket ? 1 : 0

  name          = local.lb_access_logs_bucket
  sse_algorithm = "AES256"

  attach_deny_insecure_transport_policy  = true
  attach_log_delivery_policy             = true
  attach_elb_log_delivery_policy         = true
  logging = {
    target_bucket = module.s3_access_logs_s3_bucket[0].bucket_id
    target_prefix = "${local.lb_access_logs_bucket}/"
  }

  versioning = {
    status     = true
    mfa_delete = false
  }

  replication = {
    bucket          = local.lb_access_logs_replication_bucket
    dest_account_id = local.replication_dest_account_id
  }

  lifecycle_rules = [
    {
      id = "TransitionRule"

      transition = [
        {
          days          = 90
          storage_class = "STANDARD_IA"
        }
      ]

      expiration = {
        days = 180
      }

      noncurrent_version_transition = [
        {
          days          = 90
          storage_class = "STANDARD_IA"
        }
      ]

      noncurrent_version_expiration = {
        days = 180
      }
    }
  ]
}


# Organization custom Config rule Lambda assume this role to have access to the accounts in Organization
resource "aws_iam_role" "organization_config_rule_lambda_assume_role" {
  count = var.enable_organization_config_rule_lambda_assume_role ? 1 : 0

  name = "${var.project_name}-organization-config-rule-lambda-assume-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = var.organization_config_rule_lambda_role_arn
        }
      },
    ]
  })

  inline_policy {
    name   = "inline_policy"
    policy = data.aws_iam_policy_document.organization_config_rule_lambda_assume_role_inline_policy.json
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-organization-config-rule-lambda-assume-role"
  })
}

data "aws_iam_policy_document" "organization_config_rule_lambda_assume_role_inline_policy" {
  statement {
    actions = [ "config:PutEvaluations" ]

    resources = [ "*" ]
  }

  statement {
    actions = [ "iam:GetAccountAuthorizationDetails" ]

    resources = [ "*" ]
  }
}

# Set up Security Hub
resource "aws_securityhub_standards_subscription" "security_hub_aws_foundational_security_best_practices" {
  count = var.enable_sh_aws_foundational_security_best_practices_standard ? 1 : 0

  standards_arn = "arn:aws:securityhub:us-east-1::standards/aws-foundational-security-best-practices/v/1.0.0"
}
