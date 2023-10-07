
-- 14.0.0  Access Control and User Management
--         Expect this lab to take approximately 25 minutes.
--         Lab Purpose: Students will work with the Snowflake security model and
--         learn how to create roles, grant privileges, build, and implement
--         basic security models.

-- 14.1.0  Determine Privileges (GRANTs)

-- 14.1.1  Navigate to [Worksheets] and create a new worksheet named Managing
--         Security.

-- 14.2.0  14.1.2 If you haven’t created the class database or warehouse, do it
--         now

CREATE WAREHOUSE IF NOT EXISTS COBRA_WH;
CREATE DATABASE IF NOT EXISTS COBRA_DB;


-- 14.2.1  Run these commands to see what has been granted to you as a user, and
--         to your roles:

SHOW GRANTS TO USER COBRA;
SHOW GRANTS TO ROLE TRAINING_ROLE;
SHOW GRANTS TO ROLE SYSADMIN;
SHOW GRANTS TO ROLE SECURITYADMIN;

--         NOTE: The TRAINING_ROLE has some specific privileges granted - not
--         all roles in the system would be able to see these results.

-- 14.3.0  Work with Role Permissions

-- 14.3.1  Change your role to USERADMIN:

USE ROLE USERADMIN;


-- 14.3.2  Create two new custom roles, called COBRA_CLASSIFIED and
--         COBRA_GENERAL:

CREATE OR REPLACE ROLE COBRA_CLASSIFIED;
CREATE OR REPLACE ROLE COBRA_GENERAL;


-- 14.3.3  GRANT both roles to SYSADMIN, and to your user:

GRANT ROLE COBRA_CLASSIFIED, COBRA_GENERAL TO ROLE SYSADMIN;
GRANT ROLE COBRA_CLASSIFIED, COBRA_GENERAL TO USER COBRA;


-- 14.3.4  Change to the role SYSADMIN, so you can assign permissions to the
--         roles you created:

USE ROLE SYSADMIN;


-- 14.3.5  Create a warehouse named COBRA_SHARED_WH:

CREATE OR REPLACE WAREHOUSE COBRA_SHARED_WH;
USE WAREHOUSE COBRA_SHARED_WH;


-- 14.3.6  Grant both new roles privileges to use the shared warehouse:

GRANT USAGE ON WAREHOUSE COBRA_SHARED_WH
  TO ROLE COBRA_CLASSIFIED;
GRANT USAGE ON WAREHOUSE COBRA_SHARED_WH
  TO ROLE COBRA_GENERAL;


-- 14.3.7  Create a database called COBRA_CLASSIFIED_DB:

CREATE OR REPLACE DATABASE COBRA_CLASSIFIED_DB;


-- 14.3.8  Grant the role COBRA_CLASSIFIED all necessary privileges to create
--         tables on any schema in COBRA_CLASSIFIED_DB:

GRANT USAGE ON DATABASE COBRA_CLASSIFIED_DB
TO ROLE COBRA_CLASSIFIED;
GRANT USAGE ON ALL SCHEMAS IN DATABASE COBRA_CLASSIFIED_DB
TO ROLE COBRA_CLASSIFIED;
GRANT CREATE TABLE ON ALL SCHEMAS IN DATABASE COBRA_CLASSIFIED_DB
TO ROLE COBRA_CLASSIFIED;


-- 14.3.9  Use the role COBRA_CLASSIFIED, and create a table called
--         SUPER_SECRET_TBL inside the COBRA_CLASSIFIED_DB.PUBLIC schema:

USE ROLE COBRA_CLASSIFIED;
USE WAREHOUSE COBRA_SHARED_WH;
USE COBRA_CLASSIFIED_DB.PUBLIC;
CREATE OR REPLACE TABLE SUPER_SECRET_TBL (id INT);


-- 14.3.10 Insert some data into the table:

INSERT INTO SUPER_SECRET_TBL VALUES (1), (10), (30);


-- 14.3.11 Check if the login_CLASSIFIED role can access the table

SELECT * FROM COBRA_CLASSIFIED_DB.PUBLIC.SUPER_SECRET_TBL;


-- 14.3.12 Switch to the login_GENERAL role and try accessing the table

USE  ROLE COBRA_GENERAL;
SELECT * FROM COBRA_CLASSIFIED_DB.PUBLIC.SUPER_SECRET_TBL;


-- 14.3.13 Because we haven’t given any permissions to the database, schema, or
--         the table, this doesn’t work.

-- 14.3.14 Before we give login_GENERAL permissions, try using SECONDARY_ROLES
--         to access the table

USE SECONDARY ROLES ALL;
SELECT * FROM COBRA_CLASSIFIED_DB.PUBLIC.SUPER_SECRET_TBL;


-- 14.3.15 Since SECONDARY ROLES ALL allows the user to use any permissions on
--         any role they’ve been granted, This will work.

-- 14.3.16 Now try using the SECONDARY ROLES to create a new table in the
--         database.

USE SCHEMA COBRA_CLASSIFIED_DB.PUBLIC;
CREATE TABLE NOT_SO_SECRET_TBL (id INT);


-- 14.3.17 This will fail since SECONDARY ROLES doesn’t support CREATE

