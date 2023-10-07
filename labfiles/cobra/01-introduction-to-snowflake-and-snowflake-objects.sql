
-- 1.0.0   Introduction to Snowflake and Snowflake Objects
--         The purpose of this lab is to familiarize you with Snowflake’s
--         Snowsight user interface. Specifically, you will learn how to create
--         and use Snowflake objects that you will need to use to run queries
--         and conduct data analysis in your day-to-day work.
--         If you’re a data engineer, you’ll learn skills important to your
--         role. If you’re not a data engineer, the process of creating the
--         objects will both help you learn how to navigate the Snowsight
--         interface and become familiar with warehouses, databases, roles and
--         schemas, all of which together form the context for any SQL
--         statements you are likely to execute. NOTE: Context refers to the
--         resources and objects that must be specified in order for SQL
--         statements to execute.
--         - How to navigate Snowsight to find the tools you’ll need
--         - How to create and manage folders and worksheets
--         - How to set the context via the Snowsight UI or with SQL code
--         - How to create warehouses, databases, schemas and tables
--         - How to run a simple query
--         You are a data engineer working for Snowbear Air, which is an airline
--         that flies to fun destinations all over the world. You’ve been tasked
--         to design and implement data sets that will be used by business
--         analysts that create flight profitability reports for executive
--         management. You have been asked to create a few Snowflake objects in
--         a development environment to test out your SQL statements. You will
--         need to create:
--         - A database
--         - A schema
--         - A warehouse
--         - A table you will then populate with the regions and countries that
--         Snowbear Air serves
--         HOW TO COMPLETE THIS LAB
--         In order to complete the first part of this lab, you will type the
--         SQL commands directly into a worksheet that you create. It is not
--         recommended that you cut and paste from the workbook pdf as that
--         sometimes results in errors.
--         To complete the second half of this lab, you will take the first .SQL
--         file of the set of .SQL files we provided to you and use it to create
--         a new worksheet. At that point you can simply run the code we
--         provide. We’ll provide instructions along the way.
--         Let’s get started!

-- 1.1.0   Launching Snowsight

-- 1.1.1   Access the URL provided to you for this course.

-- 1.1.2   You will be taken to a login page. Enter the username and password
--         provided to you for this course.

-- 1.1.3   You will be prompted to change the password. Follow the prompts to
--         change the password and click Submit.

-- 1.1.4   Log in with your new password. This will take you to the Classic
--         WebUI. Next, click the button on the top right of the screen to
--         access Snowsight.
--         Your screen should look similar to the screen below:
--         Home
--         Now let’s get familiar with the left-hand navigation bar and its
--         contents.

-- 1.1.5   Click on Dashboards in the left-hand navigation bar.
--         You should see the blank screen below. If you had access to any
--         dashboards, they would appear in the Dashboards pane that takes up
--         the majority of the screen.
--         Dashboards

-- 1.1.6   Click on Data in the left-hand navigation bar.
--         You should see the screen below. An Object Selection Pane and an
--         Object Detail Pane should now be visible.
--         Object Panes
--         Now let’s navigate to a table.

-- 1.1.7   Click SNOWBEARAIR_DB in the Object Selection Pane.

-- 1.1.8   Click schema PROMO_CATALOG_SALES.

-- 1.1.9   Click Tables to expand the table tree.

-- 1.1.10  Click any table to view details about the table.
--         Navigating to a Table
--         By navigating the tree in the Object Selection pane, you can view
--         details about many Snowflake Objects. Try to click through a few more
--         to get familiar with the tree.

-- 1.1.11  Now click on Private Sharing in the left-hand navigation bar.
--         You should now see a few data sets that are available for you to
--         consume.
--         Data Sharing

-- 1.1.12  Now click on Marketplace in the left-hand navigation bar.
--         You should now see a few data sets that are available for you to
--         consume.
--         Marketplace
--         Scroll through this section and take a look at the offerings. You may
--         see sections titled Featured Providers, Most Recent, Financial,
--         Business, Marketing, Local and Demographics. What you see may differ
--         as the Data Marketplace is dynamic and new types of data sets are
--         being added every day.
--         As you can imagine, both the Shared Data tab and the Marketplace tab
--         are likely to be useful to many Snowflake users in their day-to-day
--         work.

-- 1.1.13  Now click on Activity in the left-hand navigation bar.
--         The Query History sub-option under Activity should be selected by
--         default. Your query history will be empty, but after running queries
--         your screen will eventually look similar to the one shown below:
--         Activity
--         There will be a list of SQL statements with various columns
--         describing query history. You can click the Columns button above the
--         list to select which columns to display.

