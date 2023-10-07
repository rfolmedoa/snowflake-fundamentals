
-- 6.0.0   Loading Structured Data
--         The purpose of this lab is to introduce you to data loading and data
--         unloading.
--         - How to load data from a file in an external stage into a table
--         using the COPY INTO command.
--         - How to define a GZIP file format.
--         - How to review the properties of a stage.
--         - How to load a GZipped file from an external stage into a table.
--         - How to validate data prior to loading
--         - How to handle data loading errors
--         You are a data engineer at Snowbear Air. You need to create and
--         populate a table that will be used in reporting. The table will be
--         called REGION and you will populate it from a pre-existing file
--         (region.tbl) in an external stage. The file is headerless, pipe-
--         delimited and contains five rows.
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

-- 6.1.0   Loading Data from an External Stage into a Table Using COPY INTO
--         In this exercise you will learn how to load a file from an external
--         stage into a table using the COPY INTO command.

-- 6.1.1   Create a new folder called Data Loading

-- 6.1.2   Create a new worksheet named Load Structured Data.

-- 6.1.3   Use the following SQL to set the context:

USE ROLE TRAINING_ROLE;
CREATE WAREHOUSE IF NOT EXISTS COBRA_WH;
USE WAREHOUSE COBRA_WH;
CREATE DATABASE IF NOT EXISTS COBRA_DB;
USE COBRA_DB.PUBLIC;


-- 6.1.4   Create a REGION table. This table will be loaded from a source file:

CREATE OR REPLACE TABLE REGION (
       R_REGIONKEY NUMBER(38,0) NOT NULL,
       R_NAME      VARCHAR(25)  NOT NULL,
       R_COMMENT   VARCHAR(152)
);


-- 6.1.5   Create a file format called MYPIPEFORMAT, that will read the pipe-
--         delimited region.tbl file:

CREATE OR REPLACE FILE FORMAT MYPIPEFORMAT
  TYPE = CSV
  COMPRESSION = NONE
  FIELD_DELIMITER = '|'
  FILE_EXTENSION = 'tbl'
  ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;


-- 6.1.6   Create a file format called MYGZIPPIPEFORMAT that will read the
--         compressed version of the region.tbl file. It should be identical to
--         the MYPIPEFORMAT, except you will set COMPRESSION = GZIP.

CREATE OR REPLACE FILE FORMAT MYGZIPPIPEFORMAT
 TYPE = CSV
 COMPRESSION = GZIP
 FIELD_DELIMITER = '|'
 FILE_EXTENSION = 'tbl'
 ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;


-- 6.2.0   Load the region.tbl File
--         The files for this task have been pre-loaded into a location on AWS.
--         The external stage that points to that location has been created for
--         you. The stage is in the TRAININGLAB schema of the TRAINING_DB
--         database. In this task you will review the files in the stage, and
--         load them using the file formats you created.

-- 6.2.1   Review the properties of the stage:

DESCRIBE STAGE TRAINING_DB.TRAININGLAB.ED_STAGE;

--         NOTE: The file format defined in the stage is not quite right for
--         this data. In particular, the field delimiter is set to a comma. You
--         have two choices - you could either modify the file format definition
--         in the stage itself, or you could specify a different file format
--         with the COPY INTO command. You will use your MYPIPEFORMAT file
--         format.

-- 6.2.2   Confirm the region.tbl file is in the external stage with the list
--         command:

LIST @training_db.traininglab.ed_stage/load/lab_files/ pattern='.*region.*';


-- 6.2.3   Load the data from the external stage to the REGION table, using the
--         file format you created in the previous task:

COPY INTO REGION
FROM @training_db.traininglab.ed_stage/load/lab_files/
FILES = ('region.tbl')
FILE_FORMAT = (FORMAT_NAME = MYPIPEFORMAT);


-- 6.2.4   Select and review the data in the REGION table, either by executing
--         the following command in your worksheet or by using Preview Data in
--         the sidebar:

SELECT * FROM REGION;


-- 6.3.0   Loading a GZip Compressed File on an External Stage into a Table
--         The scenario for this activity is fundamentally the same as the
--         previous activity. The difference is that you will load the REGION
--         Table from a gzip compressed file that is in the external stage. You
--         will use the MYGZIPPIPEFORMAT file format you created in the previous
--         part of this lab.

-- 6.3.1   Empty the REGION Table in the PUBLIC schema of COBRA_DB:

TRUNCATE TABLE region;


-- 6.3.2   Confirm that the region.tbl.gz file is in the external stage:

