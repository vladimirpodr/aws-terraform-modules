
resource "kubernetes_secret" "flux_git_secret" {
  for_each = { for k, v in var.repositories : k => v if try(v.git_secret_arn, null) != null }

  metadata {
    name      = "flux-${each.key}-repo-secret"
    namespace = var.addon_context.kubernetes_namespace
    labels    = { "argocd.argoproj.io/secret-type" : "repository" }
  }

  data = {
    username = "username"
    password = jsondecode(data.aws_secretsmanager_secret_version.git_secret_version[each.key].secret_string)["token"]
  }
}

resource "helm_release" "flux_image_update" {
  for_each = { for k, v in var.repositories : k => v  if try(v.git_secret_arn, null) != null }

  name      = "image-update-${each.key}"
  chart     = "${path.module}/charts/image-update"
  version   = "0.1.0"
  namespace = var.addon_context.kubernetes_namespace

  # Application Meta.
  set {
    name  = "name"
    value = each.key
    type  = "string"
  }

  set {
    name  = "branch"
    value = each.value.branch
    type  = "string"
  }
}


resource "helm_release" "flux_git_repository" {
  for_each = { for k, v in var.repositories : k => v  if try(v.git_secret_arn, null) != null }

  name      = "git-repository-${each.key}"
  chart     = "${path.module}/charts/git-repository"
  version   = "0.1.0"
  namespace = var.addon_context.kubernetes_namespace

  # Application Meta.
  set {
    name  = "name"
    value = each.key
    type  = "string"
  }

  set {
    name  = "url"
    value = each.value.url
    type  = "string"
  }

  set {
    name  = "branch"
    value = each.value.branch
    type  = "string"
  }

  set {
    name  = "secretRefName"
    value = "flux-${each.key}-repo-secret"
    type  = "string"
  }
}
