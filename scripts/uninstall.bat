@echo off
REM Uninstallation script for Windows
REM Copyright (c) 2026 live-by-unix
REM BSD 3-Clause License

setlocal enabledelayedexpansion

REM Determine installation directory
if "%~1"=="--system" (
    set "INSTALL_DIR=C:\Program Files\srm"
    echo Info: Performing system-wide uninstallation
) else (
    set "INSTALL_DIR=%USERPROFILE%\bin"
    echo Info: Performing user-local uninstallation
)

REM Check if installation directory exists
if not exist "%INSTALL_DIR%" (
    echo Warning: Installation directory does not exist: %INSTALL_DIR%
    echo Info: Nothing to uninstall
    exit /b 0
)

REM Remove files
set removed_files=0

if exist "%INSTALL_DIR%\srm.bat" (
    echo Info: Removing %INSTALL_DIR%\srm.bat
    del "%INSTALL_DIR%\srm.bat"
    set /a removed_files+=1
)

if exist "%INSTALL_DIR%\srmi.bat" (
    echo Info: Removing %INSTALL_DIR%\srmi.bat
    del "%INSTALL_DIR%\srmi.bat"
    set /a removed_files+=1
)

if exist "%INSTALL_DIR%\srm-windows.exe" (
    echo Info: Removing %INSTALL_DIR%\srm-windows.exe
    del "%INSTALL_DIR%\srm-windows.exe"
    set /a removed_files+=1
)

if %removed_files%==0 (
    echo Warning: No srm files found in %INSTALL_DIR%
    echo Info: Nothing to uninstall
    exit /b 0
)

echo Success: Uninstallation completed successfully
echo.
echo Removed %removed_files% file(s) from %INSTALL_DIR%
echo.
echo Important: This uninstallation does NOT empty your Recycle Bin
echo Any files you moved to Recycle Bin remain there until you empty it

endlocal
