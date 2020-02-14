-- --
-- -- Create TEST tablespace
-- --        TEST    schema
-- -- and    TESTUSR
-- --
spool cr_TESTdat.log append
-- --
-- -- Create new tablespace in current instance
-- --
CREATE TABLESPACE TESTDAT logging
        DATAFILE '/u05/oradata/${ORACLE_SID}/TESTdat_01.dbf' SIZE 4096M
        AUTOEXTEND OFF
        EXTENT MANAGEMENT LOCAL
        SEGMENT SPACE MANAGEMENT AUTO
;

-- --
-- -- Create new main schema user
-- --

CREATE USER TEST
  IDENTIFIED BY ""
  DEFAULT TABLESPACE TESTDAT
  QUOTA UNLIMITED ON TESTDAT ;

-- --
-- -- Create new user
-- --

CREATE USER TESTUSR
  IDENTIFIED BY ""
  DEFAULT TABLESPACE TESTDAT ;

-- --
-- -- Create TEST_power_user_role  2019
-- --

create role TEST_power_user_role;

-- --

-- --
-- -- Grant role privileges 2019
-- --

GRANT CREATE session to TEST_power_user_role;
GRANT ALTER session to TEST_power_user_role;
GRANT UNLIMITED TABLESPACE to TEST_power_user_role;
GRANT CREATE TABLE to TEST_power_user_role;
GRANT CREATE VIEW to TEST_power_user_role;
GRANT CREATE MATERIALIZED VIEW to TEST_power_user_role;
GRANT CREATE TRIGGER to TEST_power_user_role;
GRANT CREATE SEQUENCE to TEST_power_user_role;
GRANT CREATE PROCEDURE to TEST_power_user_role;
GRANT CREATE JOB to TEST_power_user_role;
--GRANT CREATE DATABASE LINK to TEST_power_user_role;
GRANT CREATE INDEX to TEST_power_user_role;
GRANT CREATE INDEXTYPE to TEST_power_user_role;
GRANT CREATE SYNONYM  to TEST_power_user_role;
--GRANT CREATE CLUSTER to TEST_power_user_role;
--GRANT CREATE TYPE to TEST_power_user_role;
--GRANT CREATE OPERATOR to TEST_power_user_role;
--GRANT CREATE DIMENSION to TEST_power_user_role;
GRANT DEBUG CONNECT SESSION to TEST_power_user_role;
GRANT DEBUG PROCEDURE to TEST_power_user_role;
--GRANT QUERY REWRITE to TEST_power_user_role;
--GRANT GLOBAL QUERY REWRITE to TEST_power_user_role;

-- --
-- -- Grant role Specified Table permissions
-- --

GRANT SELECT, INSERT, UPDATE ON  schema.table_name TO TEST_power_user_role;
GRANT SELECT, INSERT, UPDATE ON  schema.table_name TO TEST_power_user_role;
GRANT SELECT, INSERT, UPDATE ON  schema.table_name TO TEST_power_user_role;

-- --

-- --
-- -- Grant TEST_power_user_role to Users
-- --

grant TEST_power_user_role to user1;
grant TEST_power_user_role to user2;
grant TEST_power_user_role to TEST;

-- --


-- --
-- -- OLD Stuff
-- --
-- --
-- -- Grant basic roles to Users
-- --
--GRANT CONNECT, RESOURCE TO user1;
--GRANT CONNECT, RESOURCE TO user2;
--GRANT CONNECT, RESOURCE TO USER;
-- --
-- -- -- --
-- -- Create role for select (read only) access to current tables in schema TESTDAT
-- --
-- CREATE ROLE TESTDAT_ALL_TAB_SEL_ROLE ;
-- SELECT 'grant select on '||OWNER||'.'||TABLE_NAME||' to TESTDAT_ALL_TAB_SEL_ROLE ;' as script
-- FROM dba_tables
-- WHERE owner='TESTDAT';
-- BEGIN
--   FOR  tab  IN (
--     SELECT  OWNER, TABLE_NAME
--       FROM  dba_tables
--      WHERE  owner = 'TESTDAT'
--   ) LOOP
--       EXECUTE IMMEDIATE 'GRANT SELECT  ON '||tab.owner||'.'||tab.table_name||' TO TESTDAT_ALL_TAB_SEL_ROLE';
--   END LOOP;
-- END;
-- /
-- GRANT
--   TESTDAT_ALL_TAB_SEL_ROLE
-- TO TESTUSR ;
-- --
-- -- Allow user to login (create sessions etc)
-- --
-- --
-- Perform when account can be released to the user
-- --
-- GRANT
--   MINCONNECT_ROLE
-- TO TESTUSR ;
-- --
spool off
