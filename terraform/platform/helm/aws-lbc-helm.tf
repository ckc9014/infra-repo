resource "helm_release" "aws_lb_controller" {
  name             = "aws-load-balancer-controller"
  namespace        = "kube-system"
  create_namespace = false

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.13.1"   # use a compatible version

  values = [local.aws_lb_controller_values]
}