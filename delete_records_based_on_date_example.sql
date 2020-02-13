delete from ov_sets where EXECUTION_ID in (select execution_id from ov_script_executions where start_time > TO_DATE('07/11/2019', 'MM/DD/YYYY'));
delete from ov_files where EXECUTION_ID in (select execution_id from ov_script_executions where start_time > TO_DATE('07/11/2019', 'MM/DD/YYYY'));
delete from ov_executions where start_time > TO_DATE('07/11/2019', 'MM/DD/YYYY');
