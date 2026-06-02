resource "helm_release" "aws_lb_controller" {
  name             = "aws-load-balancer-controller"
  namespace        = "kube-system"
  create_namespace = false

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "3.2.2"

  values = [local.aws_lb_controller_values]
  atomic  = true
  wait   = true
  timeout = 80
}