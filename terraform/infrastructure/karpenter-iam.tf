# 1. IAM Role for the Karpenter Controller Pod
resource "aws_iam_role" "karpenter_controller" {
  name = "${local.name_prefix}-karpenter-controller-role"

  # Trust Policy: Allows EKS Pod Identity service to assume this role for the Karpenter service account
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = {
    Name        = "${local.name_prefix}-karpenter-controller-role"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# 2. IAM Policy with necessary permissions for Karpenter
resource "aws_iam_policy" "karpenter_controller" {
  name = "${local.name_prefix}-karpenter-controller-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:CreateFleet",                         # ✅ add
          "ec2:DescribeImages",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeSpotPriceHistory",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeLaunchTemplates",
          "ec2:CreateLaunchTemplate",
          "ec2:DeleteLaunchTemplate",
          "ec2:CreateLaunchTemplateVersion",        # recommended
          "ec2:DeleteLaunchTemplateVersions",      # recommended
          "iam:PassRole",
          "iam:GetInstanceProfile",
          "iam:ListInstanceProfiles",
          "iam:CreateInstanceProfile",              # needed
          "iam:AddRoleToInstanceProfile",          # needed
          "iam:TagInstanceProfile",                # needed
          "iam:CreateServiceLinkedRole",
          "iam:DeleteInstanceProfile",
          "eks:DescribeCluster",
          "ssm:GetParameter",
          "pricing:GetProducts"                    # needed for spot/on‑demand pricing
        ]
        Resource = "*"
      }
    ]
  })
}

# 3. Attach the Policy to the Role
resource "aws_iam_role_policy_attachment" "karpenter_controller" {
  role       = aws_iam_role.karpenter_controller.name
  policy_arn = aws_iam_policy.karpenter_controller.arn
}

# 4. EKS Pod Identity Association
# This links the IAM role to the service account 'karpenter'
resource "aws_eks_pod_identity_association" "karpenter" {
  cluster_name    = module.eks.cluster_name
  namespace       = "kube-system"
  service_account = "karpenter"
  role_arn        = aws_iam_role.karpenter_controller.arn
}

# IAM role for training pod
resource "aws_iam_role" "training_pod_role" {
  name = "${local.name_prefix}-training-pod-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "pods.eks.amazonaws.com" }
      Action = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })
}

# S3 write policy
resource "aws_iam_role_policy" "training_pod_s3" {
  name = "${local.name_prefix}-training-pod-s3"
  role = aws_iam_role.training_pod_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "s3:PutObject"
      Resource = "arn:aws:s3:::training-bucket-02609053/*"
    }]
  })
}

# Pod Identity association for training pod
resource "aws_eks_pod_identity_association" "training" {
  cluster_name    = module.eks.cluster_name
  namespace       = "training"
  service_account = "default"
  role_arn        = aws_iam_role.training_pod_role.arn
}


# 5. IAM Role & Instance Profile for Karpenter Nodes (EC2 instances)
resource "aws_iam_role" "karpenter_node" {
  name = "${local.name_prefix}-karpenter-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = {
    Name        = "${local.name_prefix}-karpenter-node-role"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy" "karpenter_node_list_access" {
  name = "${local.name_prefix}-karpenter-node-list-access"
  role = aws_iam_role.karpenter_node.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "eks:ListAccessEntries"
        Resource = "*"
      }
    ]
  })
}

# Attach the required policies to the node role
resource "aws_iam_role_policy_attachment" "karpenter_node_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ])

  role       = aws_iam_role.karpenter_node.name
  policy_arn = each.value
}

# Instance profile that Karpenter will attach to the EC2 instances it launches
resource "aws_iam_instance_profile" "karpenter" {
  name = "${local.name_prefix}-karpenter-node-profile"
  role = aws_iam_role.karpenter_node.name
}

