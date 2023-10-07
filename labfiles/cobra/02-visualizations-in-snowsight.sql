
-- 2.0.0   Visualizations in Snowsight
--         The purpose of this lab is to show you how to use the visualization
--         features and tools available in Snowsight. Specifically, you’ll learn
--         how to leverage Contextual Statistics for specific columns in a table
--         in order to gain quick insights into data. Also, you’ll learn how to
--         create a dashboard from an existing query.
--         - How to create a dashboard from a worksheet
--         - How to use auto-complete to write a query
--         - How to use ad-hoc filters to get insights into data
--         - How to add tiles to a dashboard
--         - How to share a dashboard
--         Snowbear Air is interested in seeing a year-by-year summary of gross
--         sales. You’ve been asked to write a query with a graph and share it
--         via a Snowflake dashboard. You’ve decided to use the
--         PROMO_SALES_CATALOG schema to accomplish your task.
--         HOW TO COMPLETE THIS LAB
--         In the previous lab you may have used the SQL code file for that lab
--         to create a new worksheet and then just run the code provided. That
--         approach will not work for this lab because of the nature of what you
--         will be doing.
--         Instead, open the document in a text editor such as TextEdit (Mac) or
--         Notepad (Windows). Then you can either type the commands directly, or
--         cut and paste the code into a worksheet as indicated in the
--         instructions. Microsoft Word is not recommended as it can often
--         introduce hidden characters that will cause your code not to run.
--         Also, it is not recommended that you cut and paste from the workbook
--         pdf as the same problem previously described can occur.
--         Let’s get started!

-- 2.1.0   Creating a Dashboard

-- 2.1.1   Using skills you’ve already learned, create a new folder called
--         Visualizations in Snowsight.

-- 2.1.2   Within your new folder, create a new worksheet called Dashboard Data.

-- 2.1.3   Set the context by executing the statements below in your worksheet:

USE ROLE TRAINING_ROLE;
USE SCHEMA SNOWBEARAIR_DB.PROMO_CATALOG_SALES;
USE WAREHOUSE COBRA_WH;


-- 2.1.4   Now let’s write our query. Just take a moment to review it. You don’t
--         need to run it.

SELECT 
          *  
FROM
        CUSTOMER C
        INNER JOIN NATION N ON C.C_NATIONKEY = N.N_NATIONKEY
        INNER JOIN REGION R ON N.N_REGIONKEY = R.R_REGIONKEY
        INNER JOIN ORDERS O ON C.C_CUSTKEY = O.O_CUSTKEY
        INNER JOIN LINEITEM L ON O.O_ORDERKEY = L.L_ORDERKEY
        INNER JOIN PART P ON L.L_PARTKEY = P.P_PARTKEY
        INNER JOIN SUPPLIER S ON L.L_SUPPKEY = S.S_SUPPKEY;

--         As you can see, you are selecting *, which returns all the fields.
--         However, all you need is a year column and a gross revenue column.

-- 2.2.0   How to use Auto-Complete to write a query
--         Now you’re going to use the auto-complete feature to add year and
--         gross revenue to the columns returned by the query.
--         The Auto-Complete Feature
--         The auto-complete feature suggests SQL Keywords, databases, schemas,
--         tables, field names, functions and other object types while you are
--         typing.
--         By using auto-complete, you can work faster and make fewer typos.
--         We need to get the O_ORDERDATE column from the ORDERS table and pass
--         it through a function that will extract the year. Let’s do that now.

-- 2.2.1   Add the YEAR column using auto-complete
--         Remove the asterisk and type YEAR as shown below:
--         Auto-complete
--         As you can see, when you type the word year, the auto-complete
--         feature generates a list of functions to select from. Select YEAR and
--         hit enter.

-- 2.2.2   Add O_ORDERDATE as an argument in the year function
--         Type O and then a period. you should see the drop-down menu shown
--         below:
--         Auto-complete
--         As you type table names and table aliases, the auto-complete feature
--         generates a list of fields you can select from.
--         Select O_ORDERDATE and alias the column as YEAR.

