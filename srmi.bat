@echo off
REM srmi.bat - Safe RM Information for Windows
REM Windows batch-script information command
REM Copyright (c) 2026 live-by-unix
REM BSD 3-Clause License

setlocal enabledelayedexpansion

set "SRM_VERSION=1.0.0"

REM Parse argument
if "%~1"=="" goto :help
if "%~1"=="--help" goto :help
if "%~1"=="--version" goto :version
if "%~1"=="--usage" goto :usage
if "%~1"=="--license" goto :license
goto :invalid

:help
echo srm ^(Safe RM^) - Information
echo.
echo NAME
echo     srmi - Display information about srm ^(Safe RM^)
echo.
echo SYNOPSIS
echo     srmi [OPTION]
echo.
echo DESCRIPTION
echo     srm is a cross-platform alternative to rm that moves files and directories
echo     to the native Trash or Recycle Bin instead of permanently deleting them.
echo.
echo     srmi displays information about srm, including help, version, usage,
echo     license, and platform compatibility.
echo.
echo OPTIONS
echo     --help      Display this help message
echo     --version   Display version information
echo     --usage     Display brief usage summary
echo     --license   Display license information
echo.
echo PLATFORMS
echo     macOS       Uses NSFileManager API for native Finder Trash integration
echo     Linux       Implements FreeDesktop.org Trash specification
echo     Windows     Uses Windows Shell IFileOperation API ^(srm.bat^)
echo.
echo ENTRY POINTS
echo     POSIX:      srm ^(removal^), srmi ^(information^)
echo     Windows:    srm.bat ^(removal^), srmi.bat ^(information^)
echo.
echo IMPORTANT NOTE
echo     srm --help does NOT display help information. The removal commands treat
echo     --help and --version as ordinary filenames. Use srmi --help for documentation.
echo.
echo EXAMPLES
echo     srmi --help
echo     srmi --version
echo     srmi --usage
echo     srmi --license
echo.
echo INSTALLATION
echo     macOS/Linux:  ./scripts/install.sh
echo     Windows:      scripts\install.bat
echo.
echo DOCUMENTATION
echo     README.md        Overview and quick start
echo     INSTALL.md       Installation instructions
echo     USAGE.md         Detailed usage guide
echo     WINDOWS.md       Windows-specific documentation
echo     COMPATIBILITY.md Platform compatibility details
echo     docs\            Additional platform-specific documentation
echo.
echo REPOSITORY
echo     https://github.com/live-by-unix/srm
echo.
echo WEBSITE
echo     https://live-by-unix.github.io/srm
echo.
echo AUTHOR
echo     live-by-unix
echo.
echo COPYRIGHT
echo     Copyright ^(c^) 2026 live-by-unix
echo     BSD 3-Clause License
exit /b 0

:version
echo srm ^(Safe RM^) version %SRM_VERSION%
echo Copyright ^(c^) 2026 live-by-unix
echo BSD 3-Clause License
echo.
echo Platform: Windows
exit /b 0

:usage
echo Usage: srm.bat [OPTION]... FILE...
echo Move files to the native Recycle Bin instead of permanently deleting them.
echo.
echo Common options:
echo   -f, --force         ignore nonexistent files and arguments
echo   -r, -R, --recursive  remove directories and their contents recursively
echo   -v, --verbose       explain what is being done
echo   --                  end of options
echo.
echo For information: srmi.bat --help
echo For version:     srmi.bat --version
exit /b 0

:license
echo BSD 3-Clause License
echo.
echo Copyright ^(c^) 2026 live-by-unix
echo.
echo Redistribution and use in source and binary forms, with or without
echo modification, are permitted provided that the following conditions are met:
echo.
echo 1. Redistributions of source code must retain the above copyright notice, this
echo    list of conditions and the following disclaimer.
echo.
echo 2. Redistributions in binary form must reproduce the above copyright notice,
echo    this list of conditions and the following disclaimer in the documentation
echo    and/or other materials provided with the distribution.
echo.
echo 3. Neither the name of the copyright holder nor the names of its
echo    contributors may be used to endorse or promote products derived from
echo    this software without specific prior written permission.
echo.
echo THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
echo AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
echo IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
echo DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
echo FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
echo DAMAGES ^(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
echo SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION^) HOWEVER
echo CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
echo OR TORT ^(INCLUDING NEGLIGENCE OR OTHERWISE^) ARISING IN ANY WAY OUT OF THE USE
echo OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
exit /b 0

:invalid
echo srmi: invalid option '%~1' >&2
echo Try 'srmi --help' for more information. >&2
exit /b 2
