resource "helm_release" "karpenter" {
  name             = "karpenter"
  namespace        = "kube-system"
  create_namespace = false 

  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "1.10.0"

  values = [local.karpenter_static_values]

  set = [
    {
      name  = "settings.clusterName"
      value = data.terraform_remote_state.infra.outputs.cluster_name
    },
    {
      name  = "settings.clusterEndpoint"
      value = data.terraform_remote_state.infra.outputs.cluster_endpoint
    },

  ]
}