
-- 17.0.0  Introduction to Monitoring Usage and Billing
--         The purpose of this lab is to familiarize you with the Snowflake
--         database, the schemas in the database, and how you can use that data
--         to monitor how users are using the objects in your system and what
--         the associated costs are with that usage.
--         - Monitor usage and billing with the ACCOUNT_USAGE schema
--         - Determine which warehouses do not have resource monitors activated
--         for them
--         - Determine the most expensive queries from the last 30 days
--         - Determine the top 10 queries with the most spillage to remote
--         storage
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

-- 17.1.0  Snowflake Database
--         Snowflake provides a system-defined, read-only shared database named
--         SNOWFLAKE that contains metatdata and historical usage data about the
--         objects in your organization and account.
--         The purpose of the database is to allow you to monitor object usage
--         metrics as well as the costs associated with that usage so you can
--         make any adjustments needed to get the most for the credits being
--         spent.
--         Below is a list of the schemas that you can query to get the
--         information you need about object usage and the associated costs.
--         Snowflake Database Schemas
--         ACCOUNT_USAGE: Views that display object metadata and usage metrics
--         for your account.
--         CORE: Contains views and other schema objects utilized in select
--         Snowflake features. Currently, the schema only contains the system
--         tags used by Data Classification. Additional views and schema objects
--         will be introduced in future releases.
--         DATA_SHARING_USAGE: Views that display object metadata and usage
--         metrics related to listings published in the Snowflake Marketplace or
--         a data exchange.
--         ORGANIZATION_USAGE: Views that display historical usage data across
--         all the accounts in your organization.
--         READER_ACCOUNT_USAGE: Similar to ACCOUNT_USAGE, but only contains
--         views relevant to the reader accounts (if any) provisioned for the
--         account.
--         Important: By default, only account administrators (users with the
--         ACCOUNTADMIN role) can access the SNOWFLAKE database and schemas, or
--         perform queries on the views; however, privileges on the database can
--         be granted to other roles in your account to allow other users to
--         access the objects.
--         Note: There is also a schema called INFORMATION_SCHEMA. It is created
--         by default and exists in every Snowflake database.

-- 17.1.1  Links to more information about the Snowflake Database Schemas
--         Click any of the links below if you’d like to read more about the
--         Snowflake database or the schemas listed above.
--         Click here for Snowflake Database
--         Click here for ACCOUNT_USAGE
--         Click here for CORE and Data Classification
--         Click here for DATA_SHARING_USAGE
--         Click here for ORGANIZATION_USAGE
--         Click here for READER_ACCOUNT_USAGE

-- 17.2.0  Monitoring Usage and Billing with the ACCOUNT_USAGE schema
--         The ACCOUNT_USAGE schema supports usage and billing monitoring
--         because it exposes a number of secure views that display data related
--         to object usage history, grants to roles and users, data loading
--         history, metering history, storage history, task history, users,
--         roles and more.
--         Secure views present in the SNOWFLAKE.ACCOUNT_USAGE schema
--         The main approach to writing queries that will help you monitor usage
--         and billing is to look at the views that appear relevant and then run
--         through the column list to see if they appear relevant to your goal.
--         As there are many views in each schema, some with a lot of columns,
--         it will take time and experience working with the schemas to become
--         sufficiently familiar with them such that you know exactly how to get
--         the answers you want off the top of your head.

-- 17.2.1  To get started, create a new worksheet named Warehouse Sizing with
--         the following context:

USE ROLE TRAINING_ROLE;
CREATE WAREHOUSE IF NOT EXISTS COBRA_WH;
USE WAREHOUSE COBRA_WH;


-- 17.2.2  Credit Consumption by Warehouse
--         Monitoring credit consumption for specific objects is a classic use
--         of data in the ACCOUNT_USAGE schema. Here is an example of two
--         queries that utilize the WAREHOUSE_METERING_HISTORY view:

USE SCHEMA SNOWFLAKE.ACCOUNT_USAGE;

-- Credits used (all time = past year)
SELECT WAREHOUSE_NAME
      ,SUM(CREDITS_USED_COMPUTE) AS CREDITS_USED_COMPUTE_SUM
  FROM ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
 GROUP BY 1
 ORDER BY 2 DESC;

-- Credits used (past N days/weeks/months)
SELECT WAREHOUSE_NAME
      ,SUM(CREDITS_USED_COMPUTE) AS CREDITS_USED_COMPUTE_SUM
  FROM ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
 WHERE START_TIME >= DATEADD(DAY, -7, CURRENT_TIMESTAMP())  // Past 7 days
 GROUP BY 1
 ORDER BY 2 DESC;


--         These queries enable you to determine if there are specific
--         warehouses that are consuming more credits than the others. You can
--         then drill into questions such as: Should they be consuming that
--         quantity of credits? Are there specific warehouses that are consuming
--         more credits than anticipated?
--         In the event a warehouse is consuming too many credits you could take
--         action to rectify the sitution. Depending on what the warehouse is
--         being used for, you could consider modifying the auto-suspend policy
--         or the scaling policy, checking the data loading history to see if
--         efficient practices are being used, or analyzing the size and
--         efficiency of queries being run on the warehouse, or adding a
--         resource monitor to the warehouse.
--         Below is a list of the columns in this schema.
--         Warehouse Metering History columns

