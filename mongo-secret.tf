
resource "kubernetes_secret" "mongo-secret" {
  metadata {
    name = "${local.infra_env}-mongo-secret"
  }
  data = {
    "username" = base64encode("root")
    "password" = base64encode("example")
  }
}