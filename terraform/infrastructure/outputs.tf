output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "karpenter_controller_role_arn" {
  description = "IAM role ARN used by Karpenter controller (EKS Pod Identity)"
  value       = aws_iam_role.karpenter_controller.arn
}

output "karpenter_node_role_arn" {
  description = "IAM role ARN for Karpenter worker nodes"
  value       = aws_iam_role.karpenter_node.arn
}

output "karpenter_node_instance_profile" {
  description = "Instance profile name for Karpenter worker nodes"
  value       = aws_iam_instance_profile.karpenter.name
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}