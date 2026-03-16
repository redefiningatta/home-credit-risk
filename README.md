# Home Credit Risk — Production Analytics Platform

A production-grade credit risk analytics platform built on the modern data stack, simulating the analytical infrastructure used by financial services data teams.

## Business Problem
Home Credit serves customers with limited or no credit history. The goal of this project is to build an end-to-end platform that predicts default risk, models NPV under different economic scenarios, and informs lending strategy decisions — directly mapping to the analytical work of a credit risk or data engineering team.

## Architecture
```
Kaggle API → GCS → Airbyte → BigQuery Raw
                                    ↓
                              dbt Staging
                                    ↓
                           dbt Intermediate
                                    ↓
                             dbt Marts
                          ┌─────────────────┐
                          │  Credit Risk    │
                          │  NPV Model      │
                          │  Lending Strat  │
                          └─────────────────┘
                                    ↓
                    Analysis Notebooks + Dashboard
```

## Tech Stack
| Layer | Tool |
|---|---|
| Ingestion | Airbyte OSS + Kaggle API |
| Storage | Google BigQuery |
| Transformation | dbt Core |
| Orchestration | Apache Airflow |
| Data Quality | dbt tests + Elementary |
| CI/CD | GitHub Actions |
| Analysis | Python, pandas, scikit-learn |

## Project Structure
```
home-credit-risk/
├── ingestion/          # Airbyte config and ingestion scripts
├── orchestration/      # Airflow DAGs
├── transform/          # dbt project — staging, intermediate, marts
├── analysis/           # Jupyter notebooks
└── docs/               # Architecture diagrams and runbook
```

## Data Source
[Home Credit Default Risk — Kaggle](https://www.kaggle.com/competitions/home-credit-default-risk)
307,511 customers, 8 tables, 122 features.

## Sprint Progress
- [x] Sprint 1 — Infrastructure and Ingestion
- [ ] Sprint 2 — Analytics and Modelling

## Author
Peter Okpeh | [LinkedIn](https://linkedin.com/in/peterokpeh) | [GitHub](https://github.com/redefiningatta)
