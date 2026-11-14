CREATE OR REFRESH MATERIALIZED VIEW silver_enrollments_clean (
    CONSTRAINT valid_progress
    EXPECT (progress_pct BETWEEN 0 AND 100)
    ON VIOLATION DROP ROW,
    CONSTRAINT valid_price
    EXPECT (price_paid >= 0)
    ON VIOLATION DROP ROW
)
AS
WITH cleaned AS (
    SELECT DISTINCT
        enrollment_id,
        learner_id,
        LOWER(TRIM(learner_email)) AS learner_email,
        COALESCE(NULLIF(TRIM(learner_city), ''), 'Unknown') AS learner_city,
        age_group,
        course_id,
        course_name,
        COALESCE(INITCAP(NULLIF(TRIM(category), '')), 'Unknown') AS category,
        INITCAP(TRIM(course_level)) AS course_level,
        instructor_name,
        enrollment_date,
        INITCAP(TRIM(enrollment_channel)) AS enrollment_channel,
        list_price,
        discount_amount,
        COALESCE(price_paid, list_price - discount_amount) AS price_paid,
        payment_method,
        progress_pct,
        hours_watched,
        course_rating,
        certificate_issued
    FROM bronze_course_enrollments

SELECT *,
    CASE
        WHEN progress_pct = 100 THEN 'Completed'
        WHEN progress_pct > 0 THEN 'In Progress'
        ELSE 'Not Started'
    END AS learner_status
FROM cleaned;

CREATE OR REFRESH MATERIALIZED VIEW silver_enrollments_rejected
AS
SELECT *,
    CASE
        WHEN progress_pct < 0 OR progress_pct > 100
            THEN 'Progress is outside 0 to 100'
        ELSE 'Price paid is negative'
    END AS reject_reason
FROM bronze_course_enrollments
WHERE
    progress_pct < 0
    OR progress_pct > 100
    OR price_paid < 0;
