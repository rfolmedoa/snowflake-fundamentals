
-- 12.0.0  Create User-Defined Functions and Stored Procedures
--         Expect this lab to take approximately 30 minutes.

-- 12.1.0  Create a JavaScript User-Defined Function

-- 12.1.1  Open a new worksheet and name it UDFs and set the context:

USE ROLE TRAINING_ROLE;
CREATE WAREHOUSE IF NOT EXISTS COBRA_WH;
USE WAREHOUSE COBRA_WH;
CREATE DATABASE IF NOT EXISTS COBRA_DB;
USE COBRA_DB.PUBLIC;


-- 12.1.2  Run the following to create a UDF named Convert2Meters:

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


-- 12.1.3  Call the UDF just created as part of a SELECT statement and return
--         the value in meters:

SELECT Convert2Meters(10, 'yard');


-- 12.2.0  Create a SQL User-defined Function

-- 12.2.1  Create a function that returns the count of orders based on the
--         customer number. It will be a scalar function because it will return
--         a single value. After creating the UDF, use it in a query:

CREATE OR REPLACE FUNCTION order_cnt(custkey number(38,0))
  RETURNS number(38,0)
  AS 
  $$
    SELECT COUNT(1) FROM "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1"."ORDERS"WHERE o_custkey = custkey
  $$;
  
SELECT C_name, C_address, order_cnt(C_custkey)
FROM "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1"."CUSTOMER" LIMIT 10;


-- 12.3.0  CREATE a Stored Procedure

-- 12.3.1  Create a Javascript stored procedure named ChangeWHSize().
--         Remember that Javascript is case-sensitive, whereas SQL is not. The
--         Javascript appears between the $$ delimiters, so make sure case in
--         the Javascript portion is preserved.
--         The procedure demonstrates executing SQL statements in a stored
--         procedure:

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



-- 12.3.2  Call the stored procedure with a valid warehouse size:

CALL changewhsize ('COBRA_wh', 'small');


-- 12.3.3  Call the stored procedure with an invalid warehouse size:

CALL changewhsize ('COBRA_wh', 'XLARGE');


-- 12.3.4  Suspend and resize the warehouse

ALTER WAREHOUSE COBRA_WH SET WAREHOUSE_SIZE=XSmall;
ALTER WAREHOUSE COBRA_WH SUSPEND;

