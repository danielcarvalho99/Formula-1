CREATE OR REPLACE TABLE `f1_silver.dim_driver` AS
WITH normalized AS (
  SELECT
    REGEXP_REPLACE(LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
      FirstName,
    'ã', 'a'), 'á', 'a'), 'à', 'a'), 'â', 'a'), 'ç', 'c'), 'é', 'e'), 'è', 'e'), 'ê', 'e')), r'\s+', '_') AS first_name_normalized,
    REGEXP_REPLACE(LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
      LastName,
    'ã', 'a'), 'á', 'a'), 'à', 'a'), 'â', 'a'), 'ç', 'c'), 'é', 'e'), 'è', 'e'), 'ê', 'e')), r'\s+', '_') AS            last_name_normalized,
    FirstName,
    LastName,
    FullName,
    BroadcastName,
    Abbreviation,
    HeadshotUrl,
    EventDate
  FROM `f1_bronze.races`
),
deduped AS (
  SELECT
    MAX(CONCAT(first_name_normalized, '_', last_name_normalized)) AS id,
    MAX(BroadcastName) AS broadcast_name,
    MAX(Abbreviation) AS abbreviation,
    FirstName AS first_name,
    LastName AS last_name,
    FullName AS full_name
  FROM normalized
  GROUP BY FirstName, LastName, FullName
),
latest_headshot AS (
  SELECT DISTINCT
    FullName,
    LAST_VALUE(HeadshotUrl) OVER (
      PARTITION BY FullName
      ORDER BY EventDate
      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS headshot_url
  FROM normalized
)
SELECT
  d.id,
  d.broadcast_name,
  d.abbreviation,
  d.first_name,
  d.last_name,
  d.full_name,
  h.headshot_url
FROM deduped d
LEFT JOIN latest_headshot h ON d.full_name = h.FullName
ORDER BY d.full_name;


CREATE OR REPLACE TABLE `f1_silver.dim_team` AS
WITH agg_teams AS (
SELECT DISTINCT
  TeamId AS id,
  TeamName AS name,
  MAX(TeamColor) AS color,
  Year as year
FROM
  `f1_bronze.races`
GROUP BY
  TeamId, TeamName, Year
)

SELECT
  id,
  name,
  color
FROM
  agg_teams
QUALIFY
  ROW_NUMBER() OVER(PARTITION BY id ORDER BY year DESC) = 1;

CREATE OR REPLACE TABLE `f1_silver.dim_event` AS
WITH normalized AS (
  SELECT
    REGEXP_REPLACE(LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
      Location,
    'ã', 'a'), 'á', 'a'), 'à', 'a'), 'â', 'a'), 'ç', 'c'), 'é', 'e'), 'è', 'e'), 'ê', 'e')), r'\s+', '_') AS location_normalized,
    Country,
    Location,
    OfficialEventName,
    EventDate,
    EventName,
    EventFormat
  FROM `f1_bronze.races`
)
SELECT DISTINCT
  CONCAT(location_normalized, '_', SUBSTR(EventDate, 1, 4)) AS id,
  Country AS country,
  Location AS location,
  OfficialEventName AS official_name,
  SAFE_CAST(SUBSTR(EventDate, 1, 10) AS DATE) AS date,
  EventName AS name,
  EventFormat AS format
FROM normalized;

CREATE OR REPLACE TABLE `f1_silver.dim_time` AS
SELECT
  FORMAT_DATE('%Y%m%d', d) AS id,
  EXTRACT(YEAR FROM d) AS year,
  EXTRACT(MONTH FROM d) AS month,
  EXTRACT(DAY FROM d) AS day,
  EXTRACT(QUARTER FROM d) AS quarter,
  EXTRACT(DAYOFWEEK FROM d) AS day_of_week,
  EXTRACT(WEEK FROM d) AS week_of_year,
  FORMAT_DATE('%B', d) AS month_name,
  FORMAT_DATE('%A', d) AS day_name,
  IF(EXTRACT(DAYOFWEEK FROM d) IN (1, 7), true, false) AS is_weekend
FROM (
  SELECT DATE_ADD('1990-01-01', INTERVAL seq DAY) AS d
  FROM UNNEST(GENERATE_ARRAY(0, 36524)) AS seq
);