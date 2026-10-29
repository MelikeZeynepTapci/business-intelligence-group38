-- DWH1 ETL: load dim_timeday
-- The orchestrator supplies the warehouse/staging search_path for this transaction.

-- Step 1: Truncate target table, the dim_timeday in this case
TRUNCATE TABLE dim_timeday RESTART IDENTITY;

-- Step 2: Insert data into the dim_timeday
INSERT INTO dim_timeday (id)
-- replace with your time-dimension generation logic
VALUES 
(1)
, (2)
, (3)
, (4)
, (5)




