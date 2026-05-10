# resource "kubernetes_manifest" "apps_root" {
#   depends_on = [helm_release.argocd]
#   manifest   = yamldecode(file(local.apps_root_path))
# }

# resource "kubernetes_manifest" "platform_root" {
#   depends_on = [helm_release.argocd]
#   manifest   = yamldecode(file(local.platform_root_path))
# }

resource "kubernetes_manifest" "karpenter_nodepool" {
  depends_on = [helm_release.karpenter]
  manifest   = yamldecode(local.nodepool_manifest)
}

resource "kubernetes_manifest" "karpenter_ec2nodeclass" {
  depends_on = [helm_release.karpenter]
  manifest   = yamldecode(local.ec2nodeclass_manifest)
}