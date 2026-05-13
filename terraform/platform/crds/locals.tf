locals {
   argocd_values_file = file("${path.module}/values/argocd/values.yaml")
}