# terraform/outputs.tf
output "kubernetes_cluster_name" {
  value = google_container_cluster.primary.name
}

output "kubernetes_cluster_host" {
  value = google_container_cluster.primary.endpoint
}

output "chaos_mesh_dashboard_service" {
  value = "Access the Chaos Mesh dashboard by running: kubectl port-forward svc/chaos-dashboard -n chaos-testing 2333:2333"
}