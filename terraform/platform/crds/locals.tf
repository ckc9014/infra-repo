locals {
  argocd_values_file = file("${path.module}/values/argocd/values.yaml")
}

locals {
  karpenter_values_file = templatefile("${path.module}/values/karpenter/values.yaml", {
    cluster_name     = data.terraform_remote_state.infra.outputs.cluster_name
    cluster_endpoint = data.terraform_remote_state.infra.outputs.cluster_endpoint
  })
}