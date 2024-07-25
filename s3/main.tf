locals {
  bucket_name             = lower(var.name)
  replication_bucket_name = lookup(var.replication, "bucket", null)
  attach_policy           = var.attach_s3_access_log_delivery_policy || var.attach_elb_log_delivery_policy || var.attach_log_delivery_policy || var.attach_deny_insecure_transport_policy || var.attach_deny_unencrypted_objects_policy || var.attach_policy
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

### Create IAM role for bucket replication
resource "aws_iam_role" "s3_replication" {
  count = length(keys(var.replication)) == 0 ? 0 : 1

  name = "${local.bucket_name}-replication"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "S3ReplicationPolicy"
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "s3_replication" {
  count = length(keys(var.replication)) == 0 ? 0 : 1

  name = "${local.bucket_name}-replication"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${local.bucket_name}"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersion",
        "s3:GetObjectVersionForReplication",
        "s3:GetObjectVersionAcl"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${local.bucket_name}/*"
      ]
    },
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${local.replication_bucket_name}/*"
    }
  ]
}
POLICY
}

resource "aws_iam_policy_attachment" "replication" {
  count = length(keys(var.replication)) == 0 ? 0 : 1

  name       = "${local.bucket_name}-replication-role"
  roles      = [aws_iam_role.s3_replication[0].name]
  policy_arn = aws_iam_policy.s3_replication[0].arn
}

### Create S3 bucket
resource "aws_s3_bucket" "this" {
  bucket        = local.bucket_name
  force_destroy = var.force_destroy
  
  tags = merge(var.tags, {
    Name = local.bucket_name
  })
}

resource "aws_s3_bucket_logging" "this" {
  count = length(keys(var.logging)) > 0 ? 1 : 0

  bucket = aws_s3_bucket.this.id

  target_bucket = var.logging["target_bucket"]
  target_prefix = try(var.logging["target_prefix"], null)
}

resource "aws_s3_bucket_replication_configuration" "this" {
  count = length(keys(var.replication)) == 0 ? 0 : 1

  bucket = aws_s3_bucket.this.id
  role   = aws_iam_role.s3_replication[0].arn

  rule {
    id       = "replication-to-${local.replication_bucket_name}"
    priority = "0"
    status   = "Enabled"

    delete_marker_replication {
      status = "Disabled"
    }

    filter {
      prefix = lookup(var.replication, "prefix", null)
    }

    destination {
      bucket  = "arn:aws:s3:::${local.replication_bucket_name}"
      account = lookup(var.replication, "dest_account_id", null)
      dynamic "encryption_configuration" {
        for_each = var.enable_sse == true && var.sse_algorithm == "aws:kms" ? [true] : []
        content {
          replica_kms_key_id = "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alias/aws/s3"
        }
      }
    }
    source_selection_criteria {
      replica_modifications {
        status = "Enabled"
      }
      dynamic "sse_kms_encrypted_objects" {
        for_each = var.enable_sse == true && var.sse_algorithm == "aws:kms" ? [true] : []
        content {
          status = "Enabled"
        }
      }
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = length(var.lifecycle_rules) > 0 ? 1 : 0

  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = var.lifecycle_rules

    content {
      id     = try(rule.value.id, null)
      status = "Enabled"

      dynamic "expiration" {
        for_each = try(flatten([rule.value.expiration]), [])

        content {
          days                         = try(expiration.value.days, null)
          expired_object_delete_marker = try(expiration.value.expired_object_delete_marker, null)
        }
      }

      dynamic "transition" {
        for_each = try(flatten([rule.value.transition]), [])

        content {
          date          = try(transition.value.date, null)
          days          = try(transition.value.days, null)
          storage_class = transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = try(flatten([rule.value.noncurrent_version_expiration]), [])

        content {
          newer_noncurrent_versions = try(noncurrent_version_expiration.value.newer_noncurrent_versions, null)
          noncurrent_days           = try(noncurrent_version_expiration.value.days, noncurrent_version_expiration.value.noncurrent_days, null)
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = try(flatten([rule.value.noncurrent_version_transition]), [])

        content {
          newer_noncurrent_versions = try(noncurrent_version_transition.value.newer_noncurrent_versions, null)
          noncurrent_days           = try(noncurrent_version_transition.value.days, noncurrent_version_transition.value.noncurrent_days, null)
          storage_class             = noncurrent_version_transition.value.storage_class
        }
      }

      dynamic "filter" {
        for_each = length(try(flatten([rule.value.filter]), [])) == 0 ? [true] : []

        content {
          prefix = try(filter.value.prefix, null)
        }
      }

    }
  }
}

resource "aws_s3_bucket_website_configuration" "this" {
  count = var.attach_policy_website ? 1 : 0

  bucket = aws_s3_bucket.this.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_versioning" "this" {
  count = length(keys(var.versioning)) > 0 ? 1 : 0

  bucket = aws_s3_bucket.this.id
  mfa    = try(var.versioning["mfa"], null)

  versioning_configuration {
    # Valid values: "Enabled" or "Suspended"
    status = try(var.versioning["enabled"] ? "Enabled" : "Suspended", tobool(var.versioning["status"]) ? "Enabled" : "Suspended", title(lower(var.versioning["status"])))

    # Valid values: "Enabled" or "Disabled"
    mfa_delete = try(tobool(var.versioning["mfa_delete"]) ? "Enabled" : "Disabled", title(lower(var.versioning["mfa_delete"])), null)
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count = var.enable_sse ? 1 : 0

  bucket = aws_s3_bucket.this.id
  rule {
    bucket_key_enabled = try(var.sse_kms_bucket_key_enabled, null)
    apply_server_side_encryption_by_default {
      sse_algorithm = var.sse_algorithm
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  count = local.attach_policy ? 1 : 0

  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.combined[0].json
}

data "aws_iam_policy_document" "combined" {
  count = local.attach_policy ? 1 : 0

  source_policy_documents = compact([
    var.attach_s3_access_log_delivery_policy ? data.aws_iam_policy_document.s3_access_log_delivery[0].json : "",
    var.attach_elb_log_delivery_policy ? data.aws_iam_policy_document.elb_log_delivery[0].json : "",
    var.attach_log_delivery_policy ? data.aws_iam_policy_document.lb_log_delivery[0].json : "",
    var.attach_deny_insecure_transport_policy ? data.aws_iam_policy_document.deny_insecure_transport[0].json : "",
    var.attach_deny_unencrypted_objects_policy ? data.aws_iam_policy_document.deny_unencrypted_objects[0].json : "",
    var.attach_policy_website ? data.aws_iam_policy_document.allow_website[0].json : "",
    var.attach_policy ? var.policy : ""
  ])
}

data "aws_iam_policy_document" "s3_access_log_delivery" {
  count = var.attach_s3_access_log_delivery_policy ? 1 : 0

  statement {
    sid = ""

    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }

    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*",
    ]
  }
}


# AWS Load Balancer access log delivery policy
data "aws_elb_service_account" "this" {
  count = var.attach_elb_log_delivery_policy ? 1 : 0
}

data "aws_iam_policy_document" "elb_log_delivery" {
  count = var.attach_elb_log_delivery_policy ? 1 : 0

  statement {
    sid = ""

    principals {
      type        = "AWS"
      identifiers = data.aws_elb_service_account.this.*.arn
    }

    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*",
    ]
  }
}

# ALB/NLB

data "aws_iam_policy_document" "lb_log_delivery" {
  count = var.attach_log_delivery_policy ? 1 : 0

  statement {
    sid = "AWSLogDeliveryWrite"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    sid = "AWSLogDeliveryAclCheck"

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
    ]

    resources = [
      aws_s3_bucket.this.arn,
    ]

  }
}

data "aws_iam_policy_document" "deny_insecure_transport" {
  count = var.attach_deny_insecure_transport_policy ? 1 : 0
  statement {
    sid    = "denyInsecureTransport"
    effect = "Deny"

    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        "false"
      ]
    }
  }
}

data "aws_iam_policy_document" "deny_unencrypted_objects" {
  count = var.attach_deny_unencrypted_objects_policy ? 1 : 0
  statement {
    sid    = "DenyIncorrectEncryptionHeader"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*",
    ]

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values = [
        var.sse_algorithm
      ]
    }
  }

  statement {
    sid    = "DenyUnEncryptedObjectUploads"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*",
    ]

    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values = [
        "true"
      ]
    }
  }
}

data "aws_iam_policy_document" "allow_website" {
  count = var.attach_policy_website ? 1 : 0
  statement {
    sid    = "StaticWebsite"
    effect = "Allow"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.id
  acl    = var.acl
}

resource "aws_s3_bucket_public_access_block" "this" {
  # Chain resources (s3_bucket -> s3_bucket_policy -> s3_bucket_public_access_block)
  bucket = local.attach_policy ? aws_s3_bucket_policy.this[0].id : aws_s3_bucket.this.id

  block_public_acls       = !var.attach_policy_website && var.block_public_acls ? true : false 
  block_public_policy     = !var.attach_policy_website && var.block_public_policy ? true : false
  ignore_public_acls      = !var.attach_policy_website && var.ignore_public_acls ? true : false
  restrict_public_buckets = !var.attach_policy_website && var.restrict_public_buckets ? true : false
}