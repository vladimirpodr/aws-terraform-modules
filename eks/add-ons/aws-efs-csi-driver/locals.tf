locals {
  add_on               = "aws-efs-csi-driver"
  name                 = "${var.addon_context.name}-${local.add_on}"
  service_account_name = "${local.add_on}-sa"

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.service_account_name
  }
}
