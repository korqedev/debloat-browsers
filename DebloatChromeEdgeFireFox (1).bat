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

:: Counters
SET CLEANED=0
SET SKIPPED=0

ECHO.
ECHO  ==========================================
ECHO   Cache Cleaner Utility
ECHO  ==========================================
ECHO.

:: ── Windows Temp Folders ─────────────────────────────────────

CALL :CleanFolder "%TEMP%"              "User Temp"
CALL :CleanFolder "%TMP%"               "TMP"
CALL :CleanFolder "%ALLUSERSPROFILE%\TEMP" "All Users Temp"
CALL :CleanFolder "%SystemRoot%\TEMP"   "System Temp"

:: ── Java Cache ───────────────────────────────────────────────

SET "JAVA_CACHE=%USERPROFILE%\AppData\LocalLow\Sun\Java\Deployment\cache"
IF EXIST "%JAVA_CACHE%" (
    ECHO [....] Clearing Java Cache...
    ERASE "%JAVA_CACHE%\*.*" /F /S /Q >NUL 2>&1
    FOR /D %%i IN ("%JAVA_CACHE%\*") DO RMDIR /S /Q "%%i" >NUL 2>&1
    IF DEFINED JAVA_HOME (
        "%JAVA_HOME%\bin\javaws.exe" -clearcache -uninstall >NUL 2>&1
    )
    ECHO [ OK ] Java Cache cleared.
    SET /A CLEANED+=1
) ELSE (
    ECHO [SKIP] Java Cache not found.
    SET /A SKIPPED+=1
)

:: ── Internet Explorer ────────────────────────────────────────

ECHO [....] Clearing Internet Explorer Cache...
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 255 >NUL 2>&1
CALL :CleanFolder "%LOCALAPPDATA%\Microsoft\Windows\Tempor~1" "IE Temp Files"

:: ── Browser Caches ───────────────────────────────────────────

CALL :CleanFolder "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache"  "Google Chrome"
CALL :CleanFolder "%LOCALAPPDATA%\Mozilla\Firefox\Profiles"               "Mozilla Firefox"
CALL :CleanFolder "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" "Microsoft Edge"

:: ── Summary ──────────────────────────────────────────────────

ECHO.
ECHO  ==========================================
ECHO   Complete! Cleaned: %CLEANED%  Skipped: %SKIPPED%
ECHO  ==========================================
ECHO.
PAUSE
EXIT /B 0


:: ============================================================
::  FUNCTION: CleanFolder
::  Usage: CALL :CleanFolder "path" "label"
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
