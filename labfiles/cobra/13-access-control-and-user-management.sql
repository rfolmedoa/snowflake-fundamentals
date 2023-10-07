
-- 13.0.0  Access Control and User Management
--         The purpose of this lab is to familiarize you with role-based access
--         control (RBAC) in Snowflake. Specifically, you’ll become familiar
--         with the Snowflake security model and learn how to create roles,
--         grant privileges, and how to build and implement basic security
--         models.
--         - How to show grants to users and roles
--         - How to grant usage on objects to roles
--         The purpose of this exercise is to give you a chance to see how you
--         can manage access to data in Snowflake by granting privileges to some
--         roles and not to others.
--         In this lab, SYSADMIN will represent the privileges of a user that
--         shouldn have access to a specific table in a specific database, while
--         the role TRAINING_ROLE will represent the privileges of a user that
--         shouldn’t.
--         This lab will walk you through the process of setting all this up so
--         you can test the roles and observe the results.
--         HOW TO COMPLETE THIS LAB
--         In order to complete this lab, you can type the SQL commands below
--         directly into a worksheet. It is not recommended that you cut and
--         paste from the workbook pdf as that sometimes results in errors.
--         You can also use the SQL code file for this lab that was provided at
--         the start of the class. To open an .SQL file in Snowsight, make sure
--         the Worksheet section is select on the left-hand navigation bar.
--         Click on the ellipsis between the Search and +Worksheet buttons. In
--         the dropdown menu, select Create Worksheet from SQL File.
--         Let’s get started!

-- 13.1.0  Determine Privileges (GRANTs)
--         In this section of the lab you’ll use SHOW GRANTS to determine what
--         roles a USER has, and what privileges a ROLE has received. This is an
--         important step in determining what a USER is or isn’t allowed to do.

-- 13.1.1  Navigate to [Worksheets] and create a new worksheet named Managing
--         Security.
--         NOTE: This worksheet must not be in a folder or the switching of
--         roles that you will need to do will not work.

-- 13.1.2  If you haven’t created the class database or warehouse, do it now

CREATE WAREHOUSE IF NOT EXISTS COBRA_WH;
CREATE DATABASE IF NOT EXISTS COBRA_DB;


-- 13.1.3  Run these commands one at a time to see what roles have been granted
--         to you as a user, and what privileges have been granted to specified
--         roles:

SHOW GRANTS TO USER COBRA;
SHOW GRANTS TO ROLE TRAINING_ROLE;
SHOW GRANTS TO ROLE SYSADMIN;

--         You should see that TRAINING_ROLE has some specific privileges
--         granted and is quite powerful. This has been done on purpose so you
--         can do the labs more easily. In a production environment it is
--         unlikely that you would ever see a role like this.

-- 13.2.0  Granting Permissions (GRANT ROLE and GRANT USAGE)
--         In this section, you’ll use GRANT ROLE to give additional privileges
--         to a ROLE, and how to use GRANT USAGE to permit a user to perform
--         actions on or with a database object.

-- 13.2.1  Change your role to SYSADMIN:

USE ROLE SYSADMIN;


-- 13.2.2  Create a warehouse named COBRA_SHARED_WH:
--         Now we’re going to create a warehouse that both roles will use. After
--         that you’ll grant permissions to both roles.

CREATE WAREHOUSE COBRA_SHARED_WH;


-- 13.2.3  Create a database called COBRA_CLASSIFIED_DB:

CREATE DATABASE COBRA_CLASSIFIED_DB;


-- 13.2.4  Use the role SYSADMIN, and create a table called SUPER_SECRET_TBL
--         inside the COBRA_CLASSIFIED_DB.PUBLIC schema:

USE SCHEMA COBRA_CLASSIFIED_DB.PUBLIC;
CREATE TABLE SUPER_SECRET_TBL (id INT);


-- 13.2.5  Insert some data into the table:

INSERT INTO SUPER_SECRET_TBL VALUES (1), (10), (30);


-- 13.2.6  GRANT SELECT privileges on SUPER_SECRET_TBL to the role
--         TRAINING_ROLE:
--         Here we’re going to GRANT SELECT to TRAINING_ROLE but we’re NOT going
--         to GRANT USAGE on the database nor on its schemas.
--         NOTE If we DON’T grant usage on the database AND on the schemas to a
--         role, that role won’t be able to do things like create tables or
--         select from tables EVEN IF that role has create or select privileges.
--         In other words, you must have the appropriate permissions on all
--         objects in the hierarchy from top to bottom in order to work at the
--         lowest level of the hierarchy.

GRANT SELECT ON SUPER_SECRET_TBL TO ROLE TRAINING_ROLE;


-- 13.2.7  Use the role TRAINING_ROLE to SELECT * from the table
--         SUPER_SECRET_TBL:
--         Now let’s try to select some data using TRAINING_ROLE. What do you
--         think is going to happen?

USE ROLE TRAINING_ROLE;
SELECT * FROM COBRA_CLASSIFIED_DB.PUBLIC.SUPER_SECRET_TBL;

--         We’re not able to select any data. That’s because the role we’re
--         using has not been granted USAGE on the database or the schema
--         PUBLIC. Let’s GRANT USAGE on both of those objects to TRAINING_ROLE
--         and see what happens.

-- 13.2.8  Grant role TRAINING_ROLE usage on all schemas in
--         COBRA_CLASSIFIED_DB:

USE ROLE SYSADMIN;
GRANT USAGE ON DATABASE COBRA_CLASSIFIED_DB TO ROLE TRAINING_ROLE;
GRANT USAGE ON ALL SCHEMAS IN DATABASE COBRA_CLASSIFIED_DB TO ROLE TRAINING_ROLE;

USE ROLE TRAINING_ROLE;
SELECT * FROM COBRA_CLASSIFIED_DB.PUBLIC.SUPER_SECRET_TBL;

--         This time it worked! This is because your role has the appropriate
--         permissions at all levels of the hierarchy.

-- 13.2.9  Drop the database COBRA_CLASSIFIED_DB:

USE ROLE SYSADMIN;
DROP DATABASE COBRA_CLASSIFIED_DB;


-- 13.3.0  Key Takeaways
--         - USAGE is granted to ROLEs, which in turn are granted to USERs.
--         - USAGE must be granted on all levels in a hierarchy (database and
--         schema) in order for a role to have the ability to select from a
--         table.
