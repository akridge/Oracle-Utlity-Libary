-----
get list of all triggers, tables and sequences to drop:
-----
select 'drop trigger ' || trigger_name || ';' stmt from user_triggers;
select 'DROP SEQUENCE ' || sequence_name || ';' stmt from user_sequences;
select 'DROP TABLE ' || table_name || ';' stmt from user_tables;
select 'DROP VIEW ' || view_name || ';' stmt from user_views;