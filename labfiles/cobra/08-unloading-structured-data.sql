
-- 8.0.0   Unloading Structured Data
--         The purpose of this lab is to introduce you to data unloading.
--         -How to unload table data into a Table Stage in Pipe-Delimited File
--         format
--         -Using an SQL statement containing a JOIN to Unload a Table into an
--         internal stage
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

-- 8.1.0   Unloading table data into a Table Stage in Pipe-Delimited File format
--         This activity is essentially the opposite of the previous two
--         activities. Rather than load a file into a table, you are going to
--         take the data you loaded and unload it into a file in a table stage.

-- 8.1.1   Open a new worksheet and set the context as follows:

USE ROLE TRAINING_ROLE;
CREATE WAREHOUSE IF NOT EXISTS COBRA_WH;
USE WAREHOUSE COBRA_WH;
CREATE DATABASE IF NOT EXISTS COBRA_DB;
USE COBRA_DB.PUBLIC;


-- 8.1.2   Create a fresh version of the REGION table with 5 records to unload:

create or replace table REGION as 
select * from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION;


-- 8.1.3   Unload the data to the REGION table stage.
--         Remember that a table stage is automatically created for each table.
--         Use the slides, workbook, or Snowflake documentation for questions on
--         the syntax. You will use MYPIPEFORMAT for the unloading. This will
--         cause the unloaded file to be formatted according to the
--         specifications of the MYPIPEFORMAT file format.

COPY INTO @%region
FROM region
FILE_FORMAT = (FORMAT_NAME = MYPIPEFORMAT);


-- 8.1.4   List the stage and verify that the data is there:

LIST @%region;


-- 8.1.5   Remove the file from the REGION table’s stage:

REMOVE @%region;


-- 8.2.0   Use a SQL statement containing a JOIN to Unload a Table into an
--         internal stage
--         This activity is essentially the same as the previous activity. The
--         difference is that you are going to unload data from more than one
--         table into a single file.

-- 8.2.1   Do a SELECT with a JOIN on the REGION and NATION tables. Review the
--         output from your JOIN.

SELECT * 
FROM "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1"."REGION" r 
JOIN "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1"."NATION" n ON r.r_regionkey = n.n_regionkey;


-- 8.2.2   Create a named stage (you can call it whatever you want):

CREATE OR REPLACE STAGE mystage;


-- 8.2.3   Unload the JOINed data into the stage you created:

COPY INTO @mystage FROM
(SELECT * FROM "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1"."REGION" r JOIN "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1"."NATION" n
ON r.r_regionkey = n.n_regionkey);


-- 8.2.4   Verify the file is in the stage:

LIST @mystage;


-- 8.2.5   Remove the file from the stage:

REMOVE @mystage;


-- 8.2.6   Remove the stage:

DROP STAGE mystage;


-- 8.2.7   Suspend and resize the warehouse

ALTER WAREHOUSE COBRA_WH SET WAREHOUSE_SIZE=XSmall;
ALTER WAREHOUSE COBRA_WH SUSPEND;


-- 8.3.0   Key Takeaways
--         - The COPY INTO command can be used to unload data.
--         - Data from multiple tables can be unloaded using a JOIN statement.
--         - You can use the LIST command to see what files are in a stage.
