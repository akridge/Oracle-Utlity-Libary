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






