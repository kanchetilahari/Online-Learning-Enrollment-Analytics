# Data Reconciliation

This document explains the data reconciliation process applied in the Online Learning Enrollment Analytics pipeline. It describes how record counts, data consistency, and aggregation results are validated across the Bronze, Silver, and Gold layers.

> **Principle:** Every record entering the pipeline should be accounted for. Data reconciliation helps identify missing records, duplicate records, rejected records, and differences between processing layers.

## 1. Introduction

Data reconciliation is the process of comparing data between different layers of a data pipeline to ensure that records are processed correctly.

In this project, reconciliation is performed across three layers of the Medallion Architecture:

- Bronze Layer – Raw enrollment data.
- Silver Layer – Cleaned and validated enrollment data.
- Gold Layer – Aggregated data for analytics and reporting.

## 2. Source Data Overview

The project uses a synthetic dataset named `course_enrollments_raw.csv`.

| Description | Details |
|---|---|
| Dataset Name | course_enrollments_raw.csv |
| Source Format | CSV |
| Total Source Records | 1,283 |
| Total Columns | 20 |
| Processing Platform | Databricks |
| Architecture | Medallion Architecture |

## 3. Reconciliation Across Layers

### 3.1 Bronze Layer Reconciliation

The Bronze layer stores the raw enrollment records.

**Validation checks:**
- Verify that all source records are loaded.
- Compare the source CSV record count with the Bronze table count.
- Check whether any records are missing during ingestion.
- Confirm that raw records are preserved.

**Bronze table:** `bronze_course_enrollments`

### 3.2 Silver Layer Reconciliation

The Silver layer cleans and validates the Bronze records.

**Validation checks:**
- Verify clean enrollment records.
- Verify rejected enrollment records.
- Check duplicate records.
- Validate missing and invalid values.
- Compare Bronze and Silver record counts.

**Silver tables:**
- `silver_enrollments_clean`
- `silver_enrollments_rejected`

### 3.3 Gold Layer Reconciliation

The Gold layer contains summarized data for business analysis.

**Validation checks:**
- Verify monthly enrollment totals.
- Compare category-level enrollment counts.
- Validate course-level summaries.
- Check enrollment channel summaries.
- Compare Gold aggregation results with cleaned Silver data.

**Gold tables:**
- `gold_monthly_enrollments`
- `gold_category_summary`
- `gold_course_summary`
- `gold_channel_summary`
- `gold_data_quality`

## 4. Record Count Reconciliation

The following table shows the expected record counts from the project pipeline.

| Layer | Table | Expected Records |
|---|---|---:|
| Bronze | bronze_course_enrollments | 1,283 |
| Silver | silver_enrollments_clean | 1,241 |
| Silver | silver_enrollments_rejected | 19 |

**Important:** The clean and rejected records total 1,260. There is a difference of 23 records compared with the Bronze count. These records must be investigated before reconciliation can be marked complete.

## 5. Reconciliation Formula

The basic reconciliation formula is:

**Total Bronze Records = Silver Clean Records + Silver Rejected Records + Other Accounted Records**

For this project:

1,283 = 1,241 + 19 + 23

The remaining 23 records need investigation to identify whether they were removed through duplicate handling, filtering, or another processing condition.

## 6. SQL Validation Queries

### 6.1 Check Bronze Record Count

```sql
SELECT COUNT(*) AS bronze_count
FROM edtech_catalog.learning.bronze_course_enrollments;
```

### 6.2 Check Silver Clean Record Count

```sql
SELECT COUNT(*) AS clean_count
FROM edtech_catalog.learning.silver_enrollments_clean;
```

### 6.3 Check Silver Rejected Record Count

```sql
SELECT COUNT(*) AS rejected_count
FROM edtech_catalog.learning.silver_enrollments_rejected;
```

### 6.4 Compare Silver Record Counts

```sql
SELECT
    (SELECT COUNT(*)
     FROM edtech_catalog.learning.silver_enrollments_clean) AS clean_records,

    (SELECT COUNT(*)
     FROM edtech_catalog.learning.silver_enrollments_rejected) AS rejected_records;
```

*Note: These queries assume the tables are accessible in the specified catalog and schema.*

## 7. Gold Layer Reconciliation

Gold tables are checked against Silver data to ensure that aggregations are correct.

| Gold Table | Reconciliation Check |
|---|---|
| gold_monthly_enrollments | Compare monthly totals with Silver records |
| gold_category_summary | Compare category totals with Silver records |
| gold_course_summary | Validate course-level enrollment totals |
| gold_channel_summary | Compare enrollment channel totals |
| gold_data_quality | Verify data quality counts |

### Important Validation Points

- Gold totals should match the corresponding Silver records.
- No rejected records should be included in trusted reporting unless explicitly allowed by the business rule.
- Monthly summaries should cover the expected enrollment periods.
- Category and channel summaries should not contain unexplained missing groups.

## 8. Reconciliation Issue Tracking

| Issue | Expected Result | Status |
|---|---|---|
| Bronze ingestion count | 1,283 | Verify |
| Silver clean count | 1,241 | Expected |
| Silver rejected count | 19 | Expected |
| Remaining 23 records | Investigate | Pending |
| Gold aggregation totals | Match Silver data | Verify |
| Dashboard KPI totals | Match Gold tables | Verify |

## 9. Best Practices

1. Always compare source and Bronze record counts.
2. Maintain separate clean and rejected datasets.
3. Document all filtering and exclusion conditions.
4. Validate aggregate totals before dashboard creation.
5. Investigate unexplained record-count differences.
6. Keep reconciliation checks as part of pipeline validation.
7. Repeat reconciliation after pipeline updates.

## 10. Conclusion

Data reconciliation ensures that enrollment records are correctly processed throughout the Medallion Architecture. By validating Bronze, Silver, and Gold data, this project improves data consistency, identifies missing records, and supports reliable dashboard reporting.
