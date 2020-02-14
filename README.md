# Oracle-Utlity-Libary
Oracle SQL &amp; PL/SQL Library. Documents, install notes, tips and tricks. and more. 

Function List:
- function _WAYPOINT_LOADER:  GPS waypoint file parcer
- function_distance_using_grand_circle_navigation: will measure distance between two tables with lats/longs

Proedures List:
- procedure_create_apex_users
- procedure_DELETE_ALL_APEX_USERS
- procedure_REMOVE_INACTIVE_APEX_USER

How to Docs List:
- Oracle XE and APEX install 2020 doc
- Oracle DAtabase backup on windows 10 doc
- Database backup batch file with robocopy features
- SQL plus notes
- data model how to 
- SQL tips and tricks

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

## Select list of columns
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
