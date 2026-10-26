#!/bin/sh
# Uninstallation script for POSIX systems (macOS/Linux)
# Copyright (c) 2026 live-by-unix
# BSD 3-Clause License

set -eu

# Colors for output
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    NC=''
fi

# Print error
error() {
    printf "${RED}Error:${NC} %s\n" "$*" >&2
}

# Print success
success() {
    printf "${GREEN}Success:${NC} %s\n" "$*"
}

# Print warning
warning() {
    printf "${YELLOW}Warning:${NC} %s\n" "$*"
}

# Print info
info() {
    printf "Info: %s\n" "$*"
}

# Script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Installation directories
if [ "${1:-}" = "--system" ]; then
    INSTALL_DIR="/usr/local/bin"
    info "Performing system-wide uninstallation"
else
    INSTALL_DIR="$HOME/bin"
    info "Performing user-local uninstallation"
fi

# Check if installation directory exists
if [ ! -d "$INSTALL_DIR" ]; then
    warning "Installation directory does not exist: $INSTALL_DIR"
    info "Nothing to uninstall"
    exit 0
fi

# Detect platform
detect_platform() {
    case "$(uname -s)" in
        Darwin)
            echo "macos"
            ;;
        Linux)
            echo "linux"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

PLATFORM="$(detect_platform)"

# Remove files
removed_files=0

if [ -f "$INSTALL_DIR/srm" ]; then
    info "Removing $INSTALL_DIR/srm"
    rm -f "$INSTALL_DIR/srm"
    removed_files=$((removed_files + 1))
fi

if [ -f "$INSTALL_DIR/srmi" ]; then
    info "Removing $INSTALL_DIR/srmi"
    rm -f "$INSTALL_DIR/srmi"
    removed_files=$((removed_files + 1))
fi

if [ "$PLATFORM" = "macos" ] && [ -f "$INSTALL_DIR/srm-macos" ]; then
    info "Removing $INSTALL_DIR/srm-macos"
    rm -f "$INSTALL_DIR/srm-macos"
    removed_files=$((removed_files + 1))
fi

if [ $removed_files -eq 0 ]; then
    warning "No srm files found in $INSTALL_DIR"
    info "Nothing to uninstall"
    exit 0
fi

success "Uninstallation completed successfully"
info ""
info "Removed $removed_files file(s) from $INSTALL_DIR"
info ""
info "Important: This uninstallation does NOT empty your Trash"
info "Any files you moved to Trash remain in Trash until you empty it"

# Check if installation directory is empty
if [ -z "$(ls -A "$INSTALL_DIR" 2>/dev/null)" ]; then
    info "Installation directory is empty: $INSTALL_DIR"
    info "You may remove it if desired:"
    info "  rmdir $INSTALL_DIR"
fi
