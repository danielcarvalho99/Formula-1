# Formula 1 data extraction

A data pipeline that extracts Formula 1 race data from an API, stores it in Google Cloud Storage, and transforms it into a structured data warehouse using BigQuery.

## Architecture

The project follows a **medallion architecture** with 3 layers:

```
API → GCS (Bronze) → BigQuery Silver → BigQuery Gold
```

- **Bronze** — Raw data landed in GCS as CSV files, exposed via BigQuery external tables
- **Silver** — Native BigQuery tables with cleaned, typed, and normalized data
- **Gold** — Aggregated, business-ready tables for dashboards and analysis

## GCP Resources

- **GCS Bucket** — `bucket-f1-data` — stores raw CSV files partitioned by season and round
- **BigQuery Dataset** — `f1_bronze` — external tables over GCS
- **BigQuery Dataset** — `f1_silver` — native tables with transformed data
- **BigQuery Dataset** — `f1_dimensions` — shared dimensions (time, drivers, teams, events)

## Tables

### Bronze (`f1_bronze`) — External Tables

| Table | Description |
|---|---|
| `races` | Raw race results loaded from GCS CSV files |

### Silver (`f1_silver`) — Native Tables

| Table | Description |
|---|---|
| `dim_driver` | Driver dimension |
| `dim_team` | Team dimension |
| `dim_event` | Event dimension |
| `dim_time` | Time dimension |
| `fact_races` | Race results fact table |

### Gold (`f1_gold`) — Native Tables

| Table | Description |
|---|---|
| `driver_rankings_by_year` | Season standings per driver |
| `teams_rankings_by_year` | Season standings per team |
| `drivers_historical_ranking` | All-time standings for driver |
| `teams_historical_ranking` | All-time standings for team |

## Setup

### Prerequisites

- python >= 3.12
- uv
- GCP project with billing enabled
- Service account with Storage Admin and BigQuery Admin roles

### Install dependencies

```bash
uv add google-cloud-storage
```

### Authentication

Place your service account JSON key in the project root and set the path in the ingestion script.

## Data Ingestion

The ingestion script fetches data from the Formula 1 API and uploads it to GCS:

```bash
python main.py
```

Files are stored following the pattern:

```
gs://bucket-f1-data/bronze/races/{year}_{round}_R.csv
```
