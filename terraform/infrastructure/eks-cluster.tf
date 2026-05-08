module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.cluster_name
  cluster_version = "1.30"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

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
}