-- 2.2.3   Add the next column using auto-complete
--         The next step is substantially the same as the previous step.
--         First, add a column containing the the sum of the gross revenue. Type
--         a comma and then SUM.
--         You should be offered the SUM function. Choose that function.
--         Then within the parentheses of the function, type L and a period.
--         Auto-complete should generate a list with the L_EXTENDEDPRICE field.
--         Alias the field as SUM_GROSS_REVENUE

-- 2.2.4   Add a GROUP BY clause and an ORDER BY clause
--         Below the FROM clause, add a GROUP BY YEAR clause and an ORDER BY
--         YEAR clause.
--         You should now have the query below.

SELECT 
          YEAR(O.O_ORDERDATE) AS YEAR
        , SUM(L.L_EXTENDEDPRICE) AS SUM_GROSS_REVENUE
        
FROM
        CUSTOMER C
        INNER JOIN NATION N ON C.C_NATIONKEY = N.N_NATIONKEY
        INNER JOIN REGION R ON N.N_REGIONKEY = R.R_REGIONKEY
        INNER JOIN ORDERS O ON C.C_CUSTKEY = O.O_CUSTKEY
        INNER JOIN LINEITEM L ON O.O_ORDERKEY = L.L_ORDERKEY
        INNER JOIN PART P ON L.L_PARTKEY = P.P_PARTKEY
        INNER JOIN SUPPLIER S ON L.L_SUPPKEY = S.S_SUPPKEY

GROUP BY
        YEAR
ORDER BY
        YEAR; 


-- 2.2.5   Run the query and check the results
--         You should see the results below:
--         Query Results
--         Note that there are two kinds of information to the right of the
--         result. There are the Query Details pane and the Contextual
--         Statistics pane. The Query Details pane shows the duration of the
--         query and the number of rows returned. The Contextual Statistics pane
--         helps you make sense of your data at a glance.
--         Also note that there is a comma for each value in the YEAR column. To
--         change it, hover your cursor over the YEAR column header, then click
--         the ellipses that appears to the right. Click the comma button to
--         remove the commas.:
--         Removing comma from the YEAR column

-- 2.2.6   Click the Query Details pane
--         Query Details
--         Note that in addition to the query duration and the rows scanned, it
--         shows the end time of the query, the role used and the warehouse
--         used.

-- 2.3.0   How to use ad-hoc filters to get insights into data
--         Now let’s work with ad-hoc filters so you can explore and gain
--         insights into the data returned by the query.

-- 2.3.1   Click on the section with the graph to apply a filter
--         Note there are two panes with Contextual Statistics, one that shows a
--         graph of data from 2012 to 2018 and is labeled YEAR, the other that
--         shows the highest and lowest values in the data set returned and is
--         labeled SUM_GROSS_REVENUE. The contextual statistics, one for each
--         column returned by the query, can be used interactively as filters on
--         the query result. Let’s explore how they work.

-- 2.3.2   Click on the YEAR filter
--         You should now see the filter. On the left is the data and the YEAR
--         column is highlighted. On the right is the filter itself.
--         YEAR filter

-- 2.3.3   Click on the leftmost column in the graph’s filter
--         Now the results should be filtered for 2012 only.
--         YEAR filter, 2012

-- 2.3.4   Select 2012 and 2013
--         Note that there are two oval selectors beneath the chosen column in
--         the filter’s graph. Click, hold and drag the right-most selector to
--         include both 2012 and 2013. Your filter should appear as shown below:
--         YEAR filter, 2012-2013
--         Now click different bars, or select any combination of multiple bars
--         to see how the filter changes the data shown.

-- 2.3.5   Click the Clear filter button
--         Clear filter button
--         The filter should appear as it did before.

-- 2.3.6   Click the Close button (X)
--         This should clear the column selected and you should see the Query
--         Details pane and the YEAR and SUM_GROSS_REVENUE filters.
--         Clear Selection Button

-- 2.3.7   Click the SUM_GROSS_REVENUE filter
--         The filter should appear as below. Click the columns and observe how
--         the data is filtered. Clicking between the columns will display the
--         following message: Query produced no results. That’s because there is
--         a gap between the value in the left-most bar and the value of the
--         right-most bar.
--         SUM_GROSS_REVENUE filter

