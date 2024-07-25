module "helm_addon" {
  source        = "../../helm-addon"
  helm_config   = local.helm_config

  depends_on = [kubernetes_namespace_v1.this]
}

resource "kubernetes_namespace_v1" "this" {
  count = try(local.helm_config["create_namespace"], true) && local.helm_config["namespace"] != "kube-system" ? 1 : 0
  metadata {
    name = local.helm_config["namespace"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Private Repo Access
# ---------------------------------------------------------------------------------------------------------------------

resource "kubernetes_secret" "argocd_gitops" {
  for_each = { for k, v in var.repositories : k => v if try(v.git_secret_arn, null) != null }

  metadata {
    name      = "${each.key}-repo-secret"
    namespace = local.helm_config["namespace"]
    labels    = { "argocd.argoproj.io/secret-type" : "repository" }
  }

  data = {
    insecure = lookup(each.value, "insecure", false)
    username = "username"
    password = jsondecode(data.aws_secretsmanager_secret_version.git_secret_version[each.key].secret_string)["token"]
    type     = "git"
    url      = each.value.url
  }

  depends_on = [module.helm_addon]
}

# ---------------------------------------------------------------------------------------------------------------------
# SSO: OpenID Connect plus Google Groups using Dex
# ---------------------------------------------------------------------------------------------------------------------

resource "kubernetes_secret" "argocd_google_groups_json" {
  count = var.enable_sso ? 1 : 0

  metadata {
    name      = "argocd-google-groups-json"
    namespace = local.helm_config["namespace"]
  }

  data = {
    "googleAuth.json" = data.aws_secretsmanager_secret_version.argocd_google_groups_json[0].secret_string
  }

  depends_on = [module.helm_addon]
}

resource "kubernetes_secret" "argocd_google_oauth_client_secret" {
  count = var.enable_sso ? 1 : 0

  metadata {
    name      = "argocd-google-oauth-client-secret"
    namespace = local.helm_config["namespace"]
    labels    = { "app.kubernetes.io/part-of" : "argocd" }
  }

  data = {
    "oidc.auth0.clientSecret" = data.aws_secretsmanager_secret_version.argocd_google_oauth_client_secret[0].secret_string
  }

  depends_on = [module.helm_addon]
}
