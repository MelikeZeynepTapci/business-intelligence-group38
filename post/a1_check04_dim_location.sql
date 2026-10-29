-- DWH1 post-ETL check: dim_location contains every staging city once and every country is mapped to a region
-- The orchestrator supplies the warehouse/staging search_path for this transaction.

WITH stats AS (
    SELECT
        (SELECT COUNT(*) FROM tb_city) AS source_cities
        , (SELECT COUNT(*) FROM dim_location) AS dwh_cities
        , (SELECT COUNT(DISTINCT countryid) FROM dim_location) AS dwh_countries
        , (SELECT COUNT(*) FROM tb_country) AS source_countries
        , (SELECT COUNT(*) FROM dim_location WHERE regionname = 'Other') AS unmapped_regions
)
SELECT
    'dim_location complete and region hierarchy mapped' AS check_name,
    CASE WHEN source_cities = dwh_cities AND source_countries = dwh_countries AND unmapped_regions = 0
         THEN 'PASS' ELSE 'FAIL' END AS status,
    source_cities, dwh_cities, source_countries, dwh_countries, unmapped_regions
FROM stats;
