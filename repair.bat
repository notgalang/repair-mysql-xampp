@ECHO OFF

REM Your XAMPP Location
SET xamppLocation=Your Xampp Location

taskkill /f /im "xampp-control.exe"

REM Check WMIC is available
WMIC.EXE Alias /? >NUL 2>&1 || GOTO s_error

REM Use WMIC to retrieve date and time
FOR /F "skip=1 tokens=1-6" %%G IN ('WMIC Path Win32_LocalTime Get Day^,Hour^,Minute^,Month^,Second^,Year /Format:table') DO (
   IF "%%~L"=="" goto s_done
      SET _yyyy=%%L
      SET _mm=00%%J
      SET _dd=00%%G
      SET _hour=00%%H
      SET _minute=00%%I
      SET _second=00%%K
)
:s_done

REM Pad digits with leading zeros
      SET _mm=%_mm:~-2%
      SET _dd=%_dd:~-2%
      SET _hour=%_hour:~-2%
      SET _minute=%_minute:~-2%
      SET _second=%_second:~-2%

REM create file name by date & time
SET filename=Jam_%_hour%_%_minute%_%_second%_Tanggal_%_dd%_%_mm%_%_yyyy%

REM create backup mysql data folder
SET backupFolder=%xamppLocation%\mysql\data_old
if not EXIST %backupFolder% (MKDIR %backupFolder%)

REM create log folder
SET myLog=%xamppLocation%\mysql\data_old\log
if not EXIST %myLog% (MKDIR %myLog%)

SET backupFile=%xamppLocation%\mysql\data_old\%filename%
if not EXIST %backupFile% (MKDIR %backupFile%)

REM log information
if %ERRORLEVEL% neq 0 (
    (echo JAM=%TIME% # TANGGAL=%DATE% # Mysql Gagal Diperbaiki) >> "%backupFolder%\log\mysql_backup_log.txt"
) else (echo JAM=%TIME% # TANGGAL=%DATE% # Mysql Berhasil Diperbaiki) >> "%backupFolder%\log\mysql_backup_log.txt"

@REM Saving mysql old data for safety
xcopy /Y /S "%xamppLocation%\mysql\data" "%xamppLocation%\mysql\data_old\%filename%"

@REM Rename file ibdata in folder backup
REN "%xamppLocation%\mysql\backup\ibdata1" "ibdata1_backup"

@RD /S /Q "%xamppLocation%\mysql\data\mysql"
@RD /S /Q "%xamppLocation%\mysql\data\performance_schema"
@RD /S /Q "%xamppLocation%\mysql\data\test"
@RD /S /Q "%xamppLocation%\mysql\data\phpmyadmin"

@REM Delete all files in folder, except one file and all folder
FOR %%a IN ("%xamppLocation%\mysql\data\*") DO IF /i NOT "%%~nxa"=="ibdata1" DEL "%%a"

@REM copy all files and folders in folder to another folder
xcopy /Y /S "%xamppLocation%\mysql\backup" "%xamppLocation%\mysql\data"

DEL "%xamppLocation%\mysql\data\ibdata1_backup"
REN "%xamppLocation%\mysql\backup\ibdata1_backup" "ibdata1"

EXIT