output "cluster_name" {
value = google_container_cluster.gke_cluster.name
}

output "cluster_endpoint" {
value = google_container_cluster.gke_cluster.endpoint
}

output "artifact_repo" {
value = google_artifact_registry_repository.repo.id
}

output "service_account_email" {
value = google_service_account.etl_sa.email
}

output "workload_pool" {
value = "${var.project_id}.svc.id.goog"
}