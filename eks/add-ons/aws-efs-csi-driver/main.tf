resource "aws_iam_policy" "main" {
  name        = "${local.name}-irsa-policy"
  description = "IAM Policy for AWS EFS CSI Driver"
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