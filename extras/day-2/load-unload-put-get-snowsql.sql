snowsql -a ODA31684 -u INSTRUCTOR1 -r TRAINING_ROLE -w INSTRUCTOR1_WH -d INSTRUCTOR1_DB -s PUBLIC

USE ROLE TRAINING_ROLE;
USE WAREHOUSE INSTRUCTOR1_WH;
USE DATABASE INSTRUCTOR1_DB;
USE SCHEMA PUBLIC;
 
CREATE OR REPLACE TABLE sales_fact
    (
    sales_date DATE,
    customer_id INTEGER,
    store_id INTEGER,
    basket_id BIGINT,
    product_id INTEGER,
    sales_quantity INTEGER,
    discount_amount FLOAT
    );

SHOW TABLES;

--PUT FILE IN TABLE STAGE    
put file:///Users/jajohnson/Downloads/load/sales_fact.tsv @INSTRUCTOR1_DB.public.%sales_fact;

list @%sales_fact;

--PUT A FILE IN USER STAGE
put file:///Users/jajohnson/Downloads/load/test_load.txt @~ auto_compress=false;

ls @~;

rm @~ pattern='.*txt.*';

ls @~;

CREATE OR REPLACE STAGE my_stage;

--PUT A FILE IN NAMED STAGE
put file:///Users/jajohnson/Downloads/load/test_load_csv.csv @my_stage;

ls @my_stage;

rm @my_stage pattern='.*csv.*';

ls @my_stage;

SHOW STAGES;

CREATE OR REPLACE FILE FORMAT MYTSVFORMAT
 TYPE = CSV
 COMPRESSION = GZIP
 FIELD_DELIMITER = '\t'
 ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;

COPY INTO sales_fact FROM @instructor1_db.public.%sales_fact FILES = ('sales_fact.tsv.gz') FILE_FORMAT = (FORMAT_NAME = MYTSVFORMAT);

SELECT * FROM sales_fact LIMIT 10;

CREATE OR REPLACE FILE FORMAT MYPARQUETFORMAT
    TYPE = PARQUET
    COMPRESSION = AUTO;
    
SHOW FILE FORMATS;

COPY INTO @my_stage FROM (SELECT * FROM SALES_FACT) FILE_FORMAT = (FORMAT_NAME = MYPARQUETFORMAT) OVERWRITE = TRUE;  

ls @my_stage;

get @my_stage file:///Users/jajohnson/Downloads/;

drop my_stage;