LIST @training_db.traininglab.ed_stage/load/lab_files/ pattern='.*region.*';


-- 6.3.3   Reload the REGION table from the region.tbl.gz file. Review the
--         syntax of the COPY INTO command used in the previous task. Specify
--         the file to COPY as region.tbl.gz.

COPY INTO region
FROM @training_db.traininglab.ed_stage/load/lab_files/
FILES = ('region.tbl.gz')
FILE_FORMAT = ( FORMAT_NAME = MYGZIPPIPEFORMAT);


-- 6.3.4   Query the table to confirm the data was successfully loaded:

SELECT * FROM region;


-- 6.3.5   Suspend and resize the warehouse

ALTER WAREHOUSE COBRA_WH SET WAREHOUSE_SIZE=XSmall;
ALTER WAREHOUSE COBRA_WH SUSPEND;


-- 6.4.0   Validating data prior to load
--         Now we’re going to practice using the VALIDATION_MODE parameter of
--         the COPY INTO statement to check for problems with the file prior to
--         loading it.

-- 6.4.1   Modify the NATION table by running the statement below.


CREATE OR REPLACE TABLE nation (
                          NATION_KEY INTEGER
                        , NATION VARCHAR
                        , REGION_KEY INTEGER
                        , COMMENTS VARCHAR
                    );
                  


-- 6.4.2   Try to copy into the NATION Table by executing the COPY INTO
--         statement below
--         Notice that the validation mode is RETURN_ALL_ERRORS. This will
--         return any and all errors if there are any. Regardless, no data will
--         be loaded. This is because by providing a value for VALIDATION_MODE,
--         we are indicating we only want to check the file, not load the file.


COPY INTO NATION
FROM @training_db.traininglab.ed_stage/load/lab_files/
FILES = ('nation.tbl')
FILE_FORMAT = (FORMAT_NAME = MYPIPEFORMAT)
VALIDATION_MODE = RETURN_ALL_ERRORS;


--         You should have gotten a message that says Query produced no results.
--         This means there were no errors and that you can load the table. But
--         now we’re going to recreate the table and switch the order of the
--         columns. By making REGION_KEY, which is an integer column, the second
--         column in the table, we will have errors because the second column in
--         the file is a VARCHAR field.

-- 6.4.3   Recreate the NATION table and execute the COPY INTO statement
--         Note that in this case we are using RETURN_ERRORS. Like
--         RETURN_ALL_ERRORS, it will return any and all errors stemming from
--         the loading of the file indicated in the COPY INTO statement below.


CREATE OR REPLACE TABLE nation (
                          NATION_KEY INTEGER
                        , REGION_KEY INTEGER    
                        , NATION VARCHAR
                        , COMMENTS VARCHAR
                    );

COPY INTO NATION
FROM @training_db.traininglab.ed_stage/load/lab_files/
FILES = ('nation.tbl')
FILE_FORMAT = (FORMAT_NAME = MYPIPEFORMAT)
VALIDATION_MODE = RETURN_ERRORS;


--         Now you should have 25 rows indicating that the VARCHAR value we
--         tried to load into the REGION column has created an error. Had we
--         tried to load the file, none of the rows would have loaded.

-- 6.4.4   Check only the first 10 rows
--         In the next statement we set the VALIDATION_MODE to RETURN_10_ROWS.
--         So, our statement will only check the first ten rows and return the
--         first error it encounters.


COPY INTO NATION
FROM @training_db.traininglab.ed_stage/load/lab_files/
FILES = ('nation.tbl')
FILE_FORMAT = (FORMAT_NAME = MYPIPEFORMAT)
VALIDATION_MODE = RETURN_10_ROWS;


--         As you can see, we have a message saying that the numeric value
--         ALGERIA is not recognized.

-- 6.5.0   Error Handling
--         Now we’re going to examine error handling options for data loading in
--         Snowflake.

-- 6.5.1   Recreate the table with all columns in the same order as they are in
--         the nation.tbl file


CREATE OR REPLACE TABLE nation (
                          NATION_KEY INTEGER
                        , NATION VARCHAR
                        , REGION_KEY INTEGER
                        , COMMENTS VARCHAR
                    );



-- 6.5.2   Verify the query
--         AS you will see in the query below, we’ve introducted an error in the
--         third column. For all rows where the region key is 1, we’ve converted
--         it to the VARCHAR value America. This will generate five errors when
--         loading into an INTEGER column.


