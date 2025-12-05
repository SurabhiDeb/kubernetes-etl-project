# This is a simple ETL worker that will: read CSV, aggregate bt category, write to BigQuery
import os
import pandas as pd
from datetime import datetime
from google.cloud import bigquery

# Config
CSV_PATH = os.environ.get("CSV_PATH", "/data/raw/input.csv")
BQ_PROJECT = os.environ.get("BQ_PROJECT", "<your-project>")
BQ_DATASET = os.environ.get("BQ_DATASET", "etl_dataset")
BQ_TABLE = os.environ.get("BQ_TABLE", "daily_summary")


def transform(df: pd.DataFrame) -> pd.DataFrame:
    df = df.rename(columns=lambda c: c.strip())
    df["amount"] = pd.to_numeric(df["amount"], errors="coerce").fillna(0)
    summary = df.groupby("category", as_index=False)["amount"].sum()
    summary["summary_date"] = datetime.utcnow().date().isoformat()
    summary = summary.rename(columns={"amount": "total_amount"})
    return summary[["summary_date", "category", "total_amount"]]


def load_to_bigquery(df: pd.DataFrame):
    client = bigquery.Client(project=BQ_PROJECT)
    dataset_ref = client.dataset(BQ_DATASET)
    table_ref = dataset_ref.table(BQ_TABLE)

    job_config = bigquery.LoadJobConfig(
        write_disposition=bigquery.WriteDisposition.WRITE_APPEND,
        autodetect=True,
    )
    job = client.load_table_from_dataframe(
        df, table_ref, job_config=job_config)
    job.result()  # Wait for the job
    print(f"Loaded {len(df)} rows to {BQ_PROJECT}.{BQ_DATASET}.{BQ_TABLE}")


def main():
    if not os.path.exists(CSV_PATH):
        print(f"CSV not found at {CSV_PATH}")
        return

    df = pd.read_csv(CSV_PATH)
    out = transform(df)
    load_to_bigquery(out)
    print("ETL finished.")


if __name__ == "__main__":
    main()
