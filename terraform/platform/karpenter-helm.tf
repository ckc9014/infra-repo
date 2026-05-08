resource "helm_release" "karpenter" {
  name             = "karpenter"
  namespace        = "kube-system"
  create_namespace = false 

  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "1.10.0"

  
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