SELECT    
          n.$1 AS N_KEY
        , n.$2 AS NATION    
        , CASE 
            WHEN n.$3 = 1 THEN 'AMERICA'
            ELSE n.$3
          END AS R_KEY
        , n.$4 AS COMMENTS
FROM @training_db.traininglab.ed_stage/load/lab_files/nation.tbl (file_format => 'MYPIPEFORMAT') n;



-- 6.5.3   Attempt to load the data
--         Notice that we’ve set the ON_ERROR parameter to continue. This means
--         that all rows that don’t generate an error will get loaded.


COPY INTO nation
FROM (
        SELECT    
              n.$1 AS N_KEY
            , n.$2 AS NATION    
            , CASE 
                WHEN n.$3 = 1 THEN 'AMERICA'
                ELSE n.$3
              END AS R_KEY
            , n.$4 AS COMMENTS

        FROM @training_db.traininglab.ed_stage/load/lab_files/nation.tbl (file_format => 'MYPIPEFORMAT') n
    )
FILE_FORMAT = (FORMAT_NAME = MYPIPEFORMAT)
ON_ERROR = CONTINUE;


--         As you can see from the results, the status is PARTIALLY_LOADED and
--         rows_loaded is 20 out of the original 25.

-- 6.5.4   Run the SELECT statement below to verify the contents of the table,
--         then truncate the table.


SELECT * FROM nation;

TRUNCATE TABLE nation;



-- 6.5.5   Retry the insert with ON_ERROR = ABORT_STATEMENT
--         ABORT_STATEMENT is the default value and it will cause the entire
--         load to fail.


COPY INTO nation
FROM (
        SELECT    
              n.$1 AS N_KEY
            , n.$2 AS NATION    
            , CASE 
                WHEN n.$3 = 1 THEN 'AMERICA'
                ELSE n.$3
              END AS R_KEY
            , n.$4 AS COMMENTS

        FROM @training_db.traininglab.ed_stage/load/lab_files/nation.tbl (file_format => 'MYPIPEFORMAT') n
    )
FILE_FORMAT = (FORMAT_NAME = MYPIPEFORMAT)
ON_ERROR = ABORT_STATEMENT; --ALSO THE DEFAULT OPTION WHEN ON_ERROR ISN'T SPECIFIED


--         As you can see, the error is Numeric value AMERICA is not recognized.
--         No data was loaded.

-- 6.5.6   Retry the insert with ON_ERROR = SKIP_FILE_4
--         With this statement, we’re telling Snowflake that we want to load the
--         file if we have four or more errors. Since we know our file will
--         generate 5 errors, the load should fail completely.


COPY INTO nation
FROM (
        SELECT    
              n.$1 AS N_KEY
            , n.$2 AS NATION    
            , CASE 
                WHEN n.$3 = 1 THEN 'AMERICA'
                ELSE n.$3
              END AS R_KEY
            , n.$4 AS COMMENTS

        FROM @training_db.traininglab.ed_stage/load/lab_files/nation.tbl (file_format => 'MYPIPEFORMAT') n
    )
FILE_FORMAT = (FORMAT_NAME = MYPIPEFORMAT)
ON_ERROR = SKIP_FILE_4; 


--         As you can see, you got an error that says LOAD_FAILED.

-- 6.5.7   Retry the insert with ON_ERROR = SKIP_FILE_6
--         With this statement, we’re telling Snowflake that we want to load the
--         file if we have six or more errors. Since we know our file will
--         generate 5 errors, we should get a partial load.


COPY INTO nation
FROM (
        SELECT    
              n.$1 AS N_KEY
            , n.$2 AS NATION    
            , CASE 
                WHEN n.$3 = 1 THEN 'AMERICA'
                ELSE n.$3
              END AS R_KEY
            , n.$4 AS COMMENTS

        FROM @training_db.traininglab.ed_stage/load/lab_files/nation.tbl (file_format => 'MYPIPEFORMAT') n
    )
FILE_FORMAT = (FORMAT_NAME = MYPIPEFORMAT)
ON_ERROR = SKIP_FILE_6;


--         As you can see, the file was partially loaded. 20 out of 25 rows were
--         loaded.

-- 6.6.0   Key Takeaways
--         - Files to be loaded can be compressed or not compressed.
--         - The COPY INTO command can be used to load.
--         - You can use the LIST command to see what files are in a stage.
--         - The VALIDATION_MODE parameter of the COPY INTO statement to check
--         for problems with the file prior to loading it.
--         - You can set the ON_ERROR parameter of the COPY INTO statement to
--         load all, some or none of the data if one or more errors are
--         detected.
