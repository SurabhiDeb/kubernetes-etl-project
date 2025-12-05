1) Create folder infra/ and paste each file above into the folder using the exact filenames:
- versions.tf
- variables.tf
- main.tf
- outputs.tf

2) Initialize Terraform:
cd infra
terraform init

3) Plan & apply (replace <PROJECT_ID> with your value):
terraform plan -var="project_id=kubernetes-project-480307"
terraform apply -var="project_id=kubernetes-project-480307" -auto-approve

4) After apply completes, get cluster credentials for kubectl:
gcloud container clusters get-credentials etl-cluster --zone us-central1-a --project kubernetes-project-480307

5) Push your Docker image to Artifact Registry (example):
gcloud auth configure-docker us-central1-docker.pkg.dev --quiet
docker tag gcr.io/kubernetes-project-480307/etl-worker:dev us-central1-docker.pkg.dev/kubernetes-project-480307/etl-repo/etl-worker:latest
docker push us-central1-docker.pkg.dev/kubernetes-project-480307/etl-repo/etl-worker:latest

6) Apply Kubernetes manifests (CronJob, Secrets) using kubectl.

Notes:
- This Terraform creates a simple cluster and an artifact registry repository. For production, add VPC, private clusters, node pools, autoscaling, and Workload Identity fully configured.