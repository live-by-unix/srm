#!/bin/sh
# Build script for macOS native helper
# Copyright (c) 2026 live-by-unix
# BSD 3-Clause License

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$SCRIPT_DIR"

echo "Building srm-macos helper..."

# Compile the Objective-C helper
clang -framework Foundation -o "$PROJECT_DIR/srm-macos" srm-macos.m

if [ $? -eq 0 ]; then
    echo "Build successful: $PROJECT_DIR/srm-macos"
    chmod +x "$PROJECT_DIR/srm-macos"
else
    echo "Build failed"
    exit 1
fi
