locals {
  add_ons_namespace = "core"

  eks_oidc_issuer_url  = var.eks_oidc_provider != null ? var.eks_oidc_provider : replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")
  eks_cluster_endpoint = var.eks_cluster_endpoint != null ? var.eks_cluster_endpoint : data.aws_eks_cluster.eks_cluster.endpoint

  # Configuration for managing add-ons via ArgoCD.
  argocd_addon_config = {
    awsEfsCsiDriver            = var.enable_aws_efs_csi_driver ? module.aws_efs_csi_driver[0].argocd_gitops_config : null
    awsLoadBalancerController  = var.enable_aws_load_balancer_controller ? module.aws_load_balancer_controller[0].argocd_gitops_config : null
    clusterAutoscaler          = var.enable_cluster_autoscaler ? module.cluster_autoscaler[0].argocd_gitops_config : null
    DatadogAgent               = var.enable_datadog_agent ? module.datadog_agent[0].argocd_gitops_config : null
    # ingressNginx              = var.enable_ingress_nginx ? module.ingress_nginx[0].argocd_gitops_config : null
    keda                       = var.enable_keda ? module.keda[0].argocd_gitops_config : null
    metricsServer              = var.enable_metrics_server ? module.metrics_server[0].argocd_gitops_config : null
    flux2                      = var.enable_flux2 ? module.flux2[0].argocd_gitops_config : null
    # karpenter                 = var.enable_karpenter ? module.karpenter[0].argocd_gitops_config : null
    externalDns                = var.enable_external_dns ? module.external_dns[0].argocd_gitops_config : null
    csiSecretsStoreProviderAws = var.enable_secrets_store_csi_driver_provider_aws ? module.csi_secrets_store_provider_aws[0].argocd_gitops_config : null
  }

  addon_context = {
    name                           = var.name
    aws_region_name                = data.aws_region.current.name
    aws_caller_identity_account_id = data.aws_caller_identity.current.account_id
    eks_cluster_id                 = var.eks_cluster_id
    aws_eks_cluster_endpoint       = local.eks_cluster_endpoint
    eks_oidc_issuer_url            = local.eks_oidc_issuer_url
    eks_oidc_provider_arn          = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.eks_oidc_issuer_url}"
    kubernetes_namespace           = local.add_ons_namespace
    tags                           = var.tags
  }

  global_application_values = {
    region      = local.addon_context.aws_region_name
    account     = local.addon_context.aws_caller_identity_account_id
    clusterName = local.addon_context.eks_cluster_id
    namespace   = local.addon_context.kubernetes_namespace
  }

  application_values = merge(
    local.global_application_values,
    { for k, v in local.argocd_addon_config : k => v if v != null }
  )
}
