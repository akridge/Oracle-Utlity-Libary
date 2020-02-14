# Oracle-Utlity-Libary
Oracle SQL &amp; PL/SQL Library. Documents, install notes, tips and tricks. and more. 
[Functions](https://github.com/akridge/Oracle-Utlity-Libary/tree/master/plsql_functions)
* function _WAYPOINT_LOADER:  GPS waypoint file parcer
* function_distance_using_grand_circle_navigation: will measure distance between two tables with lats/longs

[Proedures](https://github.com/akridge/Oracle-Utlity-Libary/tree/master/plsql_procedures)
* procedure_create_apex_users
* procedure_DELETE_ALL_APEX_USERS
* procedure_REMOVE_INACTIVE_APEX_USER

[How to Docs](https://github.com/akridge/Oracle-Utlity-Libary/tree/master/how_to_docs)
* Oracle XE and APEX install 2020 doc
* Oracle database backup on windows 10 doc & backup batch file with robocopy features
* SQL plus notes/SQL tips and tricks
* Data Model how to

# Useful SQL statements
## Select output that will give a list of all triggers, tables and sequences to drop:
``` 
select 'drop trigger ' || trigger_name || ';' stmt from user_triggers;
select 'DROP SEQUENCE ' || sequence_name || ';' stmt from user_sequences;
select 'DROP TABLE ' || table_name || ';' stmt from user_tables;
select 'DROP VIEW ' || view_name || ';' stmt from user_views;
``` 
## Select list of all  tables to drop w/ cascade:
``` 
select 'DROP TABLE ' || table_name || 'CASCADE CONSTRAINTS ' || ';' stmt from user_tables;
``` 
## Select list of tables
``` 
select * from all_tables;

select table_name from user_tables

select * from tab
``` 

## Select a list of all columns from a table
``` 
SELECT column_name FROM user_tab_cols WHERE table_name=UPPER('TheTableName')
``` 

## Select all data from a table
``` 
SELECT * from table_name
``` 

## Select records within date
``` 
select * from table_name where START_TIME > TO_DATE('11-JUL-19', 'DD-MON-YY');
```
 
or 

``` 
CREATE_DTM >TO_DATE('2019-04-30 03:00:00', 'YYYY-MM-DD HH24:MI:SS')
CREATE_DTM >TO_DATE('2019-07-25', 'YYYY-MM-DD')
``` 

# Update Table
``` 
UPDATE table t1
   SET (column_name) = (SELECT t2.column_name
                         FROM table_name_two t2
                        WHERE t1.primary_key_column_id = t2.primary_key_column_id
                         )
 WHERE EXISTS (
    SELECT 1
      FROM table_name_two t2
     WHERE t1.primary_key_column_id = t2.primary_key_column_id
      )
``` 

## Select user privileges

``` 
select * from session_privs;
``` 

## Select and filter Special Characters in records

### the following will filter out line breaks
``` 
SELECT * from table_name
where instr(comments, chr(10)) > 0;
``` 

### the following will filter out commas. A comma will mess with CSV export
``` 
SELECT * from table_name
where comments like '%,%';
``` 

### use the following to update the column as needed
``` 
SELECT REPLACE(stringColumnName, 'thestring', '')
FROM table_name
``` 

## Alter User Permissions

### change password
``` 
ALTER User INSERUSERNAME IDENTIFIED BY INSERTNEWUSERPASSWORD;
``` 
### GRANT PERMISSIONS
``` 
GRANT SELECT,INSERT,DELETE,UPDATE,CREATE SESSION ON TABLENAME TO USERNAME;
GRANT SELECT ON TABLENAME TO USERNAME;

``` 

## print any table into csv
``` 
clear screen -- clears the output screen
SET pagesize 300 -- every 300 rows, print the column headers
SET sqlformat csv -- spit the results out in a comma separated values format
cd c:\users\first.last -- change the current working directory
spool table.csv -- capture everything that happens next to this file
SELECT * FROM table; -- get me the employees
spool off -- stop writing to that file
!TYPE table.csv -- run this OS command (windows CAT of a file basically)
``` 

# Create New Schema User
``` 
CREATE USER [SCHEMA NAME]
  IDENTIFIED BY "[PASSWORD]" 
  DEFAULT TABLESPACE  [TABLESPACE] 
  QUOTA 500M ON [TABLESPACE] ;
``` 
### allow user to login
``` 
GRANT CREATE SESSION TO [SCHEMA NAME] ;
``` 
### SYSTEM PRIVILEGES example
``` 
GRANT CREATE TABLE TO [SCHEMA NAME] ;
GRANT CREATE SEQUENCE TO [SCHEMA NAME] ;
GRANT CREATE TRIGGER TO [SCHEMA NAME] ;
GRANT CREATE SYNONYM TO [SCHEMA NAME] ;
GRANT CREATE VIEW TO [SCHEMA NAME] ;
GRANT CREATE MATERIALIZED VIEW TO [SCHEMA NAME] ;
GRANT ALTER SESSION TO [SCHEMA NAME] ;
GRANT CREATE DATABASE LINK TO [SCHEMA NAME];
GRANT CREATE PROCEDURE TO [SCHEMA NAME];
GRANT CREATE TYPE TO [SCHEMA NAME];
``` 


# Grant Select Permissions on all objects loop
``` 
DECLARE
  objName VARCHAR(255);
  sqlGrant VARCHAR(255) := 'grant all on ';
BEGIN
  FOR i in (select object_name from user_objects where object_type = 'TABLE' OR object_type = 'VIEWS' 
            OR object_type = 'TRIGGERS' OR object_type = 'SEQUENCES' OR object_type = 'PROCEDURES' 
			OR object_type = 'FUNCTIONS' OR object_type = 'TRIGGERS')
  LOOP
    objName := i.object_name;
    execute immediate sqlGrant || objName || ' to username';
  END LOOP;
END;
``` 

# Update APEX app Build Status 
``` 
begin
  apex_util.set_app_build_status(APP#, 'STATUS_HERE');
end;

``` 
Example
``` 
begin
  apex_util.set_app_build_status(102, 'RUN_AND_BUILD');
end;
``` 

