provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_persistent_volume_claim" "example" {
  metadata {
    name = var.pvc_name
  }
  spec {
    storage_class_name = "manual"
    access_modes       = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume" "example" {
  metadata {
    name = var.pv_name
  }
  spec {
    storage_class_name = "manual"
    capacity = {
      storage = "10Gi"
    }
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      nfs {
        path   = "/data"
        server = "worker-node"
      }
    }
  }
}

resource "kubernetes_deployment_v1" "my-app" {
  metadata {
    name = var.deployment_name_my_app
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = var.deployment_name_my_app
      }
    }

    template {
      metadata {
        labels = {
          app = var.deployment_name_my_app
        }
      }

      spec {
        container {
          name  = var.deployment_name_my_app
          image = "mysql:5.6"
          env {
            name  = "MYSQL_ROOT_PASSWORD"
            value = "terraform"
          }
          env {
            name  = "MYSQL_DATABASE"
            value = "task"
          }
          volume_mount {
            name       = "test"
            mount_path = "/data"
          }
        }

        volume {
          name = "test"
          persistent_volume_claim {
            claim_name = var.pvc_name
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment_v1" "wordpress-app" {
  metadata {
    name = var.deployment_name_wordpress
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = var.deployment_name_wordpress
      }
    }

    template {
      metadata {
        labels = {
          app = var.deployment_name_wordpress
        }
      }

      spec {
        container {
          name  = var.deployment_name_wordpress
          image = "wordpress:latest"
          env {
            name  = "WORDPRESS_DB_NAME"
            value = var.deployment_name_my_app
          }
          env {
            name  = "WORDPRESS_DB_USER"
            value = "root"
          }
          env {
            name  = "WORDPRESS_DB_PASSWORD"
            value = "terraform"
          }
          volume_mount {
            name       = "wordpress-data"
            mount_path = "/var/www/html"
          }
        }

        volume {
          name = "wordpress-data"
          persistent_volume_claim {
            claim_name = var.pvc_name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "wordpress-service" {
  metadata {
    name = var.service_name_wordpress
  }

  spec {
    selector = {
      app = var.deployment_name_wordpress
    }

    type = "NodePort"

    port {
      port        = 80
      target_port = 80
      node_port   = 31000
    }
  }
}
