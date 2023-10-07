
-- 9.0.0   Loading and Unloading Structured Data
--         Expect this lab to take approximately 30 minutes.

-- 9.1.0   Create Tables and File Formats
--         This exercise will load the region.tbl file into a REGION table in
--         your Database. The region.tbl file which is already in the cloud is
--         pipe (|) delimited. It has no header and contains the following five
--         rows:
--         NOTE: There is a delimiter at the end of every line, which by default
--         is interpreted as an additional column by the COPY INTO statement.

-- 9.1.1   Navigate to [Worksheets] and create a new worksheet named Load
--         Structured Data. Use the following SQL to set the context:

USE ROLE TRAINING_ROLE;
CREATE WAREHOUSE IF NOT EXISTS COBRA_WH;
USE WAREHOUSE COBRA_WH;
CREATE DATABASE IF NOT EXISTS COBRA_DB;
USE COBRA_DB.PUBLIC;


-- 9.1.2   Execute all of the CREATE TABLE statements:

CREATE OR REPLACE TABLE REGION (
       R_REGIONKEY NUMBER(38,0) NOT NULL,
       R_NAME      VARCHAR(25)  NOT NULL,
       R_COMMENT   VARCHAR(152)
);


-- 9.1.3   Create a file format called MYPIPEFORMAT, that will read the pipe-
--         delimited region.tbl file:

CREATE OR REPLACE FILE FORMAT MYPIPEFORMAT
  TYPE = CSV
  COMPRESSION = NONE
  FIELD_DELIMITER = '|'
  FILE_EXTENSION = 'tbl'
  ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;


-- 9.1.4   Create a file format called MYGZIPPIPEFORMAT that will read the
--         compressed version of the region.tbl file. It should be identical to
--         the MYPIPEFORMAT, except you will set COMPRESSION = GZIP.

CREATE OR REPLACE FILE FORMAT MYGZIPPIPEFORMAT
 TYPE = CSV
 COMPRESSION = GZIP
 FIELD_DELIMITER = '|'
 FILE_EXTENSION = 'tbl'
 ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;


-- 9.2.0   Load the region.tbl File
--         The files for this task have been pre-loaded into a location on AWS.
--         The external stage that points to that location has been created for
--         you. The stage is in the TRAININGLAB schema of the TRAINING_DB
--         database. In this task you will review the files in the stage, and
--         load them using the file formats you created.

-- 9.2.1   Review the properties of the stage:

DESCRIBE STAGE TRAINING_DB.TRAININGLAB.ED_STAGE;

--         NOTE: The file format defined in the stage is not quite right for
--         this data. In particular, the field delimiter is set to a comma. You
--         have two choices - you could either modify they file format
--         definition in the stage itself, or you could specify a different file
--         format with the COPY INTO command. You will use your MYPIPEFORMAT
--         file format.

-- 9.2.2   Confirm the file is in the external stage with the list command:

LIST @training_db.traininglab.ed_stage/load/lab_files/ pattern='.*region.*';


-- 9.2.3   Load the data from the external stage to the REGION table, using the
--         file format you created in the previous task:

COPY INTO REGION
FROM @training_db.traininglab.ed_stage/load/lab_files/
FILES = ('region.tbl')
FILE_FORMAT = (FORMAT_NAME = MYPIPEFORMAT);


-- 9.2.4   Select and review the data in the REGION table, either by executing
--         the following command in your worksheet or by using Preview Data in
--         the sidebar:

SELECT * FROM REGION;


-- 9.3.0   Load a GZip Compressed File
--         This exercise will reload the REGION Table from a gzip compressed
--         file that is in the external stage. You will use your
--         MYGZIPPIPEFORMAT file format.
--         For these next steps, you will use a smaller warehouse.

-- 9.3.1   Empty the REGION Table in the PUBLIC schema of COBRA_DB:

TRUNCATE TABLE region;


-- 9.3.2   Confirm that the region.tbl.gz file is in the external stage:

LIST @training_db.traininglab.ed_stage/load/lab_files/ pattern='.*region.*';


-- 9.3.3   Reload the REGION table from the region.tbl.gz file. Review the
--         syntax of the COPY INTO command used in the previous task. Specify
--         the file to COPY as region.tbl.gz.

COPY INTO region
FROM @training_db.traininglab.ed_stage/load/lab_files/
FILES = ('region.tbl.gz')
FILE_FORMAT = ( FORMAT_NAME = MYGZIPPIPEFORMAT);


-- 9.3.4   Query the table to view the data:

SELECT * FROM region;


-- 9.4.0   Load data using the Load Data Wizard
--         In this portion of the lab you’ll learn how to load data from a file
--         on your desktop using the Load Data Wizard. You are going to generate
--         the file to load in CSV format, create your own file format, and load
--         the data using the Wizard.

-- 9.4.1   First, run the following query to generate the file you’re going to
--         load. Note that it uses the REPLACE function to remove any stray
--         commas in the R_COMMENT field. Since we’re going to ultimately load
--         the file using a CSV file format, this will ensure that all rows will
--         load without any inadvertent errors.

