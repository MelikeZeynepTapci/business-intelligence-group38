-- DWH1 post-ETL check: ft_servicemonthly has no duplicate grain rows, no orphan keys and plausible measures
-- The orchestrator supplies the warehouse/staging search_path for this transaction.

WITH stats AS (
    SELECT
        COUNT(*) - COUNT(DISTINCT (f.locationid, f.servicetypeid, f.timemonthid)) AS duplicate_grain
        , COUNT(*) FILTER (WHERE l.id IS NULL OR st.id IS NULL OR t.id IS NULL) AS orphan_keys
        , COUNT(*) FILTER (WHERE f.servicecount <= 0
                              OR f.underqualifiedcount > f.servicecount
                              OR f.avgservicequality NOT BETWEEN 1 AND 5) AS bad_measures
    FROM ft_servicemonthly f
    LEFT JOIN dim_location l ON l.id = f.locationid
    LEFT JOIN dim_servicetype st ON st.id = f.servicetypeid
    LEFT JOIN dim_timemonth t ON t.id = f.timemonthid
)
SELECT
    'ft_servicemonthly grain unique, keys resolved, measures plausible' AS check_name,
    CASE WHEN duplicate_grain = 0 AND orphan_keys = 0 AND bad_measures = 0 THEN 'PASS' ELSE 'FAIL' END AS status,
    duplicate_grain, orphan_keys, bad_measures
FROM stats;
