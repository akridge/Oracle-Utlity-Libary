create or replace procedure "P_REMOVE_INACTIVE_APEX_USER"
 
as
 
begin
 
    for i in(select diver from list_of_users where active = NO)
    loop
 
        APEX_UTIL.REMOVE_USER(p_user_name => i.diver);
 
    end loop;
end;
