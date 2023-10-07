
-- 3.0.0   Querying Data with Time Travel
--         The purpose of this lab is to familiarize you with how Time Travel
--         can be used to analyze data. Specifically, you’ll take a data set and
--         compare two different points in time to satisfy a what-if question.
--         In order to do this, you’ll clone a table and use syntax designed to
--         query two distinct Time Travel data snapshots.
--         - How to clone a table
--         - How to write query clauses that support Time Travel actions
--         - How to fetch and utilize the ID of the last query you ran
--         Snowbear Air charges a different tax rate depending on the country in
--         which the customer lives. It just so happens that countries across
--         the world are thinking about setting a tax rate of around 5% for the
--         kind of products that Snowbear Air sells via its promotional catalog.
--         Although Snowbear Air doesn’t know what the new tax rate will be,
--         leadership has decided it would like to see some kind of what-if
--         analysis in order to determine how much more they will potentially be
--         collecting. The concern is that a higher tax rate could result in
--         consumers paying a higher cost based on current product prices. If
--         that price is too high, Snowbear Air may make the decision to lower
--         its prices in order to keep sales high.
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

-- 3.1.0   Conducting a What-If Scenario
--         The goal will be to determine what has been paid in taxes over the
--         past seven years and what the amount would have been if the tax rate
--         had been 5%.

-- 3.1.1   Using the skills you learned in the first lab, create a new folder
--         called Time Travel

-- 3.1.2   Using the skills you learned in the first lab, create a worksheet
--         inside the folder you just created and name it Time Travel

-- 3.1.3   Create a new schema
--         For the purposes of this lab, we’re going to create a new schema.
--         Let’s create the schema by running the following statements in your
--         new worksheet:

USE ROLE TRAINING_ROLE;
USE WAREHOUSE COBRA_WH;

CREATE DATABASE IF NOT EXISTS COBRA_DB;
CREATE SCHEMA IF NOT EXISTS COBRA_DB.COBRA_LAB;

USE SCHEMA COBRA_DB.COBRA_LAB;


-- 3.1.4   The Plan
--         We are going to clone the LINEITEM table into our schema, which will
--         make a copy of the table that still points to all the data in the
--         original table. Next, we are going to fetch a reference point in
--         time. Then, we will update the total price column in the clone.
--         Finally, using that point of reference, we will run a query to
--         compare the data at the time of cloning to the data after the update.

-- 3.1.5   Clone the LINEITEM table
--         The LINEITEM table shows the details of each order. Each line shows a
--         specific product in the order along with the discount and tax
--         percentages that were applied to that line. What we’re going to do is
--         update the values in the tax percentage column called L_TAX and then
--         compare how the change impacts the net cost to the customer for the
--         product represented by each line item.
--         Now let’s create a zero-copy clone of LINEITEM. This is essentially a
--         snapshot of the table which shares the underlying data of the
--         original table at the point of creation. However, once we make a
--         change to the clone as part of this lab, those changes will be unique
--         to our new table. Additionally, any changes to the original table of
--         course do not impact the clone.
--         For purposes of this lab, we are going to work with only 1000 records
--         so our queries execute quickly. Whether you’re working with 1,000
--         rows or 1,000,000 rows, the concept is the same.
--         The code below will create a 1000 row sample table and then clone
--         that sample table:

CREATE OR REPLACE TABLE LINEITEM_SAMPLE AS
SELECT * 
FROM SNOWBEARAIR_DB.PROMO_CATALOG_SALES.LINEITEM 
ORDER BY L_ORDERKEY, L_LINENUMBER LIMIT 1000;

CREATE OR REPLACE TABLE LINEITEM_CLONE CLONE LINEITEM_SAMPLE;


-- 3.1.6   Verify the clone
--         Run the code below to ensure the clone was created and is properly
--         populated:

SELECT * FROM LINEITEM_CLONE;  

--         You should now see the contents of the newly cloned table below the
--         query.

-- 3.1.7   Updating the LINEITEM table
--         The following UPDATE statement will update the tax rate column to
--         apply a 5% tax rate. Go ahead and run it now:

