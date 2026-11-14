# Online Learning Enrollment Analytics Platform: Medallion Architecture with Lakeflow Spark Declarative Pipelines

An end-to-end online learning enrollment analytics project built using **Azure Databricks**, **Lakeflow Spark Declarative Pipelines (SQL)**, and **Medallion Architecture** (Bronze → Silver → Gold).

This project transforms raw course enrollment data into clean, structured, and business-ready analytical tables. It includes data cleaning, validation, data-quality tracking, reconciliation, and dashboard development.


## Table of Contents

- Business Problem
- Architecture
  Pipeline Lineage
- Tech Stack
- Dataset
- Repository Structure
- Layer Details
- Data Quality Rules
- Reconciliation
- Gold Tables
- Dashboard
- How to Run
- Business Requirements Coverage
- Key Learnings
- Future Improvements

## Business Problem

Online learning platforms generate enrollment data from different courses, learners, and enrollment channels. Raw data may contain missing values, inconsistent text, duplicate records, invalid email addresses, incorrect progress values, and negative course prices.

Manual data cleaning makes reporting difficult and less reliable.

**Goal:** Build a repeatable data pipeline that preserves raw enrollment data, cleans and validates records, and creates trusted Gold tables for enrollment analysis and business reporting.

## Architecture

`course_enrollments_raw.csv` (Unity Catalog Volume) → **Bronze** (raw data) → **Silver** (cleaned and validated data) → **Gold** (business aggregations) → Databricks AI/BI Dashboard / Genie

| Layer | Purpose | Key Actions |
|---|---|---|
| Bronze | Preserve source data | Load raw CSV and maintain original records |
| Silver | Improve data quality | Clean text, validate records, handle duplicates, separate rejected records |
| Gold | Support business analysis | Create monthly, category, course, channel, and data-quality summaries |


## Pipeline Lineage

The pipeline processes enrollment data through three layers using Lakeflow Spark Declarative Pipelines.

| Object | Type | Description |
|---|---|---|
| `bronze_course_enrollments` | Bronze table | Raw enrollment records |
| `silver_enrollments_clean` | Silver table | Cleaned enrollment records |
| `silver_enrollments_rejected` | Silver table | Rejected enrollment records |
| `gold_monthly_enrollments` | Gold table | Monthly enrollment summary |
| `gold_category_summary` | Gold table | Enrollment summary by category |
| `gold_course_summary` | Gold table | Course-level performance summary |
| `gold_channel_summary` | Gold table | Enrollment summary by channel |
| `gold_data_quality` | Gold table | Data-quality summary |


## Tech Stack

- Azure Databricks
- Lakeflow Spark Declarative Pipelines
- SQL
- Unity Catalog
- Unity Catalog Volumes
- Delta Lake
- Databricks AI/BI Dashboards
- Databricks Genie

## Dataset

The project uses a synthetic online learning enrollment dataset named **`course_enrollments_raw.csv`**.

| Dataset Information | Details |
|---|---|
| File Name | course_enrollments_raw.csv |
| File Format | CSV |
| Total Records | 1,283 |
| Total Columns | 20 |
| Data Domain | Online Learning / EdTech |
| Processing Platform | Azure Databricks |

The dataset contains learner, course, enrollment, progress, pricing, and channel-related information.

It is used to demonstrate data ingestion, cleaning, validation, aggregation, and reporting.

## Repository Structure

```text
Online-Learning-Enrollment-Analytics/
│
├── README.md
│
├── Dataset/
│   └── course_enrollments_raw.csv
│
├── Bronze/
│   └── bronze_transformation.sql
│
├── Silver/
│   └── silver_transformation.sql
│
├── Gold/
│   └── gold_transformation.sql
│
├── Dashboard/
│   ├── Overview/
│   ├── Courses_and_Channels/
│   └── Data_Quality/
│
├── Images/
│   ├── Architecture/
│   ├── Pipeline/
│   └── Dashboard/
│
└── Documentation/
    ├── data_quality_rules.md
    ├── data_reconciliation.md
    └── review_questions.md
```

## Layer Details

### Bronze Layer

- Reads the raw CSV file from a Unity Catalog Volume.
- Stores original enrollment records.
- Maintains the source data for traceability.
- Provides the starting point for Silver transformations.

**Bronze table:** `bronze_course_enrollments`

### Silver Layer

- Removes unnecessary leading and trailing spaces.
- Standardizes text values.
- Identifies missing and invalid values.
- Validates learner email information.
- Checks course progress values.
- Identifies negative course prices.
- Handles duplicate enrollment records.
- Separates clean and rejected records.

