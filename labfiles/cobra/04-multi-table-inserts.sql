
-- 4.0.0   Multi-Table Inserts
--         In this lab you will learn how to execute multi-table inserts, how to
--         use SWAP, and how execute MERGE statements.
--         - How to use sequences to create unique values in a primary key
--         column
--         - How to use unconditional multi-table insert statements
--         - How to use ALTER TABLE  SWAP WITH to swap table content and
--         metadata
--         - How to use MERGE statements to add new rows to a table
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

-- 4.1.0   Working with Sequences
--         In this section you will learn how to create and use a sequence. We
--         will use a sequence in the next section to replace a UUID value with
--         an integer as the unique identifier for each row in a table. Then we
--         will use the same sequence to express a primary key-foreign key
--         relationship between two tables.
--         Read the section below to get familiar with sequences in Snowflake.
--         SEQUENCE
--         A SEQUENCE is a named object that belongs to a schema in Snowflake.
--         It consists of a set of sequential, unique numbers that increase in
--         value or decrease in value based on how the sequence is configured.
--         Sequences can be used to populate columns in a Snowflake table with
--         unique values.
--         SEQUENCE PARAMETERS
--         NOTE
--         Sequence values are generally contiguous but sometimes there can be a
--         gap. Regardless, they should either increase in value if the
--         INCREMENT value is positive, and decrease if the INCREMENT value is
--         negative.

-- 4.1.1   If you haven’t created the class database or warehouse, do it now

CREATE WAREHOUSE IF NOT EXISTS COBRA_WH;
CREATE DATABASE IF NOT EXISTS COBRA_DB;


-- 4.1.2   Set the context for the lab

USE ROLE TRAINING_ROLE;
USE WAREHOUSE COBRA_WH;
USE SCHEMA COBRA_DB.PUBLIC;


-- 4.1.3   Create a sequence called item_seq
--         Here we’re going to create a sequence called item_seq. We will then
--         use it as a primary key in a table. Note that the start value is 1
--         and that the increment value is 1. This means we can expect the
--         sequence to start with 1 and continue with 2, 3, 4, 5, etc.

CREATE OR REPLACE SEQUENCE item_seq START = 1 INCREMENT = 1;


-- 4.1.4   Now evaluate the nextval expression of the sequence we just created
--         once to see the first value.

-- Bump the seq and show the next value.
SELECT Item_seq.nextval;

--         As you can see, the value is 1. The expression .nextval returns a new
--         value each time it is evaluated. If you want to apply it to a table
--         you will need to use the nextval expression for the first time right
--         after creating the sequence. If not it will pick up the next number
--         in the sequence instead of the very first. Let’s test this idea and
--         observe the results.

-- 4.1.5   Create a table, insert some values, and select all values from the
--         table.

-- Create a table with the sequence.
CREATE OR REPLACE TABLE item_table ( Item_id INTEGER default Item_seq.nextval, description VARCHAR(20));

-- Insert some rows.
INSERT INTO item_table (description) VALUES ('Wheels'), ('Tires'), ('hubcaps');

-- Select all values
SELECT * FROM item_table;

--         As you can see, the first row has an item_id of 2 rather than 1. This
--         is because when we created the table, we had already previously
--         iterated to the first sequence value 1. So when we evaluated the
--         nextval expression a second time, the next value was fetched, which
--         was 2.
--         Let’s try this again and recreate the sequence and the table.

-- 4.1.6   Recreate the sequence and the table

-- Reset the sequence. Recreating the sequence is the only way to reset a sequence. 
CREATE OR REPLACE SEQUENCE Item_seq START = 1 INCREMENT = 1;

-- Create a table with the sequence.
CREATE OR REPLACE TABLE item_table ( Item_id INTEGER default Item_seq.nextval, description VARCHAR(20));

-- Insert some rows.
INSERT INTO item_table (description) VALUES ('Wheels'), ('Tires'), ('hubcaps');

