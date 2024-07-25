locals {
  add_on               = "lb-controller"
  name                 = "${var.addon_context.name}-${local.add_on}"
  service_account_name = "${local.add_on}-sa"
}
