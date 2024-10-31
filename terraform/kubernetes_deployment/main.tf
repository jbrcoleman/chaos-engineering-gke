# Kubernetes Deployment
resource "kubernetes_deployment" "go_service" {
  metadata {
    name = "go-service"
    labels = {
      app = "go-service"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "go-service"
      }
    }

    template {
      metadata {
        labels = {
          app = "go-service"
        }
      }

      spec {
        container {
          image = "gcr.io/${var.project_id}/go-service:latest"
          name  = "go-service"

          port {
            container_port = 8080
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 8080
            }
            initial_delay_seconds = 5
            period_seconds       = 10
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 8080
            }
            initial_delay_seconds = 15
            period_seconds       = 20
          }
        }
      }
    }
  }

  depends_on = [
    helm_release.chaos_mesh
  ]
}

# Kubernetes Service
resource "kubernetes_service" "go_service" {
  metadata {
    name = "go-service"
  }

  spec {
    selector = {
      app = "go-service"
    }

    port {
      port        = 80
      target_port = 8080
    }

    type = "LoadBalancer"
  }

  depends_on = [
    kubernetes_deployment.go_service
  ]
}

# Chaos Experiments as separate Kubernetes manifests
resource "kubernetes_manifest" "pod_failure_chaos" {
   manifest =  yamldecode(file("${path.module}/../../kubernetes/chaos/pod-failure.yaml"))

  depends_on = [
    helm_release.chaos_mesh,
    kubernetes_deployment.go_service
  ]
}

resource "kubernetes_manifest" "network_delay_chaos" {
  manifest =  yamldecode(file("${path.module}/../../kubernetes/chaos/network-delay.yaml"))

  depends_on = [
    helm_release.chaos_mesh,
    kubernetes_deployment.go_service
  ]
}

resource "kubernetes_manifest" "cpu_stress_chaos" {
  manifest =  yamldecode(file("${path.module}/../../kubernetes/chaos/cpu-stress.yaml"))

  depends_on = [
    helm_release.chaos_mesh,
    kubernetes_deployment.go_service
  ]
}

# Chaos Mesh Installation
resource "helm_release" "chaos_mesh" {
  name       = "chaos-mesh"
  repository = "https://charts.chaos-mesh.org"
  chart      = "chaos-mesh"
  namespace  = "chaos-testing"
  version    = "2.6.0"

  create_namespace = true

  set {
    name  = "dashboard.create"
    value = "true"
  }

}

# Kubernetes namespace
resource "kubernetes_namespace" "chaos_testing" {
  metadata {
    name = "chaos-testing"
  }
}