-- Select all rows the from the table
SELECT * FROM item_table;

--         As you can see, the sequence applied to the table now starts off with
--         1.

-- 4.1.7   DROP table and sequence.

DROP SEQUENCE item_seq;
DROP TABLE item_table;


-- 4.1.8   Try the different sequences below and observe the results
--         The purpose of the exercise below is to get an idea of how the START
--         and INCREMENT values change the resulting values in a sequence.


CREATE OR REPLACE SEQUENCE seq_1 START = 1 INCREMENT = 1;
CREATE OR REPLACE SEQUENCE seq_2 START = 2 INCREMENT = 2;
CREATE OR REPLACE SEQUENCE seq_3 START = 3 INCREMENT = 3;

--run each statement below 3 or 4 times
SELECT seq_1.nextval;
SELECT seq_2.nextval;
SELECT seq_3.nextval;



-- 4.2.0   Working with Unconditional Multi-Table Inserts
--         In this section, we will take a table called member and divide its
--         data between a customer table, an address table, and a phone table.
--         This will allow a single customer to have multiple addresses and
--         multiple phone numbers.
--         Since we are splitting the original table into three disparate
--         tables, MEMBER_ID is going to be used for the primary key-foreign key
--         relationship between the three tables, an AUTOINCREMENT will not
--         work. We will solve this by using a sequence to insert a new numeric
--         value into each table.
--         In order to do this, we will use a multi-table insert to copy the
--         member data into the three different tables. We will also replace the
--         UUID-based primary key with a sequence.

-- 4.2.1   Create a sequence
--         Before we execute the multi-table insert, we are going to create a
--         sequence to create a unique ID outside of the table and use it for
--         the MEMBER_ID Column. The default for a sequence is START = 1 and
--         INCREMENT = 1. Use this as the default for the MEMBERS table.

CREATE OR REPLACE SEQUENCE member_seq START = 1 INCREMENT = 1;


-- 4.2.2   Create the member, member_address and member_phone tables

CREATE OR REPLACE TABLE member (
    member_id INTEGER DEFAULT member_seq.nextval,
    points_balance NUMBER,
    started_date DATE,
    ended_date DATE,
    registered_date DATE,
    firstname VARCHAR,
    lastname VARCHAR,
    gender VARCHAR,
    age NUMBER,
    email VARCHAR
);

CREATE OR REPLACE TABLE member_address (
    member_id INTEGER,
    street VARCHAR,
    city VARCHAR,
    state VARCHAR,
    zip VARCHAR
);

CREATE OR REPLACE TABLE member_phone (
    member_id INTEGER,
    phone VARCHAR
);


-- 4.2.3   Populate the tables
--         Next you’ll execute multi-table insert statement that will copy the
--         data from an existing table into the member, member_address, and
--         member_phone tables.
--         UNCONDITIONAL MULTI-TABLE INSERT SYNTAX
--         A multi-table insert statement can insert rows into multiple tables
--         from the same statement. Note the syntax below:
--         Now execute the statement below to populate your tables. Note how the
--         syntax below reflects what you see in the box above:

INSERT ALL
    INTO member(member_id,
            points_balance,
            started_date,
            ended_date,
            registered_date,
            firstname,
            lastname,
            gender,
            age,
            email)
    VALUES (member_id,
            points_balance,
            started_date,
            ended_date,
            registered_date,
            firstname,
            lastname,
            gender,
            age,
            email)
    INTO member_address (member_id,
            street,
            city,
            state,
             zip)
    VALUES (member_id,
            street,
            city,
            state,
            zip)
    INTO member_phone(member_id,
            phone)
    VALUES (member_id,
            phone)
    SELECT member_seq.NEXTVAL AS member_id,
           points_balance,
           started_date,
           ended_date,
           registered_date,
           firstname,
           lastname,
           gender,
           age,
           email,
           street,
           city,
           state,
           zip,
           phone
     FROM "SNOWBEARAIR_DB"."MODELED"."MEMBERS";


