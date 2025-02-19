resource "kubernetes_service" "mongo-service" {
  metadata {
    name = "${local.infra_env}-mongo-service"
  }
  spec {
    selector = {
      app = kubernetes_deployment.mongo-deployment.metadata[0].labels.app
    }
    session_affinity = "ClientIP"
    port {
      port        = 27017
      target_port = 27017
    }
  }
}

resource "kubernetes_deployment" "mongo-deployment" {
  metadata {
    name = "${local.infra_env}-mongo-deployment"
    labels = {
      app = "mongo"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "mongo"
      }
    }

    template {
      metadata {
        labels = {
          app = "mongo"
        }
      }

      spec {
        container {
          image = "mongo:8.0"
          name  = "mongodb"
          port {
            container_port = 27017
          }
        env {
          name = "MONGO_INITDB_ROOT_USERNAME"
          value = kubernetes_secret.mongo-secret.data.username
          }
        env {
          name = "MONGO_INITDB_ROOT_PASSWORD"
          value = kubernetes_secret.mongo-secret.data.password
          }
        }
      }
    }
  }
}