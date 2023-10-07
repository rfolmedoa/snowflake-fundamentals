
-- 7.0.0   Data Transformation During Data Loading
--         The purpose of this lab is to introduce you to how to transform data
--         when loading it.
--         - How to transform data while loading it
--         You are a data engineer at Snowbear Air. You need to populate a table
--         with a list of nations and you need to provide a region name as well
--         as a region code. But, the file doesn’t have those two pieces of
--         data. You will need to transform the data in the file prior to
--         loading it so it has that data.
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

-- 7.1.0   Transforming Data During Load

-- 7.1.1   Create a new folder called Data Loading and Transformation

-- 7.1.2   Create a new worksheet named Transforming Data During Load.

-- 7.1.3   Create the context


CREATE DATABASE IF NOT EXISTS  COBRA_db;
CREATE SCHEMA IF NOT EXISTS COBRA_transform;
USE SCHEMA COBRA_transform;
USE SCHEMA COBRA_db.COBRA_transform;



-- 7.1.4   Search for the nation file
--         Execute the statement below to list the files in the stage with a
--         .tbl extension.


LIST @training_db.traininglab.ed_stage/load/lab_files/ pattern='.*\.tbl.*';


--         If you scroll down far enough, you will find nation.tbl. That is the
--         file that you want to transform and load.

-- 7.1.5   Query the file in the stage
--         Before you run the statement below, take a close look at the SELECT
--         clause. Notice that there are three columns that start with the alias
--         for the file (n) and are followed by a period, a dollar sign and a
--         number. These refer to the first three columns in the file. You can
--         refer to columns in the SELECT clause in this way whether or not they
--         exist in the file. If they don’t the entire column will simply be
--         null.


SELECT n.$1, n.$2, n.$3
FROM @training_db.traininglab.ed_stage/load/lab_files/nation.tbl n ;


--         Note that the first two columns have data while the third one is
--         null. In fact, the first column is the one we want. The problem is
--         that we want to transform the data prior to loading it into a table,
--         and it’s in a pipe-delimited format. So, we need to create a file
--         format that will handle the data and let us query individual columns
--         straight out of the file.

-- 7.1.6   Create a pipe-delimited file format


CREATE OR REPLACE FILE FORMAT MYPIPEFORMAT
  TYPE = CSV
  COMPRESSION = NONE
  FIELD_DELIMITER = '|'
  FILE_EXTENSION = 'tbl'
  ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;



-- 7.1.7   Create the target table
--         We’ve been given a target table format. Let’s create the table now:


CREATE OR REPLACE TABLE nation (
                                  NATION_KEY INTEGER
                                , REGION VARCHAR
                                , REGION_CODE VARCHAR
                                , NATION VARCHAR
                                , COMMENTS VARCHAR
                            );



-- 7.1.8   Use the file format to query the file.
--         As you can see, we’ve added the file format right after the table
--         name. We’ve also aliased all of the columns.


SELECT n.$1 AS N_KEY, n.$2 AS N_NAME, n.$3 AS R_KEY, n.$4 AS N_COMMENT
FROM @training_db.traininglab.ed_stage/load/lab_files/nation.tbl (file_format => 'MYPIPEFORMAT') n ;


--         N_KEY can be the source for NATION_KEY in our target table. However,
--         we only have a region key, not a region name. Also, we need to
--         provide a region code that consists of the first two letters of the
--         region name. Finally, N_NAME can be the source for NATION. The
--         problem is that it is the second column in the file, but it needs to
--         go into the fourth column in the table.
--         Fortunately, Snowflake allows us to insert columns in a different
--         order than they exist in the file. Also, we can use functions and
--         CASE…WHEN statements to transform the data into the format we need it
--         to be in. The query below does that for us.

-- 7.1.9   Execute the statement below


SELECT    n.$1 AS N_KEY
        , CASE 
            WHEN n.$3 = 0 THEN 'AFRICA' 
            WHEN n.$3 = 1 THEN 'AMERICA'
            WHEN n.$3 = 2 then 'ASIA' 
            WHEN n.$3 = 3 THEN 'EUROPE'
            ELSE 'MIDDLE EAST'
          END AS REGION
        , substr(REGION, 1, 2) AS REGION_CODE
        , n.$2 AS NATION
        , n.$4 AS COMMENTS

FROM @training_db.traininglab.ed_stage/load/lab_files/nation.tbl (file_format => 'MYPIPEFORMAT') n ;


--         As you can see, the columns are now in the order and format that we
--         need. Let’s insert the data now.

-- 7.1.10  Insert the data
--         Execute the COPY INTO statement below and then check the results.


COPY INTO nation
FROM (
        SELECT    
              n.$1 AS N_KEY
            , CASE 
                WHEN n.$3 = 0 THEN 'AFRICA' 
                WHEN n.$3 = 1 THEN 'AMERICA'
                WHEN n.$3 = 2 then 'ASIA' 
                WHEN n.$3 = 3 THEN 'EUROPE'
                ELSE 'MIDDLE EAST'
              END AS REGION
            , substr(REGION, 1, 2) AS REGION_CODE
            , n.$2 AS NATION
            , n.$4 AS COMMENTS

        FROM @training_db.traininglab.ed_stage/load/lab_files/nation.tbl (file_format => 'MYPIPEFORMAT') n
    );


--         In the result pane you should see a row that says status = loaded and
--         rows_loaded = 25. If you do, the load was successful.

-- 7.1.11  Run the SELECT statement below to view the contents of the NATION
--         table


SELECT * FROM nation;


--         You should have 25 rows of data in your table.

-- 7.1.12  Suspend and resize the warehouse

ALTER WAREHOUSE COBRA_WH SET WAREHOUSE_SIZE=XSmall;
ALTER WAREHOUSE COBRA_WH SUSPEND;


-- 7.2.0   Key Takeaways
--         - You can transform data prior to loading it.
--         - When transforming data, you can reorder the columns coming out of
--         the file, and you can use (but are not limited to) functions or
--         CASE…WHEN statements.