-- 4.2.4   Confirm there is data in the tables

SELECT * FROM member ORDER BY member_id;

SELECT * FROM member_address;

SELECT * FROM member_phone;


-- 4.2.5   Join the tables and observe the results
--         Now let’s run a few queries to see how we can join the tables we
--         created to answer questions about the members and their contact
--         information.

-- Execute a join between the member and the member_address table.
SELECT 
          m.member_id
        , firstname
        , lastname
        , street
        , city
        , state
        , zip 
FROM 
    member m 
    LEFT JOIN member_address ma on m.member_id = ma.member_id;

-- Run a join between the member, member_address and phone tables.
SELECT 
          m.member_id
        , firstname
        , lastname
        , street
        , city
        , state
        , zip 
        , phone
FROM 
    member m 
    LEFT JOIN member_address ma on m.member_id = ma.member_id
    LEFT JOIN member_phone mp on m.member_id = mp.member_id;


-- 4.2.6   Add another row to the MEMBER table
--         Since the MEMBER table is using the Sequence as the default, we can
--         insert another row and it will get the next unique value.


INSERT 
    INTO member(points_balance,
            started_date,
            registered_date,
            firstname,
            lastname,
            gender,
            age,
            email)
    VALUES (102000,
            '2014-9-12',
            '2014-8-1',
            'Fred',
            'Wiffle',
            'M',
            '34',
            'Fwiffle@AOL.com');



-- 4.2.7   Check the sequence number of the new row
--         Notice the value might not be what you would expect. In other words
--         it may be unique but it may not be the next value in the sequence
--         which would be 1001.


SELECT * FROM member WHERE member_id > 1000;



-- 4.3.0   Working with Conditional Multi-Table Inserts
--         In this section we’re going to expand on the work we did earlier.
--         Specifically, we will use a conditional multi-table insert to break
--         the member table into a gold_member and a club_member table. Gold
--         members have more than 5,000,000 points in their points balance and
--         Club members have less than 5,000,000. We will use the points_balance
--         column to determine who is a gold member.

-- 4.3.1   Create the tables


-- The first table will be the gold_member table. 
CREATE OR REPLACE TABLE gold_member(
    member_id INTEGER DEFAULT member_seq.nextval,
    points_balance NUMBER,
    started_date DATE,
    ended_date DATE,
    registered_date DATE,
    firstname VARCHAR,
    lastname VARCHAR,
    gender VARCHAR,
    age NUMBER,
    email VARCHAR
);
-- The second table will be the club_member table.

CREATE OR REPLACE TABLE club_member (
    member_id INTEGER DEFAULT member_seq.nextval,
    points_balance NUMBER,
    started_date DATE,
    ended_date DATE,
    registered_date DATE,
    firstname VARCHAR,
    lastname VARCHAR,
    gender VARCHAR,
    age NUMBER,
    email VARCHAR
);



-- 4.3.2   Execute the inserts


INSERT ALL
    WHEN points_balance >= 5000000 THEN    
        INTO gold_member(member_id,
            points_balance,
            started_date,
            ended_date,
            registered_date,
            firstname,
            lastname,
            gender,
            age,
            email)
    VALUES (member_id,
            points_balance,
            started_date,
            ended_date,
            registered_date,
            firstname,
            lastname,
            gender,
            age,
            email)
    ELSE        -- points_balance is less than 500,000 so this member is a Club member
            INTO club_member (member_id,
            points_balance,
            started_date,
            ended_date,
            registered_date,
            firstname,
            lastname,
            gender,
            age,
            email)
    VALUES (member_id,
            points_balance,
            started_date,
            ended_date,
            registered_date,
            firstname,
            lastname,
            gender,
            age,
            email)
    SELECT member_id,
            points_balance,
            started_date,
            ended_date,
            registered_date,
            firstname,
            lastname,
            gender,
            age,
            email
 from member;



