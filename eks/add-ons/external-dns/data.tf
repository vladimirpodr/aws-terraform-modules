data "aws_iam_policy_document" "main" {
  statement {
    effect = "Allow"
    resources = var.route53_zone_arns
    actions = ["route53:ChangeResourceRecordSets"]
  }

  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
    ]
  }
}
