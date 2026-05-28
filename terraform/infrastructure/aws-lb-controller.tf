# ----------------------------------------------------------------------
# IAM Policy: fetch from official AWS GitHub repo
# ----------------------------------------------------------------------
data "http" "aws_lb_controller_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.13.1/docs/install/iam_policy.json"
}

resource "aws_iam_policy" "lb_controller" {
  name        = "AWSLoadBalancerControllerPolicy"
  description = "Policy for AWS Load Balancer Controller"
  policy      = data.http.aws_lb_controller_policy.response_body
}

# ----------------------------------------------------------------------
# IAM Role with trust policy for EKS Pod Identity
# ----------------------------------------------------------------------

resource "aws_iam_role" "lb_controller" {
  name = "aws-lb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "pods.eks.amazonaws.com" 
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lb_controller" {
  role       = aws_iam_role.lb_controller.name
  policy_arn = aws_iam_policy.lb_controller.arn
}

# ----------------------------------------------------------------------
# EKS Pod Identity Association (links service account to IAM role)
# ----------------------------------------------------------------------
resource "aws_eks_pod_identity_association" "lb_controller" {
  cluster_name    = aws_eks_cluster.main.name 
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.lb_controller.arn
}