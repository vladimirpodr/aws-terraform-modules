data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

################################################################################
# Key
################################################################################

resource "aws_kms_key" "this" {
  deletion_window_in_days            = var.deletion_window_in_days
  description                        = var.description
  enable_key_rotation                = var.enable_key_rotation
  key_usage                          = var.key_usage
  multi_region                       = var.multi_region
  policy                             = coalesce(var.policy, data.aws_iam_policy_document.this.json)

  tags = var.tags
}

################################################################################
# Policy
################################################################################

data "aws_iam_policy_document" "this" {
  # Default policy - account wide access to all key operations
  dynamic "statement" {
    for_each = var.enable_default_policy ? [1] : []

    content {
      sid       = "Default"
      actions   = ["kms:*"]
      resources = ["*"]

      principals {
        type        = "AWS"
        identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
      }
    }
  }

  # Key owner - all key operations
  dynamic "statement" {
    for_each = length(var.key_owners) > 0 ? [1] : []

    content {
      sid       = "KeyOwner"
      actions   = ["kms:*"]
      resources = ["*"]

      principals {
        type        = "AWS"
        identifiers = var.key_owners
      }
    }
  }

  # Key administrators - https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-administrators
  dynamic "statement" {
    for_each = length(var.key_administrators) > 0 ? [1] : []

    content {
      sid = "KeyAdministration"
      actions = [
        "kms:Create*",
        "kms:Describe*",
        "kms:Enable*",
        "kms:List*",
        "kms:Put*",
        "kms:Update*",
        "kms:Revoke*",
        "kms:Disable*",
        "kms:Get*",
        "kms:Delete*",
        "kms:TagResource",
        "kms:UntagResource",
        "kms:ScheduleKeyDeletion",
        "kms:CancelKeyDeletion",
      ]
      resources = ["*"]

      principals {
        type        = "AWS"
        identifiers = var.key_administrators
      }
    }
  }

  # Key users - https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-users
  dynamic "statement" {
    for_each = length(var.key_users) > 0 ? [1] : []

    content {
      sid = "KeyUsage"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:CreateGrant",
        "kms:DescribeKey",
      ]
      resources = ["*"]

      principals {
        type        = "AWS"
        identifiers = var.key_users
      }

      dynamic "condition" {
        for_each = var.key_users_conditions
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }

  # Key users with AWS service - https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-service-integration
  dynamic "statement" {
    for_each = length(var.key_users_with_service) > 0 ? [1] : []

    content {
      sid = "KeyUsageWithService"
      actions = [
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:RevokeGrant",
      ]
      resources = ["*"]

      principals {
        type        = "AWS"
        identifiers = var.key_users_with_service
      }

      condition {
        test     = "Bool"
        variable = "kms:GrantIsForAWSResource"
        values   = [true]
      }
    }
  }

  # Key service users - https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-services.html
    dynamic "statement" {
    for_each = length(var.key_service_users) > 0 ? [1] : []

    content {
      sid = "KeyServiceUsage"
      actions = [
        "kms:GenerateDataKey",
        "kms:Decrypt"
      ]
      resources = ["*"]

      principals {
        type        = "Service"
        identifiers = var.key_service_users
      }
    }
  }

  # Key users to decrypt - https://docs.aws.amazon.com/secretsmanager/latest/userguide/auth-and-access_examples_cross.html
    dynamic "statement" {
    for_each = length(var.key_users_to_decrypt) > 0 ? [1] : []

    content {
      sid = "KeyUsageToDecryptResources"
      actions = [
        "kms:DescribeKey",
        "kms:Decrypt"
      ]
      resources = ["*"]

      principals {
        type        = "AWS"
        identifiers = var.key_users_to_decrypt
      }
    }
  }
}

################################################################################
# Alias
################################################################################

resource "aws_kms_alias" "this" {
  for_each = toset(var.aliases)

  name          = "alias/${each.value}"
  target_key_id = aws_kms_key.this.key_id
}