
-- 16.0.0  Continuous Data Protection
--         Lab Purpose: You will work with Snowflake’s cloning and TimeTravel
--         features. You will have the opportunity to clone a table, drop and
--         then undrop a table, and experience how to work with Time Travel.

-- 16.1.0  Use Zero-Copy Clone to Copy Database Objects
--         In this task you’re going to clone the LINEITEM table into the
--         Training_DB database from the Public Schema in the
--         Snowflake_Sample_Database. You’ll notice the speed at which you’re
--         able to clone an incredibly large Table in Snowflake.

-- 16.1.1  Navigate to [Worksheets].

-- 16.1.2  Open a new worksheet

-- 16.1.3  If you haven’t created the class database or warehouse, do it now

CREATE WAREHOUSE IF NOT EXISTS COBRA_WH;
CREATE DATABASE IF NOT EXISTS COBRA_DB;


-- 16.1.4  set your standard context.

USE ROLE TRAINING_ROLE;
USE WAREHOUSE COBRA_WH;
USE DATABASE COBRA_DB;
USE SCHEMA PUBLIC;


-- 16.1.5  Create a copy of the LINEITEM table that is found in the
--         TRAIING_DB.TRAININGLAB schema:

CREATE TABLE lineitem_copy AS
SELECT * FROM TRAINING_DB.TRAININGLAB.LINEITEM;


-- 16.1.6  Create a CLONE of the copy you just created:

CREATE TABLE lineitem_clone
    CLONE lineitem_copy;


-- 16.1.7  COUNT the rows in the LINEITEM_COPY table:

SELECT COUNT(*) FROM lineitem_copy;


-- 16.1.8  COUNT the rows in the LINEITEM_CLONE table:

SELECT COUNT(*) FROM lineitem_clone;


-- 16.1.9  Insert some values into the LINEITEM_COPY table:

INSERT INTO lineitem_copy (l_comment, l_shipdate) values
('Insert 1 into COPY', '2020-01-01'),
('Insert 2 into COPY', '2020-01-02'),
('Insert 3 into COPY', '2020-01-03'),
('Insert 4 into COPY', '2020-01-04'),
('Insert 5 into COPY', '2020-01-05');


-- 16.1.10 Select the new rows from LINEITEM_COPY:

SELECT l_comment, l_shipdate
FROM lineitem_copy
WHERE l_shipdate > '2019-12-31';


-- 16.1.11 Run the same statement against LINEITEM_CLONE, to see the clone has
--         not changed:

SELECT l_comment, l_shipdate
FROM lineitem_clone
WHERE l_shipdate > '2019-12-31';


-- 16.1.12 Insert some values into the LINEITEM_CLONE table:

INSERT INTO lineitem_clone (l_comment, l_shipdate) values
('Insert 6 into CLONE', '2020-01-01'),
('Insert 7 into CLONE', '2020-01-02'),
('Insert 8 into CLONE', '2020-01-03'),
('Insert 9 into CLONE', '2020-01-04'),
('Insert 10 into CLONE', '2020-01-05');


-- 16.1.13 Select the new rows from the LINEITEM_CLONE table. Run the same
--         SELECT that you ran against the LINEITEM_COPY table, to see that the
--         rows are not there:

SELECT l_comment, l_shipdate
FROM lineitem_clone
WHERE l_shipdate > '2019-12-31';
SELECT l_comment, l_shipdate
FROM lineitem_copy
WHERE l_shipdate > '2019-12-31';


-- 16.1.14 Run the same SELECT against the original LINEITEM table, and verify
--         that none of the rows are there:

SELECT l_comment, l_shipdate
FROM TRAINING_DB.TRAININGLAB.LINEITEM
WHERE l_shipdate > '2019-12-31';


-- 16.1.15 Run a JOIN against the LIEITEM_COPY and LINEITEM_CLONE tables to see
--         the difference in the new rows that were added:

SELECT a.l_comment AS comment_copy, a.l_shipdate AS shipdate_copy,
       b.l_comment AS comment_clone, b.l_shipdate AS shipdate_clone
FROM lineitem_copy a
JOIN lineitem_clone b ON a.l_shipdate=b.l_shipdate
WHERE a.l_shipdate > '2019-12-30';


-- 16.2.0  UNDROP a Table

-- 16.2.1  Create a new worksheet named Time Travel.

-- 16.2.2  Create the base table to be used in this exercise:

CREATE TABLE testdrop (c1 NUMBER);


-- 16.2.3  Display the table history and review the values in the dropped_on
--         column. Note that all values are NULL:

SHOW TABLES HISTORY;


-- 16.2.4  DROP the TESTDROP table:

DROP TABLE testdrop;


-- 16.2.5  Query the TESTDROP table. The table will not be found:

SELECT * FROM testdrop;


-- 16.2.6  Rerun the table history and review the values in the dropped_on
--         column:

SHOW TABLES HISTORY;

--         NOTE: The dropped_on column is now populated, to indicate the table
--         was dropped.

-- 16.2.7  Use the UNDROP command to recover the TESTDROP table:

UNDROP TABLE testdrop;


-- 16.2.8  Query the TESTDROP table. It will succeed:

SELECT * FROM testdrop;


-- 16.3.0  Recover a Table to a Time Before a Change Was Made

-- 16.3.1  Rerun the table history and review the values in the dropped_on
--         column; notice how the values reflect that TESTDROP is no longer
--         dropped:

SHOW TABLES HISTORY;


-- 16.3.2  Insert the following values into the TESTDROP table:

INSERT INTO testdrop VALUES (1000), (2000), (3000), (4000);


-- 16.3.3  Query the data in the TESTDROP table to confirm that the four rows
--         have been inserted:

SELECT * FROM testdrop;


-- 16.3.4  Delete values from the table:

DELETE FROM testdrop WHERE c1 IN (2000, 3000);


-- 16.3.5  Review the data in the TESTDROP table to confirm that only the values
--         1000 and 4000 remain:

SELECT * FROM testdrop;


-- 16.3.6  Navigate to the History tab and locate the query where you deleted
--         the 2000 and 3000 records. Copy this query’s ID.

-- 16.3.7  Query the TESTDROP table at a time before the records were deleted:

SELECT *
FROM testdrop BEFORE (STATEMENT => '<query ID>');


-- 16.3.8  Create a new table that holds the value of TESTDROP before the query
--         that deleted the rows was executed:

CREATE TABLE testdrop_restored
CLONE testdrop BEFORE (STATEMENT  => '<query ID>');


-- 16.3.9  Review the data in the restored table to confirm that the values 2000
--         and 3000 have been restored and you have four (4) records:

SELECT * FROM testdrop_restored;


-- 16.3.10 Execute a JOIN that shows rows that are in TESTDROP_RESTORED, but not
--         in TESTDROP:

SELECT * FROM testdrop_restored
   LEFT JOIN testdrop ON testdrop.c1 = testdrop_restored.c1;


-- 16.3.11 Drop the TESTDROP Table:

DROP TABLE testdrop;


-- 16.3.12 Query the Table. Notice the error message about the table not
--         existing:

SELECT * FROM testdrop;


-- 16.4.0  Object-Naming Constraints

-- 16.4.1  Create the base table to be used in this exercise:

CREATE TABLE loaddata1 (c1 NUMBER);


-- 16.4.2  Insert the following values into the LoadData1 table:

INSERT INTO LoadData1 VALUES (1111), (2222), (3333), (4444);


-- 16.4.3  Query the data in the LoadData1 table to confirm that the four (4)
--         rows have been inserted:

SELECT * FROM loaddata1;


-- 16.4.4  Drop the LoadData1 Table and confirm you receive an error that the
--         object does not exist when you try to query it:

DROP TABLE loaddata1;
SELECT * FROM loaddata1;


-- 16.4.5  Create a new iteration of the LoadData1 table with the same structure
--         as the previous iteration, and load values:

CREATE TABLE loaddata1 (c1 NUMBER);
INSERT INTO loaddata1
VALUES (777), (888), (999);


-- 16.4.6  Drop the LoadData1 table again and create a third iteration of the
--         LoadData1 table with the same structure, but do not insert any
--         values.

DROP TABLE loaddata1;
CREATE TABLE loaddata1 (c1 NUMBER);


-- 16.4.7  Undrop the LoadData1 table. What happens?

UNDROP TABLE loaddata1;

--         You cannot run the UNDROP command if a table exists with the same
--         name as the dropped table.

-- 16.4.8  Rerun the table history and note that there are now multiple entries
--         with the same name, but with different dropped_on values.
--         You were unable to successfully undrop the table in the step above,
--         because there is currently an active independent iteration of it:

SHOW TABLES HISTORY;


-- 16.4.9  Rename the current LoadData1 table iteration to LoadData3 and then
--         run the undrop command for LoadData1:

ALTER TABLE loaddata1 RENAME TO loaddata3;
UNDROP TABLE loaddata1;


-- 16.4.10 Select the data from LoadData1 and note that iteration 2 has been
--         restored:

SELECT * FROM loaddata1;


-- 16.4.11 Re-run the table history to verify that the second iteration of the
--         table is now active:

SHOW TABLES HISTORY;


-- 16.4.12 Rename the current LoadData1 table iteration to LoadData2, and undrop
--         loaddata1:

ALTER TABLE loaddata1 RENAME TO loaddata2;
UNDROP TABLE loaddata1;


-- 16.4.13 Select the data from LoadData. You will see that the first iteration
--         has been restored:

SELECT * FROM loaddata1;


-- 16.4.14 Re-run the table history to verify that all iterations of the table
--         are now active:

SHOW TABLES HISTORY;


-- 16.4.15 Query each of the LoadData tables and verify the different
--         iterations; all dropped and restored via Time Travel:

SELECT * FROM loaddata1;
SELECT * FROM loaddata2;
SELECT * FROM loaddata3;


-- 16.4.16 Rerun the table history to verify that all iterations of the table
--         are now active:

SHOW TABLES HISTORY;


-- 16.4.17 Suspend and resize the warehouse

ALTER WAREHOUSE COBRA_WH SET WAREHOUSE_SIZE=XSmall;
ALTER WAREHOUSE COBRA_WH SUSPEND;

