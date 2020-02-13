@echo off
REM
REM The script assumes that user can connect using "/ as sysdba" and Flash
REM Recovery Area is enabled.
REM
REM =================
REM Backup procedure
REM =================
REM
REM    For database in NoArchiveLog mode, database is shutdown and an offline
REM    backup is done;
REM    For database in Archive log mode, online backup is done.
REM
REM    During the backup procedure, the script stores flash recovery area
REM    location by saving complete initialization parameter to
REM    ?/DATABASE/SPFILE2INIT.ORA file. This will be used during restore
REM    operation to find Flash Recovery Area location. If this file is lost,
REM    then user must enter Flash Recovery Area location during restore
REM    operation.
REM
REM    Two backups are maintained in Flash Recovery Area and the corresponding
REM    log files for last two backup job are saved in
REM    ?/DATABASE/OXE_BACKUP_CURRENT.LOG and ?/DATABASE/OXE_BACKUP_PREVIOUS.LOG
REM

setlocal

@(
   echo connect / as sysdba;
   echo set head off
   echo set echo off
   echo set linesize 515
   echo variable var varchar2^(512^)^;
   echo execute :var := sys.dbms_backup_restore.normalizefilename^(^'FRA_LOC^'^)^;
   echo spool %temp%\backup_rmanlog.log
   echo select sys.dbms_backup_restore.normalizefilename^(^'OXE_BACKUP_CURRENT.LOG^'^) BACKUP_RMANLOG from dual^;
   echo exit^;
) > %temp%\backup_rmanlog.sql
sqlplus /nolog @%temp%\backup_rmanlog.sql >nul
FOR /F %%i in (%temp%\backup_rmanlog.log) do set BACKUP_RMANLOG=%%i

@(
   echo connect / as sysdba;
   echo set head off
   echo set echo off
   echo set linesize 515
   echo variable var varchar2^(512^)^;
   echo execute :var := sys.dbms_backup_restore.normalizefilename^(^'FRA_LOC^'^)^;
   echo spool %temp%\backup_rmanprevlog.log
   echo select sys.dbms_backup_restore.normalizefilename^(^'OXE_BACKUP_PREVIOUS.LOG^'^) BACKUP_RMANLOG from dual^;
   echo exit^;
) > %temp%\backup_rmanprevlog.sql
sqlplus /nolog @%temp%\backup_rmanprevlog.sql >nul
FOR /F %%i in (%temp%\backup_rmanprevlog.log) do set BACKUP_RMANPREVLOG=%%i

@(
   echo connect / as sysdba;
   echo set head off
   echo set echo off
   echo set linesize 515
   echo spool %temp%\backup_fra.log
   echo select value from v$parameter where lower^(name^)=^'db_recovery_file_dest^'^;
   echo exit^;
) > %temp%\backup_fra.sql
sqlplus /nolog @%temp%\backup_fra.sql >nul
set BACKUP_FRA=
FOR /F %%i in (%temp%\backup_fra.log) do set BACKUP_FRA=%%i
if "%BACKUP_FRA%"=="" set Errorstr=         Flash Recovery Area is not enabled & goto :backupfailederr

@(
   echo connect / as sysdba;
   echo set head off
   echo set echo off
   echo set linesize 515
   echo spool %temp%\backup_fra2.log
   echo select sys.dbms_backup_restore.normalizefilename^(^'%BACKUP_FRA%^'^) BACKUP_FRA from dual^;
   echo exit^;
) > %temp%\backup_fra2.sql
sqlplus /nolog @%temp%\backup_fra2.sql >nul
FOR /F %%i in (%temp%\backup_fra2.log) do set BACKUP_FRA=%%i

@(
   echo connect / as sysdba;
   echo set head off
   echo set echo off
   echo set linesize 515
   echo variable var varchar2^(512^)^;
   echo execute :var := sys.dbms_backup_restore.normalizefilename^(^'SPFILE2INIT^'^)^;
   echo spool %temp%\backup_spfile2init.log
   echo select sys.dbms_backup_restore.normalizefilename^(^'SPFILE2INIT.ORA^'^) spfile2init from dual^;
   echo exit^;
) > %temp%\backup_spfile2init.sql
sqlplus /nolog @%temp%\backup_spfile2init.sql >nul
FOR /F %%i in (%temp%\backup_spfile2init.log) do set SPFILE2INIT=%%i

