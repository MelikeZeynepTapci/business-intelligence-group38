-- DWH1 post-ETL check: ft_servicemonthly cost and duration reconcile with staging (no filters applied)
-- The orchestrator supplies the warehouse/staging search_path for this transaction.

WITH src AS (
    SELECT SUM(servicecost) AS cost, SUM(durationminutes) AS duration FROM tb_serviceevent
),
dwh AS (
    SELECT SUM(totalcost) AS cost, SUM(totaldurationmin) AS duration FROM ft_servicemonthly
)
SELECT
    'ft_servicemonthly totalcost and totaldurationmin match tb_serviceevent' AS check_name,
    CASE WHEN s.cost = d.cost AND s.duration = d.duration THEN 'PASS' ELSE 'FAIL' END AS status,
    s.cost AS source_cost, d.cost AS dwh_cost,
    s.duration AS source_duration, d.duration AS dwh_duration
FROM src s CROSS JOIN dwh d;
