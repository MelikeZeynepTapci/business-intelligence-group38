-- DWH1 ETL: load dim_location (shared dimension: city -> country -> region)
-- The orchestrator supplies the warehouse/staging search_path for this transaction.

TRUNCATE TABLE dim_location RESTART IDENTITY CASCADE;

INSERT INTO dim_location (id, cityname, citypopulation, latitude, longitude
    , countryid, countryname, countrypopulation, regionname)
SELECT
    ci.id
    , ci.cityname
    , ci.population
    , ci.latitude
    , ci.longitude
    , co.id
    , co.countryname
    , co.population
    , CASE
        WHEN co.countryname IN ('Austria', 'Belgium', 'France', 'Germany', 'Netherlands') THEN 'Western Europe'
        WHEN co.countryname IN ('Belarus', 'Czech Republic', 'Hungary', 'Poland', 'Russia') THEN 'Eastern Europe'
        WHEN co.countryname IN ('Denmark', 'Finland', 'Sweden', 'United Kingdom') THEN 'Northern Europe'
        WHEN co.countryname IN ('Croatia', 'Greece', 'Italy', 'Serbia', 'Spain') THEN 'Southern Europe'
        WHEN co.countryname IN ('Turkey') THEN 'Western Asia'
        ELSE 'Other'
      END
FROM tb_city ci
JOIN tb_country co ON co.id = ci.countryid
ORDER BY ci.id;
