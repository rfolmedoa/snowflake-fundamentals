//HOW TO RETRIEVE THE ASSIGNED NETWORK_POLICY FOR ALL USERS?
//This article provides an easy way to get a list of ALL users and their assigned NETWORK_POLICY.
//https://community.snowflake.com/s/article/How-to-Retrieve-the-Assigned-NETWORK-POLICY-for-all-Users
//Feb 10, 2022•Knowledge
//Article Body
//Solution
//Currently, there is no easy way to get a list of ALL users and their assigned NETWORK_POLICY.
//There is an enhancement request logged for this internally.
// 
//The way to get this information is to manually:
//Get a list of users using "SHOW users" 
//Then for each user call  "show parameters like 'NETWORK_POLICY' for user. <username>" 
//The following sample code provides a programmatic way to get the information.

CREATE OR REPLACE PROCEDURE myuserlist()
  RETURNS VARCHAR NOT NULL
  LANGUAGE JAVASCRIPT
  EXECUTE AS CALLER
  AS
  $$
  var return_value = "";
  try { 
     // table to store the final user and network policy 
     command = "create or replace temporary table USER_LEVELS (username varchar(100),value VARCHAR(100), level VARCHAR(100));";
     snowflake.createStatement( {sqlText: command}  ).execute();

     // run command for listing users,  use the like statement to narrow the list if required
     var stmt = snowflake.createStatement( {sqlText: "SHOW users;"}  );
     stmt.execute();  
     
     // use the previous query ID to get the list of users and put into user_list table
     var queryid = stmt.getQueryId();
     stmt = snowflake.createStatement(
       {sqlText: "create or replace temporary table user_list as select $1 from table(result_scan('"+queryid+"'));"}
      );
     stmt.execute();
     
     // Now go through the user_list table and call show parameters for each user and put the result in USER_LEVELS table
      var command = "SELECT * FROM user_list;";
      var stmt = snowflake.createStatement( {sqlText: command } );
      var rs = stmt.execute();

      //First record  
      if (rs.next())  {
          name = rs.getColumnValue(1);
          cmd = "show parameters like 'NETWORK_POLICY' for user \"" + name + "\"" 
          var stmtx = snowflake.createStatement( {sqlText: cmd}  );
          stmtx.execute();  
          var queryid = stmtx.getQueryId();
          stmty = snowflake.createStatement(
             {sqlText: "insert into  USER_LEVELS select '" + name + "',$2,$4 from table(result_scan('"+queryid+"'));"}
             );
          stmty.execute();
      }
      
      // Remaining records 
      while (rs.next())  {
          name = rs.getColumnValue(1);
          cmd = "show parameters like 'NETWORK_POLICY' for user \"" + name + "\"" 
          var stmtx = snowflake.createStatement( {sqlText: cmd}  );
          stmtx.execute();  
          var queryid = stmtx.getQueryId();
          stmty = snowflake.createStatement(
             {sqlText: "insert into  USER_LEVELS select '" + name + "',$2,$4 from table(result_scan('"+queryid+"'));"}
             );
          stmty.execute();
      }
  }
  catch (err)  {
      result =  "Failed: Code: " + err.code + "\n  State: " + err.state;
      result += "\n  Message: " + err.message;
      result += "\nStack Trace:\n" + err.stackTraceTxt;
  }
  return return_value;


  $$
  ;
 
CALL myuserlist();
select * from user_info order by 1;
select * from USER_LEVELS order by 1 ;
drop table user_levels;
drop table user_info;