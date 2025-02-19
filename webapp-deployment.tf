
# locals {
#   infra_env = terraform.workspace
# }


# variable "node_port" {
#     type = number
#     description = "Holds container port for nodegroups pods"
# }

resource "kubernetes_service" "webapp-service" {
  metadata {
    name = "${local.infra_env}-webapp-deployment"
  }
  spec {
    selector = {
      app = kubernetes_deployment.webapp-deployment.metadata[0].labels.app
    }
    session_affinity = "ClientIP"
    type = "NodePort"
    
    port {
      port        = 27017
      target_port = 27017
      node_port = var.node_port
    }

  }
}

resource "kubernetes_deployment" "webapp-deployment" {
  metadata {
    name = "${local.infra_env}-webapp"
    labels = {
      app = "webapp"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "webapp"
      }
    }

    template {
      metadata {
        labels = {
          app = "webapp"
        }
      }

      spec {
        container {
          image = "nanajanashia/k8s-demo-app:v1.0"
          name  = "webapp"
          port {
            container_port = 3000
          }
          env {
          name = "USER_NAME"
          value = kubernetes_secret.mongo-secret.data.username
          }
          env {
          name = "USER_PWD"
          value = kubernetes_secret.mongo-secret.data.password
          }
          env {
          name = "DB_URL"
          value = kubernetes_config_map.mongo-config.data.mongo-url
          }
        }

      }
    }
  }
}