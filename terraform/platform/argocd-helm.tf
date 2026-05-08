resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "7.7.18"

  # Ensure the EKS cluster is ready before installing ArgoCD
  depends_on = [module.eks]

  set = [
    {
      name  = "server.insecure"
      value = "true"
    },
    {
      name  = "server.resources.requests.cpu"
      value = "500m"
    },
    {
      name  = "server.resources.requests.memory"
      value = "512Mi"
    },
    {
      name  = "server.config.accounts.kubectl.enable"
      value = "true"
    }
  ]
}