-- 2.3.8   Click the Clear filter and Close selection buttons

-- 2.3.9   Move the worksheet to the Dashboards
--         Now let’s create our dashboard. You can do this by either creating a
--         brand new dashboard, or by moving an existing worksheet to
--         Dashboards. Let’s try this second method.

-- 2.3.10  Click the down arrow next to the worksheet name (Dashboard Data)

-- 2.3.11  Select Move to, then New dashboard from the dialog box.
--         Move to Dashboards

-- 2.3.12  Name the new dashboard Gross Sales and click the Create Dashboard
--         button.
--         You should now see a screen that looks like the worksheet itself.
--         This is where you can edit the query that creates the data for the
--         dashboard. In the upper-left hand corner there should be a Return to
--         Gross Sales link.

-- 2.3.13  Click the Return to Gross Sales link
--         You should now see the dashboard but in presentation mode.
--         Presentation mode
--         The data itself is in a tile that is present on the dashboard. Tiles
--         are used to present data or graphs in the dashboard.

-- 2.4.0   How to add tiles to a dashboard
--         Now we’re going to add a new tile so we can show a graph.

-- 2.4.1   Click the plus sign just below the home button and the dashboard name
--         to create a graph
--         A dialog box should appear with a New Tile from Worksheet button.

-- 2.4.2   Click the New Tile from Worksheet button
--         A new worksheet should appear with no SQL code.

-- 2.4.3   Paste the query below into the empty pane.

SELECT 
          YEAR(O.O_ORDERDATE) AS YEAR
        , SUM(L.L_EXTENDEDPRICE) AS SUM_GROSS_REVENUE
        
FROM
        CUSTOMER C
        INNER JOIN NATION N ON C.C_NATIONKEY = N.N_NATIONKEY
        INNER JOIN REGION R ON N.N_REGIONKEY = R.R_REGIONKEY
        INNER JOIN ORDERS O ON C.C_CUSTKEY = O.O_CUSTKEY
        INNER JOIN LINEITEM L ON O.O_ORDERKEY = L.L_ORDERKEY
        INNER JOIN PART P ON L.L_PARTKEY = P.P_PARTKEY
        INNER JOIN SUPPLIER S ON L.L_SUPPKEY = S.S_SUPPKEY

GROUP BY
        YEAR
ORDER BY
        YEAR; 


-- 2.4.4   Rename this tile
--         Just like with the worksheets we created earlier, a time and date
--         should appear at the top of the worksheet. Click the time/date and
--         change the time and date to Dashboard Graph.

-- 2.4.5   Run the query
--         A result pane identical to the one we saw before should appear.

-- 2.4.6   Click the ellipses in the heading of the YEAR column and remove the
--         commas from the year values

-- 2.4.7   Click the Chart button
--         The Chart button is just above the result pane, next to the blue
--         results button.
--         A line graph should be chosen by default:
--         Presentation mode

-- 2.4.8   Click Return to Gross Sales in the upper-left hand corner
--         You should now see a completed dashboard like the one shown below:
--         Presentation mode
--         Now let’s see how to share our dashboard.

-- 2.5.0   How to share a dashboard

-- 2.5.1   Click the share button in the upper-right hand corner
--         In this dialog box you can search for and invite someone to view and
--         use this dashboard.
--         Share dialog box
--         You don’t have anyone to share with, so we’ll just walk you through
--         the process so you understand it. It’s so simple!
--         First, you would select a user by typing their user name:
--         Sharing with a user
--         Next you would select a permission level for them, such as Edit, View
--         + run, or just View results:
--         Granting permissions to user
--         Then you would click the Done button. That’s it!

-- 2.6.0   Key Takeaways
--         - The auto-complete feature is a useful tool for writing queries. It
--         helps you work faster and with fewer typos.
--         - While conducting ad-hoc analyses you can use filters to gain
--         insights into your data.
--         - You can create dashboards out of existing worksheets.
--         - Snowflake makes it super-easy to share worksheets with colleagues.
