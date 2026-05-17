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

  cluster_addons = {
    eks-pod-identity-agent = {
      most_recent = true
    }

    coredns = {
      most_recent = true
      # Override the CoreDNS configuration to forward to Google's public DNS
      configuration_values = jsonencode({
        corefile = <<-EOT
          .:53 {
              errors
              health
              ready
              kubernetes cluster.local in-addr.arpa ip6.arpa {
                  pods insecure
                  fallthrough in-addr.arpa ip6.arpa
              }
              prometheus :9153
              forward . 8.8.8.8 8.8.4.4
              cache 30
              loop
              reload
              loadbalance
          }
        EOT
      })
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  # Tags that Karpenter uses to discover resources.
  cluster_tags = {
    "karpenter.sh/discovery" = local.cluster_name
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
      name           = "system-node-group"
      instance_types = ["t3.small"]

      desired_size = 6
      min_size     = 6
      max_size     = 8

      subnet_ids = module.vpc.private_subnets

      taints = [
        {
          key    = "CriticalAddonsOnly"
          value  = "true"
          effect = "NO_SCHEDULE" # or "NO_EXECUTE"
        }
      ]

      tags = {
        Environment = var.environment
        Role        = "system"
      }
    }
  }
}
