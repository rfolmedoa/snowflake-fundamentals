USE ROLE ACCOUNTADMIN;
USE WAREHOUSE INSTRUCTOR1_WH;
USE DATABASE INSTRUCTOR1_DB;
USE SCHEMA PUBLIC;
-- https://docs.snowflake.com/en/user-guide/managing-behavior-change-releases.html
-- https://community.snowflake.com/s/article/Pending-Behavior-Change-Log
-- Enabling the Preview
-- This preview is bound to the 2021_10 behavior change bundle.
-- To enable the preview, call the SYSTEM$ENABLE_BEHAVIOR_CHANGE_BUNDLE function. For example:

-- get status
select system$behavior_change_bundle_status('2021_10');
select system$behavior_change_bundle_status('2022_02');
select system$behavior_change_bundle_status('2022_03');

-- enable bundle
select system$enable_behavior_change_bundle('2022_03');

-- disable bundle
select system$disable_behavior_change_bundle('2021_03');