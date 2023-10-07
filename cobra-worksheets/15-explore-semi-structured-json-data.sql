
-- 15.0.0  Explore Semi-Structured JSON Data
--         In this lab you will practice using Snowflake’s SQL extensions to
--         query and work with semi-structured data. The lab provides exercises
--         for you to work directly with historical weather station semi-
--         structured data and see how to transform it into standard data
--         structures.
--         In order to do this lab, you can key SQL commands presented in this
--         lab directly into a worksheet. You can also use the code file for
--         this lab that was provided at the start of the class. To use the
--         file, simply drag and drop it into an open worksheet. It is not
--         recommended that you cut and paste from the workbook pdf as that
--         sometimes results in errors.

-- 15.1.0  Review the Weather Data

-- 15.1.1  Create a new worksheet and name it Explore Weather Data.

-- 15.1.2  Set your worksheet context as follows:

-- 15.1.3  Use the following commands within your worksheet:

USE ROLE TRAINING_ROLE;
CREATE WAREHOUSE IF NOT EXISTS COBRA_WH
WAREHOUSE_SIZE=XSmall
INITIALLY_SUSPENDED=True
AUTO_SUSPEND=300;
USE WAREHOUSE COBRA_WH;
USE SCHEMA TRAINING_DB.WEATHER;


-- 15.1.4  Use the DESCRIBE TABLE command to describe the isd_2019_daily table:

DESCRIBE TABLE isd_2019_total;

--         Notice that this table contains just two columns: V (variant) and T
--         (timestamp).

-- 15.1.5  Select all columns from the isd_2019_daily Table, limit the results
--         to 10 rows, and explore the data and its content:

SELECT * FROM isd_2019_total
LIMIT 10;


-- 15.1.6  In the Results set, click on the JSON data to pull up the Details
--         pane with the VARIANT data.
--         This will display the structure of a single record of the JSON data.

-- 15.1.7  Use FLATTEN to extract the top-level keys from the V column. Use
--         LIMIT 10:

SELECT v, key, value FROM isd_2019_total w,
LATERAL FLATTEN (input => w.v)
LIMIT 10;


-- 15.1.8  Run a query to extract the time, station, country, elevation, temp,
--         and other weather objects from the table:

SELECT v:data.observations[0].dt AS time,
       v:station.name AS station,
       v:station.country AS country,
       v:station.elev AS elevation,
       v:data.observations[0].air.temp AS temp_celsius,
       v:data.observations[0].air."dew-point" AS dew_point,
       v:data.observations[0].wind."speed-rate" AS wind_speed
FROM weather.isd_2019_total
LIMIT 10;


-- 15.1.9  Run the following to display the types of columns from the last run
--         query:

DESCRIBE RESULT LAST_QUERY_ID();

--         NOTE: The values returned are all VARIANT.

-- 15.1.10 Return to the previous instance as that data pertains more to what we
--         are trying to do. Run the previous query again:

SELECT v:data.observations[0].dt AS time,
       v:station.name AS station,
       v:station.country AS country,
       v:station.elev AS elevation,
       v:data.observations[0].air.temp AS temp_celsius,
       v:data.observations[0].air."dew-point" AS dew_point,
       v:data.observations[0].wind."speed-rate" AS wind_speed
FROM weather.isd_2019_total
LIMIT 10;


-- 15.1.11 Evaluate the results.
--         Do you notice anything unusual about the STATION column?
--         The values are enclosed in double quotes, which indicates that the
--         column is not a VARCHAR, but a VARIANT. In the query performed,
--         you’ve extracted a portion of the VARIANT but have not yet converted
--         it to a native SQL type.

-- 15.1.12 Remove the double quotes around the values by casting each value as a
--         data type other than VARIANT:

SELECT v:data:observations[0].dt::DATETIME AS time,
       v:station.name::VARCHAR AS station,
       v:station.country::VARCHAR AS country,
       v:station.elev::NUMBER(8,4) AS elevation,
       v:data.observations[0].air.temp::NUMBER(8,4) AS temp_celsius,
       v:data.observations[0].air."dew-point"::NUMBER(8,4) AS dew_point,
       v:data.observations[0].wind."speed-rate"::NUMBER AS wind_speed
FROM weather.isd_2019_total
LIMIT 10;


-- 15.1.13 Run the following to display the types of columns from the last run
--         query:

DESCRIBE RESULT LAST_QUERY_ID();

--         Note the values returned have been updated.

-- 15.2.0  Extract and Transform the Data

-- 15.2.1  Extract the weather station reported air temperature data. Instead of
--         keeping the value a VARIANT, cast it to a NUMBER(38,1):

SELECT v:station.name::VARCHAR AS station,
       v:station.country::VARCHAR AS country,
       v:data.observations[0].air.temp::NUMBER(38,1) AS temp_celsius
FROM weather.isd_2019_total
WHERE country = 'FR';


-- 15.2.2  Explore the results.
--         Are you seeing any large numbers?
--         NOTE: Some weather stations were unable to record data and an
--         observation quality code column should be evaluated to avoid skew
--         data readings when performing data analysis.

-- 15.2.3  Extract the weather station reported air temperature data that has
--         pass all quality control checks. Rename the column temp_celsius and
--         include only temperature data with a temp-quality-code equal to 1:

SELECT v:station.name::VARCHAR AS station,
       v:station.country::VARCHAR AS country,
       v:data.observations[0].air.temp::NUMBER(38,1) AS temp_celsius
FROM weather.isd_2019_total
WHERE country = 'FR' 
AND v:data.observations[0].air."temp-quality-code" = '1';


-- 15.2.4  Limit the results to records for a 7 day period starting on
--         2020-08-14 and ending on 2020-08-21 (you must cast the time column as
--         a date, so it matches the type of output from the TO_DATE function):

SELECT v:data.observations[0].air.temp::NUMBER(38,1) AS temp_celsius,
       v:data.observations[0].dt::DATE AS date
FROM weather.isd_2019_total
WHERE date >= to_date('2019-08-14') AND date <= to_date('2019-08-21')
    AND v:data.observations[0].air."temp-quality-code" = '1'
ORDER BY date;


-- 15.2.5  Write a query to pull country, station name, and highest temperatures
--         for a two (2) day period starting on 2019-08-14 and ending on
--         2019-08-16.

SELECT v:station.country::VARCHAR AS country,
       v:station.name::VARCHAR AS station,
       MAX(v:data.observations[0].air.temp)::NUMBER(38,1) AS max_celsius
FROM weather.isd_2019_total
WHERE v:data.observations[0].dt::date >= to_date('2019-08-14')
    AND v:data.observations[0].dt::date <= to_date('2019-08-16')
    AND v:data.observations[0].air."temp-quality-code" = '1'
GROUP BY country, station;


-- 15.2.6  Run the same query, but return the temperature in Fahrenheit instead
--         of Celsius.
--         The formula is Fahrenheit = (Celsius * 9/5 + 32).

SELECT v:station.country::VARCHAR AS country,
       v:station.name::VARCHAR AS station,
       MAX(v:data.observations[0].air.temp) AS max_celsius,
       (MAX(v:data.observations[0].air.temp) * 9/5 + 32) AS max_fahrenheit
FROM weather.isd_2019_total
WHERE v:data.observations[0].dt::date >= to_date('2019-08-14')
    AND v:data.observations[0].dt::date <= to_date('2019-08-16')
    AND v:data.observations[0].air."temp-quality-code" = '1'
GROUP BY country, station;


-- 15.2.7  Run the following command, then click on one of the values in the V
--         column to see the format of the VARIANT:

SELECT * FROM isd_2019_daily
LIMIT 10;

--         Notice there is a data key and a station key, each with nested
--         values.

-- 15.2.8  Run a query to return 10 rows showing the timestamp, the station
--         name, and the entire data VARIANT.

SELECT t, v:station.name, v AS variant
FROM weather.isd_2019_daily
LIMIT 10;


-- 15.2.9  Click on a row in the data column, to see the structure of the data
--         VARIANT. What additional information can you extract from the JSON
--         data provided?

-- 15.2.10 Use the FLATTEN table function (with a LATERAL JOIN) to iterate
--         through the objects in the observations field and extract air
--         temperature and the observation time and air temperature value:

SELECT weather.t as date,
       weather.v:station.name::VARCHAR AS station,
       weather.v:station.country::VARCHAR AS country,
       observations.value:air.temp::NUMBER(38,1) AS temp_celsius,
       observations.value:dt::timestamp_ntz AS time
FROM weather.isd_2019_daily weather,
LATERAL FLATTEN(input => v:data.observations) observations
LIMIT 100;

--         Note the results: the first three (3) columns (DATE, STATION and
--         COUNTRY) repeat for several rows while the remaining columns change.
--         Can you explain why those first columns repeat, but the remaining
--         columns change every row?
--         Does the number of rows where the values in the first two columns
--         repeat give you any information on the size of the data array you
--         just flattened?

-- 15.2.11 Run a query to calculate the average, max and min air temperature in
--         Celsius and Fahrenheit for each weather station.

-- 15.2.12 Run a query to calculate the average, max and min air temperature in
--         Celsius and Fahrenheit for each weather station. Limit the results to
--         records for a 7 day period starting on 2020-08-14 and ending on
--         2020-08-21 and air temperature values that has pass all quality
--         control checks:

SELECT weather.t as date,
       weather.v:station.name::VARCHAR AS station,
       weather.v:station.country::VARCHAR AS country,
       AVG(observations.value:air.temp)::NUMBER(38,1) as avg_temp_c,
       MIN(observations.value:air.temp) as min_temp_c,
       MAX(observations.value:air.temp) as max_temp_c,
       (AVG(observations.value:air.temp) * 9/5 + 32)::NUMBER(38,1) as avg_temp_f,
       (MIN(observations.value:air.temp) * 9/5 + 32) as min_temp_f,
       (MAX(observations.value:air.temp) * 9/5 + 32) as max_temp_f
FROM weather.isd_2019_daily weather,
LATERAL FLATTEN(input => v:data.observations) observations
WHERE observations.value:air."temp-quality-code" = '1'
    AND date >= to_date('2019-08-14') AND date <= to_date('2019-08-21')
GROUP BY country, date, station;


-- 15.2.13 Suspend the warehouse:

ALTER WAREHOUSE COBRA_WH SUSPEND;

