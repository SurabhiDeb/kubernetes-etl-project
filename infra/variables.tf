variable "project_id" {
description = "GCP project id"
type = string
}

variable "region" {
description = "GCP region"
type = string
default = "us-central1"
}

variable "zone" {
description = "GCP zone"
type = string
default = "us-central1-a"
}

variable "cluster_name" {
description = "GKE cluster name"
type = string
default = "etl-cluster"
}

variable "artifact_location" {
description = "Artifact Registry location (same as region recommended)"
type = string
default = "us-central1"
}

variable "node_count" {
description = "Number of nodes in default node pool"
type = number
default = 1
}

variable "node_machine_type" {
description = "Machine type for nodes"
type = string
default = "e2-medium"
}