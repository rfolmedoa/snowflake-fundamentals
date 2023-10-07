
-- 12.0.0  Using High-Performing Functions
--         As you know, common functions in relational database management
--         systems such as COUNT(DISTINCT) and percentage/percentile functions
--         require a scan and sort of an entire dataset to yield a result.
--         Although a cloud database like Snowflake is designed to handle
--         virtually unlimited quantities of data, executing a COUNT(DISTINCT)
--         on a very large cloud table could take far longer than a user is
--         willing to wait. Additionally, when working with very large datasets,
--         absolutely precise counts are unnecessary, especially if your data is
--         being updated in real time or near real time.
--         Snowflake’s high performing functions are designed to give you
--         approximate results that should satisfy your analytical needs but in
--         a far shorter time frame than a standard COUNT(DISTINCT). The purpose
--         of this lab is to give you hands-on experience with a couple of these
--         functions: HLL() or HyperLogLog, which can be used in lieu of the
--         standard COUNT(DISTINCT) function, and APPROX_PERCENTILE, which can
--         be used in lieu of the standard SQL MEDIAN function.
--         - How to leverage HyperLogLog to get an approximate count
--         - How to leverage APPROX_PERCENTILE to get an approximate median
--         You’ve just learned about a couple of Snowflake’s high performing
--         functions that you think may be useful for your analysis needs. One
--         is HyperLogLog, and the other is APPROX_PERCENTILE. You’ve decided to
--         try these out on a couple of tables that you know have anywhere from
--         hundreds of millions of rows to even billions of rows just to see how
--         they perform. This is your plan:
--         - Run both HyperLogLog and COUNT(DISTINCT) to see which returns a
--         result faster.
--         - Run both APPROX_PERCENTILE and MEDIAN() to see which returns a
--         result faster.
--         HOW TO COMPLETE THIS LAB
--         In order to complete this lab, you can key the SQL commands below
--         directly into a worksheet. It is not recommended that you cut and
--         paste from the workbook pdf as that sometimes results in errors.
--         You can also use the SQL code file for this lab that was provided at
--         the start of the class. To open an .SQL file in Snowsight, make sure
--         the Worksheet section is selected on the left-hand navigation bar.
--         Click on the ellipsis between the Search and +Worksheet buttons. In
--         the dropdown menu, select Create Worksheet from SQL File.
--         Let’s get started!

-- 12.1.0  Working with HyperLogLog

-- 12.1.1  Create a new folder and call it High Performing Functions.

-- 12.1.2  Create a new worksheet inside the folder and call it Working with
--         High Performing Functions.

-- 12.1.3  Alter the session so it does not use cached results. This will give
--         us an accurate reading as to the longest time the functions will take
--         to run:

ALTER SESSION SET use_cached_result=false;


-- 12.1.4  Set the Worksheet contexts as follows:

USE ROLE TRAINING_ROLE;
USE WAREHOUSE COBRA_WH;
USE DATABASE SNOWFLAKE_SAMPLE_DATA;
USE SCHEMA TPCH_SF100;


-- 12.1.5  Change the virtual warehouse size to XSmall
--         Your warehouse may already be XSmall, but we want to make sure that
--         it is so we can get a clear difference between how quickly each
--         function will run.

ALTER WAREHOUSE COBRA_WH SET WAREHOUSE_SIZE = 'XSmall';


-- 12.1.6  Suspend the warehouse
--         With the statements below, you’ll suspend and resume the warehouse to
--         clear any data in the warehouse data cache. Then you’ll use the query
--         below to determine an approximate count of distinct l_orderkey values
--         with Snowflake’s HyperLogLog high-performing function:
--         NOTE:If you try to suspend the warehouse but the warehouse is already
--         suspended, you may get an error indicating the warehouse is already
--         suspended. This is normal. You would simply need to restart the
--         warehouse and continue your work.

ALTER WAREHOUSE COBRA_WH SUSPEND;
ALTER WAREHOUSE COBRA_WH RESUME;

SELECT HLL(l_orderkey) FROM lineitem;