-- 4.3.3   Check that the inserts were correct
--         Run the statements below and check that the POINTS_BALANCE field in
--         gold_member is greater than or equal to 5,000,000, and that it is
--         less than 5,000,000 for club_member.


SELECT * FROM gold_member
   LIMIT 10;

SELECT * FROM club_member 
   LIMIT 10;



-- 4.4.0   Using ALTER TABLE  SWAP WITH to swap table content and metadata
--         ALTER TABLE  SWAP WITH swaps all content and metadata between two
--         specified tables, including any integrity constraints defined for the
--         tables. The two tables are essentially renamed in a single
--         transaction.
--         You’ll practice using SWAP WITH in this section. You’re going to
--         truncate the gold_member and club_member tables from the previous
--         exercise, insert the data for the gold_member table into the
--         club_member table and vice versa, then you’ll swap the tables to
--         correct the problem.

-- 4.4.1   Truncate the tables and replace the data


TRUNCATE TABLE gold_member;
TRUNCATE TABLE club_member;

INSERT ALL
    WHEN points_balance < 5000000 THEN  --inserts the club_member data into the gold_member table  
        INTO gold_member(member_id,
            points_balance,
            started_date,
            ended_date,
            registered_date,
            firstname,
            lastname,
            gender,
            age,
            email)
    VALUES (member_id,
            points_balance,
            started_date,
            ended_date,
            registered_date,
            firstname,
            lastname,
            gender,
            age,
            email)
    ELSE        -- inserts the gold_member data into the club_member table
            INTO club_member (member_id,
            points_balance,
            started_date,
            ended_date,
            registered_date,
            firstname,
            lastname,
            gender,
            age,
            email)
    VALUES (member_id,
            points_balance,
            started_date,
            ended_date,
            registered_date,
            firstname,
            lastname,
            gender,
            age,
            email)
    SELECT member_id,
            points_balance,
            started_date,
            ended_date,
            registered_date,
            firstname,
            lastname,
            gender,
            age,
            email
 from member;



-- 4.4.2   Verify the data
--         Execute the statements below to verify the values in the
--         points_balance column:


SELECT * FROM gold_member
   LIMIT 10;

SELECT * FROM club_member 
   LIMIT 10;


--         Notice that the two tables have the wrong values for points_balance.
--         The gold_member table should show values over 5,000,000, and the
--         club_member table should show lower values. Run a check to see how
--         many rows are correct in each table. These two queries shouldn’t
--         return any rows since the multi-table insert was not correct.


SELECT * FROM gold_member WHERE points_balance >= 5000000;

SELECT * FROM club_member WHERE points_balance < 5000000;


--         It is clear that the two tables are reversed: members with more than
--         5,000,000 points are in the club_member table, and members with fewer
--         points are in the gold_member table. One solution for this would be
--         to drop both tables and run the multi-table insert again. The easier
--         solution is to use the ALTER TABLE  SWAP WITH, which swaps the names
--         and all meta data information on the two tables. Let’s try that now.

-- 4.4.3   Execute the table swap below:


ALTER TABLE gold_member SWAP WITH club_member;



-- 4.4.4   Execute the statements below to see if the swap operation fixed the
--         issue.


SELECT * FROM gold_member WHERE points_balance >= 5000000;

SELECT * FROM club_member WHERE points_balance <= 5000000;


--         As you can see, the problem is now fixed.

