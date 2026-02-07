


-- 1) Load CSV into DuckDB
-- Ensure nyc_311.csv is in the SAME folder as service.duckdb (or use an absolute path)
DROP TABLE IF EXISTS raw_requests;

CREATE OR REPLACE TABLE raw_requests AS
SELECT *
FROM read_csv_auto('nyc_311.csv');

-- ----------------------------
-- 2) Build clean fact table

DROP TABLE IF EXISTS clean_requests;

CREATE OR REPLACE TABLE clean_requests AS
SELECT
    unique_key                           AS request_id,
    CAST(created_date AS TIMESTAMP)      AS created_ts,
    CAST(closed_date AS TIMESTAMP)       AS closed_ts,
    agency,
    borough,
    status,
    complaint_type,

    DATE(CAST(created_date AS TIMESTAMP))             AS created_date,
    STRFTIME(CAST(created_date AS TIMESTAMP), '%Y-%m') AS created_month,

    CASE
        WHEN closed_date IS NOT NULL THEN
            DATE_DIFF(
                'hour',
                CAST(created_date AS TIMESTAMP),
                CAST(closed_date AS TIMESTAMP)
            )
        ELSE NULL
    END AS resolution_hours
FROM raw_requests
WHERE created_date IS NOT NULL;

-- ----------------------------
-- 3) SLA breach flag (72 hours threshold)


DROP TABLE IF EXISTS clean_requests_sla;

CREATE OR REPLACE TABLE clean_requests_sla AS
SELECT
    *,
    CASE
        WHEN resolution_hours IS NULL THEN NULL
        WHEN resolution_hours > 72 THEN TRUE
        ELSE FALSE
    END AS sla_breach
FROM clean_requests;

-- 4) Final analysis table (remove invalid resolution times)

DROP TABLE IF EXISTS clean_requests_final;

CREATE OR REPLACE TABLE clean_requests_final AS
SELECT *
FROM clean_requests_sla
WHERE resolution_hours IS NOT NULL
  AND resolution_hours >= 0;

-- ----------------------------
-- 5) KPI tables


-- 5A) Monthly SLA performance
DROP TABLE IF EXISTS kpi_monthly_sla;

CREATE OR REPLACE TABLE kpi_monthly_sla AS
SELECT
    created_month,
    COUNT(*) AS total_requests,
    SUM(CASE WHEN sla_breach THEN 1 ELSE 0 END) AS sla_breaches,
    ROUND(
        100.0 * SUM(CASE WHEN sla_breach THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS sla_breach_rate_pct
FROM clean_requests_final
GROUP BY created_month
ORDER BY created_month;

-- 5B) Agency performance (filter to agencies with enough volume)
DROP TABLE IF EXISTS kpi_agency_performance;

CREATE OR REPLACE TABLE kpi_agency_performance AS
SELECT
    agency,
    COUNT(*) AS total_requests,
    MEDIAN(resolution_hours) AS median_resolution_hours,
    SUM(CASE WHEN sla_breach THEN 1 ELSE 0 END) AS sla_breaches,
    ROUND(
        100.0 * SUM(CASE WHEN sla_breach THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS sla_breach_rate_pct
FROM clean_requests_final
GROUP BY agency
HAVING COUNT(*) > 500
ORDER BY sla_breach_rate_pct DESC;

-- 5C) Slowest complaint types (bottlenecks)
DROP TABLE IF EXISTS kpi_problem_resolution;

CREATE OR REPLACE TABLE kpi_problem_resolution AS
SELECT
    complaint_type,
    COUNT(*) AS total_requests,
    MEDIAN(resolution_hours) AS median_resolution_hours
FROM clean_requests_final
GROUP BY complaint_type
HAVING COUNT(*) > 300
ORDER BY median_resolution_hours DESC
LIMIT 20;

-- ----------------------------
-- 6) Export KPI tables to CSV for Power BI

COPY kpi_monthly_sla
TO 'kpi_monthly_sla.csv'
(HEADER, DELIMITER ',');

COPY kpi_agency_performance
TO 'kpi_agency_performance.csv'
(HEADER, DELIMITER ',');

COPY kpi_problem_resolution
TO 'kpi_problem_resolution.csv'
(HEADER, DELIMITER ',');