-- 1.1.14  Now click on Admin–>Warehouses in the left-hand navigation bar.
--         You may see a list of virtual warehouses and their statuses. However,
--         as this is a training environment, there may not be any virtual
--         warehouses yet. Just know that this is where you can go to see what
--         virtual warehouses exist.
--         Remember, unlike on-premises data warehouses you may be used to, in
--         Snowflake storage and compute are separated. A Snowflake virtual
--         warehouse is a cluster of servers used to run and execute queries,
--         and it provides compute power, memory, and some local SSD storage for
--         caching operations. Other than that, no data is stored in the
--         warehouse. Instead, data is stored in Snowflake’s cloud storage
--         layer. Storage and compute are dynamically combined at runtime to
--         execute your queries.
--         Warehouses

-- 1.2.0   Creating Snowflake Objects
--         Now let’s get started on our Snowflake objects. We will need a
--         database, a schema, a warehouse and a table. Let’s make sure you
--         create the objects in the role you will be using throughout the
--         course, which is TRAINING_ROLE. This will ensure that your role will
--         own the objects, which will enable you to do whatever you need to in
--         each lab.

-- 1.2.1   If your role is not already TRAINING_ROLE, click the down arrow next
--         to your role. There should now be a pop up menu that says Switch
--         Role. Select the arrow next to your role and select TRAINING_ROLE.
--         Changing the role

-- 1.2.2   Now let’s create a database. Click Data in the left-hand navigation
--         bar, then Databases.
--         ### Click the New Database button (It’s a big blue button with +
--         Database) in the Object Details pane. The New Database dialog box
--         will appear.
--         Regarding the login convention
--         Throughout the workbooks you will see object names prefixed with the
--         term login enclosed in square brackets. You will NOT use this prefix
--         in your object names. Instead, it is a place holder for the animal
--         name provided to you by the instructor. So, if your animal name is
--         elephant and you are asked to create a database, you will replace the
--         prefix with your animal name. Thus, your database will be
--         elephant_db.

-- 1.2.3   Name your database COBRA_db and click the Create button.
--         The details of your new database should be shown in the Object
--         Details pane.

-- 1.2.4   Select your new database in the Object Selection pane.

-- 1.2.5   Click the Schemas tab in the Object Detail pane to view the schemas
--         INFORMATION_SCHEMA and PUBLIC.

-- 1.2.6   Next click the new Schema button to create your new schema:

-- 1.2.7   In the New Schema dialog box, name your schema COBRA_schema and
--         click the Create button.
--         Your schema should now be listed along with schemas
--         INFORMATION_SCHEMA and PUBLIC.
--         We haven’t created our table yet, but we’ll come back to create that
--         after we’ve created our warehouse.

-- 1.2.8   To create your warehouse, click Admin -> Warehouses in the navigation
--         bar.

-- 1.2.9   Now click the + Warehouse button to create a new Warehouse.

-- 1.2.10  In the New Warehouse dialog box, name your warehouse COBRA_WH.

-- 1.2.11  Choose X-Small for the size.

-- 1.2.12  Expand the Advanced Warehouse Options to confirm Auto Resume and Auto
--         Suspend are selected.

-- 1.2.13  Click the Create Warehouse button.
--         Your warehouse should now be listed and started.

-- 1.2.14  Create a folder.
--         We will first create a folder. Then we will create a worksheet in
--         that folder and run the appropriate SQL statements within the
--         worksheet.

-- 1.2.15  Click on Worksheets in the navigation bar.

-- 1.2.16  Click the ellipsis (…) next to the New Worksheet button in the upper
--         right hand corner of the screen.

-- 1.2.17  Click New Folder.

-- 1.2.18  In the New Folder Dialog box, type WORKING WITH OBJECTS and then
--         click the Create Folder Button.
--         The folder should now be created and its contents (empty of course)
--         shown in the right hand pane. Notice that at the top-left of this
--         pane is a link titled Worksheets. This is a bread crumb trail that
--         you can use to go up a level, but you don’t need to click it now.
--         Note that at the right of the folder name is a down arrow. If you
--         click it you will see an editable version of the folder name. But,
--         you don’t need to rename the folder.

-- 1.3.0   Creating Objects Exclusively with SQL Statements
--         Now let’s practice creating objects strictly with SQL statements.
--         You’ll see how quickly and efficiently you can accomplish object
--         creation with SQL code.
--         The first object we’ll create is a worksheet. A worksheet is a
--         container in which you can draft, revise, execute and save SQL
--         statements, and folders are used to organize those worksheets.
--         In the next few steps we’ll show you how to create a new worksheet
--         from the SQL file for this lab. The idea is for you to open the file,
--         scroll down to this part of the lab and run the SQL statements in
--         that file to complete the lab.