-- 4.5.0   Using MERGE to udpate rows in a table
--         In this section you’re going to use MERGE to update data in two
--         tables. In this scenario, SnowBear Air receives two files from their
--         Members website showing changes that have been made by the member.
--         Since the Member table was split between the CLUB and GOLD members,
--         we’ve receive two files from the web group. The first has changes for
--         the club_member table and the second has changes for the gold_member
--         table.
--         MERGE
--         MERGE can be used to insert, update, or delete values in a table
--         based on values in a second table or a subquery. This can be useful
--         if the second table is a change log that contains new rows (to be
--         inserted), modified rows (to be updated), and/or marked rows (to be
--         deleted) in the target table.
--         The command supports semantics for handling the following cases: -
--         Values that match (for updates and deletes). - Values that do not
--         match (for inserts).
--         MERGE SYNTAX
--         MERGE INTO  USING  ON ;
--         Example:
--         Note that the WHEN MATCHED THEN clause triggers the updating of one
--         field with another. This allows updates to be merged into existing
--         data

-- 4.5.1   Create temporary tables for the new data
--         In this step you’ll create the tmp_gold_member_change and
--         tmp_club_member_change table that will hold the changes for both
--         member tables.


create or replace TEMP TABLE tmp_gold_member_change (
    member_id INTEGER,
    points_balance NUMBER,
    started_date DATE,
    ended_date DATE,
    registered_date DATE,
    firstname VARCHAR,
    lastname VARCHAR,
    gender VARCHAR,
    age NUMBER,
    email VARCHAR
);

create or replace TEMP TABLE tmp_club_member_change (
    member_id INTEGER,
    points_balance NUMBER,
    started_date DATE,
    ended_date DATE,
    registered_date DATE,
    firstname VARCHAR,
    lastname VARCHAR,
    gender VARCHAR,
    age NUMBER,
    email VARCHAR
);

INSERT INTO tmp_gold_member_change (member_id, points_balance, started_date, ended_date, registered_date, firstname, lastname, gender, age, email)
    values
        (NULL,5000000,current_date(),NULL,current_date(),'Jessie','James',
                'M',64,'jjames@outlaw.com'),
        (NULL,5000000,current_date(),NULL,current_date(),'Kyle','Benton',
                'M',39,'kbenton@companyx.com'),
        (NULL,5000000,current_date(),NULL,current_date(),'Charles','Xavier',
                'M',76,'ProfessorX@Xmen.com'),
        (6,7630775,'2012-02-28','2014-04-14','2015-12-28','Anna-diana','Gookey',
                'F',29,'agookey5@hhs.gov'),
        (7,5128459,'2017-02-01',NULL,'2019-07-08','Damara','Kilfeder',
                'F',85,'dkilfeder6@scribd.com'),
        (34,9287918,'2018-12-13',NULL,'2018-03-24','Igor','Danell',
                'M',64,'idanellx@facebook.com'),
        (67,7684309,'2014-05-24',NULL,'2018-06-25','Ky','Bree',
                'M',39,'kbree1u@wikia.com'),
        (107,5221084,'2018-05-22',current_date(),'2016-03-07','Persis','Keri',
                'F',76,'pkeri2y@soundcloud.com'),
        (172,6720892,'2020-03-28',NULL,'2014-03-05','Jessalyn','Smith',
                'F',27,'jgilberthorpe4r@bbc.co.uk'),
        (177,9175745,'2012-12-22',NULL,'2012-08-02','Giacomo','Careswell',
                'M',63,'gcareswell4w@comsenz.com'),
        (236,8372164,'2016-12-22',current_date(),'2017-05-02','Guendolen',
                'Girdlestone','F',38,'ggirdlestone6j@nationalgeographic.com'),
        (426,6051750,'2018-05-06',NULL,'2020-06-28','Marietta','Busfield',
                'M',71,'mbusfieldbt@wordview.com'),
        (431,9323224,'2013-01-08',NULL,'2015-05-19','Malcolm','Eastes',
                'M',39,'meastesby@lulu.com'),
        (437,6917699,'2015-01-02',NULL,'2012-09-18','Fremont','Rizzardo',
                'M',64,'frizzardoc4@biglobe.ne.jp'),
        (453,6547799,'2012-08-27',NULL,'2011-01-01','Roselia','McMillen',
                'F',51,'rtaptonck@cdc.gov'),
        (531,6361513,'2010-11-16',NULL,'2019-03-26','Sally','O Duilleain',
                'F',76,'hoduilleaineq@printfriendly.com');