-- 14.3.18 SECONDARY ROLES will support ALTER TABLE.

ALTER TABLE SUPER_SECRET_TBL ADD COLUMN name STRING(20);


-- 14.3.19 To continue this lab, turn off SECONDARY ROLES

USE SECONDARY ROLES NONE;


-- 14.3.20 Switch back to the login_CLASSIFIED

USE ROLE COBRA_CLASSIFIED;


-- 14.3.21 Assign GRANT SELECT privileges on SUPER_SECRET_TBL to the role
--         COBRA_GENERAL:

GRANT SELECT ON SUPER_SECRET_TBL TO ROLE COBRA_GENERAL;


-- 14.3.22 Use the role COBRA_GENERAL to SELECT * from the table
--         SUPER_SECRET_TBL:

USE ROLE COBRA_GENERAL;
SELECT * FROM COBRA_CLASSIFIED_DB.PUBLIC.SUPER_SECRET_TBL;

--         What happens? Why?

-- 14.3.23 Grant role COBRA_GENERAL usage on all schemas in
--         COBRA_CLASSIFIED_DB:

USE ROLE SYSADMIN;
GRANT USAGE ON DATABASE COBRA_CLASSIFIED_DB TO ROLE COBRA_GENERAL;
GRANT USAGE ON ALL SCHEMAs IN DATABASE COBRA_CLASSIFIED_DB TO ROLE COBRA_GENERAL;


-- 14.3.24 Now try again:

USE ROLE COBRA_GENERAL;
SELECT * FROM COBRA_CLASSIFIED_DB.PUBLIC.SUPER_SECRET_TBL;


-- 14.3.25 Drop the database COBRA_CLASSIFIED_DB:

USE ROLE SYSADMIN;
DROP DATABASE COBRA_CLASSIFIED_DB;


-- 14.3.26 Drop the roles COBRA_CLASSIFIED and COBRA_GENERAL:

USE ROLE USERADMIN;
DROP ROLE COBRA_CLASSIFIED;
DROP ROLE COBRA_GENERAL;

--         HINT: What role do you need to use to do this?

-- 14.4.0  Create Parent and Child Roles

-- 14.4.1  Change your role to USERADMIN:

USE ROLE USERADMIN;


-- 14.4.2  Create a parent and child role, and GRANT the roles to the role
--         SYSADMIN. At this point, the roles are peers (neither one is below
--         the other in the hierarchy):

CREATE OR REPLACE ROLE COBRA_CHILD;
CREATE OR REPLACE ROLE COBRA_PARENT;
GRANT ROLE COBRA_CHILD, COBRA_PARENT TO ROLE SYSADMIN;


-- 14.4.3  Give your user name privileges to use the roles:

GRANT ROLE COBRA_CHILD, COBRA_PARENT TO USER COBRA;


-- 14.4.4  Change your role to SYSADMIN:

USE ROLE SYSADMIN;


-- 14.4.5  Grant the following object permissions to the child role:

GRANT USAGE ON WAREHOUSE COBRA_WH TO ROLE COBRA_CHILD;
GRANT USAGE ON DATABASE COBRA_DB TO ROLE COBRA_CHILD;
GRANT USAGE ON SCHEMA COBRA_DB.PUBLIC TO ROLE COBRA_CHILD;
GRANT CREATE TABLE ON SCHEMA COBRA_DB.PUBLIC TO ROLE COBRA_CHILD;


-- 14.4.6  Use the child role to create a table:

USE ROLE COBRA_CHILD;
USE WAREHOUSE COBRA_WH;
USE SCHEMA COBRA_DB.PUBLIC;
CREATE TABLE genealogy (name STRING, age INTEGER, mother STRING, father STRING);


-- 14.4.7  Verify that you can see the table:

SHOW TABLES LIKE '%genealogy%';


-- 14.4.8  Use the parent role and view the table:

USE ROLE COBRA_PARENT;
SHOW TABLES LIKE '%genealogy%';

--         You will not see the table, because the parent role has not been
--         granted access.

-- 14.4.9  Change back to the USERADMIN role and change the hierarchy so the
--         child role is beneath the parent role:

USE ROLE USERADMIN;
GRANT ROLE COBRA_CHILD to ROLE COBRA_PARENT;


-- 14.4.10 Use the parent role, and verify the parent can now see the table
--         created by the child:

USE ROLE COBRA_PARENT;
SHOW TABLES LIKE '%genealogy%';


-- 14.4.11 Clean up by dropping the roles, warehouse and table created in this
--         lab

USE ROLE SYSADMIN;
DROP WAREHOUSE COBRA_SHARED_WH;
DROP TABLE COBRA_DB.public.genealogy;


-- 14.4.12 Drop the roles COBRA_CHILD and COBRA_PARENT:

USE ROLE USERADMIN;
DROP ROLE COBRA_CHILD;
DROP ROLE COBRA_PARENT;


-- 14.4.13 Suspend and resize the warehouse

USE ROLE TRAINING_ROLE;
ALTER WAREHOUSE COBRA_WH SET WAREHOUSE_SIZE=XSmall;
ALTER WAREHOUSE COBRA_WH SUSPEND;

