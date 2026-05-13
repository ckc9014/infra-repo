locals {
  name_prefix  = "${var.project_name}-${var.environment}"
  cluster_name = "${local.name_prefix}-cluster"

  # apps_root_path     = "${path.module}/../argocd/apps-root.yaml"
  # platform_root_path = "${path.module}/../argocd/platform-root.yaml"
}


