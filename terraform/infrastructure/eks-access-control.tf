resource "aws_eks_access_entry" "github_actions" {
  cluster_name      = module.eks.cluster_name
  principal_arn     = var.github_actions_role_arn
  kubernetes_groups = ["github-actions-group"]
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "github_actions_admin" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_eks_access_entry.github_actions.principal_arn
  access_scope {
    type = "cluster"
  }
}

# EKS Access Entry for the Karpenter node role
resource "aws_eks_access_entry" "karpenter_nodes" {
  cluster_name      = module.eks.cluster_name
  principal_arn     = aws_iam_role.karpenter_node.arn
  kubernetes_groups = ["system:bootstrappers", "system:nodes"]
  type              = "EC2_LINUX"   # or "STANDARD" for generic
}

# Associate the access entry with the cluster admin policy (or a more restrictive one)
resource "aws_eks_access_policy_association" "karpenter_nodes" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_eks_access_entry.karpenter_nodes.principal_arn
  access_scope {
    type = "cluster"
  }
}