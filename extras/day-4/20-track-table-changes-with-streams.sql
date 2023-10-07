
-- 20.0.0  Track Table Changes with Streams
--         This lab will take approximately 25 minutes to complete.

-- 20.1.0  Create Basic Table Streams
--         In this exercise, we will introduce the basic workflow around streams
--         as well as explore the differences between delta and append-only
--         streams.

-- 20.1.1  Navigate to Worksheets and create a new worksheet.

-- 20.1.2  Name the worksheet Introduction to Streams.

-- 20.1.3  Set the Worksheet context as follows:

USE ROLE TRAINING_ROLE;
USE WAREHOUSE INSTRUCTOR1_LOAD_WH;
USE SCHEMA INSTRUCTOR1_DB.PUBLIC;


-- 20.1.4  Create a source table.

CREATE OR REPLACE TABLE data_staging
(
     CR_ORDER_NUMBER NUMBER(38,0)
    ,CR_ITEM_SK NUMBER(38,0)
    ,CR_RETURN_QUANTITY NUMBER(38,0)
    ,CR_NET_LOSS NUMBER(7,2)
);


-- 20.1.5  Create downstream tables to split the source data for different needs
--         - in this case inventory and cost:

CREATE OR REPLACE TABLE data_quantity
(
     CR_ORDER_NUMBER NUMBER(38,0)
    ,CR_ITEM_SK NUMBER(38,0)
    ,CR_RETURN_QUANTITY NUMBER(38,0)
);

CREATE OR REPLACE TABLE data_cost
(
     CR_ORDER_NUMBER NUMBER(38,0)
    ,CR_NET_LOSS NUMBER(7,2)
);


-- 20.1.6  Create the stream object on the source table:

CREATE OR REPLACE STREAM data_check ON TABLE data_staging;


-- 20.1.7  Load some sample data into the source table:

CREATE WAREHOUSE IF NOT EXISTS INSTRUCTOR1_LOAD_WH;
ALTER WAREHOUSE INSTRUCTOR1_LOAD_WH SET WAREHOUSE_SIZE = 'MEDIUM';

INSERT INTO data_staging
SELECT CR_ORDER_NUMBER
      ,CR_ITEM_SK
      ,CR_RETURN_QUANTITY
      ,CR_NET_LOSS
FROM "SNOWFLAKE_SAMPLE_DATA"."TPCDS_SF10TCL"."CATALOG_RETURNS" SAMPLE(5);


-- 20.1.8  After the data has loaded, query the table stream object.

SELECT
    CR_ORDER_NUMBER
    ,CR_ITEM_SK
    ,CR_RETURN_QUANTITY
    ,CR_NET_LOSS
    ,METADATA$ACTION
    ,METADATA$ISUPDATE
    ,METADATA$ROW_ID
FROM data_check
ORDER BY CR_ORDER_NUMBER LIMIT 10;

--         There are 3 metadata columns included in every row of a stream.

-- 20.2.0  Query Table Streams
--         Next we will access the stream and write the data into downstream
--         tables.

-- 20.2.1  Execute statements within a transaction block to consume the stream
--         data.
--         The stream will reset to a new offset when the transaction is
--         committed.

BEGIN;

    INSERT INTO data_quantity (CR_ORDER_NUMBER
                              ,CR_ITEM_SK
                              ,CR_RETURN_QUANTITY)
    SELECT CR_ORDER_NUMBER,CR_ITEM_SK,CR_RETURN_QUANTITY
    FROM data_check t
    WHERE METADATA$ACTION = 'INSERT';

    INSERT INTO data_cost (CR_ORDER_NUMBER,CR_NET_LOSS)
    SELECT t.CR_ORDER_NUMBER,t.CR_NET_LOSS
    FROM data_staging t
    JOIN data_quantity q
        ON t.CR_ORDER_NUMBER = q.CR_ORDER_NUMBER
        AND t.CR_ITEM_SK = q.CR_ITEM_SK;
COMMIT;


-- 20.2.2  Take a look at the data in the downstream tables:

