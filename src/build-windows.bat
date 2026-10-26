@echo off
REM Build script for Windows native helper
REM Copyright (c) 2026 live-by-unix
REM BSD 3-Clause License

setlocal

set "SCRIPT_DIR=%~dp0"
set "PROJECT_DIR=%SCRIPT_DIR%.."

cd /d "%SCRIPT_DIR%"

echo Building srm-windows helper...

REM Compile the C++ helper using Visual Studio
REM This requires Visual Studio or Build Tools for Visual Studio
REM Install from: https://visualstudio.microsoft.com/downloads/

cl.exe /EHsc /O2 /Fe:"%PROJECT_DIR%\srm-windows.exe" srm-windows.cpp shell32.lib shlwapi.lib

if %ERRORLEVEL% EQU 0 (
    echo Build successful: %PROJECT_DIR%\srm-windows.exe
) else (
    echo Build failed
    echo Make sure Visual Studio or Build Tools for Visual Studio is installed
    echo and that you are running from a Developer Command Prompt
    exit /b 1
)

endlocal