-- 17.2.3  Determining warehouses without resource monitors
--         If you have warehouses that are using too many credits, you can put
--         resource monitors on them.
--         The query below identifies all warehouses without resource monitors
--         in place. Resource monitors provide the ability to set limits on
--         credits consumed against a warehouse during a specific time interval
--         or date range. This can help prevent certain warehouses from
--         unintentionally consuming more credits than typically expected.


SHOW WAREHOUSES;

SELECT "name" AS WAREHOUSE_NAME
      ,"size" AS WAREHOUSE_SIZE
  FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
 WHERE "resource_monitor" = 'null';



-- 17.3.0  Billing Metrics
--         Billing metrics is all about analyzing what you’ve been billed in the
--         past so you can determine if there is a way to lower costs in the
--         future.

-- 17.3.1  Most expensive queries from the last 30 days
--         The query below analyzes queries that are potentially too expensive
--         by ordering the most expensive queries from the last 30 days. It
--         takes into account the warehouse size, assuming that a 1 minute query
--         on a larger warehouse is more expensive than a 1 minute query on a
--         smaller warehouse.


WITH WAREHOUSE_SIZE AS
(
     SELECT WAREHOUSE_SIZE, NODES
       FROM (
              SELECT 'XSMALL' AS WAREHOUSE_SIZE, 1 AS NODES
              UNION ALL
              SELECT 'SMALL' AS WAREHOUSE_SIZE, 2 AS NODES
              UNION ALL
              SELECT 'MEDIUM' AS WAREHOUSE_SIZE, 4 AS NODES
              UNION ALL
              SELECT 'LARGE' AS WAREHOUSE_SIZE, 8 AS NODES
              UNION ALL
              SELECT 'XLARGE' AS WAREHOUSE_SIZE, 16 AS NODES
              UNION ALL
              SELECT '2XLARGE' AS WAREHOUSE_SIZE, 32 AS NODES
              UNION ALL
              SELECT '3XLARGE' AS WAREHOUSE_SIZE, 64 AS NODES
              UNION ALL
              SELECT '4XLARGE' AS WAREHOUSE_SIZE, 128 AS NODES
            )
),
QUERY_HISTORY AS
(
     SELECT QH.QUERY_ID
           ,QH.QUERY_TEXT
           ,QH.USER_NAME
           ,QH.ROLE_NAME
           ,QH.EXECUTION_TIME
           ,QH.WAREHOUSE_SIZE
      FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY QH
     WHERE START_TIME > DATEADD(month,-2,CURRENT_TIMESTAMP())
)

SELECT QH.QUERY_ID
      ,'https://' || current_account() || '.snowflakecomputing.com/console#/monitoring/queries/detail?queryId='
            ||QH.QUERY_ID AS QU
      ,QH.QUERY_TEXT
      ,QH.USER_NAME
      ,QH.ROLE_NAME
      ,QH.EXECUTION_TIME as EXECUTION_TIME_MILLISECONDS
      ,(QH.EXECUTION_TIME/(1000)) as EXECUTION_TIME_SECONDS
      ,(QH.EXECUTION_TIME/(1000*60)) AS EXECUTION_TIME_MINUTES
      ,(QH.EXECUTION_TIME/(1000*60*60)) AS EXECUTION_TIME_HOURS
      ,WS.WAREHOUSE_SIZE
      ,WS.NODES
      ,(QH.EXECUTION_TIME/(1000*60*60))*WS.NODES as RELATIVE_PERFORMANCE_COST

FROM QUERY_HISTORY QH
JOIN WAREHOUSE_SIZE WS ON WS.WAREHOUSE_SIZE = upper(QH.WAREHOUSE_SIZE)
ORDER BY RELATIVE_PERFORMANCE_COST DESC
LIMIT 200;


--         This query gives you the chance to evaluate expensive queries and
--         take some action. For example, you could look at the query profile,
--         contact the user who executed the query, or take action to optimize
--         these queries.
--         Below is a list of the columns in this secure view,
--         SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY.
--         QUERY_HISTORY view columns

-- 17.3.2  Top 10 Queries With The Most Spillage to Remote Storage
--         Another way to evaluate the cost of queries is to see if they are
--         spilling to remote storage. The query below allows you do do that.


select query_id, substr(query_text, 1, 50) partial_query_text, user_name, warehouse_name, warehouse_size, 
       BYTES_SPILLED_TO_REMOTE_STORAGE, start_time, end_time, total_elapsed_time/1000 total_elapsed_time
from   snowflake.account_usage.query_history
where  BYTES_SPILLED_TO_REMOTE_STORAGE > 0
and start_time::date > dateadd('days', -45, current_date)
order  by BYTES_SPILLED_TO_REMOTE_STORAGE desc
limit 10;


--         This query also provides the warehouse name and size. Once you
--         identify the queries that are spilling to remote storage, you can
--         take action to ensure they are run on larger warehouses with more
--         local storage and memory.

-- 17.4.0  Key Takeaways
--         - As there are many views in each schema, some with a lot of columns.
--         It will take time and experience working with the schemas to become
--         sufficiently familiar with them such that you know exactly how to get
--         the answers you want off the top of your head.
--         - Resource monitors provide the ability to set limits on credits
--         consumed against a warehouse during a specific time interval or date
--         range.
--         - The Snowflake database enables you to determine where you have high
--         credit consumption so you can ask pertinent questions as to why that
--         is occurring. It then enables you to enact solutions that bring the
--         cost down.
