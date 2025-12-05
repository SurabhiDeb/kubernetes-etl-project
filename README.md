# Kubernetes ETL Pipeline (GKE + BigQuery + Terraform + CI/CD)

This project implements a **fully automated ETL data pipeline** running on **Google Kubernetes Engine (GKE)**.
It extracts raw CSV data, transforms it using a Python ETL script, and loads the processed output into **Google BigQuery** — all orchestrated via **Kubernetes CronJobs** and shipped using **GitHub Actions CI/CD**.

The entire system is **containerized, infrastructure-as-code driven, scalable, secure, and fully automated**.

## Technology Stack

| Component | Description |
|----------|-------------|
| **Python** | ETL logic (extract → transform → load) |
| **Docker** | Containerized ETL worker |
| **Terraform** | Provisioning of GCP infrastructure |
| **GKE (Google Kubernetes Engine)** | Run ETL worker jobs |
| **Workload Identity** | Secure identity-based auth (no secrets in cluster) |
| **BigQuery** | Storage of processed ETL outputs |
| **Kubernetes CronJob** | Scheduled ETL execution |
| **GitHub Actions** | CI/CD (build → push → deploy) |

## Project Structure

```
kubernetes-etl-project/
│
├── etl_worker/
│   ├── etl_worker.py
│   ├── Dockerfile
│   ├── requirements.txt
│   └── data/
│       └── input.csv
│
├── infra/
│   ├── main.tf
│   ├── variables.tf
│   ├── versions.tf
│   ├── outputs.tf
│   └── README-TERRAFORM.md
│
├── etl_cronjob.yaml
│
└── .github/
    └── workflows/
        └── cicd.yaml
```

## ETL Workflow 

### **1. Extract**
Reads CSV input file.

### **2. Transform**
- Parses raw data  
- Groups by category  
- Aggregates values  
- Produces daily summary output

### **3. Load**
Loads results into BigQuery table:

```
<PROJECT_ID>.etl_dataset.daily_summary
```

### Example Output

| summary_date | category | total_amount |
|--------------|----------|--------------|
| 2025-12-05   | Grocery  | 152.60       |

---

## Docker — Build & Test Locally

### Build image
```bash
docker build -t gcr.io/<PROJECT_ID>/etl-worker:dev -f etl_worker/Dockerfile etl_worker/
```

### Run locally
```bash
docker run --rm   -v "$(pwd)/etl_worker/data:/data/raw"   -v "$HOME/.config/gcloud:/root/.config/gcloud"   -e BQ_PROJECT=<PROJECT_ID>   -e BQ_DATASET=etl_dataset   -e BQ_TABLE=daily_summary   gcr.io/<PROJECT_ID>/etl-worker:dev
```

---

## Infrastructure — Terraform

Terraform provisions:

- GKE Cluster  
- Artifact Registry  
- BigQuery Dataset + Config  
- Service Accounts  
- Workload Identity binding  

### Deploy:
```bash
cd infra
terraform init
terraform apply -var="project_id=<PROJECT_ID>"
```

---

## Kubernetes Deployment

```bash
kubectl apply -f etl_cronjob.yaml
```

View logs:
```bash
kubectl logs -n etl <pod>
```

---

## GitHub Actions CI/CD

Workflow: `.github/workflows/cicd.yaml`

Pipeline does:
1. Auth to GCP  
2. Build Docker image  
3. Push to Artifact Registry  
4. Connect to GKE  
5. Apply CronJob  

### Required GitHub Secrets

| Secret | Description |
|--------|-------------|
| **GCP_SA_KEY** | Base64 encoded JSON key |
| **GCP_PROJECT_ID** | GCP project ID |

---

## Workload Identity

Kubernetes SA:

```
etl-worker-sa
```

mapped to GCP SA:

```
etl-worker-sa@<PROJECT_ID>.iam.gserviceaccount.com
```

---

## Verify BigQuery Data

```bash
bq query --use_legacy_sql=false '
SELECT * FROM `<PROJECT_ID>.etl_dataset.daily_summary`
ORDER BY summary_date DESC'
```

---

## Features Completed
- Python ETL
- Docker container
- Terraform infra
- GKE deployment
- BigQuery integration
- Workload identity
- CronJob automation
- GitHub Actions CI/CD

## Future Enhancements
- Add monitoring (Grafana/Prometheus)
- Add pytest unit tests
- Data quality checks
- Cloud Logging dashboards
