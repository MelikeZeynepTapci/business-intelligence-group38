-- DWH1 post-ETL check: dim_timemonth is gap-free and covers every month that has readings or service events
-- The orchestrator supplies the warehouse/staging search_path for this transaction.

WITH source_months AS (
    SELECT DISTINCT CAST(EXTRACT(YEAR FROM readat) * 100 + EXTRACT(MONTH FROM readat) AS INT) AS id FROM tb_readingevent
    UNION
    SELECT DISTINCT CAST(EXTRACT(YEAR FROM servicedat) * 100 + EXTRACT(MONTH FROM servicedat) AS INT) FROM tb_serviceevent
),
stats AS (
    SELECT
        (SELECT COUNT(*) FROM source_months sm WHERE NOT EXISTS (SELECT 1 FROM dim_timemonth t WHERE t.id = sm.id)) AS missing_months
        , (SELECT COUNT(*) FROM dim_timemonth) AS dwh_months
        , (SELECT (EXTRACT(YEAR FROM AGE(MAX(monthstart), MIN(monthstart))) * 12
                 + EXTRACT(MONTH FROM AGE(MAX(monthstart), MIN(monthstart))) + 1)::INT FROM dim_timemonth) AS expected_months
)
SELECT
    'dim_timemonth gap-free and covers all source months' AS check_name,
    CASE WHEN missing_months = 0 AND dwh_months = expected_months THEN 'PASS' ELSE 'FAIL' END AS status,
    missing_months, dwh_months, expected_months
FROM stats;