SELECT * FROM data_quantity;

SELECT * FROM data_cost;


-- 20.2.3  Query the table stream to see how it looks after records have been
--         consumed:

SELECT * FROM data_check;


-- 20.3.0  Explore Delta and Append Streams
--         Streams come in two (2) primary varieties, Delta and Append.
--         To illustrate the difference you’ll create a second source table and
--         stream, populating it with the same records as the original source
--         table.

-- 20.3.1  Create a new source table.

CREATE OR REPLACE TABLE data_staging_append
    (
     CR_ORDER_NUMBER NUMBER(38,0)
    ,CR_ITEM_SK NUMBER(38,0)
    ,CR_RETURN_QUANTITY NUMBER(38,0)
    ,CR_NET_LOSS NUMBER(7,2)
    );


-- 20.3.2  Load the same set of data into both source tables:

TRUNCATE TABLE data_staging;

INSERT INTO data_staging
    SELECT CR_ORDER_NUMBER,CR_ITEM_SK,CR_RETURN_QUANTITY, CR_NET_LOSS
FROM "SNOWFLAKE_SAMPLE_DATA"."TPCDS_SF10TCL"."CATALOG_RETURNS" SAMPLE(5);

INSERT INTO data_staging_append
    SELECT * FROM data_staging;


-- 20.3.3  Create a delta stream on the table data_staging:

CREATE OR REPLACE STREAM delta ON TABLE data_staging;

--         A delta stream captures any cumulative changes to the source table.

-- 20.3.4  Create an append stream on the table data_staging_append:

CREATE OR REPLACE STREAM append_only ON TABLE data_staging_append APPEND_ONLY=TRUE;

--         An append stream only captures inserts to the source table.

-- 20.3.5  Perform the same UPDATE operation on both tables:

UPDATE data_staging
   SET CR_RETURN_QUANTITY = 0
   WHERE CR_RETURN_QUANTITY = 5;

UPDATE data_staging_append
   SET CR_RETURN_QUANTITY = 0
   WHERE CR_RETURN_QUANTITY = 5;


-- 20.3.6  Check the status of the table streams:

SELECT CR_ORDER_NUMBER
    ,CR_ITEM_SK
    ,CR_RETURN_QUANTITY
    ,CR_NET_LOSS
    ,METADATA$ACTION
    ,METADATA$ISUPDATE
    ,METADATA$ROW_ID
FROM delta
LIMIT 10;

SELECT CR_ORDER_NUMBER
    ,CR_ITEM_SK
    ,CR_RETURN_QUANTITY
    ,CR_NET_LOSS
    ,METADATA$ACTION
    ,METADATA$ISUPDATE
    ,METADATA$ROW_ID
FROM append_only
LIMIT 10;


-- 20.3.7  Undo the previous update:

UPDATE data_staging
   SET CR_RETURN_QUANTITY = 5
   WHERE CR_RETURN_QUANTITY = 0;

UPDATE data_staging_append
   SET CR_RETURN_QUANTITY = 5
   WHERE CR_RETURN_QUANTITY = 0;


-- 20.3.8  Check the status of the streams after the second update.

SELECT CR_ORDER_NUMBER
    ,CR_ITEM_SK
    ,CR_RETURN_QUANTITY
    ,CR_NET_LOSS
    ,METADATA$ACTION
    ,METADATA$ISUPDATE
    ,METADATA$ROW_ID
FROM DELTA
LIMIT 10;

SELECT CR_ORDER_NUMBER
    ,CR_ITEM_SK
    ,CR_RETURN_QUANTITY
    ,CR_NET_LOSS
    ,METADATA$ACTION
    ,METADATA$ISUPDATE
    ,METADATA$ROW_ID
FROM append_only
LIMIT 10;


-- 20.4.0  Pair Streams and Tasks
--         Streams and tasks can be used together to track changes to data over
--         time without the need for manual intervention.

-- 20.4.1  Navigate to Worksheets and create a new worksheet.

-- 20.4.2  Name the worksheet Streams & Tasks Together.

