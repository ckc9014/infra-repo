resource "kubernetes_manifest" "karpenter_nodepool" {
  manifest   = yamldecode(local.nodepool_manifest)
}

resource "kubernetes_manifest" "karpenter_ec2nodeclass" {
  manifest   = yamldecode(local.ec2nodeclass_manifest)
}