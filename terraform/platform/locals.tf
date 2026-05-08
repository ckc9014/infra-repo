locals {
  nodepool_manifest = templatefile("${path.module}/../karpenter/nodepool.yaml.tmpl", {})
  ec2nodeclass_manifest = templatefile("${path.module}/../karpenter/ec2nodeclass.yaml.tmpl", {
    cluster_name       = var.cluster_name
    karpenter_node_role = var.karpenter_node_role_name
  })
}