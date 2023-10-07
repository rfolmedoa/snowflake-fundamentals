
-- 6.0.0   Work with Database Objects
--         Expect this lab to last 45 minutes.

-- 6.1.0   Work With Permanent, Temporary, and Transient Tables

-- 6.1.1   Create a worksheet named Work with Objects, and set the context.

USE ROLE TRAINING_ROLE;
CREATE WAREHOUSE IF NOT EXISTS COBRA_WH;
CREATE DATABASE IF NOT EXISTS COBRA_DB;
USE WAREHOUSE COBRA_WH;
USE DATABASE COBRA_DB;
USE SCHEMA PUBLIC;


-- 6.1.2   Create a table named permanent, with three columns (ID, first name,
--         and last name). Make ID an INTEGER, first name a VARCHAR(20), and
--         last name a VARCHAR(30):

CREATE TABLE permanent (id INT, first VARCHAR(20), last VARCHAR(30));


-- 6.1.3   Create a temporary table named temp, with the same three columns:

CREATE TEMPORARY TABLE temp
(id INT, first VARCHAR(20), last VARCHAR(30));


-- 6.1.4   Create a transient table named transient, with the same three
--         columns:

CREATE TRANSIENT TABLE transient
(id INT, first VARCHAR(20), last VARCHAR(30));


-- 6.1.5   Show the tables with SHOW TABLES. Notice that the kind column tells
--         you the type of each table:

SHOW TABLES;


-- 6.1.6   Open another worksheet. Copy these commands into the new worksheet
--         and run them to show the tables:

USE ROLE TRAINING_ROLE;
USE WAREHOUSE COBRA_WH;
USE DATABASE COBRA_DB;
USE SCHEMA PUBLIC;

SHOW TABLES;


-- 6.1.7   In the new worksheet SHOW TABLES does not list the temporary table
--         since it is tied to an entirely different session, but the transient
--         table is listed. Now close the new worksheet and drop the transient
--         table in the original worksheet (this one):

DROP TABLE transient;


-- 6.1.8   Add three rows of data to your permanent table:

INSERT INTO permanent
VALUES (1, 'Jarit', 'Johnson'),
(2, 'Shayla', 'Nguyen'),
(3, 'Peewee', 'Herman');


-- 6.1.9   Query the table to verify the columns and data.

SELECT * FROM permanent;


-- 6.1.10  Add a comments column, type STRING, to your permanent table.

ALTER TABLE permanent
   ADD COLUMN comments STRING;


-- 6.1.11  Query the table to see what values are in the comments column:

SELECT * FROM permanent;


-- 6.1.12  Describe the table. What do you notice about the comments column?

DESCRIBE TABLE permanent;

--         The STRING data type you set for the column was actually set as a
--         VARCHAR with the maximum number of characters.

-- 6.1.13  You decide you don’t want the comments column to be that long, so
--         change the data type to VARCHAR(1000). What happens?

ALTER TABLE permanent
  MODIFY COLUMN comments
  SET DATA TYPE VARCHAR(1000);


-- 6.1.14  DROP the comments column, then re-add it as VARCHAR(1000):

ALTER TABLE permanent DROP COLUMN comments;
ALTER TABLE permanent ADD COLUMN comments VARCHAR(1000);


-- 6.1.15  DESCRIBE the table and verify the column definition is correct:

DESCRIBE TABLE permanent;


-- 6.1.16  Create a table from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS, using $
--         notation to select columns 1, 3, 4, 5, and 6.

-- 6.1.17  Use AS to rename the columns.

-- 6.1.18  Name it my_orders. It will take a few minutes to create:

CREATE TABLE my_orders AS
SELECT $1 AS key, $3 AS status, $4 AS price, $5 AS date, $6 AS priority
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS;


-- 6.1.19  Query my_orders to see the columns. Limit the results to 10 rows:

SELECT * FROM my_orders
LIMIT 10;


-- 6.1.20  Create a table using LIKE:

CREATE TABLE like_orders LIKE SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000.ORDERS;


-- 6.1.21  Query the like_orders table to see what it contains, and then drop
--         it.

SELECT * FROM like_orders;
DROP TABLE like_orders;


