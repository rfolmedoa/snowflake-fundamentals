
-- 7.0.0   Practicing Query Fundamentals
--         Many instructions in this lab give somewhat vague or build on your
--         own instructions. We have provided additional SQL statements at the
--         end of this exercise for you to review if you get stuck building the
--         SQL yourself.
--         Expect this lab to take approximately 60 minutes.

-- 7.1.0   SELECT Statements
--         The SELECT statement sets up a tabular view of data and/or
--         calculations.

-- 7.1.1   If you haven’t created the class database or warehouse, do it now

CREATE WAREHOUSE IF NOT EXISTS COBRA_WH;
CREATE DATABASE IF NOT EXISTS COBRA_DB;


-- 7.1.2   In this task you will run several SELECT statements, with and without
--         conditional logic, to see what they return in the query results.

-- 7.1.3   Navigate to [Worksheets] and create a new worksheet named Query Data
--         and set the context:

USE ROLE TRAINING_ROLE;
USE WAREHOUSE COBRA_WH;
USE DATABASE COBRA_DB;
USE SCHEMA PUBLIC;


-- 7.1.4   Perform basic calculations using SELECT, but with no table data:

SELECT (22+47+1184), 'My String', CURRENT_TIME();


-- 7.1.5   Use AS on the previous query to rename the first column to SUM:

SELECT (22+47+1184) AS sum, 'My String', CURRENT_TIME();


-- 7.1.6   Use AS to rename all the columns.

-- 7.1.7   Use some conditional logic using CASE and WHEN:

SELECT
  CASE
     WHEN RANDOM() > 0 THEN 'POSITIVE'
     WHEN RANDOM() < 0 THEN 'NEGATIVE'
     ELSE 'Zero'
   END,
   CASE
      WHEN RANDOM(2) > 0 THEN 'POSITIVE'
      WHEN RANDOM(2) < 0 THEN 'NEGATIVE'
      ELSE 'Zero'
   END;


-- 7.1.8   Create a table named test with a single column of type NUMBER(4,2).
--         Name the column num.

CREATE TABLE test (num NUMBER(4,2));


-- 7.1.9   Insert the values 2.00, 2.57, 4.50, and 1.22 into the table.

INSERT INTO test (num) VALUES (2);
INSERT INTO test (num) VALUES (2.57);
INSERT INTO test (num) VALUES (4.5);
INSERT INTO test (num) VALUES (1.22);


-- 7.1.10  Query the table to view the contents.

SELECT * FROM test;


-- 7.1.11  Query the table and CAST the num column as an INTEGER. Also, rename
--         the column to value.

SELECT num::integer as value FROM test;

--         What happens when you CAST a NUMBER to an INTEGER?

-- 7.1.12  Change your worksheet context to use SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.

USE DATABASE SNOWFLAKE_SAMPLE_DATA;
USE SCHEMA TPCH_SF1;


-- 7.1.13  Select the columns r_regionkey, r_name, and r_comment from the REGION
--         table.

SELECT
          r_regionkey
        , r_name
        , r_comment
FROM
        region;


-- 7.1.14  Select the number of distinct values in the r_name column.

SELECT COUNT(r_name) 
FROM (SELECT DISTINCT r_name FROM region);


-- 7.1.15  Display the distinct values in the r_name column.

SELECT DISTINCT r_name FROM region;


-- 7.2.0   WHERE and LIMIT

-- 7.2.1   Select 10 rows from the ORDERS table.

SELECT *
FROM ORDERS LIMIT 10;

--OR

SELECT TOP 10 *
FROM ORDERS; 


-- 7.2.2   Select all the DISTINCT values from o_orderstatus in the ORDERS
--         table.

SELECT DISTINCT o_orderstatus
FROM ORDERS;


-- 7.2.3   Select all rows from the ORDERS table that have an order status of F:

SELECT * FROM orders WHERE o_orderstatus = 'F';


-- 7.2.4   Count all the rows from the ORDERS table that have an order status of
--         P.

SELECT
    COUNT(*)
FROM 
    ORDERS
WHERE
    o_orderstatus = 'P';


-- 7.2.5   Count all the rows from the ORDERS table that have an order status of
--         either P or O.

SELECT
    COUNT(*)
FROM 
    ORDERS
WHERE
    o_orderstatus IN ('P','O');

--OR

SELECT
    COUNT(*)
FROM 
    ORDERS
WHERE
    o_orderstatus = 'P'
    OR
    o_orderstatus = 'O';


