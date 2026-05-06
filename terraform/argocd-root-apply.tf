resource "kubernetes_manifest" "apps_root" {
  depends_on = [helm_release.argocd]
  manifest   = yamldecode(file("${path.module}/../argocd/apps-root.yaml"))
}

resource "kubernetes_manifest" "platform_root" {
  depends_on = [helm_release.argocd]
  manifest   = yamldecode(file("${path.module}/../argocd/platform-root.yaml"))
}