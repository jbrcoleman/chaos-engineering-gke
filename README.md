# GKE Chaos Engineering Project

This project demonstrates chaos engineering practices on a Google Kubernetes Engine (GKE) cluster running a Golang microservice. It uses Terraform for infrastructure provisioning and Chaos Mesh for chaos experiments.

## Project Structure

```plaintext
.
├── terraform/           # Infrastructure and Deployment Code
│   ├── main.tf         # Main Terraform configuration
│   ├── variables.tf    # Input variables
│   └── outputs.tf      # Output values
└── app/                # Application code
    ├── main.go        # Golang service
    └── Dockerfile     # Container image definition
```

## Setup Instructions

### 1. Configure Google Cloud

```bash
# Set your project ID
export PROJECT_ID="your-project-id"
gcloud config set project $PROJECT_ID

# Enable required APIs
gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com
```

### 2. Build and Push Application

```bash
cd app

# Build container image
docker build -t gcr.io/$PROJECT_ID/go-service:latest .

# Configure Docker for GCR
gcloud auth configure-docker

# Push image to GCR
docker push gcr.io/$PROJECT_ID/go-service:latest
```

### 3. Deploy Everything with Terraform

```bash
cd terraform

# Initialize Terraform and download providers
terraform init

# Review planned changes
terraform plan -var="project_id=$PROJECT_ID"

# Apply changes
terraform apply -var="project_id=$PROJECT_ID"
```

This single Terraform deployment will:
- Create the GKE cluster and VPC
- Install Chaos Mesh using Helm
- Deploy the Go service
- Configure all chaos experiments

## Understanding the Deployment

### Infrastructure Components

1. **GKE Cluster**
   - 3-node cluster using e2-medium instances
   - Custom VPC network
   - Regional deployment for high availability

2. **Chaos Mesh Installation**
   - Installed via Helm in the chaos-testing namespace
   - Includes dashboard for experiment visualization
   - Configured with best practices for GKE

3. **Go Service Deployment**
   - 3 replicas for high availability
   - Health checks and readiness probes
   - LoadBalancer service type for external access

### Chaos Experiments

All experiments are automatically deployed and configured by Terraform:

1. **Pod Failure Test**
   - Randomly terminates pods
   - Runs every 5 minutes
   - Affects one pod at a time
   - Duration: 30 seconds

2. **Network Delay Test**
   - Introduces 100ms network latency
   - Runs every 5 minutes
   - Affects all service pods
   - Duration: 30 seconds

3. **CPU Stress Test**
   - Induces CPU pressure (20% load)
   - Runs every 5 minutes
   - Affects one pod at a time
   - Duration: 30 seconds

## Monitoring and Management

### Accessing Chaos Mesh Dashboard

```bash
# Forward the dashboard port
kubectl port-forward svc/chaos-dashboard -n chaos-testing 2333:2333

# Access the dashboard at http://localhost:2333
```

### Viewing Experiments

```bash
# List all chaos experiments
kubectl get podchaos,networkchaos,stresschaos

# Get detailed information
kubectl describe podchaos pod-failure-test
```

### Monitoring Application

```bash
# Get service endpoint
kubectl get service go-service

# View application logs
kubectl logs -l app=go-service

# Check pod status
kubectl get pods -l app=go-service
```

## Modifying the Setup

### Adjusting Chaos Experiments

Edit the chaos experiment configurations in `terraform/main.tf`:

```hcl
resource "kubernetes_manifest" "pod_failure_chaos" {
  manifest = {
    spec = {
      duration  = "30s"  # Modify duration
      scheduler = {
        cron = "@every 5m"  # Modify frequency
      }
    }
  }
}
```

Then apply the changes:
```bash
terraform apply -var="project_id=$PROJECT_ID"
```

### Scaling the Application

Modify the replicas in the deployment configuration:

```hcl
resource "kubernetes_deployment" "go_service" {
  spec {
    replicas = 5  # Change number of replicas
  }
}
```

## Clean Up

To destroy all resources:

```bash
cd terraform
terraform destroy -var="project_id=$PROJECT_ID"
```

This will remove:
- All chaos experiments
- The Go service deployment
- Chaos Mesh installation
- GKE cluster and associated resources
- VPC network and subnets

## Best Practices

1. **Infrastructure as Code**
   - Keep all configurations in version control
   - Use variables for environment-specific values
   - Document all configuration changes

2. **Chaos Engineering**
   - Start with small-scale experiments
   - Monitor application behavior closely
   - Gradually increase experiment complexity
   - Always have a rollback plan

3. **Monitoring and Observability**
   - Set up proper monitoring before running experiments
   - Define clear success/failure criteria
   - Keep logs for post-mortem analysis

## Troubleshooting

### Common Issues

1. **Terraform Provider Issues**
   ```bash
   # Reinitialize providers
   terraform init -upgrade
   ```

2. **GKE Connection Issues**
   ```bash
   # Verify cluster access
   gcloud container clusters get-credentials chaos-test-cluster --region=us-central1
   ```

3. **Chaos Mesh Dashboard Not Accessible**
   ```bash
   # Check pod status
   kubectl get pods -n chaos-testing
   
   # Check service status
   kubectl get svc -n chaos-testing

### Links

- Review [Chaos Mesh documentation](https://chaos-mesh.org/docs/)
- Check [GKE troubleshooting guide](https://cloud.google.com/kubernetes-engine/docs/troubleshooting)