-- 7.2.6   Return all rows from the ORDERS table with an order date of July 21,
--         1992.

SELECT
    *
FROM 
    ORDERS
WHERE
    o_orderdate = '1992-07-21';


-- 7.2.7   Write a single query that returns all rows from the ORDERS table for
--         the customer who has an account balance of 3942.58. Do not use a
--         JOIN!
--         HINT: You will need to reference the CUSTOMER table in your WHERE
--         clause.

-- 7.2.8   Run the following command to turn off query caching:

ALTER SESSION SET USE_CACHED_RESULT=FALSE;


-- 7.2.9   Run the following command several times. Do you get the same result
--         each time?

SELECT * FROM lineitem LIMIT 3;


-- 7.2.10  Run the following command several times. Do you get the same result
--         each time?

SELECT * FROM nation LIMIT 3;


-- 7.2.11  Run the SELECT on the LINEITEM table (step 9) 12 times. For each
--         result, record the first three digits of the l_orderkey value.
--         Why do you think the two tables have different behaviors with LIMIT?
--         What is different about the two tables?

-- 7.3.0   GROUP BY, HAVING, and ORDER BY

-- 7.3.1   Show the sum of orders (based on total price) for each order status
--         in the ORDERS table:

SELECT o_orderstatus, SUM(o_totalprice) FROM orders
GROUP BY o_orderstatus;


-- 7.3.2   Show the sum of orders (based on total price) by date, for dates
--         before January 1, 1998. Sort the results by order date (most recent
--         first).

-- 7.3.3   Show the minimum, maximum, and average account balance by market
--         segment, from the CUSTOMER table.

-- 7.3.4   Using the SUPPLIER table, show the total account balance for each
--         nation (using s_nationkey) with a balance in excess of $2 million.

-- 7.3.5   Select all rows from the ORDERS table, ordering them first by
--         priority and then by total price (with the highest total price listed
--         at the top).

-- 7.3.6   Using the PART table, determine how many parts are packaged in each
--         of the available types of containers.

-- 7.3.7   Set your schema back to COBRA_DB.PUBLIC to prepare for the next
--         task:

USE SCHEMA COBRA_DB.PUBLIC;


-- 7.4.0   JOIN

-- 7.4.1   Create a table called characters using the following command:

CREATE TABLE characters(id INTEGER, name VARCHAR(6), num FLOAT);


-- 7.4.2   Insert the following values into the table. Notice the column types
--         and values:

INSERT INTO characters VALUES
   (1, 'Thanos', 10.012),
   (2, 'Bess', 3.00),
   (3, 'Tucker', 5),
   (4, 'Moana', 17.003),
   (5, 'Hobson', 123.42124),
   (6, 'Kitty', 14);


-- 7.4.3   Query characters to verify the contents.

-- 7.4.4   Create a table called movies and insert some rows, using the
--         following commands. Again, note the column types and values:

CREATE TABLE movies(id NUMBER(4,2), title VARCHAR(25), num INTEGER);

INSERT INTO movies VALUES
   (1, 'Endgame', 13),
   (2, 'Porgy and Bess', 3),
   (3, 'Tucker & Dale vs Evil', 7),
   (4, 'Moana', 5),
   (5, 'Arthur', 14),
   (6, 'Gunsmoke', 22);


-- 7.4.5   Query movies to verify the contents.

-- 7.4.6   JOIN movies to characters, on the ID columns.

-- 7.4.7   Return all columns:

SELECT * FROM characters
JOIN movies ON characters.id = movies.id;


-- 7.4.8   Run the same query, but only include the ID and NAME columns from
--         characters, and the TITLE column from movies.

-- 7.4.9   JOIN movies to characters, where characters.ID equals movies.NUM.

-- 7.4.10  JOIN movies to characters, where characters.NAME equals movies.TITLE.
--         There are many kinds of JOINs; explore a few using the same data. A
--         JOIN, also called an INNER JOIN, returns all the records where the
--         key exists in both tables. Theses are the JOINs you are tried so far.
--         A LEFT OUTER JOIN returns all of the rows in the left table, and any
--         rows in the right table that match on the specified key. When the
--         right table does not match on the key, NULL values are returned.

-- 7.4.11  Try a LEFT OUTER JOIN on the two tables to see the output:

SELECT * FROM characters LEFT OUTER JOIN movies ON characters.id = movies.num;

--         A RIGHT OUTER JOIN returns all the rows in the right table, and any
--         rows in the left table that match on the specified key. When the left
--         table does not match the right table on the key, NULL values are
--         returned.

