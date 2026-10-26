#!/bin/sh
# Build script for Linux (no native helper needed)
# The shell script implements FreeDesktop Trash spec directly
# Copyright (c) 2026 live-by-unix
# BSD 3-Clause License

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Linux does not require a native helper."
echo "The shell script implements the FreeDesktop.org Trash specification directly."
echo "No compilation needed."
