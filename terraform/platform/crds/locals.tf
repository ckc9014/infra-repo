locals {
   argocd_values_file = file("${path.module}/values/argocd/values.yaml")
}

locals {
  karpenter_static_values = file("${path.module}/values/karpenter/values.yaml")
}