
-- 9.0.0   Introduction to Tasks
--         The purpose of this lab is to teach you to create and execute tasks
--         and trees of tasks.
--         - How to create a task
--         - How to start and stop a task
--         Imagine that there is a table that stores the average time from
--         shipping to deliver for all orders in a specific month and year.
--         Let’s imagine that the order and shipping data is updated every
--         minute and so you need to update the table every minute.
--         In this exercise you’re going to write a task that updates the
--         contents of the table every minute.
--         HOW TO COMPLETE THIS LAB
--         In order to complete this lab, you can type the SQL commands below
--         directly into a worksheet. It is not recommended that you cut and
--         paste from the workbook pdf as that sometimes results in errors.
--         You can also use the SQL code file for this lab that was provided at
--         the start of the class. To open an .SQL file in Snowsight, make sure
--         the Worksheet section is selected on the left-hand navigation bar.
--         Click on the ellipsis between the Search and +Worksheet buttons. In
--         the dropdown menu, select Create Worksheet from SQL File.
--         NOTE: Tasks left running unsupervised can consume credits. In your
--         training account, it is IMPERATIVE that you suspend any tasks you
--         create. Failure to do so could result in all students being locked
--         out of their 30-day training account.
--         Let’s get started!

-- 9.1.0   Creating the target table
--         First we’ll set the context and create a new schema to use
--         specifically for this lab.

-- 9.1.1   Run the commands below to set the context.

USE ROLE TRAINING_ROLE;

CREATE DATABASE IF NOT EXISTS COBRA_DB;
USE DATABASE COBRA_DB;

CREATE WAREHOUSE IF NOT EXISTS COBRA_WH;
USE WAREHOUSE COBRA_WH;

CREATE SCHEMA IF NOT EXISTS COBRA_TASKS_SCHEMA;
USE SCHEMA COBRA_TASKS_SCHEMA;

ALTER WAREHOUSE COBRA_WH SET WAREHOUSE_SIZE = xsmall;


-- 9.1.2   Run the following command to create the table that will hold the
--         average shipping time in days. Run the SELECT statement to confirm
--         that it is empty.

CREATE OR REPLACE TABLE AVG_SHIPPING_IN_DAYS(
      yr INTEGER
    , mon INTEGER
    , avg_shipping_days DECIMAL(18,2)
);

SELECT * FROM avg_shipping_in_days;


--         As you can see, it is a simple table that stores the year, the month
--         and the average shipping days in decimal format.

-- 9.2.0   Creating the tasks
--         Now that we’ve created the tables to be populated, let’s create the
--         task tree.

-- 9.2.1   Run the following command to create the task
--         This task will calculate and load the data from the orders and
--         lineitem tables into the target table. Notice that we do an INSERT
--         OVERWRITE. This essentially overwrites the table each time the task
--         runs.

CREATE OR REPLACE TASK insert_shipping_by_date_rows
    WAREHOUSE = 'COBRA_WH'
    SCHEDULE = 'USING CRON 0-59 0-23 * * * America/Chicago'
AS    
    INSERT OVERWRITE INTO COBRA_DB.COBRA_TASKS_SCHEMA.AVG_SHIPPING_IN_DAYS (yr, mon, avg_shipping_days)
    SELECT
          YEAR(F.O_ORDERDATE) AS YR
        , MONTH(F.O_ORDERDATE) AS MON
        , AVG (DAYS_TO_SHIP)::DECIMAL(18,2) AS AVG_DAYS_TO_SHIP
    FROM        
        (
            SELECT 
                      O_ORDERDATE
                    , L_SHIPDATE
                    , L_SHIPDATE - O_ORDERDATE AS DAYS_TO_SHIP
            FROM
                    SNOWBEARAIR_DB.PROMO_CATALOG_SALES.ORDERS O 
                    LEFT JOIN SNOWBEARAIR_DB.PROMO_CATALOG_SALES.LINEITEM L ON O.O_ORDERKEY = L.L_ORDERKEY
         ) AS F 

    GROUP BY YR, MON

    ORDER BY YR, MON;

--         Notice that the schedule is set to run every minute of every hour.
--         However, we only need this task to run this once for our purposes.

-- 9.2.2   Show the task to ensure it got created correctly

SHOW TASKS;


-- 9.2.3   Run the following commands to start the tree:

ALTER TASK insert_shipping_by_date_rows RESUME;


-- 9.2.4   Use the following query to monitor what is going on in the table.
--         It may take up to a minute before you see any data in the table.

SELECT * FROM avg_shipping_in_days;


-- 9.2.5   Use this command to see the task history for the task
--         Here you can see instances in which the task was scheduled, ran and
--         succeeeded, or ran and failed.

select *
  from table(information_schema.task_history(
    scheduled_time_range_start=>dateadd('hour',-1,current_timestamp())));


-- 9.3.0   Ending the lab

-- 9.3.1   Execute the ALTER TASK command below to immediately stop the task
--         tree:

ALTER TASK insert_shipping_by_date_rows SUSPEND;


-- 9.3.2   Run the commands below to clear out the objects used in this lab:

DROP TABLE avg_shipping_in_days;
DROP TASK insert_shipping_by_date_rows;
DROP SCHEMA COBRA_TASKS_SCHEMA;
ALTER WAREHOUSE COBRA_WH SUSPEND;


-- 9.4.0   Key Takeaways
--         - The first task in a tree of tasks must be started upon a schedule,
--         using either Snowflake-specific scheduling syntax or CRON syntax.
--         - Subsequent tasks in a tree of task must be started by calling them
--         from previous tasks with an AFTER clause.
--         - It is imperative to stop a task you no longer need in order to
--         avoid wasting credits.