-- 7.4.12  Try a RIGHT OUTER JOIN on the two tables, on the same keys, to see
--         the output.
--         HINT: Use the same syntax, just replace LEFT OUTER JOIN with RIGHT
--         OUTER JOIN.
--         A FULL JOIN returns all of the records from both tables. The values
--         will be NULL where the keys do not match.

-- 7.4.13  Try a FULL JOIN on the tables, on the same keys, to see the output.
--         How many rows did you get? Why?

-- 7.5.0   PIVOT

-- 7.5.1   Set your standard context in your worksheet.

-- 7.5.2   Create a table and insert some data with the following statements:

CREATE TABLE weekly_sales(name VARCHAR(10), day VARCHAR(3), amount NUMBER(8,2));

INSERT INTO weekly_sales VALUES
   ('Fred', 'MON',  913.24), ('Fred', 'WED', 1256.87), ('Rita', 'THU',   10.45),
   ('Mark', 'TUE',  893.45), ('Mark', 'TUE', 2240.00), ('Fred', 'MON',   43.99),
   ('Mark', 'MON',  257.30), ('Fred', 'FRI', 1000.27), ('Fred', 'WED',  924.34),
   ('Rita', 'WED',  355.60), ('Rita', 'MON',  129.00), ('Fred', 'WED', 3092.56),
   ('Fred', 'TUE',  449.00), ('Mark', 'MON',  289.12), ('Fred', 'FRI',  900.57),
   ('Rita', 'THU', 1200.00), ('Fred', 'THU', 1100.95), ('Fred', 'MON',  523.33),
   ('Fred', 'TUE',  972.33), ('Fred', 'MON', 4500.87), ('Fred', 'WED',   35.90),
   ('Rita', 'MON',   28.90), ('Mark', 'FRI', 1466.02), ('Fred', 'MON', 3022.45),
   ('Mark', 'TUE',  256.88), ('Fred', 'MON',  449.00), ('Rita', 'FRI',  294.56),
   ('Fred', 'MON',  882.56), ('Fred', 'WED', 1193.20), ('Rita', 'WED',   88.90),
   ('Mark', 'WED',   10.37), ('Fred', 'THU', 2345.00), ('Fred', 'TUE', 2638.76),
   ('Rita', 'TUE',  988.26), ('Fred', 'THU', 3400.23), ('Fred', 'MON',  882.45),
   ('Rita', 'THU', 734.527), ('Rita', 'MON', 6011.20), ('Fred', 'FRI',  389.12),
   ('Fred', 'THU',  893.45), ('Mark', 'WED', 2900.13), ('Mark', 'MON',  610.45),
   ('Fred', 'FRI',   45.69), ('Rita', 'FRI', 1092.35), ('Mark', 'MON',   12.56);


-- 7.5.3   Query the table to view the data.

-- 7.5.4   Run a query with PIVOT that will list each employee in a row, and the
--         total sales for each day of the week as columns:

SELECT * FROM weekly_sales
PIVOT (SUM(amount)FOR day in ('MON','TUE','WED','THU','FRI'));


-- 7.5.5   Run a query with PIVOT that will list the average sales instead of
--         total sales, and have the days of the week as rows and each name as a
--         column.

-- 7.6.0   Subqueries

-- 7.6.1   Change the SCHEMA in your context to SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.
--         The IN statement defines a set of values.

-- 7.6.2   Run the following query to see how it works:

SELECT o_custkey, SUM(o_totalprice) FROM orders
WHERE o_custkey IN (1, 7, 10)
GROUP BY o_custkey;

--         You do not have to provide a list of values for IN: you can specify a
--         subquery to return the values for the IN statement. Use IN and a
--         subquery to return all orders from customers who are in Saudi Arabia.
--         HINT: Look at the NATION table to find the nation key for Saudi
--         Arabia.

-- 7.6.3   Return all columns from the LINEITEM table for orders where the
--         status is P and the customer key is 4.

-- 7.6.4   Using a subquery, select all records from the LINEITEM table with an
--         extended price greater than the lowest-priced item from my_orders.
--         HINT: Remember where the my_orders table is?

-- 7.6.5   Suspend and resize the warehouse

ALTER WAREHOUSE COBRA_WH SET WAREHOUSE_SIZE=XSmall;
ALTER WAREHOUSE COBRA_WH SUSPEND;


-- 7.7.0   Solutions to the Exercises
--         The following entries are the solutions to the previous exercises.
--         Try your best to complete the exercises before referring to the
--         solutions below:
