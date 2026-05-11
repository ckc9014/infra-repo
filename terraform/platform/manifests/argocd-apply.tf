resource "kubernetes_manifest" "apps_root" {
  depends_on = [helm_release.argocd]
  manifest   = yamldecode(file(local.apps_root_path))
}

resource "kubernetes_manifest" "platform_root" {
  depends_on = [helm_release.argocd]
  manifest   = yamldecode(file(local.platform_root_path))
}