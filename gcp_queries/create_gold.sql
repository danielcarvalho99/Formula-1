CREATE OR REPLACE TABLE `f1_gold.drivers_historical_ranking` AS
SELECT
  drivers.full_name,
  SUM(races.points) AS total_points,
FROM
  `f1_silver.fact_races` races
JOIN
  `f1_silver.dim_driver` drivers
ON
 races.driver_id = drivers.id
GROUP BY
  drivers.full_name
ORDER BY
  total_points DESC;

CREATE OR REPLACE TABLE `f1_gold.teams_historical_ranking` AS
SELECT
  teams.name,
  SUM(races.points) AS total_points,
FROM
  `f1_silver.fact_races` races
JOIN
  `f1_silver.dim_team` teams
ON
 races.team_id = teams.id
GROUP BY
  teams.name
ORDER BY
  total_points DESC;

CREATE OR REPLACE TABLE `f1_gold.drivers_ranking_by_year` AS
WITH agg_points AS (
  SELECT
    EXTRACT(YEAR FROM time_id) AS year,
    drivers.full_name,
    SUM(points) AS total_points
  FROM `f1_silver.fact_races` races
  JOIN `f1_silver.dim_driver` drivers ON races.driver_id = drivers.id
  GROUP BY drivers.full_name, EXTRACT(YEAR FROM time_id)
)
SELECT
  year,
  full_name,
  total_points,
  ROW_NUMBER() OVER (PARTITION BY year ORDER BY total_points DESC) AS position
FROM agg_points
ORDER BY year, position;

CREATE OR REPLACE TABLE `f1_gold.teams_ranking_by_year` AS
WITH agg_points AS (
  SELECT
    EXTRACT(YEAR FROM time_id) AS year,
    teams.name as team_name,
    SUM(points) AS total_points
  FROM `f1_silver.fact_races` races
  JOIN `f1_silver.dim_team` teams ON races.team_id = teams.id
  GROUP BY teams.name, EXTRACT(YEAR FROM time_id)
)
SELECT
  year,
  team_name,
  total_points,
  ROW_NUMBER() OVER (PARTITION BY year ORDER BY total_points DESC) AS position
FROM agg_points
ORDER BY year, position;