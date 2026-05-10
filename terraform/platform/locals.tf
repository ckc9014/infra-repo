locals {
  nodepool_manifest = templatefile("${path.module}/../../karpenter/nodepool.yaml.tmpl", {})


  ec2nodeclass_manifest = templatefile("${path.module}/../../karpenter/ec2nodeclass.yaml.tmpl", {
    cluster_name       = data.terraform_remote_state.infra.outputs.cluster_name
    karpenter_node_role = data.terraform_remote_state.infra.outputs.karpenter_node_role_name
  })
}