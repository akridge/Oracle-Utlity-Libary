# Oracle Database XE Install

## Install Files

- …\ OracleXE112\_Win64.zip

## Install Oracle Database XE

1. Unzip oracleXE112\_Win64.zip
2. Double-click on setup.exe
  1. Hit next \&gt; accept\&gt;next
  2. Enter password for sys and system
  3. Install
  4. Finish
3. Reboot machine
4. Confirm install by
  1. Start command window and type:
  2. Sqlplus /nolog
  3. Connect sys as sysdba
  4. Enter password
  5. Select \* from tab;
    1. Should get list of table but if not then something is wrong

# Create Schema

1. Using SQLPlus run the following to create
  1. Create user someuser identified by &quot;passwordhere&quot;;
2. Grant
  1. GRANT         CONNECT, RESOURCE, DBA TO someuser;
  2. GRANT UNLIMITED TABLESPACE TO someuser;

# APEX Install (5.0.2 or above)

## System Requirements

Before this install and configure:

- Disable or change any other HTTP server program default ports(example apache 8080)
- Add 8080 port to exception list to firewall settings or disable it
- And so on.

## _Install Files_

- _…\ apex\_5.1.4\_en.zip_

## Install Notes

- **When using sqlplus - never use @ in password**

## Install APEX

1. Download APEX
  - http://www.oracle.com/technetwork/developer-tools/apex/downloads/index.html
2. Unzip and place the downloaded files in (can be changed to other directories):
  - C:\apex
3. Install full development environment
  - Using SQLPlus run the following

connect sys as sysdba

Enter password: &quot;insert system password&quot;

@apexins.sql sysaux sysaux temp /i/;

1. Install apex image directory(continues from set 2)
  - Using SQLPlus run the following

SQL\&gt; connect sys as sysdba

Enter password: &quot;insert system password&quot;

@apex\_epg\_config.sql C:

1. Unlock anonymous account
  - Using SQLPlus run the following

SQL\&gt; connect sys as sysdba

Enter password: &quot;insert system password&quot;

Alter user anonymous account unlock;

1. Unlock apex\_public\_user account
  - Using SQLPlus run the following

SQL\&gt; connect sys as sysdba

Enter password: &quot;insert system password&quot;

Alter user apex\_public\_user account unlock;

1. If a new install, do the following to setup/update instance admin account:
  - Using SQLPlus run the following

SQL\&gt; connect sys as sysdba

Enter password: &quot;insert system password&quot;

@apxchpwd.sql

1. Set and enable HTTP server port
  - Using SQLPlus run the following

SQL\&gt; connect sys as sysdba

Enter password: &quot;insert system password&quot;

EXEC DBMS\_XDB.SETHTTPPORT(8080);

## Test APEX Install

1. http://localhost:8080/apex/apex\_admin
  - User: admin
  - Pass:  apex instance admin password

## Create &amp; configure APEX workspace

1. Login  to instance admin:
  - http://localhost:8080/apex/apex\_admin
    1. User: admin
    2. Pass:  apex instance admin password
2. Create workspace
  - Name: namehere
  - Select current schema: namehere
  - Enter new workspace admin info
3. Test workspace
  - http://localhost:8080/apex/
    1. instance: namehere
    2. User: admin
    3. Pass:  password
4. Install/inport app

## For a New Server or Restore Build (import schema)

- Drop all current database objects in schema. | Simple sql to get list of all triggers, tables and sequences to drop:
  - select &#39;drop trigger &#39; || trigger\_name || &#39;;&#39; stmt from user\_triggers;
  - select &#39;DROP SEQUENCE &#39; || sequence\_name || &#39;;&#39; stmt from user\_sequences;
  - select &#39;DROP TABLE &#39; || table\_name || &#39;;&#39; stmt from user\_tables;
  - select &#39;DROP VIEW &#39; || view\_name || &#39;;&#39; stmt from user\_views;
  - and so on
  - Then copy the list in new worksheet and run
- Import database objects in this order:
  - Sequences
  - Tables
  - Views
  - Data
  - Constraints
  - Triggers
  - Index