SELECT R_REGIONKEY, R_NAME, REPLACE(R_COMMENT, ',') AS R_COMMENT FROM region;


-- 9.4.2   You should see five rows in the results. Click the download button to
--         download the file:
--         Download Button

-- 9.4.3   You will see a dialog box offering you either TSV or CSV format.
--         Select CSV and click Export.

-- 9.4.4   Your file should have been saved to the location you selected.
--         Examine the file using the text editor of your choice. The file
--         should have a header row and five rows of data.

-- 9.4.5   Now let’s create a CSV file format using the user interface. In the
--         Web UI, click the Databases button in the ribbon at the top, then
--         click the File Formats tab.

-- 9.4.6   You should see a list of existing file formats, including the ones
--         you created. Click Create.

-- 9.4.7   The Create File Format dialog box should appear. Type MYCSVFORMAT in
--         the Name text box. As you can see, the other options have been
--         automatically selected for you: CSV as Format Type, Auto as
--         Compression Method, and Comma as Column Separator. Go ahead and click
--         Finish.

-- 9.4.8   Your new file format should now be listed. Now click the Tables tab
--         and select the row for table REGION.

-- 9.4.9   Click the Load Table option just above the table list.

-- 9.4.10  You should now see the Load Data dialog box. You will have to select
--         the warehouse, source files, file format and load options. Select
--         COBRA_WH and click Next.

-- 9.4.11  You should see an option to load file from your computer. Click the
--         Select Files button, navigate to and select the file you downloaded,
--         then click Next.

-- 9.4.12  You should now see an option to select a file format. Select
--         MYCSVFORMAT and click Next.

-- 9.4.13  You should now see a list of Load Options. These give you different
--         options for how errors are handled while parsing the file. We want to
--         load the data despite any errors, so select Continue loading valid
--         data from the file and click Load.

-- 9.4.14  You should see a dialog box saying files are being encrypted and
--         staged. Then you should see the load results showing that 6 rows were
--         parsed and 5 rows were loaded. Evaluate the column First Error.

-- 9.4.15  The error should read Numeric value R_REGIONKEY is not recognized.
--         This means that the column headers in the file weren’t loaded. That
--         is okay because we obviously didn’t want to load them anyway.

-- 9.4.16  Now go back to your worksheet and run the following SQL statement:

SELECT * FROM region;


-- 9.4.17  You should have five rows in the REGION table now.

-- 9.5.0   Unload a Pipe-Delimited File to a Table Stage

-- 9.5.1   Open a new worksheet and set the context as follows:

USE ROLE TRAINING_ROLE;
CREATE WAREHOUSE IF NOT EXISTS COBRA_WH;
USE WAREHOUSE COBRA_WH;
CREATE DATABASE IF NOT EXISTS COBRA_DB;
USE COBRA_DB.PUBLIC;


-- 9.5.2   Create a fresh version of the REGION table with 5 records to unload:

create or replace table REGION as 
select * from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION;


-- 9.5.3   Unload the data to the REGION table stage. Remember that a table
--         stage is automatically created for each table. Use the slides,
--         workbook, or Snowflake documentation for questions on the syntax. You
--         will use MYPIPEFORMAT for the unload:

COPY INTO @%region
FROM region
FILE_FORMAT = (FORMAT_NAME = MYPIPEFORMAT);


-- 9.5.4   List the stage and verify that the data is there:

LIST @%region;


-- 9.5.5   OPTIONAL: Use GET to download the file to your local system. Open it
--         with an editor and see what it contains.
--         NOTE: The GET command is not supported in the GUI; use the SnowSQL
--         CLI:

GET @%region file:///<path to dir> ; -- this is for MAC
GET @%region file://c:<path to dir>; -- this is for windows


-- 9.5.6   Remove the file from the REGION table’s stage:

REMOVE @%region;


-- 9.6.0   Use a SQL statement containing a JOIN to Unload a Table into an
--         internal stage

-- 9.6.1   Do a SELECT with a JOIN on the REGION and NATION tables. You can JOIN
--         on any column you wish. Review the output from your JOIN.

SELECT * 
FROM "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1"."REGION" r 
JOIN "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1"."NATION" n ON r.r_regionkey = n.n_regionkey;


-- 9.6.2   Create a named stage (you can call it whatever you want):

CREATE OR REPLACE STAGE mystage;


-- 9.6.3   Unload the JOINed data into the stage you created:

COPY INTO @mystage FROM
(SELECT * FROM "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1"."REGION" r JOIN "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1"."NATION" n
ON r.r_regionkey = n.n_regionkey);


-- 9.6.4   Verify the file is in the stage:

LIST @mystage;


-- 9.6.5   OPTIONAL: Use GET to download the file to your local system and
--         review it (requires SnowSQL)

GET @mystage file:///<path> -- for Mac
GET @mystage file://c:<path -- For Windows


-- 9.6.6   Remove the file from the stage:

REMOVE @mystage;


-- 9.6.7   Remove the stage:

DROP STAGE mystage;

