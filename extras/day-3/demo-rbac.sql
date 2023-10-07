--Best practice normally is to use SECURITYADMIN role to create, in class we use 
--TRAINING_ROLE which has been granted specific security privileges for class purposes
USE ROLE TRAINING_ROLE;

--create the parent/child role but don't yet build the hierarchy
CREATE ROLE darthvader_role;
CREATE ROLE lukeskywalker_role;

--grant your user the ability to use the roles
GRANT ROLE darthvader_role TO USER INSTRUCTOR1;
GRANT ROLE lukeskywalker_role TO USER INSTRUCTOR1;

--create and grant objects permission on the CHILD role
CREATE OR REPLACE WAREHOUSE INSTRUCTOR1_WH;
GRANT USAGE ON WAREHOUSE INSTRUCTOR1_WH TO ROLE lukeskywalker_role;
USE WAREHOUSE INSTRUCTOR1_WH;
GRANT USAGE ON DATABASE INSTRUCTOR1_DB TO ROLE lukeskywalker_role;
USE DATABASE INSTRUCTOR1_DB;
GRANT USAGE ON SCHEMA PUBLIC TO ROLE lukeskywalker_role;
USE SCHEMA PUBLIC;
GRANT CREATE TABLE ON SCHEMA INSTRUCTOR1_DB.public TO ROLE lukeskywalker_role;

--Use the child role to create a table
USE ROLE lukeskywalker_role;
USE DATABASE INSTRUCTOR1_DB;
CREATE TABLE genealogy ("NAME" STRING, "AGE" INTEGER, "MOTHER" STRING, "FATHER" STRING );

--This should fail until the next grants where we fix it
USE ROLE darthvader_role;
USE DATABASE INSTRUCTOR1_DB;
CREATE TABLE dark_genealogy ("NAME" STRING, "AGE" INTEGER, "MOTHER" STRING, "FATHER" STRING );

--so lets fix this,build the hierarchy
USE ROLE TRAINING_ROLE;
GRANT ROLE lukeskywalker_role TO ROLE darthvader_role;

--Try again, should work now
USE ROLE darthvader_role;
USE DATABASE INSTRUCTOR1_DB;
CREATE TABLE dark_genealogy ("NAME" STRING, "AGE" INTEGER, "MOTHER" STRING, "FATHER" STRING );

USE ROLE TRAINING_ROLE;
GRANT ROLE darthvader_role TO ROLE TRAINING_role;