**Silver tables:**
- `silver_enrollments_clean`
- `silver_enrollments_rejected`

### Gold Layer

Creates business-ready aggregated tables for reporting.

- `gold_monthly_enrollments`: Monthly enrollment trends.
- `gold_category_summary`: Enrollment analysis by category.
- `gold_course_summary`: Course-level enrollment analysis.
- `gold_channel_summary`: Enrollment analysis by channel.
- `gold_data_quality`: Data-quality summary.

## Data Quality Rules

The project applies data-quality checks to improve the accuracy and consistency of enrollment records.

| Rule | Treatment |
|---|---|
| Missing values | Identify missing important fields |
| Text standardization | Remove unnecessary spaces and standardize text |
| Duplicate records | Identify and handle duplicate enrollments |
| Email validation | Identify invalid email formats |
| Progress validation | Check progress between 0 and 100 |
| Price validation | Identify negative course prices |
| Learner status | Standardize learner status |
| Auditability | Preserve original records in Bronze |



## Reconciliation

Data reconciliation checks whether records are correctly processed across Bronze, Silver, and Gold layers.

| Check | Expected Result |
|---|---:|
| Source CSV rows | 1,283 |
| Bronze records | 1,283 |
| Silver clean records | 1,241 |
| Silver rejected records | 19 |
| Remaining records to investigate | 23 |
| Gold aggregation totals | Verify against Silver |




## Gold Tables

The Gold layer contains five analytical tables:

| Gold Table | Business Purpose |
|---|---|
| `gold_monthly_enrollments` | Understand monthly enrollment trends |
| `gold_category_summary` | Compare enrollment across categories |
| `gold_course_summary` | Analyze course-level performance |
| `gold_channel_summary` | Understand enrollment channels |
| `gold_data_quality` | Monitor data-quality results |

## Dashboard

The project includes an interactive Databricks AI/BI Dashboard with three main sections.

### 1. Overview
- Total enrollment records
- Monthly enrollment trends
- Overall enrollment insights

### 2. Courses and Channels
- Course-level analysis
- Category-wise enrollment
- Enrollment channel comparison

### 3. Data Quality
- Clean and rejected records
- Data-quality metrics
- Validation results


## How to Run

1. Upload `course_enrollments_raw.csv` to a Unity Catalog Volume.
2. Create or select the catalog and schema.
3. Configure the source file path in the Bronze SQL.
4. Add the Bronze, Silver, and Gold SQL files to your Lakeflow Spark Declarative Pipeline.
5. Configure the target catalog and schema.
6. Run the pipeline.
7. Verify the Bronze and Silver tables.
8. Validate the Gold tables using SQL queries.
9. Create an AI/BI Dashboard using the Gold tables.
10. Use Databricks Genie to explore enrollment data through natural-language questions.

## Business Requirements Coverage

| ID | Requirement | Implementation |
|---|---|---|
| BR-01 | Raw data ingestion | Bronze table |
| BR-02 | Data cleaning | Silver layer |
| BR-03 | Data validation | Silver validation rules |
| BR-04 | Duplicate handling | Silver layer |
| BR-05 | Monthly enrollment analysis | `gold_monthly_enrollments` |
| BR-06 | Category analysis | `gold_category_summary` |
| BR-07 | Course performance | `gold_course_summary` |
| BR-08 | Channel analysis | `gold_channel_summary` |
| BR-09 | Data-quality visibility | `gold_data_quality` |
| BR-10 | Business reporting | AI/BI Dashboard |
| BR-11 | Data exploration | Databricks Genie |
| BR-12 | Reconciliation | Data reconciliation checks |

## Key Learnings

- Understanding Medallion Architecture.
- Loading raw data into Databricks.
- Working with Unity Catalog and Volumes.
- Building data transformations using SQL.
- Cleaning and validating enrollment records.
- Handling duplicate and rejected records.
- Creating Gold analytical tables.
- Performing data reconciliation.
- Developing interactive AI/BI dashboards.
- Exploring data using Databricks Genie.

## Future Improvements

- Implement automated daily data ingestion using Auto Loader.
- Add advanced data-quality monitoring.
- Improve duplicate detection rules.
- Introduce learner and course dimension tables.
- Add more business KPIs to dashboards.
- Schedule automated pipeline refreshes.
- Integrate additional online learning datasets.
- Add automated alerts for pipeline failures.

## License

This project is created for educational and portfolio purposes.
