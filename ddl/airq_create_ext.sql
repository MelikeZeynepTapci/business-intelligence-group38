-- DWH1 staging extension DDL
-- Define the two student-created OLTP extension tables in the active staging schema.
-- The orchestrator supplies the correct search_path before this file is executed.

-- Table_X: tb_certification - certification schemes a sensor model can hold
-- Table_Y: tb_sensortypecertification - bridge (m:n) between tb_sensortype and tb_certification

-- -------------------------------
-- 1) DROP TABLE before attempting to create OLTP snapshot tables
-- -------------------------------
DROP TABLE IF EXISTS tb_sensortypecertification;
DROP TABLE IF EXISTS tb_certification;

-- Table_X
CREATE TABLE tb_certification (
    id INT NOT NULL PRIMARY KEY
    , certname VARCHAR(255) NOT NULL
    , issuer VARCHAR(255) NOT NULL
    , certtype VARCHAR(50) NOT NULL -- 'Reference', 'Performance', 'Safety', 'Durability', 'Quality'
    , CHECK (certtype IN ('Reference', 'Performance', 'Safety', 'Durability', 'Quality'))
    , CONSTRAINT uc_certification_certname UNIQUE (certname)
);

-- Table_Y
CREATE TABLE tb_sensortypecertification (
    id INT NOT NULL PRIMARY KEY
    , sensortypeid INT NOT NULL
    , certificationid INT NOT NULL
    , certifiedat DATE NOT NULL
    , CONSTRAINT fk_stcert_sensortypeid FOREIGN KEY (sensortypeid) REFERENCES tb_sensortype(id)
    , CONSTRAINT fk_stcert_certificationid FOREIGN KEY (certificationid) REFERENCES tb_certification(id)
    , CONSTRAINT uc_sensortype_certification UNIQUE (sensortypeid, certificationid)
);