INSERT INTO tmp_club_member_change (member_id, points_balance, started_date, ended_date, registered_date, firstname, lastname, gender, age, email)
    values
      (NULL,0,current_date(),NULL,'2014-06-02','Ted','Bundy',
                'M',45,'tbundy@meetup.com'),      
      (NULL,0,current_date(),NULL,'2015-04-15','Jimmy','Hoffa',
                'M',55,'jhoffa@narod.ru'),
      (NULL,0,current_date(),NULL,'2013-01-15','Mary', 'Manners',
                'F',37,'mmanners@ibm.com'),
      (NULL,0,current_date(),NULL,'2017-05-25','Nancy', 'Dew',
                'F',39,'NDew3@wsj.com'),
      (5,806553,'2017-12-15',NULL,'2016-06-16','Jessey','Cotherill',
                'M',37,'jcotherill4@indiegogo.com'),
      (8,1914198,'2012-10-08','2020-08-12','2013-11-14','Robinetta','Slayford',
                'F',33,'rslayford7@prnewswire.com'),
      (9,3527720,'2019-05-30','2020-09-22','2015-01-07','Leonidas','Weatherby',
                'M',35,'lweatherby8@gnu.org'),
      (10,678532,'2016-07-13','2020-12-1','2013-10-28','Wald','Simmank',
                'M',28,'wsimmank9@youku.com'),
      (49,4182743,'2019-07-21',NULL,'2017-09-23','Tomi','Mayweather',
                'F',71,'tgloster1c@nymag.com'),
      (51,2164969,'2012-07-29',NULL,'2011-11-11','Haleigh','Blackway',
                'M',42,'hblackway1e@hilton.com'),
      (86,63441,'2012-06-21',NULL,'2018-03-05','Dniren','West',
                'F',67,'dnorth2d@dyndns.org'),
      (102,1273020,'2019-07-03',NULL,'2016-04-30','Diandra','Peacham',
                'F',54,'dpeacham2t@.com'),
      (143,198814,'2020-01-02',NULL,'2016-09-28','Alayne','Jevons',
                'F',49,'ajevons3y@nytimes.edu'),
      (214,3713155,'2020-06-24',current_date(),'2011-10-21','Licha','MacCurlye',
                'F',62,'lmaccurlye5x@microsoft.it'),
      (221,3642431,'2020-08-21',NULL,'2015-05-19','Codi','Battram',
                'M',32,'cbattram@ft.com');
                


-- 4.5.2   Apply the MERGE statement
--         Now you’ll use a MERGE statement to apply the updates to the
--         gold_member table. After the MERGE statement is run, you will run
--         some queries to verify the changes.


MERGE INTO gold_member gm USING tmp_gold_member_change gc ON gm.member_id= gc.member_id
    WHEN matched
        THEN UPDATE SET points_balance = gc.points_balance,
                        started_date = gc.started_date,
                        ended_date = gc.ended_date,
                        registered_date = gc.registered_date,
                        firstname = gc.firstname,
                        lastname = gc.lastname,
                        gender = gc.gender,
                        age = gc.age
     WHEN NOT MATCHED THEN INSERT ( points_balance, started_date, ended_date, registered_date, firstname, lastname, gender, age, email)
                VALUES (gc.points_balance,
                        gc.started_date,
                        gc.ended_date,
                        gc.registered_date,
                        gc.firstname,
                        gc.lastname,
                        gc.gender,
                        gc.age,
                        gc.email);


-- 4.5.3   Save the query_id from the merge statement. This will be used to show
--         the what has changed in the gold_members table with the merge
--         statement.

SET merge_query_id = last_query_id();
SHOW VARIABLES;


