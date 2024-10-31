variable "region" {
  description = "A deployment area for Google Cloud resources region"
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "The name of the GKE cluster."
  type        = string
  default     = "chaos-test-cluster"
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "us-central1-f"
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "tribal-flux-435217-i0"
}