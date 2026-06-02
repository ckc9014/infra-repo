locals {
  argocd_values_file = file("${path.module}/values/argocd/values.yaml")
}

locals {
  karpenter_values_file = templatefile("${path.module}/values/karpenter/values.yaml", {
    cluster_name     = data.terraform_remote_state.infra.outputs.cluster_name
    cluster_endpoint = data.terraform_remote_state.infra.outputs.cluster_endpoint
  })
}

locals {
  aws_lb_controller_values = templatefile("${path.module}/values/aws-lbc/values.yaml", {
    cluster_name = data.terraform_remote_state.infra.outputs.cluster_name
  })
}