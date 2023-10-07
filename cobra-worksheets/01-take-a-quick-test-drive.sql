
-- 1.0.0   Take a Quick Test Drive

-- 1.1.0   Create Objects in the UI
--         In this task you will create some objects that will be used for labs
--         throughout the course. You may not yet fully understand the concepts,
--         but you will learn more about these objects as the course progresses.
--         For now, you are just creating some objects that will be required in
--         later exercises.

-- 1.1.1   Log Into Your Snowflake Account
--         Log in to your Snowflake account using the information provided by
--         your instructor. Remember, this is the web UI that was set up for you
--         by the instructor. Use the username (an animal name assigned by the
--         instructor) and the default password to access this account. A sample
--         URL would look something like this:
--         https://xy12345.snowflakecomputing.com/console#/internal/worksheet

-- 1.1.2   Locate the top ribbon, which has several icons across the top
--         (Databases, Shares, etc.).
--         These icons are used to activate different areas of the UI. Identify
--         each and attempt to learn their function. They are fairly user-
--         friendly in what they do.

-- 1.1.3   Now locate your user name and current role in the right most part of
--         the top ribbon.
--         The down arrow located directly to the right of your user name and
--         role can be used to view or modify your preferences, change your
--         password, switch roles or log out.

-- 1.1.4   Verify that you have TRAINING_ROLE selected.
--         If you have a different role selected, click the down arrow to the
--         right of your user name, select Switch Role, and then select
--         TRAINING_ROLE.

-- 1.1.5   Navigate to [Warehouses] in the top ribbon.

-- 1.1.6   Click [Create] above the list of warehouses. The **Create Warehouse**
--         dialog box appears.

-- 1.1.7   Fill in the fields with the information shown below to create a
--         warehouse you will use to run queries:
--         In a production environment, you will likely be using several
--         warehouses. For example, one for each group, or one for each type of
--         function (queries, loads, etc.). For this course, you will use just
--         this one warehouse and change its size as needed for various
--         functions.

-- 1.2.0   Create a Database:

-- 1.2.1   Navigate to [Databases].

-- 1.2.2   Click [Create] to create a database.

-- 1.2.3   Name the database COBRA_DB.

-- 1.3.0   Create a table:

-- 1.3.1   In the left-side list, click the link for the database you just
--         created.

-- 1.3.2   Click [Create] and create a table named COBRA_TBL.

-- 1.3.3   Place it in the Public schema.

-- 1.3.4   Click [Add] above the empty table to add a column.

-- 1.3.5   Create four columns with the attributes shown below, then click
--         Finish.
--         NOTE: The table below should be displayed. You must include the
--         numbers in parentheses for the types that have them (NUMBER, STRING,
--         and VARCHAR), or you will get an error:

-- 1.4.0   Create Objects Using SQL

-- 1.4.1   Navigate to [Worksheets].

-- 1.4.2   Click in the tab labeled New Worksheet, and rename your worksheet
--         Test Drive.

-- 1.4.3   Set the context and drop the database you created in the first task:

USE WAREHOUSE COBRA_WH;
USE DATABASE COBRA_DB;
USE SCHEMA PUBLIC;

DROP DATABASE COBRA_DB;

--         NOTE: This will drop any tables in the database, as well. You do not
--         need a warehouse to create objects.

-- 1.4.4   Drop your warehouse, and then recreate your database (COBRA_DB)
--         using SQL:

DROP WAREHOUSE COBRA_WH;
CREATE DATABASE COBRA_DB;


-- 1.4.5   Re-create your table in the PUBLIC schema of your database:

CREATE OR REPLACE TABLE COBRA_DB.PUBLIC.COBRA_TBL
    (id NUMBER(38,0), name STRING(10),
    country VARCHAR(20), order_date DATE);


-- 1.4.6   Re-create your warehouse, leaving it initially suspended so it is not
--         using credits until you need it:

CREATE WAREHOUSE COBRA_WH
    WAREHOUSE_SIZE=XSmall
    INITIALLY_SUSPENDED=True
    AUTO_SUSPEND=300;


-- 1.4.7   Use the following commands to set defaults for your role, database,
--         schema, and warehouse. This will be referred to as your standard
--         context throughout the rest of this workbook. Once you set these
--         defaults, any worksheet you open will automatically set your context
--         to these values.

ALTER USER COBRA
    SET
    DEFAULT_ROLE=TRAINING_ROLE
    DEFAULT_NAMESPACE=COBRA_DB.PUBLIC
    DEFAULT_WAREHOUSE=COBRA_WH;


-- 1.4.8   Log out of the web UI, and back in. This forces your new user
--         settings to be used.

-- 1.4.9   Open a new worksheet, and verify that your standard context is
--         automatically set when you open a new worksheet. If the context isn’t
--         set, select the training_role and login_wh in the context section.

-- 1.5.0   Run Queries on Sample Data

-- 1.5.1   Click the three dots to the right of the context area and select the
--         option Turn on Code Highlight.
--         Enable Code Highlight

-- 1.5.2   In the left-side navigation pane, navigate to SNOWFLAKE_SAMPLE_DATA,
--         then TPCH_SF1.

-- 1.5.3   Right-click the schema name (TPCH_SF1) and select **Set as Context**.

-- 1.5.4   Verify that the new database and schema are now set in your context.

-- 1.5.5   Click TPCH_SF1 to expand the schema, and then click the ORDERS table.
--         A pane describing the orders table appears at the bottom of the
--         navigation pane.

-- 1.5.6   Click Preview Data to preview the data in the ORDERS table.
--         Above the results is a slider with Data and Details. Data should be
--         selected by default.

-- 1.5.7   Select Details to view the detailed information on the column
--         definitions.

-- 1.5.8   In your worksheet, run the following commands to explore the data:

USE ROLE TRAINING_ROLE;

SHOW TABLES;

SELECT COUNT(*) FROM orders;

SELECT * FROM supplier LIMIT 10;

SELECT MAX(o_totalprice) FROM orders;

SELECT o_orderpriority, SUM(o_totalprice)
FROM orders
GROUP BY o_orderpriority
ORDER BY SUM(o_totalprice);

SELECT o_orderpriority, SUM(o_totalprice)
FROM orders
GROUP BY o_orderpriority
ORDER BY o_orderpriority;


-- 1.5.9   Using the syntax in the above commands as a guide, write a query that
--         will return the ps_partkey, ps_suppkey, and ps_availqty columns from
--         the PARTSUPP table. Order the output by part key.

SELECT ps_partkey, ps_suppkey, ps_availqty
FROM partsupp
ORDER BY ps_partkey;


-- 1.5.10  Notice that there are multiple rows for each ps_partkey, with
--         different values for ps_suppkey and ps_availqty. This means that
--         several suppliers stock each part key, and have different quantities
--         available.

-- 1.5.11  Rewrite the query to return just the part key, and the total
--         available quantity from all suppliers combined. GROUP and ORDER the
--         output by the part key.

SELECT ps_partkey, SUM(ps_availqty)
FROM partsupp
GROUP BY ps_partkey
ORDER BY ps_partkey;

--         How many total rows were returned by your query? 200,000
--         How many total rows are in the PARTSUPP table? 800,000

-- 1.5.12  Write a query that will return the lowest- and highest-priced items
--         (based on the extended price) from the LINEITEM table.
--         What are the lowest and hightest prices returned? (Answer: 104949.50
--         and 901.00)

SELECT MIN(l_extendedprice), MAX(l_extendedprice)
FROM lineitem;


-- 1.5.13  Suspend the warehouse

ALTER WAREHOUSE COBRA_WH SUSPEND;

