resource "kubernetes_config_map" "mongo-config" {
  metadata {
    name = "${local.infra_env}-mongo-config"
  }

  data = {
    "mongo-url" = kubernetes_service.mongo-service.metadata[0].name
  }
}