
-- 16.0.0  Determine Appropriate Warehouse Sizes
--         The purpose of this lab is to familiarize you with how different
--         warehouse sizes impact the performance of a query.
--         This lab is immediately applicable to many personas. If you’re a data
--         analyst, you’ll see how different warehouse sizes can save you and
--         your business users valuable time. If you’re a data engineer, you’ll
--         learn the importance of choosing appropriate warehouse sizes for your
--         work. If you’re a database admin, you’ll learn how important it is to
--         allocate appropriately-sized warehouses for particular groups of
--         users.
--         - How to resize warehouses
--         - How to use the query profile to monitor query performance
--         - How to use the INFORMATION_SCHEMA and QUERY_HISTORY view to analyze
--         query performance
--         In this task you will disable the query result cache, and run the
--         same query on different sized warehouses to determine which is the
--         best size for the query. You will suspend your warehouse after each
--         test, to clear the data cache so the performance of the next query is
--         not artificially enhanced.
--         Remember, scaling warehouse size up (for more complex queries) and
--         down (for less complex queries) is a strategy for either making
--         complex queries more performant or saving compute charges in the case
--         of less complex queries. In this example, we introduce a query that
--         requires a scaling up/down strategy (it has a lot of data, includes
--         numerous joins and has more than one filter in the WHERE clause).
--         HOW TO COMPLETE THIS LAB
--         In order to complete this lab, you can type the SQL commands below
--         directly into a worksheet. It is not recommended that you cut and
--         paste from the workbook pdf as that sometimes results in errors.
--         You can also use the SQL code file for this lab that was provided at
--         the start of the class. To open an .SQL file in Snowsight, make sure
--         the Worksheet section is selected on the left-hand navigation bar.
--         Click on the ellipsis between the Search and +Worksheet buttons. In
--         the dropdown menu, select Create Worksheet from SQL File.
--         Let’s get started!

-- 16.1.0  Run a sample query with an extra small warehouse
--         NOTE: You are going to run the same query several times but with a
--         different size warehouse each time. Keep the Query Profile browser
--         tab open each time you run a query so you can make comparisons later.

-- 16.1.1  Navigate to [Worksheets].

-- 16.1.2  Create a new worksheet named Warehouse Sizing with the following
--         context:

USE ROLE TRAINING_ROLE;
CREATE WAREHOUSE IF NOT EXISTS COBRA_WH;
USE SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL;
USE WAREHOUSE COBRA_WH;


-- 16.1.3  Change the size of your warehouse to Xsmall:

ALTER WAREHOUSE COBRA_WH
SET WAREHOUSE_SIZE = XSmall WAIT_FOR_COMPLETION = TRUE;


-- 16.1.4  Suspend and resume the warehouse to make sure its data cache is
--         empty, disable the query result cache and set a query tag:

ALTER WAREHOUSE COBRA_WH SUSPEND;
ALTER WAREHOUSE COBRA_WH RESUME;
ALTER SESSION SET USE_CACHED_RESULT = FALSE;
ALTER SESSION SET QUERY_TAG = 'COBRA_WH_Sizing';


-- 16.1.5  Run the following query
--         This query will list detailed catalog sales data together with a
--         running sum of sales price within the order (it will take several
--         minutes to run):

SELECT cs_bill_customer_sk, cs_order_number, i_product_name, cs_sales_price, SUM(cs_sales_price)
OVER (PARTITION BY cs_order_number
   ORDER BY i_product_name
   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) run_sum
FROM catalog_sales, date_dim, item
WHERE cs_sold_date_sk = d_date_sk
AND cs_item_sk = i_item_sk
AND d_year IN (2000) AND d_moy IN (1,2,3,4,5,6)
LIMIT 100;


-- 16.1.6  View the query profile, and click on the operator WindowFunction[1].

