# ---------------------------------------------------------------------------------------------------------------------
# ArgoCD Application Bootstrapping (Helm)
# ---------------------------------------------------------------------------------------------------------------------
resource "helm_release" "argocd_application" {
  for_each = { for k, v in var.applications : k => merge(local.default_argocd_application, v) if  merge(local.default_argocd_application, v).add_on_application == false }

  name      = each.key
  chart     = "${path.module}/chart"
  version   = "0.1.0"
  namespace = each.value.namespace
  create_namespace = true

  # Application Meta.
  set {
    name  = "name"
    value = each.key
    type  = "string"
  }

  set {
    name  = "project"
    value = each.value.project
    type  = "string"
  }

  # Source Config.
  set {
    name  = "source.repoUrl"
    value = each.value.repo_url
    type  = "string"
  }

  set {
    name  = "source.targetRevision"
    value = each.value.target_revision
    type  = "string"
  }

  set {
    name  = "source.path"
    value = each.value.path
    type  = "string"
  }

  set {
    name  = "source.helm.releaseName"
    value = each.key
    type  = "string"
  }

  set {
    name  = "source.helm.valueFiles"
    value = "{${each.value.value_file}}"
    type = "auto"
  }

  set {
    name  = "source.helm.values"
    value = yamlencode(each.value.values)
    type = "auto"
  }

  # Destination Config.
  set {
    name  = "destination.server"
    value = each.value.destination
    type  = "string"
  }

  set {
    name  = "destination.namespace"
    value = each.value.namespace
    type  = "string"
  }

  set {
    name  = "autoSyncPolicy"
    value = each.value.auto_sync_policy
    type  = "string"
  }
}

resource "helm_release" "argocd_add_on_application" {
  for_each = { for k, v in var.applications : k => merge(local.default_argocd_application, v) if  merge(local.default_argocd_application, v).add_on_application == true }

  name      = each.key
  chart     = "${path.module}/chart"
  version   = "0.1.0"
  namespace = "argocd"
  create_namespace = true

  # Application Meta.
  set {
    name  = "name"
    value = each.key
    type  = "string"
  }

  set {
    name  = "project"
    value = each.value.project
    type  = "string"
  }

  # Source Config.
  set {
    name  = "source.repoUrl"
    value = each.value.repo_url
    type  = "string"
  }

  set {
    name  = "source.targetRevision"
    value = each.value.target_revision
    type  = "string"
  }

  set {
    name  = "source.path"
    value = each.value.path
    type  = "string"
  }

  set {
    name  = "source.helm.releaseName"
    value = each.key
    type  = "string"
  }

  set {
    name  = "source.helm.values"
    value = yamlencode(merge(
      { repoUrl = each.value.repo_url },
      each.value.values
    ))
    type = "auto"
  }

  # Destination Config.
  set {
    name  = "destination.server"
    value = each.value.destination
    type  = "string"
  }

  set {
    name  = "destination.namespace"
    value = each.value.namespace
    type  = "string"
  }

  set {
    name  = "autoSyncPolicy"
    value = each.value.auto_sync_policy
    type  = "string"
  }
}
