locals {
  name_prefix = "${var.project_name}-${var.environment}"
  cluster_name = "${local.name_prefix}-cluster"
}

locals {
  apps_root_path    = "${path.module}/../argocd/apps-root.yaml"
  platform_root_path = "${path.module}/../argocd/platform-root.yaml"
}


locals {
  nodepool_manifest = templatefile("${path.module}/../karpenter/nodepool.yaml.tmpl", {})

  ec2nodeclass_manifest = templatefile("${path.module}/../karpenter/ec2nodeclass.yaml.tmpl", {
    cluster_name       = module.eks.cluster_name
    karpenter_node_role = aws_iam_role.karpenter_node.name
  })
}

