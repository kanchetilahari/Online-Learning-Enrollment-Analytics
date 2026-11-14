CREATE OR REFRESH STREAMING TABLE bronze_course_enrollments AS
SELECT *,
       _metadata.file_name AS source_file,
       current_timestamp() AS loaded_at
FROM STREAM read_files(
  '/Volumes/edtech_catalog/default/course_enrollment',
  format => 'csv',
  header => true
);
