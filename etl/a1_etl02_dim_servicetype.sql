-- DWH1 ETL: load dim_servicetype (service type -> service group -> category)
-- The orchestrator supplies the warehouse/staging search_path for this transaction.

TRUNCATE TABLE dim_servicetype RESTART IDENTITY CASCADE;

INSERT INTO dim_servicetype (id, typename, servicegroup, category, minlevel, minlevelname, details)
SELECT
    st.id
    , st.typename
    , st.servicegroup
    , st.category
    , st.minlevel
    , CASE st.minlevel WHEN 1 THEN 'Entry' WHEN 2 THEN 'Junior' WHEN 3 THEN 'Senior' WHEN 4 THEN 'Lead' END
    , st.details
FROM tb_servicetype st
ORDER BY st.id;
