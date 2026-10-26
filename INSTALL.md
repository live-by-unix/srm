# Installation Guide

This guide covers installation procedures for macOS, Linux, and Windows.

## Table of Contents

- [macOS](#macos)
- [Linux](#linux)
- [Windows](#windows)
- [Uninstallation](#uninstallation)
- [Troubleshooting](#troubleshooting)

## macOS

### Prerequisites

- macOS 10.8 or later
- Xcode Command Line Tools (for building the native helper)
- A terminal (Terminal.app, iTerm2, etc.)

### User-Local Installation (Recommended)

This installation requires no administrator privileges and installs to your home directory.

```bash
# Clone the repository
git clone https://github.com/live-by-unix/srm.git
cd srm

# Run the installation script
./scripts/install.sh
```

The installation script will:
1. Build the macOS native helper (`srm-macos`)
2. Copy `srm` and `srmi` to `~/bin`
3. Copy `srm-macos` to `~/bin`
4. Set executable permissions

### Adding to PATH

If `~/bin` is not in your PATH, add it to your shell configuration:

**For zsh (default on macOS):**
```bash
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**For bash:**
```bash
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bash_profile
source ~/.bash_profile
```

### System-Wide Installation (Optional)

Requires administrator privileges:

```bash
sudo ./scripts/install.sh --system
```

This installs to `/usr/local/bin` and makes srm available to all users.

### Verification

```bash
# Check installation
which srm
which srmi

# Display version
srmi --version

# Test with a temporary file
echo "test" > /tmp/testfile.txt
srm /tmp/testfile.txt
```

## Linux

### Prerequisites

- A Linux distribution with FreeDesktop.org Trash support
- A POSIX-compliant shell (bash, zsh, dash, etc.)
- No native helper compilation required

### User-Local Installation (Recommended)

```bash
# Clone the repository
git clone https://github.com/live-by-unix/srm.git
cd srm

# Run the installation script
./scripts/install.sh
```

The installation script will:
1. Copy `srm` and `srmi` to `~/bin`
2. Set executable permissions
3. Verify Trash directory structure

### Adding to PATH

If `~/bin` is not in your PATH:

**For bash:**
```bash
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**For zsh:**
```bash
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### System-Wide Installation (Optional)

Requires administrator privileges:

```bash
sudo ./scripts/install.sh --system
```

This installs to `/usr/local/bin`.

### Trash Directory

srm uses the FreeDesktop.org Trash specification:
- Default location: `~/.local/share/Trash`
- Respects `$XDG_DATA_HOME` if set
- Creates Trash structure automatically

### Verification

```bash
# Check installation
which srm
which srmi

# Display version
srmi --version

# Check Trash directory
ls -la ~/.local/share/Trash
```

## Windows

### Prerequisites

- Windows 7 or later
- Visual Studio 2015 or later (or Build Tools for Visual Studio)
- Administrator privileges (optional, for system-wide installation)

### Building the Native Helper

The Windows implementation requires a compiled native helper (`srm-windows.exe`).

1. Install Visual Studio or Build Tools for Visual Studio:
   - Download from: https://visualstudio.microsoft.com/downloads/
   - Select "Desktop development with C++" workload

2. Open a Developer Command Prompt:
   - Start Menu → Visual Studio → Developer Command Prompt for VS

3. Build the helper:
   ```cmd
   cd path\to\srm
   cd src
   build-windows.bat
   ```

The build script compiles `srm-windows.cpp` using the Visual Studio compiler.

### User-Local Installation (Recommended)

```cmd
REM Clone the repository
git clone https://github.com/live-by-unix/srm.git
cd srm

REM Run the installation script
scripts\install.bat
```

The installation script will:
1. Check for `srm-windows.exe`
2. Copy `srm.bat` and `srmi.bat` to `%USERPROFILE%\bin`
3. Copy `srm-windows.exe` to `%USERPROFILE%\bin`
4. Add `%USERPROFILE%\bin` to PATH (optional)

### Adding to PATH

The installation script can add `%USERPROFILE%\bin` to your PATH. Manual configuration:

1. Press Win key, search for "Environment Variables"
2. Click "Edit the system environment variables"
3. Click "Environment Variables"
4. Under "User variables", find "Path" and click "Edit"
5. Click "New" and add: `%USERPROFILE%\bin`
6. Click OK on all dialogs

### System-Wide Installation (Optional)

Requires administrator privileges:

```cmd
scripts\install.bat --system
```

This installs to `C:\Program Files\srm` and adds to system PATH.

### Supported Shells

- **Command Prompt (cmd.exe)**: Full support
- **PowerShell**: Full support
- **Git Bash / MSYS2**: Use the POSIX `srm` script instead

### Verification

```cmd
REM Check installation
where srm.bat
where srmi.bat

REM Display version
srmi.bat --version

REM Test with a temporary file
echo test > %TEMP%\testfile.txt
srm.bat %TEMP%\testfile.txt
```

## Uninstallation

### macOS

```bash
# User-local uninstallation
./scripts/uninstall.sh

# System-wide uninstallation
sudo ./scripts/uninstall.sh --system
```

### Linux

```bash
# User-local uninstallation
./scripts/uninstall.sh

# System-wide uninstallation
sudo ./scripts/uninstall.sh --system
```

### Windows

```cmd
REM User-local uninstallation
scripts\uninstall.bat

REM System-wide uninstallation
scripts\uninstall.bat --system
```

**Important:** Uninstallation removes only the srm files. It does not:
- Empty your Trash
- Delete Trash contents
- Remove any files you've moved to Trash

## Troubleshooting

### macOS

**Problem:** `srm-macos: command not found`

**Solution:** Ensure the macOS helper was built and installed:
```bash
cd src
./build-macos.sh
cd ..
./scripts/install.sh
```

**Problem:** "Trash directory not found"

**Solution:** This is unusual on macOS. Check that `~/.Trash` exists:
```bash
ls -la ~/.Trash
```

### Linux

**Problem:** "failed to create Trash directory"

**Solution:** Check permissions on `~/.local/share`:
```bash
mkdir -p ~/.local/share/Trash/files
mkdir -p ~/.local/share/Trash/info
```

**Problem:** Trash not appearing in desktop environment

**Solution:** Ensure your desktop environment supports FreeDesktop Trash specification. GNOME, KDE, XFCE, and most modern environments do.

### Windows

**Problem:** "Windows helper not found"

**Solution:** Build the native helper:
```cmd
cd src
build-windows.bat
```

**Problem:** Build fails with "cl.exe not found"

**Solution:** Install Visual Studio Build Tools and run from a Developer Command Prompt.

**Problem:** Files not appearing in Recycle Bin

**Solution:** Ensure:
1. The helper was built successfully
2. You're running on a supported Windows version (7+)
3. The drive has a Recycle Bin (subst drives may not)

**Problem:** "operation was aborted"

**Solution:** This can occur if:
- The file is on a network drive without Recycle Bin support
- Insufficient permissions
- File is locked by another process

### General

**Problem:** "permission denied" when running srm

**Solution:** Ensure the scripts are executable:
```bash
chmod +x srm srmi
```

**Problem:** Command not found after installation

**Solution:** Verify PATH configuration:
```bash
# macOS/Linux
echo $PATH | grep bin

# Windows
echo %PATH%
```

## Next Steps

After installation, see:
- [USAGE.md](USAGE.md) for detailed usage instructions
- [WINDOWS.md](WINDOWS.md) for Windows-specific information
- [docs/](docs/) for platform-specific documentation
