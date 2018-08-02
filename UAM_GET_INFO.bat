@echo off
echo ***********UAM***********
echo .

set oracle_sid=orcl

set uamdir=%~d0%~p0
pushd %uamdir%

set spooldir=GENER_UAM_OUTPUT

if not exist %spooldir% (
	echo creating spool dir: %spooldir%
	echo.
	mkdir %spooldir%
)

if /I "%1"=="" goto :interactive
goto :not_interactive

:interactive

set /p oracle_sid="Oracle SID (default='%oracle_sid%'):"
set /p schema="Destination Schema:"
@echo off
set "psCommand=powershell -Command "$pword = read-host 'Enter Password' -AsSecureString ; ^
    $BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pword); ^
        [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)""
for /f "usebackq delims=" %%p in (`%psCommand%`) do set dbpwd=%%p


goto :got_parameters


:not_interactive
set do_pause=N

set connectionstring=%~1
for /F "tokens=1,2 delims=/ " %%a in ("%connectionstring%") do (
   set schema=%%a
   set tmp1=%%b
)

for /F "tokens=1,2 delims=@ " %%a in ("%tmp1%") do (
   set dbpwd=%%a
   set oracle_sid=%%b
)


if %schema%==N (
set /p schema="Enter Destination Schema:"
) else (
set schema=%schema:~1%
)

echo.
echo Target schema is %schema%

if %dbpwd%==N (
goto :set_pwd
) else (
set dbpwd=%dbpwd:~1%
)

goto :skip_pwd

:set_pwd 

set "psCommand=powershell -Command "$pword = read-host 'Enter Password' -AsSecureString ; ^
    $BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pword); ^
        [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)""
for /f "usebackq delims=" %%p in (`%psCommand%`) do set dbpwd=%%p

:skip_pwd

if %oracle_sid%==N (
set /p oracle_sid="Enter Oracle Database:"
) else (
set oracle_sid=%oracle_sid:~1%
)

echo.
echo Target Database is %oracle_sid%

:got_parameters

set LOGFILE="UAM_Script_%schema%.log"
set userConnStr=%schema%/%dbpwd%@%oracle_sid%
set userConn=%schema%@%oracle_sid%

echo.
echo *****************************************************
echo Target schema/DB is %userConn%
echo *****************************************************
echo.

echo.
echo **************Retriving UAM info from Schema ********************************
echo.

pushd %spooldir%
del /Q *.*
call %uamdir%"UAM_gen.bat"

echo.
echo ************** Done!******************************

start /min notepad.exe %LOGFILE%

findstr /I /c:"ora-" %LOGFILE% && (
set errFound=1
) || (
set errFound=0
)

set ERRORLEVEL=0
if %errFound%==1 (
echo There is ORA- error in log file
set ERRORLEVEL=1
)


popd

exit /b %ERRORLEVEL%