-- 6.1.22  The LIKE modifier creates a table with the same column definitions as
--         the source table, without copying any of the data.

-- 6.2.0   Create a table with an auto-increment column and a default column

-- 6.2.1   First, create the table below. Note that the part number column auto-
--         increments and that the restocking fee column has a default value of
--         5.50.

CREATE OR REPLACE TABLE autoincDefault_demo (part_num integer AUTOINCREMENT, part_name varchar(30), restocking_fee number(8,2) DEFAULT 5.50 );


-- 6.2.2   Now let’s insert some data and check out the result:

INSERT INTO autoincDefault_demo (part_name) values ('Wheel'), ('Tires');

SELECT * FROM autoincDefault_demo;


-- 6.2.3   Note that there are two rows and the part numbers are 1 and 2
--         respectively. Because we didn’t insert a value for the restocking
--         fee, the value for restocking fee for both rows is 5.50.

-- 6.2.4   Now let’s insert two more rows and provide a specific value for
--         restocking fee:

INSERT INTO autoincDefault_demo (part_name, restocking_fee) values ('Engine Block', 25), ('Transmission', 75.50);

SELECT * FROM autoincDefault_demo;


-- 6.2.5   As you can see, the part number values for the new rows are 3 and 4
--         respectively. Snowflake gave the rows those values because that
--         column is set to auto-increment. The restocking fee is overwritten
--         since those values were provided.

-- 6.3.0   Work with Views

-- 6.3.1   Set the context and create a view from the my_orders table you
--         created in the previous task:

USE ROLE TRAINING_ROLE;
USE WAREHOUSE COBRA_WH;
USE DATABASE COBRA_DB;
USE SCHEMA PUBLIC;

CREATE VIEW orders_view(status, date, price) AS
  SELECT status, date, SUM(price) FROM my_orders
  GROUP BY status, date;


-- 6.3.2   Create a secure view with the same information:

CREATE SECURE VIEW s_orders_view(status, date, price) AS
  SELECT status, date, SUM(price) FROM my_orders
  GROUP BY status, date;


-- 6.3.3   Create a materialized view with the same information:

CREATE MATERIALIZED VIEW m_orders_view(status, date, price) AS
  SELECT status, date, SUM(price) FROM my_orders
GROUP BY status, date;

--         NOTE: A materialized view takes longer to create than a standard
--         view. Why?

-- 6.3.4   SHOW your views. Examine the columns to determine how you can tell
--         what type of view it is:

SHOW VIEWS;


-- 6.3.5   See if you can create a view that is both secure and materialized:

CREATE TABLE members (
  id INT, first_name VARCHAR(20),
  last_name VARCHAR(30),
  member_since DATE,
  level VARCHAR(6));

INSERT INTO members
VALUES
(103, 'Barbra', 'Streisand', '10/05/2019', 'silver'),
(95, 'Ray', 'Bradbury', '06/06/2006', 'bronze'),
(111, 'Daenerys', 'Targaryen', '2/4/2019', 'gold'),
(87, 'Homer', 'Simpson', '3/1/1998', 'gold');

CREATE SECURE MATERIALIZED VIEW sm_view
  AS SELECT first_name, last_name FROM members;


-- 6.3.6   Select all data from your orders_view view. Note how long it takes:

SELECT * FROM orders_view;


-- 6.3.7   Suspend your warehouse to clear any remaining cache:

ALTER WAREHOUSE COBRA_WH SUSPEND;


-- 6.3.8   Select all data from your s_orders_view view, and note how long it
--         takes:

SELECT * FROM s_orders_view;


-- 6.3.9   Suspend your warehouse then select all data from your m_orders_view
--         view. Note how long it takes:

ALTER WAREHOUSE COBRA_WH SUSPEND;
SELECT * FROM m_orders_view;

--         Which type of view was fastest? Which was the slowest?

-- 6.3.10  Drop your views and suspend the warehouse:

DROP VIEW orders_view;
DROP VIEW s_orders_view;
DROP MATERIALIZED VIEW m_orders_view;
DROP MATERIALIZED VIEW sm_view;
ALTER WAREHOUSE COBRA_WH SUSPEND;

