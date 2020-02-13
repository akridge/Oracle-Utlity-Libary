Get list of tables:
select * from all_tables;
or
select table_name from user_tables
or
select * from tab


Get list of columns:
SELECT column_name FROM user_tab_cols WHERE table_name=UPPER('TheTableName')

Get all data from a table:
SELECT * from table_name
