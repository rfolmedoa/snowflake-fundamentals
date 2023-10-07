
-- 3.0.0   OPTIONAL: Understanding and Working with SnowSQL
--         Lab Purpose: Use SnowSQL and run several queries directly through the
--         command-line tool. The final exercise provides you with practice
--         running SQL scripts through the Snowflake command line tool.
--         Expect this lab to take approximately 35 minutes.

-- 3.1.0   SnowSQL
--         SnowSQL is a command line tool, typically downloaded and installed on
--         your local machine. It provides interactive access to running SQL on
--         Snowflake similar to the Web UI. The Web UI does not currently
--         support the GET or PUT in SQL for putting data into stages or getting
--         out of stages. We will use SnowSQL here to learn how to upload data
--         into Snowflake internal stages and download data out of Snowflake
--         internal stages.
--         For the purposes of this training class, we have installed it on a
--         cloud server so you can gain some experience with the tool without
--         having to download it to your local machine.
--         We highly recommend that as you start getting further into Snowflake
--         that you download and install SnowSQL on your local machine. Even
--         though the cloud provided SnowSQL will help you complete this lab,
--         for your work you’ll want to download and install it on your own
--         machine. https://docs.snowflake.com/en/user-guide/snowsql-install-
--         config.html

-- 3.2.0   Login
--         If you haven’t already for another lab, you’ll need to login to the
--         Snowflake University cloud hosted Jupyter. This instance can be used
--         for a variety of data science, and connector exploration but for this
--         lab we’ll just be using the SnowSQL through a web terminal.

-- 3.2.1   Navigate to Snowflake University Jupyter Server
--         Open a web browser, and navigate to:
--         https://labs.snowflakeuniversity.com
--         Login using Snowflake credentials
--         Access to Snowflake University Jupyter Server is controlled by the
--         Snowflake Education Account credentials (Snowflake account name,
--         Snowflake login name which is usually an animal name, and password)
--         provided to you by the course instructor.
--         After the Snowflake Training Account credentials expire so will
--         access to Snowflake University Jupyter server.
--         After successfully logging in, an individual notebook environment is
--         being built for your exclusive use. It may take a few minutes until
--         your environment is ready (up to 10 minutes, but likely about 3-4
--         minutes).
--         Open Terminal

-- 3.2.2   Start SnowSQL interactively
--         In your browser, you’ll launch a Terminal window that will give you a
--         command prompt. Click on terminal, and then use the launched terminal
--         to start aned use SnowSQL.
--         Open Terminal
--         In the command above, -a specifies the name of the Snowflake account
--         you are connecting to (the instructor will provide you with the
--         account name). The -u parameter specifies your user name.

-- 3.2.3   Verify that your current role is set to your default of
--         TRAINING_ROLE:

SELECT CURRENT_ROLE();


-- 3.2.4   If you haven’t created the class database or warehouse, do it now

CREATE WAREHOUSE IF NOT EXISTS COBRA_WH;
CREATE DATABASE IF NOT EXISTS COBRA_DB;


-- 3.2.5   Create a COBRA_TBL if you hadn’t already in COBRA_DB. You may
--         have already created this table in a previous lab, but if not we’ll
--         create it now:

USE WAREHOUSE COBRA_WH;
CREATE DATABASE IF NOT EXISTS COBRA_DB;
use database COBRA_DB;
CREATE OR REPLACE TABLE COBRA_DB.PUBLIC.COBRA_TBL (
  id NUMBER(38,0),
  name STRING(10),
  country VARCHAR(20),
  order_date DATE
);


-- 3.2.6   Insert the following three rows into the table you created earlier:

INSERT INTO COBRA_TBL VALUES(2, 'A','UK', '11/02/2005');
INSERT INTO COBRA_TBL VALUES(4, 'C','SP', '11/02/2005');
INSERT INTO COBRA_TBL VALUES(3, 'C','DE', '11/02/2005');


-- 3.2.7   Insert several more rows using a single INSERT INTO statement:

INSERT INTO COBRA_TBL VALUES
    (1, 'ORDERC007', 'JAPAN', '11/02/2005'),
    (7, 'ORDERF821', 'UK', '11/03/2005'),
    (12, 'ORDERB029', 'USA', '11/03/2005');


-- 3.2.8   Query the data in COBRA_TBL and order it by ID:

SELECT * FROM COBRA_TBL
ORDER BY id;

--         Following the syntax above, insert four rows of data into the MEMBERS
--         table you created earlier. The five columns are customer ID, first
--         name, last name, membership start date, and membership level. HINT:
--         Remember what schema this table is in!

INSERT INTO COBRA_SCHEMA.members
VALUES
(103, 'Barbra', 'Streisand', '10/05/2019', 'silver'),
(95, 'Ray', 'Bradbury', '06/06/2006', 'bronze'),
(111, 'Daenerys', 'Targaryen', '2/4/2019', 'gold'),
(87, 'Homer', 'Simpson', '3/1/1998', 'gold');


-- 3.2.9   Return all rows and columns in the table:

SELECT * FROM COBRA_SCHEMA.members;


-- 3.2.10  Exit the SnowSQL interface:

!exit


-- 3.3.0   Run a Script in SnowSQL

-- 3.3.1   Create a file called script.sql that contains the following:

USE ROLE TRAINING_ROLE;
USE WAREHOUSE COBRA_WH;
USE DATABASE COBRA_DB;
USE SCHEMA PUBLIC;
SELECT * FROM COBRA_TBL;

--         New Script.sql

-- 3.3.2   Return to Terminal, pass it your script (-f), and supply your
--         password when requested:

snowsql -a [account] -u COBRA -f script.sql

--         NOTE: You must either be in the same location as your script when you
--         run it, or you must provide the full path to the script.

-- 3.3.3   You will see your output and then SnowSQL will exit.