UPDATE 
        LINEITEM_CLONE
SET
        L_TAX = 0.05
FROM
        LINEITEM_CLONE L
        INNER JOIN SNOWBEARAIR_DB.PROMO_CATALOG_SALES.PART P ON L.L_PARTKEY = P.P_PARTKEY; 



-- 3.1.8   Fetch the last query id
--         NOW run the statement below to fetch the query id and verify the
--         contents of the UPDATE_ID variable:

SET UPDATE_ID = LAST_QUERY_ID();

SELECT $UPDATE_ID;

--         Note that what we just did was to set the value of a SQL variable
--         called UPDATE_ID to the unique id of the last query we ran by calling
--         the LAST_QUERY_ID() function.

-- 3.1.9   Checking the results
--         Now that we have our reference point, we’ll be able to access the
--         data that existed in the table prior to executing the UPDATE.
--         The query below fetches the original values and the new values in two
--         separate result sets and then joins them together.
--         Note that the sub-query that fetches the original values uses the
--         following BEFORE clause:
--         In essence it is fetching the state of the cloned table prior to our
--         update. The goal with this query is to check our results and
--         determine if the original values are indeed different from the new
--         ones.
--         Go ahead and run the query now:

 SELECT 
          ROUND((( L.L_QUANTITY * P.P_RETAILPRICE ) * (1-L.L_DISCOUNT)) * (1+L.L_TAX),2) AS TOTALCOST_NEW
        , ORG.TOTALCOST_ORIGINAL
        , L.L_QUANTITY
        , P.P_RETAILPRICE
        , L.L_DISCOUNT
        , L.L_TAX AS NEW_TAX
        , ORG.L_TAX AS ORG_TAX
        
 FROM 
      LINEITEM_CLONE L
      LEFT JOIN 
      (
         SELECT
                LC.L_ORDERKEY
              , LC.L_LINENUMBER
              , L_TAX
              , ROUND((( LC.L_QUANTITY * P.P_RETAILPRICE ) * (1-LC.L_DISCOUNT)) * (1+LC.L_TAX),2) AS TOTALCOST_ORIGINAL
        
         FROM
              LINEITEM_CLONE
         BEFORE
              (STATEMENT => $update_id) AS LC
         INNER JOIN SNOWBEARAIR_DB.PROMO_CATALOG_SALES.PART P ON LC.L_PARTKEY = P.P_PARTKEY
        
       ) ORG ON L.L_ORDERKEY = ORG.L_ORDERKEY AND L.L_LINENUMBER = ORG.L_LINENUMBER
        INNER JOIN SNOWBEARAIR_DB.PROMO_CATALOG_SALES.PART P ON L.L_PARTKEY = P.P_PARTKEY
 ORDER BY
        L.L_ORDERKEY, L.L_LINENUMBER;

--         We won’t explain the fields as the field names are probably self-
--         explanatory. The query also shows the quantity, retail price,
--         discount and tax percentages so you can see the input values that
--         went into the calculations.
--         As you reviewed the results, you probably noticed that in some
--         instances the tax rate was the same, in some it was lower and in some
--         it was higher. So, the impact of a tax change could be that customers
--         will pay more tax or less tax than before.
--         Naturally, this example is a bit more simplistic than what you might
--         find in a real scenario. Regardless, it does demonstrate the power of
--         Time Travel to compare two points in time.

-- 3.1.10  Cleaning Up
--         Run the statement below to suspend your warehouse:

ALTER WAREHOUSE COBRA_WH SUSPEND;


-- 3.2.0   Key Takeaways
--         - In order to leverage Time Travel data for data analysis purposes,
--         you need a reference point. This can be a TIMESTAMP, an OFFSET or a
--         STATEMENT.
--         - You will need to put an AT|BEFORE clause in your query in order to
--         pull the results of a particular data set as of a particular point in
--         time.
--         - Zero-copy cloning means that when you clone a table, at the point
--         in time the cloned table is created, it shares the same data as the
--         original table. Once you start making changes to either table’s data,
--         the new data resides only within the table in which the change was
--         made.
