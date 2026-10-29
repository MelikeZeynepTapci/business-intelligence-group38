-- DWH1 ETL: load dim_timemonth (month -> quarter -> year)
-- Covers every month between the first and last reading/service date.
-- The orchestrator supplies the warehouse/staging search_path for this transaction.

TRUNCATE TABLE dim_timemonth RESTART IDENTITY CASCADE;

INSERT INTO dim_timemonth (id, monthstart, monthnum, monthname, quarternum, quarterlabel, yearnum)
SELECT
    CAST(EXTRACT(YEAR FROM m) * 100 + EXTRACT(MONTH FROM m) AS INT)
    , CAST(m AS DATE)
    , CAST(EXTRACT(MONTH FROM m) AS INT)
    , TRIM(TO_CHAR(m, 'Month'))
    , CAST(EXTRACT(QUARTER FROM m) AS INT)
    , CONCAT(EXTRACT(YEAR FROM m), '-Q', EXTRACT(QUARTER FROM m))
    , CAST(EXTRACT(YEAR FROM m) AS INT)
FROM generate_series(
        (SELECT DATE_TRUNC('month', MIN(d)) FROM (
            SELECT MIN(readat) AS d FROM tb_readingevent
            UNION ALL SELECT MIN(servicedat) FROM tb_serviceevent) x)
      , (SELECT DATE_TRUNC('month', MAX(d)) FROM (
            SELECT MAX(readat) AS d FROM tb_readingevent
            UNION ALL SELECT MAX(servicedat) FROM tb_serviceevent) y)
      , INTERVAL '1 month') AS m
ORDER BY m;
