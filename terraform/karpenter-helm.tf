# terraform/karpenter-helm.tf

resource "helm_release" "karpenter" {
  name             = "karpenter"
  namespace        = "kube-system"
  create_namespace = false # kube-system already exists

  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "v1.2.0"

  # Ensure the cluster is ready and Helm provider is configured
  depends_on = [module.eks]

  set = [
    {
      name  = "serviceAccount.create"
      value = "true"
    },
    {
      name  = "serviceAccount.name"
      value = "karpenter"
    },
    {
      name  = "settings.clusterName"
      value = module.eks.cluster_name
    },
    {
      name  = "settings.clusterEndpoint"
      value = module.eks.cluster_endpoint
    },
    {
      name  = "settings.interruptionQueue"
      value = "" # optional, can be set later
    },
    {
      name  = "webhook.enabled"
      value = "true"
    }
  ]
}