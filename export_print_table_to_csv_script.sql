use the following to print any table into csv
----------------------------------------

clear screen
SET pagesize 300
SET sqlformat csv
cd c:\users\firstname.lastname\Desktop
spool test.csv
SELECT * FROM table_name;
spool off
!TYPE test.csv



clear screen -- clears the output screen
SET pagesize 300 -- every 300 rows, print the column headers
SET sqlformat csv -- spit the results out in a comma separated values format
cd c:\users\first.last -- change the current working directory
spool table.csv -- capture everything that happens next to this file
SELECT * FROM table; -- get me the employees
spool off -- stop writing to that file
!TYPE table.csv -- run this OS command (windows CAT of a file basically)
