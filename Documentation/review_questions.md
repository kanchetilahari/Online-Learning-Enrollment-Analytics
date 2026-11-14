# Project Review Questions and Answers

Answers to eight important technical review questions from the Online Learning Enrollment Analytics Platform, written in the context of this project using Lakeflow Spark Declarative Pipelines on Azure Databricks.

---

## 1. Why do we preserve raw enrollment data in Bronze instead of cleaning the source immediately?

The Bronze layer stores the original enrollment data received from the source CSV file. Preserving raw data is important because:

- **Traceability:** Cleaned records in Silver can be compared with their original Bronze records.
- **Reprocessability:** If a cleaning rule is incorrect, we can update the rule and process the Bronze data again.
- **Auditability:** We can identify which records were changed, rejected, or retained.
- **Data protection:** Original source values remain available without permanent modification.
- **Flexibility:** New business rules can be applied without uploading the source file again.

If we clean the source immediately, the original values may be lost, making it difficult to investigate data-quality problems.

---

## 2. What is the difference between a data-quality flag and rejecting an enrollment record?

| | Flag | Reject / Exclude |
|---|---|---|
| What happens | The record is retained and marked as suspicious | The record is separated from the clean dataset |
| Use when | A value needs further investigation | A record violates a defined rejection rule |
| Example | Invalid email or progress outside the allowed range | Duplicate enrollment record |
| Risk | Suspicious records may enter reports if not filtered | Valid records may be lost if rules are too strict |
| Reversible | Yes | Yes, because Bronze data is preserved |

In this project, data validation is performed in the Silver layer. Clean records are stored in `silver_enrollments_clean`, while rejected records are stored in `silver_enrollments_rejected`.

The actual rejection conditions should follow the implemented SQL and pipeline logic.

---

## 3. Why is selecting the correct duplicate key important in an enrollment dataset?

An enrollment dataset may contain multiple records for the same learner because a learner can enroll in several courses.

For example, the same learner may enroll in:

- Python Programming
- Data Analytics
- Machine Learning

Therefore, using only the learner ID as a duplicate key could incorrectly remove valid enrollments.

Duplicate detection should use the actual enrollment-level identifier or a combination of columns that uniquely identifies an enrollment.

Possible fields include:

- Enrollment ID
- Learner ID
- Course ID
- Enrollment date

Exact duplicates and business-level duplicates should be checked separately.

**Important:** The final duplicate key must be confirmed using the actual dataset columns and business requirements.

---

## 4. How would you investigate an invalid email, progress value, or negative course price?

The investigation process includes:

1. **Identify:** Find the suspicious records in the Silver layer.
2. **Compare:** Check the corresponding original records in Bronze.
3. **Validate email:** Check whether the email follows the expected format.
4. **Check progress:** Verify whether course progress is between 0 and 100.
5. **Check price:** Investigate whether a negative price is a data-entry error, refund, or another business adjustment.
6. **Document:** Record the reason for flagging or rejecting the record.
7. **Update:** Change the cleaning rule only when the business requirement supports it.

The main principle is to investigate unusual values before assuming they are incorrect.

---

## 5. How can you prove that Gold enrollment totals are consistent with cleaned Silver data?

We can use SQL reconciliation queries to compare Silver records with Gold aggregations.

Important validation checks include:

- Compare total clean enrollment records with the monthly Gold enrollment totals.
- Compare category-level enrollment totals with Silver data.
- Compare course-level enrollment totals with Silver data.
- Compare channel-level enrollment totals with Silver data.
- Check whether rejected records are excluded from trusted reporting.

Example SQL:

```sql
SELECT COUNT(*) AS silver_total
FROM edtech_catalog.learning.silver_enrollments_clean;
```

To validate monthly enrollment counts:

```sql
SELECT SUM(enrollment_count) AS gold_monthly_total
FROM edtech_catalog.learning.gold_monthly_enrollments;
```

The totals should agree when both queries use the same enrollment population and counting rules.

**Note:** Replace `enrollment_count` if your Gold table uses a different column name.

---

## 6. What would change if new enrollment files arrived every day?

If new enrollment files arrive daily, the pipeline can be improved to support incremental data processing.

- **Ingestion:** Use Auto Loader to automatically detect and ingest new CSV files.
- **Bronze:** Store incoming records with source-file and ingestion metadata.
- **Deduplication:** Check duplicates across both new and previously processed records.
- **Idempotency:** Prevent the same file from being processed multiple times.
- **Scheduling:** Configure pipeline refreshes or triggers.
- **Monitoring:** Track failed pipeline runs and data-quality issues.
- **Schema
