
-- 10.0.0  Snowflake Functions
--         The purpose of this lab is to introduce you to Snowflake’s large,
--         built-in function library.
--         Most of the time, the average Snowflake user uses three Snowflake
--         components to get work done: core SQL constructs (SQL itself), the
--         compute layer, and functions. In other words, functions are useful to
--         every workload, to include data engineering, data lake, data
--         warehousing, data science, data applications and even data sharing.
--         In this lab you’ll become familiar with a handful of SQL functions.
--         In fact, you may be familiar with similar or identical functions from
--         other database or data warehouse systems.
--         - How to work with scalar functions
--         - How to work with regular and windowing aggregate functions
--         - How to use table and system functions
--         - How to use FLATTEN to work with semi-structured (JSON) data
--         HOW TO COMPLETE THIS LAB
--         In order to complete this lab, you can type the SQL commands below
--         directly into a worksheet. It is not recommended that you cut and
--         paste from the workbook pdf as that sometimes results in errors.
--         You can also use the SQL code file for this lab that was provided at
--         the start of the class. To open an .SQL file in Snowsight, make sure
--         the Worksheet section is selected on the left-hand navigation bar.
--         Click on the ellipsis between the Search and +Worksheet buttons. In
--         the dropdown menu, select Create Worksheet from SQL File.

-- 10.1.0  Scalar Functions
--         Scalar functions take a single row or value as input and return a
--         single value, such as a number, a string, or a boolean value.
--         Click here to learn more about Snowflake’s scalar functions.
--         (https://docs.snowflake.com/en/sql-reference/account-
--         usage.html#reader-account-usage-views)
--         Now let’s try using a few scalar functions. Note that although you
--         are probably familiar with most if not all of them, some may have
--         different names or syntax than what you’ve seen in other systems. For
--         example, while some systems use an IF…THEN syntax for if-then
--         statements, Snowflake uses IFF().

-- 10.1.1  Open a worksheet and name it Functions and set the context:

USE ROLE TRAINING_ROLE;
CREATE WAREHOUSE IF NOT EXISTS COBRA_WH;
USE WAREHOUSE COBRA_WH;
CREATE DATABASE IF NOT EXISTS COBRA_DB;
USE COBRA_DB.PUBLIC;


-- 10.1.2  String functions: UPPER
--         Execute the statement below to convert c_name to uppercase.

SELECT
          c_name
        , UPPER(c_name)
FROM
        "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1"."CUSTOMER";


-- 10.1.3  Conditional Functions: IFF
--         Execute the following statements using the conditional function IFF
--         to see what it does. Note that the double colon (::) casts the result
--         of the IFF function to a number that is 16 digits long and with 2
--         decimal places.

SELECT  
    o_orderkey,
    o_totalprice,
    o_orderpriority,
    IFF(o_orderpriority LIKE '1-URGENT', o_totalprice * 0.01, o_totalprice * 0.005)::NUMBER(16,2) AS ShippingCost  
FROM 
    "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1"."ORDERS";


-- 10.1.4  Conditional Functions: CASE
--         Here you’ll use a conditional function to label a customer as
--         preferred or not preferred. You’ll also use a CASE expression to
--         print out text for preferred customers.

SELECT (c_salutation || ' ' || c_first_name || ' ' || c_last_name) AS full_name,
    CASE
        WHEN c_preferred_cust_flag LIKE 'Y'
            THEN 'Preferred Customer'
        WHEN c_preferred_cust_flag LIKE 'N'
            THEN 'Not Preferred Customer'
    END AS customer_status
FROM
    "SNOWFLAKE_SAMPLE_DATA"."TPCDS_SF100TCL"."CUSTOMER"
LIMIT 100;



-- 10.1.5  Numeric Functions: RANDOM
--         Use the following statements to generate data. Note that random()
--         with no argument generates a different number every time. If you
--         provide a seed value, for example, random(12), the same value will be
--         returned every time:

SELECT RANDOM() AS random_variable;

SELECT RANDOM(100) AS random_fixed;


-- 10.1.6  Context Functions
--         Run this query to use some context functions:

SELECT CURRENT_DATE(), DATE_PART('DAY', CURRENT_DATE()), CURRENT_TIME();


-- 10.1.7  String Functions: Converting strings to arrays and arrays to strings
--         Run this statement to change an array back to a string with a
--         separator:

SELECT
          STRTOK_TO_ARRAY(query_text)
        , ARRAY_TO_STRING(STRTOK_TO_ARRAY(query_text),'#')
FROM
        SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE
        query_text LIKE 'select%'
        AND
        query_text NOT LIKE 'select 1%'
LIMIT 5;


-- 10.1.8  Aggregate Functions: AVG, MIN, MAX, STDDEV
--         Here we use a query to produce aggregates on the total execution time
--         of past queries. The SQL statement below accomplishes this by
--         querying the QUERY_HISTORY secure view in the ACCOUNT_USAGE schema of
--         the Snowflake database.

SELECT
          MONTH(qh.start_time) AS "month"
        , DAYOFMONTH(qh.start_time) AS dom
        , qh.warehouse_name
        , AVG(qh.total_elapsed_time)
        , MIN(qh.total_elapsed_time)
        , MAX(qh.total_elapsed_time)
        , STDDEV(qh.total_elapsed_time)
FROM
        SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY qh
WHERE
        query_text LIKE 'select%'
        AND
        query_text NOT LIKE 'select 1%'
GROUP BY
        "month", dom, qh.warehouse_name
ORDER BY
        "month", dom, qh.warehouse_name;


-- 10.2.0  Use Regular and Windows Aggregate Functions
--         Aggregate functions work across rows to perform mathematical
--         functions such as MIN, MAX, COUNT, and a variety of statistical
--         functions.
--         Many of the aggregate functions can work with the OVER clause
--         enabling aggregations across a group of rows. This is called a WINDOW
--         function.
--         In this section you will work with some of the aggregate window
--         functions.
--         Click here to learn more about Snowflake’s Window functions.
--         Click here to learn more about Snowflake’s Aggregate functions.

-- 10.2.1  WINDOW functions:
--         Here we use a query to determine the SUM of credits per warehouse and
--         day of the month. The SQL statement below accomplishes this by
--         querying the WAREHOUSE_METERING_HISTORY secure view in the
--         ACCOUNT_USAGE schema of the Snowflake database. We partition by day
--         of the month and warehouse name.

SELECT
          DAYOFMONTH(start_time) AS DAY_OF_MONTH
        , DATE(START_TIME) AS DT
        , warehouse_name
        , credits_used
        , SUM(credits_used)
            OVER (PARTITION BY DAYOFMONTH(start_time), warehouse_name
            ORDER BY DAYOFMONTH(start_time), warehouse_name ) AS day_tot_credits
FROM
        SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY

GROUP BY
        DAY_OF_MONTH, warehouse_name, DT, credits_used

ORDER BY
        DAY_OF_MONTH, warehouse_name, DT, credits_used;


-- 10.3.0  TABLE and System Functions
--         Table functions return a set of rows instead of a single scalar
--         value. Table functions appear in the FROM clause of a SQL statement
--         and cannot be used as scalar functions.
--         System functions are functions that allow you to execute actions in
--         the system, or that return information about queries or the system
--         itself.

-- 10.3.1  Use a table function to retrieve 1 hour of query history:

SELECT
        *
FROM
        TABLE(information_schema.query_history
            (DATEADD('hours', -1, CURRENT_TIMESTAMP()), CURRENT_TIMESTAMP()))
ORDER BY
        start_time;


-- 10.3.2  Use the RESULT_SCAN function to return the last result set:
--         The function RESULT_SCAN returns the result set of a previous command
--         (within 24 hours of when you executed the query) as if the result
--         were a table. This is useful if you want to process the output of
--         SHOW or DESCRIBE, the output of a query executed on account usage
--         information, such as INFORMATION_SCHEMA or ACCOUNT_USAGE, or the
--         output of a stored procedure.
--         The query below is simple and just produces the results of the last
--         query you ran.

SELECT * FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));


