--------------------------------------------------------
--  File created - Friday-February-02-2018   
--
-- Procedure to create APEX Users based on table with a list of users
--------------------------------------------------------
CREATE PROCEDURE SCHEMANAME.P_CREATE_APEX_USER 

as

        vUID number := 2000;

    begin

        for i in(select first_name, last_name, email from list_of_users wherere active = YES)
        loop

            vUID := vUID + 1;

            wwv_flow_fnd_user_api.create_fnd_user (
            p_user_id                      => vUID,
            p_user_name                    => to_char(i.diver),
            p_first_name                   => to_char(i.first_name),
            p_last_name                    => to_char(i.last_name),
            p_description                  => to_char(i.diver),
            p_email_address                => to_char(i.email),
            p_web_password                 => 'password',
            p_web_password_format          => 'CLEAR_TEXT',
            p_group_ids                    => NULL,
            p_developer_privs              => '',
            p_default_schema               => 'GISDAT',
            p_account_locked               => 'N',
            p_account_expiry               => sysdate,
            p_failed_access_attempts       => 0,
            p_change_password_on_first_use => 'Y',
            p_first_password_use_occurred  => 'N',
            p_allow_app_building_yn        => 'N',
            p_allow_sql_workshop_yn        => 'N',
            p_allow_websheet_dev_yn        => 'N',
            p_allow_team_development_yn    => 'N',
            p_allow_access_to_schemas      => '');

        end loop;
    end;
