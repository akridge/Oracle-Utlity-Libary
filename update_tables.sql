----------------------------------------------------------------------------------------------------------------------------
update_tables
----------------------------------------------------------------------------------------------------------------------------
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
















