-- 1.3.1   Click Worksheets in the left-hand navigation bar.

-- 1.3.2   Click the down arrow next to the title of the folder (WORKING WITH
--         OBJECTS).

-- 1.3.3   Select Create Worksheet from SQL File from the drop-down menu.

-- 1.3.4   Use the file dialog box to navigate to the file for this lab (should
--         have the same name as the title of this lab) and open the file.

-- 1.3.5   Once the file is open, put the worksheet in the folder you created
--         for this class as shown below:
--         Moving a worksheet to a folder

-- 1.3.6   Now scroll down to this place in the lab and use the contents of the
--         file that follow to continue the lab.

-- 1.3.7   Set context defaults for this course
--         By setting these defaults, you will ensure that these will be part of
--         your context by default each time you open a worksheet in subsequent
--         labs.


ALTER USER COBRA    
SET default_warehouse=COBRA_wh
    default_namespace=COBRA_db.public
    default_role=training_role; 



-- 1.3.8   Set the context for the remainder of this lab
--         The context defines the default database/schema location in which our
--         SQL statements run, and the WH and role to use in support of this.
--         So, let’s set the context so we can run our SQL statements.
--         Run the following statements in the SQL portion of this worksheet.


USE ROLE TRAINING_ROLE;
USE WAREHOUSE COBRA_WH;
USE DATABASE COBRA_DB;
USE SCHEMA COBRA_SCHEMA;



-- 1.3.9   Drop all the objects previously created
--         Now we’re going to drop everything we created with the Snowsight UI:


DROP TABLE region_and_nation;
DROP SCHEMA COBRA_SCHEMA;
DROP DATABASE COBRA_DB;
DROP WAREHOUSE COBRA_WH;



-- 1.3.10  Create the warehouse by executing the following statement:


CREATE WAREHOUSE COBRA_WH
  WITH WAREHOUSE_SIZE = 'XSMALL'
       AUTO_SUSPEND = 180
       AUTO_RESUME = TRUE
       INITIALLY_SUSPENDED = TRUE;


--         Since we set INITIALLY_SUSPENDED = TRUE, the warehouse isn’t actually
--         running. Let’s confirm its status and then start the warehouse.

-- 1.3.11  Run the following statements to confirm the warehouse status and to
--         start it


-- Use this to confirm the warehouse's status
SHOW WAREHOUSES like 'COBRA_WH';

-- RESUME will start the warehouse, SUSPEND will stop the warehouse
ALTER WAREHOUSE COBRA_WH RESUME;

-- Now add this warehouse to the current context
USE WAREHOUSE COBRA_WH;



-- 1.3.12  Run the following statements to create the required tables.
--         Now let’s create one of the first tables we need for our business
--         analysts. It is a table that contains the regions and nations served
--         by Snowbear Air and it will be used in many reports across the
--         company’s business functions.
--         In order to create this table, we need to run SQL statements in a
--         worksheet.


-- These statements create the database and schema
CREATE DATABASE COBRA_DB;
CREATE SCHEMA COBRA_SCHEMA;

-- These statements determine which database and warehouse will be used
USE DATABASE COBRA_DB;
USE SCHEMA COBRA_SCHEMA;

-- These statements create and populate the table
CREATE OR REPLACE TABLE region_and_nation (
      id INTEGER
    , region TEXT
    , nation TEXT
);


-- 1.3.13  Now insert the data you need into the table.

INSERT INTO region_and_nation
SELECT 
      N_NATIONKEY
    , R_NAME
    , N_NAME
FROM
    TRAINING_DB.TPCH_SF1.NATION N 
    INNER JOIN TRAINING_DB.TPCH_SF1.REGION R ON N.N_REGIONKEY = R.R_REGIONKEY
ORDER BY
    R_NAME, N_NAME;
    
-- Use this statement to confirm the table was populated    
SELECT
    *
FROM
    region_and_nation
ORDER BY 
    REGION, NATION;


--         You should now see the results of your query in the query pane.

-- 1.4.0   Key Takeaways
--         - You can create database objects both via the Snowsight UI and by
--         executing SQL code in a worksheet.
--         - Data Sharing options such Data Marketplace can be accessed via
--         Snowsight by users with the appropriate privileges.
--         - You can browse database objects and view their details by using the
--         navigation bar, the Object Selection and Object Details panes.
--         - The context of a worksheet session consists of a role, schema,
--         database and warehouse.
--         - The context of a worksheet can be set via the Snowsight UI or via
--         SQL statements.
--         - You can create folders in which to save and organize worksheets.
