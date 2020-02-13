Oracle Database 11g XE backup on Windows 10

**Setup archive log mode**

1. Invoke SQL\*Plus and connect as a user with SYSDBA privileges.
2. 2. Shut down the database instance using the NORMAL, IMMEDIATE, or TRANSACTIONAL option:

SHUTDOWN IMMEDIATE

3.  Make a whole database backup including all data files and control files. You can use operating system commands or RMAN to perform this operation.This backup can be used in the future for recovery with archived redo log files that will be created once the database is in ARCHIVELOG mode.

4.  Start the instance and mount the database:

STARTUP MOUNT

5.  Place the database in ARCHIVELOG mode:

ALTER DATABASE ARCHIVELOG;

6.  Open the database:

ALTER DATABASE OPEN;

7.  set size limit

ALTER system set db\_recovery\_file\_dest\_size = 20G;

Make sure user has part of DBA group

- In windows 10 go to
  - &quot;edit local users and groups&quot;
  - Edit user
  - Add group &quot;OVA\_DBA&quot;

Run backup script

- Oraclexe/app/oracle/product/11.2.0/server/bin
- Or
- …\Backup Database.bat (include robocopy script at bottom of file)