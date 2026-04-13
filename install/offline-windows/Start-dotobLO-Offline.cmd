@echo off
setlocal

set SCRIPT_DIR=%~dp0
set INSTALLER=%SCRIPT_DIR%dotob-lo-installer-online.exe
set TAR=%SCRIPT_DIR%dotob-lo_core_1.0.tar

if not exist "%INSTALLER%" (
  echo Missing installer: %INSTALLER%
  exit /b 1
)

if not exist "%TAR%" (
  echo Missing offline tar: %TAR%
  exit /b 1
)

start "dotob.LO" /wait "%INSTALLER%"
exit /b %ERRORLEVEL%

