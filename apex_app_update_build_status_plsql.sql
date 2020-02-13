
----template----
begin
  apex_util.set_app_build_status(APP#, 'STATUS_HERE');
end;

---------------------------------------------------------------
----Example----

begin
  apex_util.set_app_build_status(102, 'RUN_AND_BUILD');
end;