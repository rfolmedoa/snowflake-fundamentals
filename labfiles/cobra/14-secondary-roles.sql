
-- 14.0.0  Secondary Roles
--         The purpose of this lab is to familiarize you with secondary roles
--         and how you can use them to access both a primary role and a
--         secondary role already granted to the user within a single session.
--         - How to use Secondary Roles to aggregate permissions from more than
--         one role
--         You are going to use USE SECONDARY ROLES to aggregate permissions
--         from two different roles, SYSADMIN and TRAINING_ROLE.
--         First, you will use SYSADMIN to create a database and table and to
--         insert a row into the table. You will then switch to TRAINING_ROLE
--         and try to access the table.
--         Next, you will enable secondary roles and try accessing the table
--         again with TRAINING_ROLE.
--         You will then disable secondary roles and switch back to SYSADMIN in
--         order to grant TRAINING_ROLE access to the database, schema, and
--         table. You will then switch back to TRAINING_ROLE and try the access
--         again.
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

-- 14.1.0  Determine Privileges (GRANTs)
--         In this section of the lab you’ll use SHOW GRANTS to determine what
--         roles a USER has, and what privileges a ROLE has received. This is an
--         important step in determining what a USER is or isn’t allowed to do.

-- 14.1.1  Navigate to [Worksheets] and create a new worksheet named Secondary
--         Roles.
--         NOTE: This worksheet must not be in a folder or the switching of
--         roles that you will need to do will not work.

-- 14.1.2  If you haven’t created the class warehouse, do it now

CREATE WAREHOUSE IF NOT EXISTS COBRA_WH;


-- 14.2.0  Granting Permissions (GRANT ROLE and GRANT USAGE)
--         In this section, you’ll learn how to use GRANT ROLE to give
--         additional privileges to other ROLEs, and how to use GRANT USAGE to
--         permit a ROLE to perform actions on or with a database object.

-- 14.2.1  Change to the role SYSADMIN to create the new database and table

USE ROLE SYSADMIN;


-- 14.2.2  Create a database called COBRA_ROLETEST_DB:

CREATE DATABASE COBRA_ROLETEST_DB;
USE COBRA_ROLETEST_DB.PUBLIC;
CREATE TABLE ROLE_TBL (id INT);

-- Insert a row of data into the table.
INSERT INTO ROLE_TBL VALUES (1), (10), (30);

-- Check the table to make sure it got the data
SELECT * FROM ROLE_TBL;


-- 14.2.3  Switch to the TRAINING_ROLE and try to access the database, schema,
--         and table created above

USE ROLE TRAINING_ROLE;
SELECT * FROM COBRA_ROLETEST_DB.PUBLIC.ROLE_TBL;

--         We’re not able to select any data because TRAINING_ROLE has not been
--         granted access to select from the table ROLE_TBL.

-- 14.2.4  Enable SECONDARY ROLE ALL and try again

USE SECONDARY ROLE ALL;
SELECT * FROM COBRA_ROLETEST_DB.PUBLIC.ROLE_TBL;

--         With SECONDARY ROLE ALL set, the current user can use any permission
--         from any role the user has been granted except CREATE.

-- 14.2.5  Alter the table while SECONDARY ROLE ALL is set

ALTER TABLE COBRA_ROLETEST_DB.PUBLIC.ROLE_TBL ADD COLUMN name STRING(20);
SELECT * FROM COBRA_ROLETEST_DB.PUBLIC.ROLE_TBL;

--         This should work since the roles granted to your user include the
--         SYSADMIN role, the owner of the table.

-- 14.2.6  Try creating a new table in the COBRA_ROLETEST_DB

CREATE TABLE COBRA_ROLETEST_DB.PUBLIC.NOROLE_TBL (name STRING(20));

--         You cannot create a table because the current role TRAINING_ROLE does
--         not have CREATE TABLE privileges on the database. As mentioned
--         before, USE SECONDARY ROLES does not include CREATE privileges given
--         to other roles.

-- 14.2.7  Disable SECONDARY ROLES

USE SECONDARY ROLE NONE;


-- 14.2.8  Switch back to the SYSADMIN role and give TRAINING_ROLE permission to
--         select from the table
--         Here we’re going to GRANT SELECT to the ROLETEST_TBL but we’re NOT
--         going to GRANT USAGE on the database nor on its schemas.

USE ROLE SYSADMIN;
GRANT SELECT ON COBRA_ROLETEST_DB.PUBLIC.ROLE_TBL TO ROLE TRAINING_ROLE;


-- 14.2.9  Select some data using TRAINING_ROLE

USE ROLE TRAINING_ROLE;
SELECT * FROM COBRA_ROLETEST_DB.PUBLIC.ROLE_TBL;

--         We’re not able to select any data. That’s because the role we’re
--         using does not have GRANT USAGE on the database or the schema PUBLIC.
--         Let’s GRANT USAGE on both of those objects and see what happens.

-- 14.2.10 Grant role TRAINING_ROLE usage on all schemas in COBRA_ROLETEST_DB:

USE ROLE SYSADMIN;
GRANT USAGE ON DATABASE COBRA_ROLETEST_DB TO ROLE TRAINING_ROLE;
GRANT USAGE ON ALL SCHEMAs IN DATABASE COBRA_ROLETEST_DB TO ROLE TRAINING_ROLE;


-- 14.2.11 Now try again:

USE ROLE TRAINING_ROLE;
SELECT * FROM COBRA_ROLETEST_DB.PUBLIC.ROLE_TBL;

--         This time it worked! This is because TRAINING_ROLE has all the needed
--         permissions, without having to resort to any secondary roles.

-- 14.2.12 Drop the database COBRA_ROLETEST_DB:

USE ROLE SYSADMIN;
DROP DATABASE COBRA_ROLETEST_DB;


-- 14.3.0  Key Takeaways
--         - Secondary roles can be used to aggregate permissions in a single
--         session.
--         - You can only create objects if the primary role has permissions to
--         do that.