--         How long did it take to run and how many distinct values did it find?
--         It should have taken fewer than 10 seconds to run and it should have
--         counted right around 145,660,677 rows.

-- 12.1.7  Suspend and resume the warehouse again to clear the data cache.
--         Execute the regular COUNT version of the query so we can compare the
--         results to the those of the HyperLogLog execution:

ALTER WAREHOUSE COBRA_WH SUSPEND;
ALTER WAREHOUSE COBRA_WH RESUME;

SELECT COUNT(DISTINCT l_orderkey) FROM lineitem;

--         How long did it take to run and how many distinct values did it
--         count? It should have taken more than 20 seconds to run and it should
--         have returned a count of exactly 150,000,000 values.
--         So, the difference is approximately 4,339,323 rows, which is a
--         variance of 2.9%. If a variance of 2.9% is not critical to whatever
--         analysis you’re doing, especially when working with counts in the
--         hundreds of millions, then HyperLogLog can be a better choice than
--         COUNT(DISTINCT) in those instances.

-- 12.2.0  Use Percentile Estimation Functions
--         Now let’s try out the APPROX_PERCENTILE function. This function can
--         give a more rapid response than the regular SQL MEDIAN function.
--         Rather than the LINEITEM table we’re going to use the ORDERS table.

-- 12.2.1  Change your warehouse size to Large and clear your warehouse cache:

ALTER WAREHOUSE COBRA_WH
    SET WAREHOUSE_SIZE = 'Large';

ALTER WAREHOUSE COBRA_WH SUSPEND;
ALTER WAREHOUSE COBRA_WH RESUME;


-- 12.2.2  Start by using the SQL Median Function. The following statement
--         determines the median order total in each year of data:

SELECT 
      YEAR(O_ORDERDATE)
    , MEDIAN(O_TOTALPRICE)
    
FROM
    ORDERS
    
GROUP BY
    YEAR(O_ORDERDATE)
    
ORDER BY  
    YEAR(O_ORDERDATE);

--         How long did it take to run and what results did you get? It should
--         have run in 15-20 seconds, and you should have gotten the results
--         below:
--         - 1992 - 144310.1 - 1993 - 144303.67 - 1994 - 144285.85 - 1995 -
--         144282.92 - 1996 - 144322.46 - 1997 - 144284.45 - 1998 - 144318.58

-- 12.2.3  Run the Percentile Estimation Function on the orders table to find
--         the approximate 50th percentile of sales for each year in the table:

ALTER WAREHOUSE COBRA_WH SUSPEND;
ALTER WAREHOUSE COBRA_WH RESUME;

SELECT 
      YEAR(O_ORDERDATE)
    , APPROX_PERCENTILE(O_TOTALPRICE, 0.5)
    
FROM
    ORDERS
    
GROUP BY
    YEAR(O_ORDERDATE)
    
ORDER BY  
    YEAR(O_ORDERDATE);  

--         How long did it take to run and what results did you get? It should
--         have run in fewer than 2 seconds, and you should have gotten the
--         results that look very much like (but not exactly like) the ones
--         below:
--         - 1992 - 144315.338198642 - 1993 - 144302.777148666 - 1994 -
--         144284.126806681 - 1995 - 144278.419806512 - 1996 - 144325.010908467
--         - 1997 - 144289.365240779 - 1998 - 144323.018226321
--         As you can see, the APPROX_PERCENTILE function does run quite a bit
--         faster than the standard MEDIAN() function and produces almost the
--         exact same result. Your results may not look exactly like the figures
--         we’ve shown above because the function returns an approximate value
--         each time. Regardless, for the tiny variance you get, you can get a
--         far faster return of the result set.

-- 12.2.4  Change your warehouse size to XSmall:

ALTER WAREHOUSE COBRA_WH
    SET WAREHOUSE_SIZE = 'XSmall';

ALTER WAREHOUSE COBRA_WH SUSPEND;


-- 12.3.0  Key takeaways
--         - If small variances are not critical to you, high performing
--         functions can help you write more efficient queries that run much
--         faster for your business users.
