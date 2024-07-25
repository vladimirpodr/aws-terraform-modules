### Variables
variable "basename" { type = string }
variable "names" { type = list(string) }
variable "enable_lifecycle_policy" { type = bool }
variable "lifecycle_policy" { type = string }
variable "allow_push_users_arn" {
  type    = list
  default = []
}
variable "tags" {
  type    = map(string)
  default = {}
}

### ECR
resource "aws_ecr_repository" "ecr" {
  for_each = toset(var.names)

  name = "${lower(var.basename)}-${each.value}"

  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.tags, {
    Name = "${lower(var.basename)}-${each.value}"
  })
}

# ECR Lifecycle Policy
resource "aws_ecr_lifecycle_policy" "lifecycle" {
  for_each = var.enable_lifecycle_policy == true ? toset(var.names) : []

  repository = "${lower(var.basename)}-${each.value}"

  policy = var.lifecycle_policy

  depends_on = [
    aws_ecr_repository.ecr
  ]
}

resource "aws_ecr_registry_scanning_configuration" "configuration" {
  scan_type = "ENHANCED"

  rule {
    scan_frequency = "CONTINUOUS_SCAN"
    repository_filter {
      filter      = "*"
      filter_type = "WILDCARD"
    }
  }
}

data "aws_organizations_organization" "current" {}


data "aws_iam_policy_document" "policy" {
  statement {
    sid = "AllowPull"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:ListImages"
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [
        data.aws_organizations_organization.current.id
      ]
    }
  }

  dynamic "statement" {
    for_each = toset(var.allow_push_users_arn)

    content {
      sid = "AllowPush"
      principals {
        type        = "AWS"
        identifiers = [statement.value]
      }

      actions = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:DescribeImages",
        "ecr:BatchGetImage",
        "ecr:GetLifecyclePolicy",
        "ecr:GetLifecyclePolicyPreview",
        "ecr:ListTagsForResource",
        "ecr:DescribeImageScanFindings",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:PutImage",
        "ecr:CreateRepository"
      ]
    }
  }
}

resource "aws_ecr_repository_policy" "policy" {
  for_each = toset(var.names)

  repository = "${lower(var.basename)}-${each.value}"

  policy = data.aws_iam_policy_document.policy.json
}

### Outputs
output "repo_names" {
  value = toset([
    for repo in aws_ecr_repository.ecr : repo.name
  ])
}

output "repo_arns" {
  value = toset([
    for repo in aws_ecr_repository.ecr : repo.arn
  ])
}

# vim:filetype=terraform ts=2 sw=2 et:
