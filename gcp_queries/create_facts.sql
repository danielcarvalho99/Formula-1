CREATE OR REPLACE TABLE `f1_silver.fact_races` AS
WITH normalized AS (
  SELECT
    CONCAT(
      REGEXP_REPLACE(LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        FirstName,
      'ã', 'a'), 'á', 'a'), 'à', 'a'), 'â', 'a'), 'ç', 'c'), 'é', 'e'), 'è', 'e'), 'ê', 'e')), r'\s+', '_'),
      '_',
      REGEXP_REPLACE(LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        LastName,
      'ã', 'a'), 'á', 'a'), 'à', 'a'), 'â', 'a'), 'ç', 'c'), 'é', 'e'), 'è', 'e'), 'ê', 'e')), r'\s+', '_')
    ) AS driver_id,
    REGEXP_REPLACE(LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
      Location,
    'ã', 'a'), 'á', 'a'), 'à', 'a'), 'â', 'a'), 'ç', 'c'), 'é', 'e'), 'è', 'e'), 'ê', 'e')), r'\s+', '_') AS location_normalized,
    *
  FROM `f1_bronze.races`
)
SELECT
  driver_id,
  TeamId AS team_id,
  SAFE_CAST(SUBSTR(EventDate, 1, 10) AS DATE) AS time_id,
  CONCAT(location_normalized, '_', SUBSTR(EventDate, 1, 4)) AS event_id,
  SAFE_CAST(Position AS INT64) AS position,
  SAFE_CAST(ClassifiedPosition AS INT64) AS classified_position,
  SAFE_CAST(GridPosition AS INT64) AS grid_position,
  REGEXP_REPLACE(Time, r'^\d+ days ', '') AS race_time,
  Status AS status,
  SAFE_CAST(Points AS INT64) AS points,
  SAFE_CAST(Laps AS INT64) AS laps
FROM normalized;