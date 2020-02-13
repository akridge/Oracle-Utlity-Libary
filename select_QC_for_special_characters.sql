---- select_QC_for_special_characters ----

- use before data migration/export to filter out special charcters -


-- the following will filter out line breaks

SELECT * from table_name
where instr(comments, chr(10)) > 0;



-- the following will filter out commas. A comma will mess with CSV export
SELECT * from table_name
where comments like '%,%';



-- use the following to update the column as needed
SELECT REPLACE(stringColumnName, 'thestring', '')
FROM table_name

