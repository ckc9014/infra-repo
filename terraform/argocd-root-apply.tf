resource "kubernetes_manifest" "root_application" {
  depends_on = [helm_release.argocd]
  manifest   = yamldecode(file("${path.module}/../argocd/apps-root.yaml"))
}