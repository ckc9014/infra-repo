resource "kubernetes_manifest" "karpenter_nodepool" {
  depends_on = [helm_release.karpenter]
  manifest   = yamldecode(local.nodepool_manifest)
}

resource "kubernetes_manifest" "karpenter_ec2nodeclass" {
  depends_on = [helm_release.karpenter]
  manifest   = yamldecode(local.ec2nodeclass_manifest)
}