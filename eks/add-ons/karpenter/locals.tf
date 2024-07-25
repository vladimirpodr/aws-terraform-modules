locals {
  name                 = "karpenter"
  service_account_name = "karpenter"
  eks_cluster_endpoint = var.addon_context.aws_eks_cluster_endpoint

  irsa_config = {
    kubernetes_namespace              = local.helm_config["namespace"]
    kubernetes_service_account        = local.service_account_name
    create_kubernetes_namespace       = try(local.helm_config["create_namespace"], true)
    create_kubernetes_service_account = true
    irsa_iam_policies                 = concat([aws_iam_policy.karpenter.arn], var.irsa_policies)
  }

  argocd_gitops_config = {
    enable                    = true
    serviceAccountName        = local.service_account_name
    controllerClusterEndpoint = local.eks_cluster_endpoint
    awsDefaultInstanceProfile = var.node_iam_instance_profile
  }
}
