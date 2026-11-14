# Data Quality Rules

This document describes the data-quality (DQ) rules applied in the Online Learning Enrollment Analytics pipeline, how each issue is treated, and where it is enforced.

> **Principle:** Raw enrollment data is preserved in the Bronze layer. Data issues are identified, cleaned, flagged, or rejected according to documented rules. Gold tables contain summarized data for trusted reporting.

## 1. Known Issues in the Source Data

The source file (`course_enrollments_raw.csv`) contains 1,283 rows and 20 columns. It is a synthetic dataset designed for learning and analytics.

| # | Issue | Example |
|---|---|---|
| 1 | Leading/trailing whitespace | `" Data Science "` instead of `"Data Science"` |
| 2 | Inconsistent text formatting | Mixed uppercase and lowercase values |
| 3 | Missing values | Null or blank learner details |
| 4 | Duplicate records | Repeated enrollment records |
| 5 | Invalid email addresses | Incorrect email format |
| 6 | Invalid progress values | Progress below 0 or above 100 |
| 7 | Negative course price | Course price less than zero |
| 8 | Invalid enrollment details | Missing or incorrect enrollment information |
| 9 | Invalid dates | Incorrect date values |

## 2. Rules by Layer

### Bronze: Preserve Raw Data

The Bronze layer stores the original enrollment data without business-level cleaning.

| Rule ID | Rule | Treatment |
|---|---|---|
| BRZ-01 | Preserve original source values | No business-level modifications |
| BRZ-02 | Store source enrollment records | Load raw CSV data |
| BRZ-03 | Maintain source record count | Validate against source |
| BRZ-04 | Preserve original data for auditing | Retain raw records |

### Silver: Clean, Standardize and Validate

The Silver layer applies data-cleaning and validation rules.

| Rule ID | Dimension | Rule | Treatment | Action |
|---|---|---|---|---|
| SLV-01 | Standardization | Remove leading and trailing spaces from text fields | TRIM() | Fix |
| SLV-02 | Standardization | Standardize text formatting | Consistent text values | Fix |
| SLV-03 | Completeness | Identify missing required values | Null and blank checks | Flag |
| SLV-04 | Duplicates | Identify duplicate enrollment records | Duplicate detection | Exclude |
| SLV-05 | Email validation | Validate learner email information | Email format check | Flag |
| SLV-06 | Business validity | Course progress must be between 0 and 100 | Range validation | Flag |
| SLV-07 | Business validity | Course price must not be negative | Price validation | Flag |
| SLV-08 | Status validation | Standardize learner status | Status classification | Fix |
| SLV-09 | Record separation | Separate clean and rejected records | Validation conditions | Separate |

### Gold: Business-Ready Data

The Gold layer contains aggregated tables used for reporting and dashboard development.

| Rule ID | Rule | Treatment |
|---|---|---|
| GLD-01 | Monthly enrollment summaries use cleaned Silver data | Aggregate |
| GLD-02 | Category summaries use valid enrollment records | Aggregate |
| GLD-03 | Course summaries provide course-level insights | Aggregate |
| GLD-04 | Channel summaries show enrollment by channel | Aggregate |
| GLD-05 | Data quality summary provides quality metrics | Summarize |
| GLD-06 | Gold results are checked against Silver records | Reconcile |

## 3. Flag vs. Reject

| | **Flag** | **Reject / Exclude** |
|---|---|---|
| Meaning | Record is retained but marked as suspicious | Record is separated from clean reporting data |
| Use when | A value needs investigation | A record violates a defined rejection rule |
| Example | Invalid email or progress outside the allowed range | Duplicate enrollment record |
| Visible in | Silver quality checks | Silver rejected table |
| Reversible | Yes | Yes, because raw data remains in Bronze |

## 4. Data Quality Validation Columns

The following checks describe the quality information that can be maintained during Silver processing.

| Column / Check | Type | Description |
|---|---|---|
| Missing required values | Boolean | Identifies missing important fields |
| Invalid email | Boolean | Identifies invalid email formats |
| Duplicate record | Boolean | Identifies repeated enrollment records |
| Invalid progress | Boolean | Identifies progress outside 0–100 |
| Negative price | Boolean | Identifies negative course prices |
| Learner status | String | Identifies standardized learner status |
| Clean record | Boolean | Indicates whether the record passes the implemented cleaning rules |

*Note: These are logical quality checks. Use the actual column names from your implemented Silver tables in the final documentation.*

## 5. Pipeline Expectations

The Silver layer performs validation before records are used for Gold reporting.

Example SQL checks:

```sql
-- Check missing learner details
SELECT *
FROM edtech_catalog.learning.silver_enrollments_clean
WHERE learner_email IS NULL;

-- Check invalid progress
SELECT *
FROM edtech_catalog.learning.silver_enrollments_clean
WHERE progress < 0 OR progress > 100;

-- Check negative course price
SELECT *
FROM edtech_catalog.learning.silver_enrollments_clean
WHERE course_price < 0;
```

*Note: Replace column names if your actual dataset uses different names. These are example validation queries, not confirmation that these exact columns exist.*

## 6. Investigating Suspicious Values

When an invalid or suspicious enrollment record is identified:

1. Identify the affected record in the Silver layer.
2. Compare the record with its original Bronze data.
3. Check learner details, course information, progress, and price.
4. Determine whether the issue is missing data, invalid data, or a duplicate.
5. Apply the documented cleaning or rejection rule.
6. Verify that the Gold summaries are not affected by rejected records.

## 7. Data Quality Issue Summary

The following counts are based on the expected project results where available. Individual issue counts should be filled after running the corresponding validation queries.

| Issue | Rule ID | Count | Treatment |
|---|---|---:|---|
| Missing or invalid values | SLV-03 | TODO | Flagged |
| Duplicate records | SLV-04 | TODO | Excluded |
| Invalid email addresses | SLV-05 | TODO | Flagged |
| Invalid progress | SLV-06 | TODO | Flagged |
| Negative course prices | SLV-07 | TODO | Flagged |
| Learner status standardization | SLV-08 | TODO | Fixed |
| Clean records | SLV-09 | 1,241 expected | Retained |
| Rejected records | SLV-09 | 19 expected | Separated |

## 8. Assumptions and Decisions

- Bronze data is preserved as the raw source.
- Text standardization is performed in Silver.
- Duplicate records are separated from clean records.
- Invalid progress values are checked against the 0–100 range.
- Negative course prices are identified through validation.
- Missing values are not automatically replaced without a documented business rule.
- Gold tables are created using cleaned Silver data.
- Synthetic enrollment data is used for this project.
- Final issue counts must be verified against the actual pipeline output.

## 9. Conclusion

Data quality rules help maintain accurate and consistent enrollment information. The Bronze layer preserves raw data, the Silver layer cleans and validates records, and the Gold layer provides business-ready summaries for analytics and dashboard reporting.