-- 20.4.3  Set the Worksheet context as follows:

USE ROLE TRAINING_ROLE;
USE WAREHOUSE INSTRUCTOR1_LOAD_WH;
USE SCHEMA INSTRUCTOR1_DB.PUBLIC;


-- 20.4.4  Create a basic data staging (source) table with a table stream and
--         downstream tables to use for the exercise:

CREATE OR REPLACE TABLE data_staging
(
     CR_ORDER_NUMBER NUMBER(38,0)
    ,CR_ITEM_SK NUMBER(38,0)
    ,CR_RETURN_QUANTITY NUMBER(38,0)
    ,CR_NET_LOSS NUMBER(7,2)
);

CREATE OR REPLACE STREAM data_check ON TABLE data_staging;


-- 20.4.5  Create downstream tables to use for the exercise:

CREATE OR REPLACE TABLE data_quantity 
(
     CR_ORDER_NUMBER NUMBER(38,0)
    ,CR_ITEM_SK NUMBER(38,0)
    ,CR_RETURN_QUANTITY NUMBER(38,0)
);

CREATE OR REPLACE TABLE data_cost 
(
    CR_ORDER_NUMBER NUMBER(38,0)
   ,CR_NET_LOSS NUMBER(7,2)
);


-- 20.4.6  Create a stored procedure that performs your transformations.
--         The stored procedure moves data downstream from our staging table.

CREATE OR REPLACE PROCEDURE usp_load_prod()
RETURNS STRING NOT NULL
LANGUAGE javascript
AS
$$
  var my_sql_command = ""
  
  var my_sql_command = "INSERT INTO data_quantity \
      (CR_ORDER_NUMBER,CR_ITEM_SK,CR_RETURN_QUANTITY) \
      SELECT CR_ORDER_NUMBER,CR_ITEM_SK,CR_RETURN_QUANTITY \
      FROM data_check t \
      WHERE METADATA$ACTION = 'INSERT'"; 

  var statement1 = snowflake.createStatement( {sqlText: my_sql_command} );
  var result_set1 = statement1.execute();
  
  var my_sql_command = "INSERT INTO data_cost (CR_ORDER_NUMBER,CR_NET_LOSS) \
                        SELECT t.CR_ORDER_NUMBER,t.CR_NET_LOSS \
                        FROM data_staging t \
                          JOIN data_quantity q \
                        ON t.CR_ORDER_NUMBER = q.CR_ORDER_NUMBER \
                        AND t.CR_ITEM_SK = q.CR_ITEM_SK;";

  var statement2 = snowflake.createStatement( {sqlText: my_sql_command} );
  var result_set2 = statement2.execute();

  return my_sql_command; // Statement returned for info/debug purposes
$$;


-- 20.4.7  Create a task to run the stored procedure on a regular basis.
--         The task will run on a schedule. If it finds data in the table
--         stream, it will execute the stored procedure:

CREATE OR REPLACE TASK capture_data
  WAREHOUSE = ANIMAL_TASK_WH
  SCHEDULE = 'USING cron * * * * * UTC'
WHEN
  SYSTEM$STREAM_HAS_DATA('data_check')
AS
  CALL usp_load_prod();

ALTER TASK capture_data RESUME;

SHOW TASKS;


-- 20.4.8  To test the task, insert some data into the staging table:

INSERT INTO data_staging
  SELECT CR_ORDER_NUMBER,CR_ITEM_SK,
  CR_RETURN_QUANTITY, CR_NET_LOSS
FROM "SNOWFLAKE_SAMPLE_DATA"."TPCDS_SF10TCL"."CATALOG_RETURNS" SAMPLE(5);

SELECT * FROM data_check LIMIT 20;


-- 20.4.9  After a couple of minutes, check the downstream tables to verify the
--         task executed:

SELECT TOP 10 * FROM data_quantity;

SELECT TOP 10 * FROM data_cost;


-- 20.4.10 Finally, suspend the task to avoid any unwanted credit spending:

ALTER TASK capture_data SUSPEND;


