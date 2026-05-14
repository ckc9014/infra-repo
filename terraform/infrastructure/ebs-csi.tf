
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name = module.eks.cluster_name
  addon_name   = "aws-ebs-csi-driver"
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = aws_iam_role.karpenter_node.name  
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_iam_role_policy_attachment" "system_ebs_csi" {
  role       = module.eks.eks_managed_node_groups["system"].iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}