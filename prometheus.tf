
resource "kubernetes_namespace" "prometheus" {
    metadata {
        name = "${local.infra_env}-prometheus"
    }
}
resource "helm_release" "prometheus-helm" {
  count = local.infra_env == "default" ? 1 : 0
  name       = "${local.infra_env}-prometheus-helm"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  namespace  = kubernetes_namespace.prometheus.metadata[0].name
  set {
    name = "type"
    value = "NodePort"
  }
  set {
    name  = "persistence.enabled"
    value = "true" 
  }

  set {
    name  = "persistence.storageClass"
    value = "gp2"  # Specify your storage class here
  }

}