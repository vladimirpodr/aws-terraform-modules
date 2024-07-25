locals {
  add_on               = "cluster-autoscaler"
  name                 = "${var.addon_context.name}-${local.add_on}"
  service_account_name = "${local.add_on}-sa"
}

data "aws_iam_policy_document" "main" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplateVersions"
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeInstanceTypes",
      "eks:DescribeNodegroup",
    ]
    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/${var.addon_context.eks_cluster_id}"
      values   = ["owned"]
    }
  }
}

resource "aws_iam_policy" "main" {
  name        = "${local.name}-irsa-policy"
  description = "Cluster Autoscaler IAM policy"
  policy      = data.aws_iam_policy_document.main.json
  tags        = var.addon_context.tags
}

module "irsa" {
  source  = "../irsa"

  name                              = local.name
  create_kubernetes_service_account = true
  kubernetes_namespace              = var.addon_context.kubernetes_namespace
  kubernetes_service_account        = local.service_account_name
  irsa_iam_policies                 = [aws_iam_policy.main.arn]
  eks_cluster_id                    = var.addon_context.eks_cluster_id
  eks_oidc_provider_arn             = var.addon_context.eks_oidc_provider_arn
}