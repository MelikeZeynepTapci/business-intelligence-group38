-- DWH1 ETL: load ft_servicemonthly (Fact 2, Student B)
-- Grain: one row per city x service type x month.
-- Underqualified = technician's role level at the time (tb_employee row) < tb_servicetype.minlevel.
-- The orchestrator supplies the warehouse/staging search_path for this transaction.

TRUNCATE TABLE ft_servicemonthly RESTART IDENTITY;

INSERT INTO ft_servicemonthly (locationid, servicetypeid, timemonthid
    , servicecount, totalcost, totaldurationmin, underqualifiedcount, avgservicequality)
SELECT
    sd.cityid
    , se.servicetypeid
    , CAST(EXTRACT(YEAR FROM se.servicedat) * 100 + EXTRACT(MONTH FROM se.servicedat) AS INT)
    , COUNT(*)
    , SUM(se.servicecost)
    , SUM(se.durationminutes)
    , SUM(CASE WHEN r.rolelevel < st.minlevel THEN 1 ELSE 0 END)
    , ROUND(AVG(se.servicequality), 2)
FROM tb_serviceevent se
JOIN tb_sensordevice sd ON sd.id = se.sensordevid
JOIN tb_servicetype st ON st.id = se.servicetypeid
JOIN tb_employee e ON e.id = se.employeeid
JOIN tb_role r ON r.id = e.roleid
GROUP BY sd.cityid, se.servicetypeid
    , CAST(EXTRACT(YEAR FROM se.servicedat) * 100 + EXTRACT(MONTH FROM se.servicedat) AS INT)
ORDER BY 3, 1, 2;
