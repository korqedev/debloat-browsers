@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION
TITLE Cache Cleaner Utility

:: ============================================================
::  Cache Cleaner Utility
::  Clears temp files, browser caches, and Java cache
:: ============================================================

:: Check for Administrator privileges
NET SESSION >NUL 2>&1
IF %ERRORLEVEL% NEQ 0 (
    ECHO [ERROR] This script must be run as Administrator.
    ECHO Right-click the file and select "Run as administrator".
    PAUSE
    EXIT /B 1
)

:: ── Default all options ON (1=yes, 0=no) ────────────────────
SET OPT_WINTEMP=1
SET OPT_JAVA=1
SET OPT_IE=1
SET OPT_CHROME=1
SET OPT_FIREFOX=1
SET OPT_EDGE=1

:MENU
CLS
ECHO.
ECHO  ==========================================
ECHO   Cache Cleaner Utility - Select Options
ECHO  ==========================================
ECHO.
CALL :ShowOption "1" "Windows Temp Folders" %OPT_WINTEMP%
CALL :ShowOption "2" "Java Cache"           %OPT_JAVA%
CALL :ShowOption "3" "Internet Explorer"    %OPT_IE%
CALL :ShowOption "4" "Google Chrome"        %OPT_CHROME%
CALL :ShowOption "5" "Mozilla Firefox"      %OPT_FIREFOX%
CALL :ShowOption "6" "Microsoft Edge"       %OPT_EDGE%
ECHO.
ECHO   [C] Clean selected   [A] Select All   [N] Deselect All   [Q] Quit
ECHO.
SET /P CHOICE="  Enter option: "

IF /I "%CHOICE%"=="1" CALL :Toggle OPT_WINTEMP  & GOTO :MENU
IF /I "%CHOICE%"=="2" CALL :Toggle OPT_JAVA     & GOTO :MENU
IF /I "%CHOICE%"=="3" CALL :Toggle OPT_IE       & GOTO :MENU
IF /I "%CHOICE%"=="4" CALL :Toggle OPT_CHROME   & GOTO :MENU
IF /I "%CHOICE%"=="5" CALL :Toggle OPT_FIREFOX  & GOTO :MENU
IF /I "%CHOICE%"=="6" CALL :Toggle OPT_EDGE     & GOTO :MENU
IF /I "%CHOICE%"=="A" CALL :SelectAll           & GOTO :MENU
IF /I "%CHOICE%"=="N" CALL :DeselectAll         & GOTO :MENU
IF /I "%CHOICE%"=="C" GOTO :CLEAN
IF /I "%CHOICE%"=="Q" EXIT /B 0
GOTO :MENU


:CLEAN
CLS
SET CLEANED=0
SET SKIPPED=0

ECHO.
ECHO  ==========================================
ECHO   Cleaning in progress...
ECHO  ==========================================
ECHO.

IF "%OPT_WINTEMP%"=="1" (
    CALL :CleanFolder "%TEMP%"                "User Temp"
    CALL :CleanFolder "%TMP%"                 "TMP"
    CALL :CleanFolder "%ALLUSERSPROFILE%\TEMP" "All Users Temp"
    CALL :CleanFolder "%SystemRoot%\TEMP"     "System Temp"
)

IF "%OPT_JAVA%"=="1" (
    SET "JAVA_CACHE=%USERPROFILE%\AppData\LocalLow\Sun\Java\Deployment\cache"
    IF EXIST "!JAVA_CACHE!" (
        ECHO [....] Clearing Java Cache...
        ERASE "!JAVA_CACHE!\*.*" /F /S /Q >NUL 2>&1
        FOR /D %%i IN ("!JAVA_CACHE!\*") DO RMDIR /S /Q "%%i" >NUL 2>&1
        IF DEFINED JAVA_HOME (
            "%JAVA_HOME%\bin\javaws.exe" -clearcache -uninstall >NUL 2>&1
        )
        ECHO [ OK ] Java Cache cleared.
        SET /A CLEANED+=1
    ) ELSE (
        ECHO [SKIP] Java Cache not found.
        SET /A SKIPPED+=1
    )
)

IF "%OPT_IE%"=="1" (
    ECHO [....] Clearing Internet Explorer Cache...
    RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 255 >NUL 2>&1
    CALL :CleanFolder "%LOCALAPPDATA%\Microsoft\Windows\Tempor~1" "IE Temp Files"
)

IF "%OPT_CHROME%"=="1"  CALL :CleanFolder "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache"  "Google Chrome"
IF "%OPT_FIREFOX%"=="1" CALL :CleanFolder "%LOCALAPPDATA%\Mozilla\Firefox\Profiles"               "Mozilla Firefox"
IF "%OPT_EDGE%"=="1"    CALL :CleanFolder "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" "Microsoft Edge"

ECHO.
ECHO  ==========================================
ECHO   Done!  Cleaned: %CLEANED%  ^|  Skipped: %SKIPPED%
ECHO  ==========================================
ECHO.
PAUSE
EXIT /B 0


:: ============================================================
::  FUNCTION: ShowOption  "key" "label" state
:: ============================================================
:ShowOption
SET "_KEY=%~1"
SET "_LBL=%~2"
SET "_STATE=%~3"
IF "%_STATE%"=="1" (
    ECHO   [*] %_KEY%. %_LBL%
) ELSE (
    ECHO   [ ] %_KEY%. %_LBL%
)
GOTO :EOF


:: ============================================================
::  FUNCTION: Toggle  VARNAME
:: ============================================================
:Toggle
IF "!%~1!"=="1" (SET "%~1=0") ELSE (SET "%~1=1")
GOTO :EOF


:: ============================================================
::  FUNCTION: SelectAll / DeselectAll
:: ============================================================
:SelectAll
SET OPT_WINTEMP=1
SET OPT_JAVA=1
SET OPT_IE=1
SET OPT_CHROME=1
SET OPT_FIREFOX=1
SET OPT_EDGE=1
GOTO :EOF

:DeselectAll
SET OPT_WINTEMP=0
SET OPT_JAVA=0
SET OPT_IE=0
SET OPT_CHROME=0
SET OPT_FIREFOX=0
SET OPT_EDGE=0
GOTO :EOF


:: ============================================================
::  FUNCTION: CleanFolder  "path" "label"
:: ============================================================
:CleanFolder
SET "TARGET=%~1"
SET "LABEL=%~2"
IF NOT EXIST "%TARGET%" (
    ECHO [SKIP] %LABEL% not found.
    SET /A SKIPPED+=1
    GOTO :EOF
)
ECHO [....] Clearing %LABEL%...
ERASE "%TARGET%\*.*" /F /S /Q >NUL 2>&1
FOR /D %%i IN ("%TARGET%\*") DO RMDIR /S /Q "%%i" >NUL 2>&1
ECHO [ OK ] %LABEL% cleared.
SET /A CLEANED+=1
GOTO :EOF
