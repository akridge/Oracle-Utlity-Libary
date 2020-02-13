--------------------------------------------------------
--  DDL for Procedure P_DELETE_ALL_APEX_USERS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "SCHEMANAME"."P_DELETE_ALL_APEX_USERS" 

as

/*

Running this procedure will essentially delete all users that were created in mass using the procedure "P_CREATE_APEX_USERS" (user ids 1-1999)

ONLY RUN THIS PROCEDURE WHEN YOU INTEND TO DELETE ALL USERS

*/

begin

    for i in 1..1999
    loop

        APEX_UTIL.REMOVE_USER(p_user_id => i);

    end loop;
end;

/
