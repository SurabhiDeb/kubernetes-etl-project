provider "google" {
project = var.project_id
region = var.region
zone = var.zone
}

# Enable required APIs
resource "google_project_service" "container_api" {
project = var.project_id
service = "container.googleapis.com"
}

resource "google_project_service" "artifact_api" {
project = var.project_id
service = "artifactregistry.googleapis.com"
}

resource "google_project_service" "bigquery_api" {
project = var.project_id
service = "bigquery.googleapis.com"
}

resource "google_project_service" "iam_api" {
project = var.project_id
service = "iam.googleapis.com"
}

# Artifact Registry for Docker images
resource "google_artifact_registry_repository" "repo" {
project = var.project_id
location = var.artifact_location
repository_id = "etl-repo"
description = "Artifact Registry for ETL Docker images"
format = "DOCKER"
}

# Service account for GKE workloads to interact with BigQuery
resource "google_service_account" "etl_sa" {
account_id = "etl-worker-sa"
display_name = "ETL Worker Service Account"
}

# Grant BigQuery Data Editor to the service account
resource "google_project_iam_member" "bq_data_editor" {
project = var.project_id
role = "roles/bigquery.dataEditor"
member = "serviceAccount:${google_service_account.etl_sa.email}"
}

# Create GKE cluster with Workload Identity enabled (recommended)
resource "google_container_cluster" "gke_cluster" {
name = var.cluster_name
location = var.zone

remove_default_node_pool = false
initial_node_count = var.node_count

node_config {
machine_type = var.node_machine_type
oauth_scopes = [
"https://www.googleapis.com/auth/cloud-platform",
]
}

workload_identity_config {
workload_pool = "${var.project_id}.svc.id.goog"
}

# Basic cluster auto-upgrade/auto-repair settings (optional)
maintenance_policy {
daily_maintenance_window {
start_time = "03:00"
}
}
}

resource "google_iam_workload_identity_pool" "gke_pool" {
  workload_identity_pool_id = "${var.project_id}-pool"
  display_name = "GKE Workload Identity Pool"
  disabled = false
}

# Optional: add IAM binding so GKE nodes can impersonate service accounts via Workload Identity
# (This binding allows Kubernetes service accounts to act as the Google service account.)
resource "google_service_account_iam_member" "sa_workload_identity_binding" {
  service_account_id = google_service_account.etl_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.gke_pool.name}/attribute.project_id/${var.project_id}"
}


# (Optional) Create a Kubernetes namespace + k8s service account via Terraform's kubernetes provider
# If you want Terraform to fully configure the in-cluster K8s resources you can add the kubernetes provider
# after obtaining the kubeconfig. For beginners, we will output the cluster access command and let you apply
# Kubernetes manifests with kubectl.