-- 10.3.3  Use the SHOW command with the RESULT_SCAN function to have SQL
--         generate a list of commands to describe tables:
--         Note that Snowflake’s SQL is generally case-insensitive. It usually
--         changes identifiers to upper case unless they are enclosed in quotes.
--         In this example, the name column must be lower case, so it is placed
--         in quotation marks.

SHOW TABLES;
SELECT CONCAT('DESC ',"name",';')
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));


-- 10.3.4  SYSTEM$WHITELIST
--         The SYSTEM$WHITELIST function enables you to see information on hosts
--         that should be unblocked for Snowflake to work. Click on the item in
--         the first row to see what the column contains:

SELECT SYSTEM$WHITELIST();

--         Note that the data is in semi-structured format and that the output
--         of the column SYSTEM$WHITELIST() is a link. Click on a link to view
--         the data.

-- 10.3.5  SYSTEM$WHITELIST, Semi-structured data and FLATTEN
--         Now we’re going to use the FLATTEN table function to flatten the data
--         for the previous query so it appears more like structured data.

SELECT VALUE:type AS type,
       VALUE:host AS host,
       VALUE:port AS port
FROM TABLE(FLATTEN(INPUT => PARSE_JSON(system$whitelist())));


-- 10.3.6  Suspend and resize the warehouse

ALTER WAREHOUSE COBRA_WH SET WAREHOUSE_SIZE=XSmall;
ALTER WAREHOUSE COBRA_WH SUSPEND;


-- 10.4.0  Key Takeaways
--         - Snowflake has many of the functions you are already accustomed to
--         using in other software programs.
--         - You can query the query history secure view
--         (SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY) to produce numeric aggregates
--         on query execution times.
--         - Table functions return a set of rows rather than a scalar value.
--         - System functions are functions that allow you to execute actions in
--         the system, or that return information about queries or the system
--         itself.