-- 16.1.7  Take note of the performance metrics for this operator
--         You should see significant spilling to local storage, and possibly
--         spilling to remote storage.
--         The spill to local storage indicates the warehouse did not have
--         enough memory, and so it spilled to local SSD storage.
--         If it spills to remote storage, the warehouse did not have enough SSD
--         storage to store the spill from memory on its local SSD drive.

-- 16.1.8  Take note of the performance on the small warehouse.
--         Warehouse Performance

-- 16.2.0  Run a sample query with a small warehouse

-- 16.2.1  Suspend your warehouse, change its size to small, and resume it:

ALTER WAREHOUSE COBRA_WH SUSPEND;
ALTER WAREHOUSE COBRA_WH SET WAREHOUSE_SIZE = small WAIT_FOR_COMPLETION = TRUE;
ALTER WAREHOUSE COBRA_WH RESUME;


-- 16.2.2  Re-run the test query:

SELECT cs_bill_customer_sk, cs_order_number, i_product_name, cs_sales_price, SUM(cs_sales_price)
OVER (PARTITION BY cs_order_number
   ORDER BY i_product_name
   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) run_sum
FROM catalog_sales, date_dim, item
WHERE cs_sold_date_sk = d_date_sk
AND cs_item_sk = i_item_sk
AND d_year IN (2000) AND d_moy IN (1,2,3,4,5,6)
LIMIT 100;


-- 16.2.3  View the query profile, and click the operator WindowFunction[1].

-- 16.2.4  Take note of the performance metrics for this operator.
--         You should see lower amounts spilling to local storage and remote
--         disk, as well as faster execution.

-- 16.3.0  Run a sample query with a medium warehouse

-- 16.3.1  Suspend your warehouse, change its size to Medium, and resume it:

ALTER WAREHOUSE COBRA_WH SUSPEND;
ALTER WAREHOUSE COBRA_WH SET WAREHOUSE_SIZE = Medium WAIT_FOR_COMPLETION = TRUE;
ALTER WAREHOUSE COBRA_WH RESUME;


-- 16.3.2  Re-run the test query:

SELECT cs_bill_customer_sk, cs_order_number, i_product_name, cs_sales_price, SUM(cs_sales_price)
OVER (PARTITION BY cs_order_number
   ORDER BY i_product_name
   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) run_sum
FROM catalog_sales, date_dim, item
WHERE cs_sold_date_sk = d_date_sk
AND cs_item_sk = i_item_sk
AND d_year IN (2000) AND d_moy IN (1,2,3,4,5,6)
LIMIT 100;


-- 16.3.3  View the query profile, and click the operator WindowFunction[1].

-- 16.3.4  Take note of the performance metrics for this operator.
--         You should see lower amounts spilling to local storage and remote
--         disk, as well as faster execution.

-- 16.4.0  Run a sample query with a large warehouse

-- 16.4.1  Suspend your warehouse, change its size to Large, and resume it:

ALTER WAREHOUSE COBRA_WH SUSPEND;
ALTER WAREHOUSE COBRA_WH SET WAREHOUSE_SIZE = Large WAIT_FOR_COMPLETION = TRUE;
ALTER WAREHOUSE COBRA_WH RESUME;


-- 16.4.2  Re-run the test query:

SELECT cs_bill_customer_sk, cs_order_number, i_product_name, cs_sales_price, SUM(cs_sales_price)
OVER (PARTITION BY cs_order_number
   ORDER BY i_product_name
   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) run_sum
FROM catalog_sales, date_dim, item
WHERE cs_sold_date_sk = d_date_sk
AND cs_item_sk = i_item_sk
AND d_year IN (2000) AND d_moy IN (1,2,3,4,5,6)
LIMIT 100;


-- 16.4.3  Take note of the performance metrics for this operator.
--         You will see that there is no spilling to local or remote storage.

-- 16.5.0  Run a sample query with an extra large warehouse

-- 16.5.1  Suspend the warehouse, change it to XLarge in size, and resume it:

ALTER WAREHOUSE COBRA_WH SUSPEND;
ALTER WAREHOUSE COBRA_WH SET WAREHOUSE_SIZE = XLarge WAIT_FOR_COMPLETION = TRUE;
ALTER WAREHOUSE COBRA_WH RESUME;


-- 16.5.2  Re-run the test query.

SELECT cs_bill_customer_sk, cs_order_number, i_product_name, cs_sales_price, SUM(cs_sales_price)
OVER (PARTITION BY cs_order_number
   ORDER BY i_product_name
   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) run_sum
FROM catalog_sales, date_dim, item
WHERE cs_sold_date_sk = d_date_sk
AND cs_item_sk = i_item_sk
AND d_year IN (2000) AND d_moy IN (1,2,3,4,5,6)
LIMIT 100;


-- 16.5.3  Note the performance.

-- 16.5.4  Suspend your warehouse, and change its size to XSmall:
--         Now we’re going to run some queries to analyze performance. We’re
--         going to change the warehouse size and remove the query tag from our
--         session.

ALTER WAREHOUSE COBRA_WH SUSPEND;
ALTER WAREHOUSE COBRA_WH SET WAREHOUSE_SIZE = XSmall WAIT_FOR_COMPLETION = TRUE;
ALTER SESSION UNSET QUERY_TAG;


-- 16.5.5  View query history results for the performance tests
--         Run a query showing the query history results for these performance
--         tests using the table function
--         INFORMATION_SCHEMA.QUERY_HISTORY_BY_SESSION()

SELECT query_id,query_text, warehouse_size,(execution_time / 1000) Time_in_seconds 
    FROM TABLE(information_schema.query_history_by_session())
WHERE  query_tag = 'COBRA_WH_Sizing' 
AND WAREHOUSE_SIZE IS NOT NULL
AND QUERY_TYPE LIKE 'SELECT' ORDER BY start_time DESC;

--         This query tells us how fast each query ran but not how many
--         partitions were scanned. Let’s take a look at partitions scanned and
--         bytes spilled to local storage.

-- 16.5.6  Dig further into query history results for performance tests
--         This query will show more information, but the ACCOUNT_USAGE schema
--         has a latency of up to 45 minutes on the QUERY_HISTORY view.

SELECT query_id,query_text, warehouse_size,(execution_time / 1000) Time_in_seconds, partitions_total, partitions_scanned,
        bytes_spilled_to_local_storage, bytes_spilled_to_remote_storage, query_load_percent
FROM "SNOWFLAKE"."ACCOUNT_USAGE"."QUERY_HISTORY" 
WHERE  query_tag = 'COBRA_WH_Sizing' 
AND WAREHOUSE_SIZE IS NOT NULL
AND QUERY_TYPE LIKE 'SELECT' ORDER BY start_time DESC;

--         As we can see, the large warehouse was the first one not to spill
--         bytes to storage, which resulted in a dramatic increase on
--         performance. While the X-Large warehouse also did not spill bytes to
--         storage and ran the query even faster, you could select either size
--         warehouse based on the speed with which you need to have the result
--         returned to you. The thing to keep in mind however is that the extra
--         large warehouse will burn more credits. So if you can live with a
--         slightly slower performance in this instance, the Large warehouse is
--         probably the right size.

-- 16.5.7  Suspend the warehouse

ALTER WAREHOUSE COBRA_WH SUSPEND;


-- 16.6.0  Key Takeaways
--         - Scaling up can make complex queries more performant; scaling down
--         for less complex queries can save you compute credits.
--         - You can analyze output from functions provided in the
--         INFORMATION_SCHEMA and the ACCOUNT_USAGE.query_history view to
--         determine query performance.
--         - Bigger isn’t always better when choosing a warehouse size. It’s
--         important to choose the right sized warehouse for the performance you
--         need but not needlessly burn compute credits.
