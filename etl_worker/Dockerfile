FROM python:3.10-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY etl_worker.py .

# Where the job expects CSV; in Kubernetes mount a PVC here or use container image for demo
VOLUME ["/data/raw"]
CMD ["python", "etl_worker.py"]
COPY data/input.csv /data/raw/input.csv
