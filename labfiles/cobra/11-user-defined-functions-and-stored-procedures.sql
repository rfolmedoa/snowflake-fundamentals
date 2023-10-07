
-- 11.0.0  User-Defined Functions and Stored Procedures
--         The purpose of this lab is to familiarize you with user-defined
--         functions and stored procedures in Snowflake.
--         - How to create a JavaScript user-defined function
--         - How to create a SQL user-defined function
--         - How to create a JavaScript stored procedure
--         HOW TO COMPLETE THIS LAB
--         In order to complete this lab, you can type the SQL commands below
--         directly into a worksheet. It is not recommended that you cut and
--         paste from the workbook pdf as that sometimes results in errors.
--         You can also use the SQL code file for this lab that was provided at
--         the start of the class. To open an .SQL file in Snowsight, make sure
--         the Worksheet section is selected on the left-hand navigation bar.
--         Click on the ellipsis between the Search and +Worksheet buttons. In
--         the dropdown menu, select Create Worksheet from SQL File.

-- 11.1.0  Create a JavaScript User-Defined Function

-- 11.1.1  Open a new worksheet and name it UDFs and set the context:

USE ROLE TRAINING_ROLE;
CREATE WAREHOUSE IF NOT EXISTS COBRA_WH;
USE WAREHOUSE COBRA_WH;
CREATE DATABASE IF NOT EXISTS COBRA_DB;
USE COBRA_DB.PUBLIC;


-- 11.1.2  Run the following to create a UDF named Convert2Meters:
--         As you can see, the UDF below is in JavaScript. The LANGUAGE clause
--         below explicitly states that it is JavaScript, so Snowflake knows
--         what to do with the script between the $$ marks.

CREATE OR REPLACE FUNCTION Convert2Meters(lengthInput double, InputScale string )
    RETURNS double
    LANGUAGE javascript
    AS
    $$
    /*
    *  convert English measurements to meters 
    */
    var scale_UC =  INPUTSCALE.toUpperCase();
    switch(scale_UC) {
    case 'INCH':
        return(LENGTHINPUT * 0.0254)
        break;
    case 'FEET':
        return(LENGTHINPUT * 0.3048)
        break;
    case 'YARD':
        return(LENGTHINPUT * 0.9144)
        break;

    default:
        return null;
        break; 
    }
  $$;


-- 11.1.3  Call the UDF just created as part of a SELECT statement and return
--         the value in meters:

SELECT Convert2Meters(10, 'yard');


-- 11.2.0  Create a SQL User-defined Function

-- 11.2.1  Create a function that returns the count of orders based on the
--         customer number. It will be a scalar function because it will return
--         a single value.
--         Note that there is only a single SQL statement between the $$ marks.
--         In a SQL UDF you can have only one SQL statement.

CREATE OR REPLACE FUNCTION order_cnt(custkey number(38,0))
  RETURNS number(38,0)
  AS 
  $$
    SELECT COUNT(1) FROM "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1"."ORDERS"WHERE o_custkey = custkey
  $$;


-- 11.2.2  Now use the UDF in a query

SELECT C_name, C_address, order_cnt(C_custkey)
FROM "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1"."CUSTOMER" LIMIT 10;


-- 11.3.0  Creating Stored Procedures

-- 11.3.1  Create a JavaScript stored procedure named ChangeWHSize().
--         Remember that JavaScript is case-sensitive, whereas SQL is not. The
--         JavaScript appears between the $$ delimiters, so make sure case in
--         the JavaScript portion is preserved.
--         The procedure demonstrates executing SQL statements in a JavaScript
--         stored procedure.
--         Also, note that you can have procedural logic, including try - catch
--         statements, in a JavaScript stored procedure.

/* ***
*   ChangeWHSize(wh_name STRING, wh_size STRING)
*
* Description: Change a WH size to a new size. The size is limited to larger or below.

*/
create or replace procedure ChangeWHSize(wh_name STRING, wh_size STRING )
    returns string
    language javascript
    strict
    execute as owner
    as
    $$
    /*
    *  Change the named warehouse to a new size if the new size is LARGE OR smaller 
    */
    var wh_size_UC = WH_SIZE.toUpperCase();
    switch(wh_size_UC) {
    case 'XSMALL':
    case 'SMALL':
    case 'MEDIUM':
    case 'LARGE':
        break;
    case 'XLARGE':
    case 'X-LARGE':
    case 'XXLARGE':
    case 'X2LARGE':
    case '2X-LARGE':
    case 'XXXLARGE':
    case 'X3LARGE':
    case '3X-LARGE':
    case 'X4LARGE':
    case '4X-LARGE':
        return "Size: " + WH_SIZE + " is too large";
        break; 
    default:
        return "Size: " + WH_SIZE + " is not valid";
        break; 
    }
        
    var sql_command = 
     "ALTER WAREHOUSE IF EXISTS " + WH_NAME + " SET WAREHOUSE_SIZE = "+ WH_SIZE;
    try {
        snowflake.execute (
            {sqlText: sql_command}
            );
        return "Succeeded.";   // Return a success/error indicator.
        }
    catch (err)  {
        return "Failed: " + err;   // Return a success/error indicator.
        }
    $$
    ;



-- 11.3.2  Call the stored procedure with a valid warehouse size:

CALL changewhsize ('COBRA_wh', 'small');


-- 11.3.3  Call the stored procedure with an invalid warehouse size:

CALL changewhsize ('COBRA_wh', 'XLARGE');


-- 11.3.4  Suspend and resize the warehouse

ALTER WAREHOUSE COBRA_WH SET WAREHOUSE_SIZE=XSmall;
ALTER WAREHOUSE COBRA_WH SUSPEND;


-- 11.4.0  Key Takeaways
--         - In the LANGUAGE clause of a UDF you can explicitly state that the
--         language is JavaScript. Snowflake will then know exactly what to do
--         with the script between the $$ marks.
--         - In a SQL UDF you can have only one SQL statement.
--         - You can embed SQL statements in a JavaScript stored procedure.
--         - You can have procedural logic, including try - catch statements, in
--         a JavaScript stored procedure.
