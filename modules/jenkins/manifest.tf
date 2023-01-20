resource "kubernetes_namespace" "jenkins_namespace" {
  metadata {
    name = var.jenkins_controller_namespace
  }
}

resource "kubernetes_namespace" "agent_namespace" {
  metadata {
    name = local.agent_namespace
  }
  count = var.create_agent_namespace ? 1 : 0
}

resource "kubernetes_secret" "docker_credentials" {
  metadata {
    name      = "ocirsecret"
    namespace = kubernetes_namespace.jenkins_namespace.metadata.0.name
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.registry_server}" = {
          "username" = var.registry_username
          "password" = var.registry_password
          "email"    = var.registry_email
          "auth"     = base64encode("${var.registry_username}:${var.registry_password}")
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}

resource "kubernetes_secret" "jenkins_secrets" {
  metadata {
    name      = "jenkins-secrets"
    namespace = kubernetes_namespace.jenkins_namespace.metadata.0.name
  }

  data = {
    "admin_password" = var.jenkins_admin_password
  }
}

resource "kubernetes_config_map" "jenkins_config" {
  metadata {
    name      = "jenkins-config"
    namespace = kubernetes_namespace.jenkins_namespace.metadata.0.name
  }

  data = {
    "jenkins-config.yaml" = templatefile("${path.root}/templates/jenkins-config.yaml", {
        admin_password = "$${admin_password}"
        admin_username = var.jenkins_admin_username
        casc_configs = "jenkins-config"
        casc_secrets = kubernetes_secret.jenkins_secrets.metadata.0.name
        jenkins_service_name = var.jenkins_service_name
        jenkins_service_port = var.jenkins_service_port
        controller_namespace = kubernetes_namespace.jenkins_namespace.metadata.0.name
        agent_default_namespace = local.agent_namespace
        max_concurrent_agents = var.max_concurrent_agents
        })
  }

}

resource "kubernetes_service_account" "jenkins_sa" {
  metadata {
    name      = "jenkins-sa"
    namespace = kubernetes_namespace.jenkins_namespace.metadata.0.name
  }

}


resource "kubernetes_cluster_role" "jenkins_cluster_role" {
  metadata {
    name = "jenkins-cluster-role-${substr(sha256(var.jenkins_service_name), 0, 5)}"
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/exec"]
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/log"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "watch", "list"]   # watch and list are required for kubernetes-credentials-provider
  }

}

resource "kubernetes_cluster_role_binding" "jenkins_cluster_role_binding" {
  metadata {
    name = "jenkins-cluster-role-binding-${substr(sha256(var.jenkins_service_name), 0, 5)}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.jenkins_cluster_role.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.jenkins_sa.metadata.0.name
    namespace = kubernetes_namespace.jenkins_namespace.metadata.0.name
  }

}

resource "kubernetes_storage_class" "bv_encrypted_storage_class" {
  storage_provisioner = "blockvolume.csi.oraclecloud.com"
  metadata {
    name = "bv-encrypted-storage-class"
  }

  parameters = {
    attachment-type = "paravirtualized"
  }

  reclaim_policy = "Delete"

  volume_binding_mode = "WaitForFirstConsumer"

}

resource "kubernetes_persistent_volume_claim" "jenkinspvc" {
  metadata {
    name      = "jenkinspvc"
    namespace = kubernetes_namespace.jenkins_namespace.metadata.0.name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "50Gi"
      }
    }
    storage_class_name = kubernetes_storage_class.bv_encrypted_storage_class.metadata.0.name
  }
  wait_until_bound = false
}

resource "kubernetes_deployment" "jenkins_deployment" {
  metadata {
    name      = "jenkins"
    namespace = kubernetes_namespace.jenkins_namespace.metadata.0.name
    labels = {
      name = "jenkins"
    }
  }
  spec {
    replicas = "1"
    selector {
      match_labels = {
        name = "jenkins"
      }
    }
    template {
      metadata {
        labels = {
          name = "jenkins"
        }
      }
      spec {
        image_pull_secrets {
          name = kubernetes_secret.docker_credentials.metadata.0.name
        }
        service_account_name = kubernetes_service_account.jenkins_sa.metadata.0.name
        security_context {
          fs_group = "1000"
          run_as_user = "1000"
        }
        container {
          name = "jenkins"
          image = "${var.image}:${var.tag}@${local.digest}"
          image_pull_policy = "Always"
          resources {
            limits = {
              memory = "2Gi"
              cpu = "1000m"
            }
            requests = {
              memory = "500Mi"
              cpu = "500m"
            }
          }
          port {
            name = "httpport"
            container_port = 8080
          }
          port {
            name = "jnlpport"
            container_port = 50000
          }
          liveness_probe {
            http_get {
              path = "/login"
              port = "8080"
            }
            initial_delay_seconds = 90
            period_seconds = 10
            timeout_seconds = 5
            failure_threshold = 5
          }
          readiness_probe {
            http_get {
              path = "/login"
              port = "8080"
            }
            initial_delay_seconds = 60
            period_seconds = 10
            timeout_seconds = 5
            failure_threshold = 3
          }
          env {
            name  = "CASC_JENKINS_CONFIG"
            value = "/var/jenkins_config/jenkins-config.yaml"
          }
          env {
            name = "LIMITS_MEMORY"
            value_from {
              resource_field_ref {
                resource = "limits.memory"
                divisor  = "1Mi"
              }
            }
          }
          env {
            name  = "JAVA_OPTS"
            value = "-Xmx$(LIMITS_MEMORY)m -XshowSettings:vm -Dhudson.slaves.NodeProvisioner.initialDelay=0 -Dhudson.slaves.NodeProvisioner.MARGIN=50 -Dhudson.slaves.NodeProvisioner.MARGIN0=0.85 -Djenkins.install.runSetupWizard=false"
          }
          env {
            name  = "SECRETS"
            value = "/secrets/jenkins"
          }
          volume_mount {
            name       = "jenkins-home"
            mount_path = "/var/jenkins_home"
          }
          volume_mount {
            name       = "jenkins-config"
            mount_path = "/var/jenkins_config"
          }
          volume_mount {
            name       = "jenkins-secrets"
            mount_path = "/secrets/jenkins"
            read_only  = true
          }
        }
        volume {
          name = "jenkins-home"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.jenkinspvc.metadata.0.name
          }
        }
        volume {
          name = "jenkins-config"
          config_map {
            name = kubernetes_config_map.jenkins_config.metadata.0.name
          }
        }
        volume {
          name = "jenkins-secrets"
          secret {
            secret_name = kubernetes_secret.jenkins_secrets.metadata.0.name
          }
        }
      }
    }
  }
}


resource "kubernetes_service" "jenkins_service" {
  metadata {
    name      = var.jenkins_service_name
    namespace = kubernetes_namespace.jenkins_namespace.metadata.0.name
    annotations = {
      "service.beta.kubernetes.io/oci-load-balancer-shape" = "flexible"
      "service.beta.kubernetes.io/oci-load-balancer-shape-flex-min" = "10"
      "service.beta.kubernetes.io/oci-load-balancer-shape-flex-max" = "10"
      "jenkins-version" = "${local.digest}"
    }
    labels = {
      "name" = "jenkins"
    }
  }
  spec {
    type = "LoadBalancer"
    port {
      name        = "httpport"
      port        = var.jenkins_service_port
      target_port = "8080"
      protocol    = "TCP"
    }
    port {
      name     = "jnlpport"
      port     = 50000
      protocol = "TCP"
    }
    selector = {
      "name" = "jenkins"
    }
  }
  depends_on = [
    kubernetes_deployment.jenkins_deployment
  ]
}



# resource "kubernetes_ingress_v1" "jenkins_ingress" {
#   metadata {
#     name      = "jenkins"
#     namespace = kubernetes_namespace.jenkins_namespace.metadata.0.name
#     annotations = {
#       "nginx.ingress.kubernetes.io/proxy-body-size"         = "50m"
#       "nginx.ingress.kubernetes.io/proxy-request-buffering" = "off"
#       "ingress.kubernetes.io/proxy-body-size"               = "50m"
#       "ingress.kubernetes.io/proxy-request-buffering"       = "off"
#     }
#   }
#   spec {
#     ingress_class_name = "nginx"
#     rule {
#       http {
#         path {
#           path = "/"
#           backend {
#             service {
#               name = "jenkins"
#               port {
#                 number = 80
#               }
#             }
#           }
#         }
#       }
#     }
#   }

# }

