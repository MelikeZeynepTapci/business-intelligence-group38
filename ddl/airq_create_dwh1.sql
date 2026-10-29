-- DWH1 warehouse DDL
-- Creates the dimensional-model tables in the active warehouse schema.
-- The orchestrator supplies the correct search_path before this file is executed.
--
-- Shared by both facts : dim_location, dim_timemonth
-- Fact 2 (Student B)   : ft_servicemonthly  + dim_servicetype
-- Fact 1 (Student A)   : ft_name1           + dim_name3, dim_name4   (placeholders, TODO Student A)

-- -------------------------------
-- 1) DROP TABLE (facts first, then dimensions)
-- -------------------------------
DROP TABLE IF EXISTS ft_servicemonthly;
DROP TABLE IF EXISTS ft_name1;

DROP TABLE IF EXISTS dim_timemonth;
DROP TABLE IF EXISTS dim_servicetype;
DROP TABLE IF EXISTS dim_location;
DROP TABLE IF EXISTS dim_name4;
DROP TABLE IF EXISTS dim_name3;

-- -------------------------------
-- 2) CREATE TABLE statements
-- -------------------------------

-- Shared dimension. Hierarchy: city -> country -> region
CREATE TABLE dim_location (
    id INT NOT NULL PRIMARY KEY            -- = tb_city.id
    , cityname VARCHAR(255) NOT NULL
    , citypopulation INT NOT NULL
    , latitude DECIMAL(10,4) NOT NULL
    , longitude DECIMAL(10,4) NOT NULL
    , countryid INT NOT NULL
    , countryname VARCHAR(255) NOT NULL
    , countrypopulation INT NOT NULL
    , regionname VARCHAR(50) NOT NULL      -- derived from country (UN geoscheme)
    , etl_load_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Hierarchy: service type -> service group -> category
CREATE TABLE dim_servicetype (
    id INT NOT NULL PRIMARY KEY            -- = tb_servicetype.id
    , typename VARCHAR(255) NOT NULL
    , servicegroup VARCHAR(255) NOT NULL
    , category VARCHAR(255) NOT NULL
    , minlevel INT NOT NULL
    , minlevelname VARCHAR(20) NOT NULL    -- Entry, Junior, Senior, Lead
    , details VARCHAR(255) NOT NULL
    , etl_load_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Shared time dimension. Hierarchy: month -> quarter -> year
CREATE TABLE dim_timemonth (
    id INT NOT NULL PRIMARY KEY            -- YYYYMM, e.g. 202405
    , monthstart DATE NOT NULL
    , monthnum INT NOT NULL
    , monthname VARCHAR(20) NOT NULL
    , quarternum INT NOT NULL
    , quarterlabel VARCHAR(10) NOT NULL    -- e.g. 2024-Q2
    , yearnum INT NOT NULL
    , etl_load_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- TODO Student A: dimensions for Fact 1
CREATE TABLE dim_name3 (
    id INT NOT NULL PRIMARY KEY
    , etl_load_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE dim_name4 (
    id INT NOT NULL PRIMARY KEY
    , etl_load_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- TODO Student A: Fact 1 (should reference dim_location and dim_timemonth)
CREATE TABLE ft_name1 (
    id INT NOT NULL PRIMARY KEY
    , etl_load_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Fact 2 (Student B)
-- Grain: one row per city x service type x month
CREATE TABLE ft_servicemonthly (
    id SERIAL PRIMARY KEY
    , locationid INT NOT NULL
    , servicetypeid INT NOT NULL
    , timemonthid INT NOT NULL
    , servicecount INT NOT NULL            -- fully additive
    , totalcost BIGINT NOT NULL            -- fully additive
    , totaldurationmin BIGINT NOT NULL     -- fully additive
    , underqualifiedcount INT NOT NULL     -- fully additive: technician role level < required minlevel
    , avgservicequality DECIMAL(4,2) NOT NULL  -- non-additive (re-weight with servicecount)
    , etl_load_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    , CONSTRAINT fk_ftservice_location FOREIGN KEY (locationid) REFERENCES dim_location(id)
    , CONSTRAINT fk_ftservice_servicetype FOREIGN KEY (servicetypeid) REFERENCES dim_servicetype(id)
    , CONSTRAINT fk_ftservice_timemonth FOREIGN KEY (timemonthid) REFERENCES dim_timemonth(id)
    , CONSTRAINT uc_ftservice_grain UNIQUE (locationid, servicetypeid, timemonthid)
);
