@echo off
REM srm.bat - Safe RM for Windows
REM Windows batch-script entry point for safe removal
REM Copyright (c) 2026 live-by-unix
REM BSD 3-Clause License

setlocal enabledelayedexpansion

REM Check for native helper
set "HELPER=%~dp0srm-windows.exe"
if not exist "%HELPER%" (
    echo srm: error: Windows helper not found: %HELPER% >&2
    echo srm: Please run the installation script to set up the complete system. >&2
    exit /b 1
)

REM Delegate to native helper with arguments
"%HELPER%" %*
