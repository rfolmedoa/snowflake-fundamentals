
-- 18.0.0  Monitor Billing & Usage Information
--         Expect this lab to take approximately 40 minutes.
--         Lab Purpose: Practice monitoring resource usage with the Snowflake UI
--         and SQL.
--         NOTE: Some of the commands you will run in these exercises require
--         ACCOUNTADMIN permission. The role TRAINING_ROLE has been granted
--         these permissions so that you can run these exercises. In your own
--         production environment, you may not get any results if you do not
--         have ACCOUNTADMIN access.

-- 18.1.0  Review Warehouse Usage

-- 18.1.1  Navigate to [Warehouses].

-- 18.1.2  Select COBRA_WH.

-- 18.1.3  Review the Warehouse Load Over Time information.

-- 18.1.4  Navigate to [Account].

-- 18.1.5  Make sure the Billing & Usage section is selected. Review the
--         information about Snowflake credits billed for the given time period.

-- 18.1.6  Open a new worksheet named Monitoring and set the context:

USE ROLE TRAINING_ROLE;
CREATE WAREHOUSE IF NOT EXISTS COBRA_WH;
USE WAREHOUSE COBRA_WH;
CREATE DATABASE IF NOT EXISTS COBRA_DB;
USE COBRA_DB.PUBLIC;


-- 18.1.7  Use SQL and the Information Schema WAREHOUSE_METERING_HISTORY table
--         function to pull Warehouse credit usage, by warehouse, for the last 5
--         days:

SELECT *
FROM TABLE(INFORMATION_SCHEMA.WAREHOUSE_METERING_HISTORY
   (DATEADD('DAYS', -5, CURRENT_DATE())));


-- 18.1.8  Starting with the query above, write your own query to look at the
--         total credits consumed by warehouse. Show the warehouses with the
--         greatest total credits first:

SELECT warehouse_name, SUM(credits_used) FROM
TABLE(INFORMATION_SCHEMA.WAREHOUSE_METERING_HISTORY
(DATEADD('DAYS', -5, CURRENT_DATE())))
GROUP BY warehouse_name
ORDER BY SUM(credits_used) DESC;


-- 18.2.0  Review Billing & Usage Information

-- 18.2.1  Set your role to TRAINING_ROLE (if not already set).

-- 18.2.2  Navigate to [Account].

-- 18.2.3  Select the Billing & Usage Section (if not already selected).

-- 18.2.4  Click the Warehouses box (if not already selected).

-- 18.2.5  Review the number of Warehouses and total credits billed and take
--         note of which month the activity is listed.
--         In the detailed activity, identify:

-- 18.2.6  Navigate to [Warehouses].

-- 18.2.7  Locate and click on your COBRA_WH and evaluate your usage over
--         time.

-- 18.2.8  Expand the time frame of the bottom graph and see what happens to the
--         top graph.

-- 18.2.9  Navigate back to [Account].

-- 18.2.10 Select the Billing & Usage Section (if not already selected).

-- 18.2.11 Click the Average Storage Used box.

-- 18.2.12 Review the Daily Average and the Rolling Monthly Average Line on the
--         graph.
--         NOTE: This is for a given Month and the storage can be broken out
--         Total (Default), Database (Active + Time Travel), Stage (Internal),
--         and Fail-Safe.

-- 18.2.13 Toggle between Total, Database, Stage, and Fail-Safe.

-- 18.2.14 Navigate to [Worksheets].

-- 18.2.15 Execute the following commands to pull various Billing & Usage
--         metrics:

-- 18.2.16 Pull all Warehouse usage for the last rolling seven (7) days from the
--         Information Schema:

SELECT * FROM TABLE(INFORMATION_SCHEMA.WAREHOUSE_METERING_HISTORY
   (DATEADD('DAYS', -7, CURRENT_DATE())));


-- 18.3.0  View and Set Parameters

-- 18.3.1  In the Worksheets tab, show all parameters for your session:

SHOW PARAMETERS IN SESSION;


-- 18.3.2  Pull the value for the DATE_OUTPUT_FORMAT parameter for your session.
--         The format set should equal the default format of YYYY-MM-DD:

SHOW PARAMETERS LIKE 'DATE_OUTPUT_FORMAT' IN SESSION;


-- 18.3.3  Run a query to SELECT the current date, and notice the format of the
--         date returned:

