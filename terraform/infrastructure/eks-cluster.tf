module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.cluster_name
  cluster_version = "1.30"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access = true

  # Enable IAM Roles for Service Accounts (IRSA)
  enable_irsa = true

  authentication_mode = "API_AND_CONFIG_MAP"

  # Tags that Karpenter uses to discover resources.
  cluster_tags = {
    "karpenter.sh/discovery" = local.name_prefix
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  # -------------------------------------------------------------
  # Managed node group for system workloads (ArgoCD, Karpenter, etc.)
  # -------------------------------------------------------------
  eks_managed_node_groups = {
    system = {
      name = "system-node-group"
      instance_types = ["t3.small"]
      min_size     = 2
      max_size     = 3
      desired_size = 2

      subnet_ids = module.vpc.private_subnets

      tags = {
        Environment = var.environment
        Role        = "system"
      }
    }
  }
}