-- 4.5.4   Verify the effect of the MERGE statement
--         The following queries use time travel to view the state of the tables
--         before and after the MERGE statement.

-- Use Time Travel to show the rows that have been inserted and updated. 

-- First show the 13 items that were updated in the gold_member table.

SELECT  m.member_id,  
        m.points_balance, mc.points_balance,
        m.started_date, mc.started_date,
        m.ended_date, mc.ended_date,
        m.registered_date, mc.registered_date,
        m.firstname, mc.firstname,
        m.lastname, mc.lastname,
        m.gender, mc.gender,
        m.age, mc.age,
        m.email, mc.email 
    FROM gold_member m INNER JOIN gold_member BEFORE (STATEMENT => $merge_query_id) mc on m.member_id = mc.member_id
    WHERE mc.member_id IN (SELECT member_id FROM tmp_gold_member_change);



-- 4.5.5   Run the statement below to show the 3 items there were inserted into
--         the gold_member table.


SELECT  m.member_id,  
        m.points_balance,
        m.started_date,
        m.ended_date,
        m.registered_date,
        m.firstname,
        m.lastname,
        m.gender,
        m.age,
        m.email
    FROM gold_member m 
    WHERE m.member_id NOT IN (SELECT member_id FROM gold_member BEFORE (STATEMENT => $merge_query_id));



-- 4.5.6   Now execute the same process with the club_member table


--Execute the merge statement for the club_member table
MERGE INTO club_member cm USING tmp_club_member_change cc ON cm.member_id= cc.member_id
    WHEN matched
        THEN UPDATE SET points_balance = cc.points_balance,
                        started_date = cc.started_date,
                        ended_date = cc.ended_date,
                        registered_date = cc.registered_date,
                        firstname = cc.firstname,
                        lastname = cc.lastname,
                        gender = cc.gender,
                        age = cc.age
     WHEN NOT MATCHED THEN INSERT ( points_balance, started_date, ended_date, registered_date, firstname, lastname, gender, age, email)
                VALUES (cc.points_balance,
                        cc.started_date,
                        cc.ended_date,
                        cc.registered_date,
                        cc.firstname,
                        cc.lastname,
                        cc.gender,
                        cc.age,
                        cc.email);
                     
-- Save the query_id from the merge statement. This will be used to show the what has changed in the club_member table with the merge statement.

SET merge_query_id = last_query_id();
SHOW VARIABLES;

-- Show the items that were updated.
SELECT  m.member_id,  
        m.points_balance, mc.points_balance,
        m.started_date, mc.started_date,
        m.ended_date, mc.ended_date,
        m.registered_date, mc.registered_date,
        m.firstname, mc.firstname,
        m.lastname, mc.lastname,
        m.gender, mc.gender,
        m.age, mc.age,
        m.email, mc.email 
    FROM club_member m INNER JOIN club_member BEFORE (STATEMENT => $merge_query_id) mc ON m.member_id = mc.member_id
    WHERE mc.member_id IN (SELECT member_id FROM tmp_club_member_change);

-- Show the items that were inserted into the member table.
SELECT  m.member_id,  
        m.points_balance,
        m.started_date,
        m.ended_date,
        m.registered_date,
        m.firstname,
        m.lastname,
        m.gender,
        m.age,
        m.email
    FROM club_member m 
    WHERE m.member_id NOT IN (SELECT member_id FROM club_member BEFORE (STATEMENT => $merge_query_id));
    

--         As you can see, the update was successful.

-- 4.6.0   Key Takeaways
--         - A single multi-insert statement can be used to insert data from one
--         table into multiple tables.
--         - You can use ALTER TABLE  SWAP WITH to easily swap content and
--         metadata between two tables.
--         - You can use the MERGE statement to add, update or delete data in a
--         table.
--         - You can use the query id of a SQL statement and time travel to
--         compare what data looked like prior to and after an update.