SELECT CURRENT_DATE();


-- 18.3.4  Set the DATE_OUTPUT_FORMAT parameter to DD MON YYYY:

ALTER SESSION SET DATE_OUTPUT_FORMAT = 'DD MON YYYY';


-- 18.3.5  Re-run the query to SELECT the current date. Notice the format of the
--         date returned has changed to match that of the value you set for the
--         DATE_OUTPUT_FORMAT–DD MON YYYY.

-- 18.3.6  Open a new Worksheet and run the query to SELECT the current date.
--         Notice that the format of the date returned matches the Snowflake
--         default of YYYY-MM-DD rather than the format you set for the
--         DATE_OUTPUT_FORMAT–DD MON YYYY. Why is this?

SELECT CURRENT_DATE();

--         HINT: Worksheets represent independent Snowflake sessions.

-- 18.4.0  Evaluate Account and Object Information
--         NOTE: The use of Information Schema & Account Usage is very similar,
--         sometimes identical. When to use which functionality will depend upon
--         your needs regarding latency, data retention, and dropped objects.
--         Information Schema & Account Usage

-- 18.5.0  Monitor Storage
--         NOTE: In this lab, you will be exploring some menus that are normally
--         accessible only to the ACCOUNTADMIN role. These privileges have been
--         granted to TRAINING_ROLE for convenience in this exercise.

-- 18.5.1  Select [Account].

-- 18.5.2  Navigate to the Billing & Usage section.

-- 18.5.3  Click the Average Storage Used option.

-- 18.5.4  Toggle between the Database, Stage, and Fail Safe categories and
--         review the change in storage for each throughout the month.

-- 18.5.5  Select the Worksheets tab. You may use the same context from the
--         previous task.

-- 18.5.6  Run a query to return average daily storage usage for the past 5
--         days, per database, for all databases in your account:

SELECT *
FROM TABLE (information_schema.database_storage_usage_history
   (DATEADD('days', -5, CURRENT_DATE()), CURRENT_DATE()));


-- 18.5.7  Modify the query to return average daily storage usage for the past 5
--         days for your account overall:

SELECT
    usage_date,
    SUM(average_database_bytes) average_database_bytes,
    SUM(average_failsafe_bytes) average_failsafe_bytes
FROM TABLE(information_schema.database_storage_usage_history
(dateadd('days',-5,current_date()),current_date()))
GROUP BY usage_date
ORDER BY usage_date;


-- 18.5.8  Run a query to return average daily data storage usage for all the
--         Snowflake stages in your account for the past 5 days:

SELECT *
FROM TABLE (information_schema.stage_storage_usage_history(DATEADD
(DAYS,-5,CURRENT_DATE()),CURRENT_DATE()));


-- 18.5.9  Pull total storage bytes for the last rolling seven (7) days from
--         Account Usage.

SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.STORAGE_USAGE
WHERE usage_date >= DATEADD('DAYS',-7,CURRENT_DATE())
ORDER BY usage_date;


-- 18.5.10 Pull storage for Internal Stages for the previous 5 days. In the
--         command below, you need to replace YYYY-MM-DD in the command with the
--         four-digit year, two-digit month, and two-digit you wish to examine.
--         NOTE: The storage is total and is not broken out by stage.

SELECT *
FROM TABLE(INFORMATION_SCHEMA.STAGE_STORAGE_USAGE_HISTORY
(DATE_RANGE_START=>'YYYY-MM-DD'));


-- 18.6.0  Query Views in Information Schema

-- 18.6.1  Open a new Worksheet. Re-name the worksheet to Information Schema.

-- 18.6.2  Retrieve the hourly Warehouse usage for the current month for your
--         COBRA_WH Virtual Warehouse, ordered by time:

SELECT *
FROM TABLE(information_schema.warehouse_metering_history
(date_range_start=>date_trunc(month, current_date),
date_range_end=>dateadd(month,1,date_trunc(month, current_date)),'COBRA_WH'))
ORDER BY start_time;


-- 18.6.3  Retrieve average daily storage for the past three (3) days, for
--         COBRA_DB Database:

SELECT *
FROM TABLE(information_schema.database_storage_usage_history
(dateadd('days',-3,current_date()),current_date(),
'COBRA_db'));


-- 18.6.4  Directly query the Information Schema TABLES View to find the size of
--         each Table in the WEATHER Schema in the TRAINING_DB Database. Sort by
--         largest table:

SELECT *
FROM SNOWFLAKE_SAMPLE_DATA.INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'WEATHER'
ORDER BY bytes DESC;


-- 18.6.5  Join the APPLICABLE_ROLES and DATABASES Information Schema Views to
--         find out which databases are available to your user and through which
--         roles:

SELECT distinct
    r.grantee,
    r.role_name,
    r.role_owner,
    d.database_name,
    d.database_owner
FROM information_schema.applicable_roles r
JOIN information_schema.databases d ON
    d.database_owner=r.role_name
WHERE r.grantee = 'COBRA';


-- 18.7.0  Query Views in Account Usage

-- 18.7.1  Retrieve the number of failed logins, by user, month-to-date from the
--         LOGIN_HISTORY View. Order the results by the highest login failure
--         rate:

SELECT user_name,
SUM(IFF(is_success = 'NO', 1, 0)) AS failed_logins,
COUNT(*) AS logins,
SUM(IFF(is_success = 'NO', 1,0)) / nullif(count(*), 0)
AS login_failure_rate
FROM SNOWFLAKE.ACCOUNT_USAGE.login_history
WHERE event_timestamp > date_trunc(month, current_date)
GROUP BY 1
ORDER BY 4 DESC;


-- 18.7.2  Determine the busiest Warehouse by number of jobs executed, by
--         querying the QUERY_HISTORY View:

SELECT warehouse_name, COUNT(*) AS number_of_jobs
FROM SNOWFLAKE.ACCOUNT_USAGE.query_history
WHERE start_time >= date_trunc(month, current_date)
  AND warehouse_name IS NOT NULL
GROUP BY 1 ORDER BY 2 DESC;


-- 18.7.3  Determine the number of used credits and costs by all Warehouses
--         within an account in the last three (3) days by querying the
--         WAREHOUSE_METERING_HISTORY View. Assume each credit costs $2.50:

SET compute_price=2.50;

SELECT date_trunc(day, start_time) AS usage_day,
SUM(coalesce(credits_used, 0.00)) AS total_credits,
SUM($compute_price * coalesce(credits_used, 0.00))
  AS billable_warehouse_usage
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE start_time >= date_trunc(day, dateadd(day, -3,current_timestamp))
  AND start_time < date_trunc(day, current_timestamp)
GROUP BY 1;


-- 18.7.4  Determine the amount of storage and associated costs used within an
--         account in the last three (3) days. Assume storage costs
--         $23/TB/month.

SET storage_price=23;

SELECT date_trunc(day, usage_date) AS usage_day,
ROUND(AVG(storage_bytes)/power(1024, 4), 3)
  AS billable_database_tb, ROUND(AVG(failsafe_bytes)/power(1024, 4), 3)
  AS billable_failsafe_tb, ROUND(AVG(stage_bytes)/power(1024, 4), 3)
  AS billable_stage_tb, $storage_price *
  (billable_database_tb + billable_failsafe_tb + billable_stage_tb)
  AS total_billable_storage_usd
FROM SNOWFLAKE.ACCOUNT_USAGE.STORAGE_USAGE
WHERE usage_date >= date_trunc(day, dateadd(day, -3, current_timestamp))
AND usage_date < date_trunc(day, current_timestamp)
GROUP BY 1;


-- 18.7.5  Show the 10 longest queries by using the QUERY_HISTORY View:

SELECT query_text, user_name, role_name,
   database_name, warehouse_name, warehouse_size, execution_status,
   ROUND(total_elapsed_time/1000,3) elapsed_sec
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
ORDER BY total_elapsed_time DESC LIMIT 10;


-- 18.7.6  Show the top 10 users in terms of total execution time within the
--         Account for the last 5 days by using the QUERY_HISTORY View:

SELECT user_name, ROUND(SUM(total_elapsed_time)/1000/60/60,3) elapsed_hrs
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE START_TIME >= DATE_TRUNC(DAY, DATEADD(DAY, -5, CURRENT_TIMESTAMP))
  AND START_TIME < DATE_TRUNC(DAY, CURRENT_TIMESTAMP)
GROUP BY 1 ORDER BY 2 DESC
LIMIT 10;


-- 18.7.7  Suspend your warehouse:

ALTER WAREHOUSE COBRA_WH SUSPEND;

