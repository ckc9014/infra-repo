resource "aws_eks_access_entry" "github_actions" {
  cluster_name      = module.eks.cluster_name
  principal_arn     = var.github_actions_role_arn
  kubernetes_groups = ["github-actions-group"]
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "github_actions_view" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminViewPolicy"
  principal_arn = aws_eks_access_entry.github_actions.principal_arn
  access_scope {
    type = "cluster"
  }
}