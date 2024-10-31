# GKE Cluster
resource "google_container_cluster" "primary" {
  name     = "chaos-test-cluster"
  location = var.zone
  
  # Remove default node pool
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
}

# Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "chaos-test-node-pool"
  cluster    = google_container_cluster.primary.name
  location   =  google_container_cluster.primary.location
  node_count = 2

  node_config {
    machine_type = "e2-micro"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

# VPC
resource "google_compute_network" "vpc" {
  name                    = "chaos-test-vpc"
  auto_create_subnetworks = false
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "chaos-test-subnet"
  ip_cidr_range = "10.0.0.0/16"
  network       = google_compute_network.vpc.name
  region        = var.region
}