@(
   echo connect / as sysdba;
   echo set head off
   echo set echo off
   echo spool %temp%\logmode.log
   echo select log_mode from v$database^;
   echo exit^;
) > %temp%\logmode.sql
sqlplus /nolog @%temp%\logmode.sql >nul
FOR /F %%i in (%temp%\logmode.log) do set LOGMODE=%%i

if "%LOGMODE%" == "NOARCHIVELOG" goto process_noarchivelog
if "%LOGMODE%" == "ARCHIVELOG" goto process_archivelog
set Errorstr=         Unknown log mode : %LOGMODE%
goto :backupfailederr

:process_noarchivelog
   echo Warning: Log archiving ^(ARCHIVELOG mode^) is currently disabled. If
   echo you restore the database from this backup, any transactions that take
   echo place between this backup and the next backup will be lost. It is
   echo recommended that you enable ARCHIVELOG mode before proceeding so
   echo that all transactions can be recovered upon restore. See the section
   echo 'Enabling ARCHIVELOG Mode...' in the online help for instructions.
   echo Backup with log archiving disabled will shut down and restart the
   set /p inp="database. Are you sure [Y/N]? "
:checkinp
if /i "%inp%" == "Y" goto :confirmedyes
if /i "%inp%" == "n" exit & goto :EOF
:Askagain
set /p inp=
goto :checkinp

:confirmedyes
if exist %BACKUP_RMANLOG% copy %BACKUP_RMANLOG% %BACKUP_RMANPREVLOG% /y >nul
echo Backup in progress...
@(
   echo set echo on^;
   echo shutdown immediate^;
   echo startup mount^;
   echo configure controlfile autobackup format for device type disk clear^;
   echo configure retention policy to redundancy 2^;
   echo configure controlfile autobackup on^;
   echo sql ^"create pfile=^'^'%SPFILE2INIT%^'^' from spfile^"^;
   echo backup as backupset device type disk database^;
   echo configure controlfile autobackup off^;
   echo alter database open^;
   echo delete noprompt obsolete^;
) > %temp%\backup_rman.dat
rman target / @%temp%\backup_rman.dat trace "%BACKUP_RMANLOG%"
if not %errorlevel% == 0 set Errorstr=         RMAN Error - See log for details & goto :backupfailederr

goto :backupsucess

:process_archivelog
if exist %BACKUP_RMANLOG% copy %BACKUP_RMANLOG% %BACKUP_RMANPREVLOG% /y >nul
echo Doing online backup of the database.
@(
   echo set echo on^;
   echo configure controlfile autobackup format for device type disk clear^;
   echo configure retention policy to redundancy 2^;
   echo configure controlfile autobackup on^;
   echo sql ^"create pfile=^'^'%SPFILE2INIT%^'^' from spfile^"^;
   echo backup as backupset device type disk database^;
   echo configure controlfile autobackup off^;
   echo sql ^'alter system archive log current^'^;
   echo delete noprompt obsolete^;
) > %temp%\backup_rman.dat
rman target / @%temp%\backup_rman.dat trace "%BACKUP_RMANLOG%"
if not %errorlevel% == 0 set Errorstr=         RMAN Error - See log for details & goto :backupfailederr

REM Switch an archived log if database is open
@(
   echo set echo on^;
   echo sql ^'alter system archive log current^'^;
) > %temp%\backup_rman2.dat
rman target / @%temp%\backup_rman2.dat trace "%BACKUP_RMANLOG%"
goto :backupsucess

:backupsucess
echo Backup of the database succeeded.
echo Log file is at %BACKUP_RMANLOG%.

robocopy C:\oraclexe\app\oracle\product\11.2.0\server\database C:\Cruise\CruiseData\MP2006\backups

pause Press any key to exit
exit
goto :EOF

:backupfailederr
echo ====================   ERROR =============================
echo          Backup of the database failed.
echo %Errorstr%.
echo          Log file is at %BACKUP_RMANLOG%.
echo ====================   ERROR =============================
pause Press any key to exit
exit
goto :EOF

robocopy C:\oraclexe\app\oracle\product\11.2.0\server\database C:\backups
