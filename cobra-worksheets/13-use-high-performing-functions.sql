
-- 13.0.0  Use High-Performing Functions
--         In order to do this lab, you can key SQL commands presented in this
--         lab directly into a worksheet. You can also use the code file for
--         this lab that was provided at the start of the class. To use the
--         file, simply drag and drop it into an open worksheet. It is not
--         recommended that you cut and paste from the workbook pdf as that
--         sometimes results in errors.
--         This lab should take approximately 20 minutes to complete.

-- 13.1.0  Use Approximate Count Functions

-- 13.1.1  Navigate to [Worksheets] and create a worksheet named Function
--         Junction.

-- 13.1.2  Alter the session so it does not use cached results:

ALTER SESSION SET use_cached_result=false;


-- 13.1.3  Set the Worksheet contexts as follows:

USE ROLE TRAINING_ROLE;
USE WAREHOUSE COBRA_WH;
USE DATABASE SNOWFLAKE_SAMPLE_DATA;
USE SCHEMA TPCH_SF100;


-- 13.1.4  Change the virtual warehouse size to XSmall, then suspend and resume
--         the warehouse to clear any data in the warehouse cache:

ALTER WAREHOUSE COBRA_WH
    SET WAREHOUSE_SIZE = 'XSmall';

ALTER WAREHOUSE COBRA_WH SUSPEND;
ALTER WAREHOUSE COBRA_WH RESUME;


-- 13.1.5  Use the query below to determine an approximate count with
--         Snowflake’s Hyperloglog high-performing function:

SELECT HLL(l_orderkey) FROM lineitem;


-- 13.1.6  Suspend and resume the warehouse again to clear the data cache.

-- 13.1.7  Execute the regular COUNT version of the query:

SELECT COUNT(DISTINCT l_orderkey) FROM lineitem;


-- 13.1.8  Compare the execution time of the two queries in steps 4 and 6.

-- 13.1.9  Note that the HLL approximate count version is much faster than the
--         regular count version.

-- 13.2.0  Use Percentile Estimation Functions
--         The APPROX_PERCENTILE function is the more efficient version of the
--         regular SQL MEDIAN function.

-- 13.2.1  Change your warehouse size to XLarge:

ALTER WAREHOUSE COBRA_WH
    SET WAREHOUSE_SIZE = 'Xlarge';

ALTER WAREHOUSE COBRA_WH SUSPEND;
ALTER WAREHOUSE COBRA_WH RESUME;


-- 13.2.2  Start by using the SQL Median Function. Given the store_sales table
--         with over 28 billion rows, the following statement determines the
--         median store sales for each store identified in the store_sales
--         table: This will take almost 15 minutes to run.

USE SCHEMA SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10tcl;
SELECT MEDIAN(ss_sales_price), ss_store_sk
FROM store_sales
GROUP BY ss_store_sk;


-- 13.2.3  Review the query results returned, as well as the total duration time
--         the statement took to complete.
--         Query History Details - Median Function

-- 13.2.4  Run the Percentile Estimation Function on the same store_sales table
--         to find the approximate 50th percentile of store sales for each store
--         identified in the store_sales table:

USE SCHEMA SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10tcl;
SELECT APPROX_PERCENTILE(ss_sales_price, 0.5), ss_store_sk
FROM store_sales
GROUP BY ss_store_sk;


-- 13.2.5  Review the time it took to complete, and the value returned. Not only
--         was it faster, but it produced a result almost identical to that of
--         MEDIAN. This will take approximately 5 minutes to run.
--         Query History Details - Median Approximate Function

-- 13.2.6  Change your warehouse size to XSmall:

ALTER WAREHOUSE COBRA_WH
    SET WAREHOUSE_SIZE = 'XSmall';

ALTER WAREHOUSE COBRA_WH SUSPEND;
ALTER WAREHOUSE COBRA_WH RESUME;

