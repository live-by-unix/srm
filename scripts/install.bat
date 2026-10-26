@echo off
REM Installation script for Windows
REM Copyright (c) 2026 live-by-unix
REM BSD 3-Clause License

setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "PROJECT_DIR=%SCRIPT_DIR%.."

REM Determine installation directory
if "%~1"=="--system" (
    set "INSTALL_DIR=C:\Program Files\srm"
    echo Info: Performing system-wide installation
) else (
    set "INSTALL_DIR=%USERPROFILE%\bin"
    echo Info: Performing user-local installation
)

REM Check for native helper
set "HELPER=%PROJECT_DIR%\srm-windows.exe"
if not exist "%HELPER%" (
    echo Error: Windows helper not found: %HELPER%
    echo.
    echo Please build the native helper first:
    echo   cd src
    echo   build-windows.bat
    echo.
    exit /b 1
)

REM Create installation directory
if not exist "%INSTALL_DIR%" (
    echo Info: Creating installation directory: %INSTALL_DIR%
    mkdir "%INSTALL_DIR%"
    if errorlevel 1 (
        echo Error: Failed to create installation directory
        echo You may need to run as administrator for system-wide installation
        exit /b 1
    )
)

REM Install batch scripts
echo Info: Installing srm.bat to %INSTALL_DIR%
copy "%PROJECT_DIR%\srm.bat" "%INSTALL_DIR%\" >nul
if errorlevel 1 (
    echo Error: Failed to copy srm.bat
    exit /b 1
)

echo Info: Installing srmi.bat to %INSTALL_DIR%
copy "%PROJECT_DIR%\srmi.bat" "%INSTALL_DIR%\" >nul
if errorlevel 1 (
    echo Error: Failed to copy srmi.bat
    exit /b 1
)

REM Install native helper
echo Info: Installing srm-windows.exe to %INSTALL_DIR%
copy "%HELPER%" "%INSTALL_DIR%\" >nul
if errorlevel 1 (
    echo Error: Failed to copy srm-windows.exe
    exit /b 1
)

REM Verify installation
if exist "%INSTALL_DIR%\srm.bat" if exist "%INSTALL_DIR%\srmi.bat" if exist "%INSTALL_DIR%\srm-windows.exe" (
    echo Success: Installation completed successfully
    echo.
    echo Installed files:
    echo   %INSTALL_DIR%\srm.bat
    echo   %INSTALL_DIR%\srmi.bat
    echo   %INSTALL_DIR%\srm-windows.exe
    echo.
    echo To use srm, ensure %INSTALL_DIR% is in your PATH
    echo.
    echo Try:
    echo   srmi.bat --version
    echo   srmi.bat --help
) else (
    echo Error: Installation verification failed
    exit /b 1
)

endlocal
