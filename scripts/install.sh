#!/bin/sh
# Installation script for POSIX systems (macOS/Linux)
# Copyright (c) 2026 live-by-unix
# BSD 3-Clause License

set -eu

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
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Installation directories
if [ "${1:-}" = "--system" ]; then
    INSTALL_DIR="/usr/local/bin"
    info "Performing system-wide installation"
else
    INSTALL_DIR="$HOME/bin"
    info "Performing user-local installation"
fi

# Create installation directory if needed
if [ ! -d "$INSTALL_DIR" ]; then
    info "Creating installation directory: $INSTALL_DIR"
    mkdir -p "$INSTALL_DIR" || {
        error "Failed to create installation directory"
        error "You may need to run with sudo for system-wide installation"
        exit 1
    }
fi

# Check write permissions
if [ ! -w "$INSTALL_DIR" ]; then
    error "No write permission for: $INSTALL_DIR"
    error "You may need to run with sudo for system-wide installation"
    exit 1
fi

# Platform-specific setup
PLATFORM="$(detect_platform)"

if [ "$PLATFORM" = "macos" ]; then
    # Build macOS helper
    info "Building macOS native helper..."
    cd "$PROJECT_DIR/src"
    if [ -f "build-macos.sh" ]; then
        ./build-macos.sh || {
            error "Failed to build macOS helper"
            exit 1
        }
    else
        error "build-macos.sh not found"
        exit 1
    fi
    cd "$PROJECT_DIR"

    # Install macOS helper
    if [ -f "$PROJECT_DIR/srm-macos" ]; then
        info "Installing srm-macos to $INSTALL_DIR"
        cp "$PROJECT_DIR/srm-macos" "$INSTALL_DIR/"
        chmod +x "$INSTALL_DIR/srm-macos"
    else
        error "srm-macos not found after build"
        exit 1
    fi
elif [ "$PLATFORM" = "linux" ]; then
    info "Linux does not require a native helper"
    info "Using pure shell implementation"
else
    warning "Unknown platform: $PLATFORM"
    warning "Proceeding with shell-only installation"
fi

# Install shell scripts
info "Installing srm to $INSTALL_DIR"
cp "$PROJECT_DIR/srm" "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/srm"

info "Installing srmi to $INSTALL_DIR"
cp "$PROJECT_DIR/srmi" "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/srmi"

# Verify installation
if [ -x "$INSTALL_DIR/srm" ] && [ -x "$INSTALL_DIR/srmi" ]; then
    success "Installation completed successfully"
    info ""
    info "Installed files:"
    info "  $INSTALL_DIR/srm"
    info "  $INSTALL_DIR/srmi"
    if [ "$PLATFORM" = "macos" ]; then
        info "  $INSTALL_DIR/srm-macos"
    fi
    info ""
    info "To use srm, ensure $INSTALL_DIR is in your PATH"
    info ""
    info "Try:"
    info "  srmi --version"
    info "  srmi --help"
else
    error "Installation verification failed"
    exit 1
fi
