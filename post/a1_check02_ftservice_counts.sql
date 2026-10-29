-- DWH1 post-ETL check: ft_servicemonthly event count, row count (grain) and underqualified count reconcile with staging
-- The orchestrator supplies the warehouse/staging search_path for this transaction.

WITH src AS (
    SELECT
        COUNT(*) AS events
        , COUNT(DISTINCT (sd.cityid, se.servicetypeid, DATE_TRUNC('month', se.servicedat))) AS grain_rows
        , SUM(CASE WHEN r.rolelevel < st.minlevel THEN 1 ELSE 0 END) AS underqualified
    FROM tb_serviceevent se
    JOIN tb_sensordevice sd ON sd.id = se.sensordevid
    JOIN tb_servicetype st ON st.id = se.servicetypeid
    JOIN tb_employee e ON e.id = se.employeeid
    JOIN tb_role r ON r.id = e.roleid
),
dwh AS (
    SELECT SUM(servicecount) AS events, COUNT(*) AS grain_rows, SUM(underqualifiedcount) AS underqualified
    FROM ft_servicemonthly
)
SELECT
    'ft_servicemonthly counts match tb_serviceevent' AS check_name,
    CASE WHEN s.events = d.events AND s.grain_rows = d.grain_rows AND s.underqualified = d.underqualified
         THEN 'PASS' ELSE 'FAIL' END AS status,
    s.events AS source_events, d.events AS dwh_events,
    s.grain_rows AS source_grain_rows, d.grain_rows AS dwh_rows,
    s.underqualified AS source_underqualified, d.underqualified AS dwh_underqualified
FROM src s CROSS JOIN dwh d;
