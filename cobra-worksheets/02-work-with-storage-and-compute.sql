
-- 2.0.0   Work with Storage and Compute

-- 2.1.0   Review the TRAINING_DB Database

-- 2.1.1   Navigate to [Databases], then locate and select TRAINING_DB.
--         NOTE: If you do not see a list of databases, you are probably still
--         drilled down into a table from the previous lab. Look for the
--         breadcrumb trail under the Snowflake logo and click Databases to
--         return to the top level of this area. You will then see the list,
--         including TRAINING_DB.

-- 2.1.2   Select Schemas from the tabs above the list of tables. Review the
--         list of schemas that are defined for this database.

-- 2.1.3   Return to the Tables tab.

-- 2.1.4   Review the table list.

-- 2.1.5   Click the LINEITEM table located in the TPCH_SF1 schema.

-- 2.1.6   Review the information about the table’s structure.

-- 2.1.7   Using the breadcrumb trail above the table list, click TRAINING_DB to
--         go back up one level.

-- 2.1.8   Click the LINEITEM table that is located in the TPCH_SF10 schema.

-- 2.1.9   Review the information about the table’s structure.

-- 2.1.10  Compare the columns in this LINEITEM table in TPCH_SF1 with the
--         columns in the LINEITEM table in TPCH_SF10.
--         You will find that the columns are identical.
--         Question: What is the difference between these tables?
--         Answer: The number of rows in each table. Tables in the TPCH_SF10
--         schema have 10 times as many rows as tables in the TPCH_SF1 schema.

-- 2.1.11  Use the breadcrumb trail to go back to TRAINING_DB.

-- 2.1.12  Sort the results by the Table Name column and find all the tables
--         named LINEITEM.

-- 2.1.13  Compare their sizes to see the difference between the tables in the
--         different schemas.

-- 2.1.14  Navigate through the Views, Schemas, and File Formats tabs.

-- 2.1.15  Notice that all views and tables reside within a schema.
--         Snowflake Accounts are composed of one or more Databases which are
--         composed of one or more Schemas. In turn, Schemas comprise one or
--         more data objects like Tables, Views, Stages, File Formats, and
--         Sequences.

-- 2.2.0   Create and Organize Objects

-- 2.2.1   Use the breadcrumb trail to return to the [Databases] main page.

-- 2.2.2   Locate and click COBRA_DB in the database list.

-- 2.2.3   In the Tables tab, click [Create].

-- 2.2.4   Take note of how the Create Table wizard requires that a Schema be
--         selected.
--         NOTE: The LINEITEM tables you looked at in the previous task are all
--         different tables, in different schemas - they just all happen to have
--         the same name. A table name must be unique within a schema but can be
--         duplicated in other schemas.

-- 2.2.5   Click [Cancel] to exit the table creation wizard.

-- 2.2.6   Return to [Databases]. Toggle between the Views, Stages, File
--         Formats, and Sequences tabs and click [Create] for each one to see
--         how to create objects of these types.

-- 2.2.7   Cancel without creating anything for each of these object types.
--         Snowflake enforces a logical hierarchy:

-- 2.2.8   Open a new worksheet, and name it Create Objects.

-- 2.2.9   If you haven’t created the class database or warehouse, do it now

CREATE WAREHOUSE IF NOT EXISTS COBRA_WH;
CREATE DATABASE IF NOT EXISTS COBRA_DB;


-- 2.2.10  Verify that it automatically sets the context to your standard
--         context.

-- 2.2.11  Create a schema in your database, and name it COBRA_SCHEMA.

-- 2.2.12  Specify the full database.schema path when you create it, then verify
--         that it is set as the default schema in your worksheet.
--         HINT: Review the syntax for creating a database; the syntax for a
--         schema is similar.

CREATE SCHEMA COBRA_DB.COBRA_SCHEMA;


-- 2.2.13  Create a MEMBERS table.

-- 2.2.14  Give it columns to hold a numeric customer ID, a first name (up to 20
--         characters), a last name (up to 30 characters), the date they joined,
--         and their award program level (bronze, silver, or gold):

CREATE TABLE members (id INT, first_name VARCHAR(20),
last_name VARCHAR(30), member_since DATE, level VARCHAR(6));


-- 2.2.15  Query the table to make sure the columns are all there.

SELECT * FROM members;


-- 2.3.0   Review Storage Usage

-- 2.3.1   Select [Account]. This section displays information on storage, data
--         transfer, and how many credits have been billed.

-- 2.3.2   Click the Average Storage Used box in the display area. This shows
--         average total storage over time.
--         NOTE: Since class just started, there will be very little data in
--         this area, and in the other areas inspected in this task - this is
--         just to show you what information can be found here.
--         Just above the display area on the right-hand side is a month
--         indicator.

-- 2.3.3   Use the pull-down menu to change months and review the change in
--         total storage over time.
--         Month Pull Down Menu
--         NOTE: The scale of the y-axis in the graph will change from month to
--         month based on the highest storage amount for that month. To compare
--         two months, make sure you are paying attention to the y-axis. Two
--         months that are visually similar may be very different as far as
--         actual storage used.

-- 2.3.4   Toggle between the Total, Database, Stage, and **Fail Safe**
--         categories and review the change in storage for each throughout the
--         month. You will learn more about Stages and Fail Safe storage later
--         in the course.

-- 2.3.5   Select [Worksheets] and return to the worksheet you have been using.
--         INFORMATION_SCHEMA is a schema that is automatically created for all
--         databases. It contains database-specific information. You will learn
--         more about this later. Use this to run a query to return average
--         daily storage usage for the past 10 days, per database, for all
--         databases in your account:

SELECT * FROM TABLE (INFORMATION_SCHEMA.DATABASE_STORAGE_USAGE_HISTORY
    (DATEADD('days', -10, CURRENT_DATE()), CURRENT_DATE()));


-- 2.4.0   Run Commands with No Virtual Warehouse

-- 2.4.1   Suspend your warehouse:

ALTER WAREHOUSE COBRA_WH SUSPEND;


-- 2.4.2   Change the worksheet context to the following:

-- 2.4.3   You can do this either with the context menu, or with the SQL command
--         below:

USE SCHEMA SNOWFLAKE_SAMPLE_DATA.TPCH_SF1;

--         Throughout the labs when asked to set your context, you can choose
--         between the SQL method and the context menu method.

-- 2.4.4   Run the following command to disable the query result cache. You will
--         learn more about this cache in the next module.

ALTER SESSION SET USE_CACHED_RESULT=FALSE;


-- 2.4.5   Execute the following query which selects MIN and MAX values for the
--         L_ORDERKEY column and a row count for the LINEITEM table:

SELECT MIN(l_orderkey), MAX(l_orderkey), COUNT(*)
FROM lineitem;


-- 2.4.6   Notice that the results return almost immediately.

-- 2.4.7   Click Query ID in the result frame, then click the Query ID.
--         Results Query Id

-- 2.4.8   This will bring up the query detail pages under Query History.

-- 2.4.9   From within the history, select the [Profile] tab above the summary
--         area. Note that the query profile states METADATA-BASED RESULT. This
--         means the results were pulled from the Snowflake metadata store, and
--         the query completed with no virtual warehouse.

-- 2.5.0   Work with Virtual Warehouses

-- 2.5.1   Return to your worksheet.

-- 2.5.2   Using SQL, create a warehouse named COBRA_WH2, with the following
--         characteristics.

-- 2.5.3   Take note of the various parameters you can set for warehouses:

-- 2.5.4   Next, run the following query:

CREATE WAREHOUSE COBRA_WH2
    WAREHOUSE_SIZE = XSMALL
    AUTO_RESUME = TRUE
    AUTO_SUSPEND = 300
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 1
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Another warehouse for completing labs';

--         NOTE: This query sets INITIALLY_SUSPENDED to TRUE. When you created a
--         warehouse with the UI the warehouse automatically started. With this
--         option the warehouse will not start until it is used for a query.
--         Note also that when you create a warehouse using SQL it is
--         automatically set in your context.

-- 2.5.5   Execute the command below to list the configured warehouses.

-- 2.5.6   You will see several more warehouses than you have created. Why do
--         you suppose that is the case?

SHOW WAREHOUSES;

--         Answer: All students are working in the TRAINING_ROLE role, and all
--         users that are in the same role have access to all the same objects.
--         Therefore, you will see all the warehouses that your fellow students
--         create, as well as your own.

-- 2.5.7   Alter COBRA_WH2 to change the following parameters:
--         NOTE: the AUTO_SUSPEND factor is specified in seconds (600/60 = 10
--         minutes).

-- 2.5.8   Next, execute the following command:

ALTER WAREHOUSE COBRA_WH2
    SET
    WAREHOUSE_SIZE = Small
    AUTO_SUSPEND = 600
    MAX_CLUSTER_COUNT = 3;


-- 2.5.9   Navigate to [Warehouses].

-- 2.5.10  Locate your Warehouse and confirm the parameters are as follows:

-- 2.5.11  Return to your worksheet and run the following query:

SHOW WAREHOUSES LIKE 'COBRA%';


-- 2.5.12  Run the following command to disable the query result cache. You will
--         learn more about this cache in the next module.

ALTER SESSION SET USE_CACHED_RESULT=FALSE;


-- 2.5.13  Execute the following query:

SELECT *
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION
LIMIT 10;


-- 2.5.14  Return to [Warehouses].

-- 2.5.15  Locate COBRA_WH2 and verify the Status is now Started.
--         Because your warehouse was set to auto resume, it started
--         automatically when it was needed to complete a query.

-- 2.5.16  Return to [Worksheets].

-- 2.5.17  Suspend COBRA_WH2:

ALTER WAREHOUSE COBRA_WH2 SUSPEND;


-- 2.5.18  Show your warehouses and confirm that the warehouse is suspended:

SHOW WAREHOUSES LIKE 'COBRA%';


-- 2.5.19  Alter COBRA_WH2 and set the WAREHOUSE_SIZE to XSmall:

ALTER WAREHOUSE COBRA_WH2 SET WAREHOUSE_SIZE=XSmall;


-- 2.5.20  Suspend and then drop COBRA_WH2:

ALTER WAREHOUSE COBRA_WH2 SUSPEND;

--         Note that you should have gotten the following error because the
--         warehouse has already been suspended: Invalid state. Warehouse
--         COBRA_WH2 cannot be suspended.
--         Proceed with the statement below to drop the warehouse:

DROP WAREHOUSE COBRA_WH2;


-- 2.5.21  Show warehouses to verify that COBRA_WH is still listed, but
--         COBRA_WH2 is not.

SHOW WAREHOUSES LIKE 'COBRA%';


-- 2.5.22  Suspend and resize the warehouse

ALTER WAREHOUSE COBRA_WH SET WAREHOUSE_SIZE=XSmall;
ALTER WAREHOUSE COBRA_WH SUSPEND;

