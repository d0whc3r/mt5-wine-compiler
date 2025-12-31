#!/bin/bash
set -e

# MT5 Project Build Script
# This script demonstrates how to build a complex MT5 project with dependencies

echo "Starting MT5 project build..."

# 1. Copy project sources to Wine environment
echo "Copying project sources..."
cp -r /home/wine/project/Experts /home/wine/.mt5/drive_c/mt5/
cp -r /home/wine/project/Include /home/wine/.mt5/drive_c/mt5/

# 2. Copy library dependencies (if you have external libraries)
echo "Copying library dependencies..."
if [ -d "/home/wine/project/lib" ]; then
    mkdir -p /home/wine/.mt5/drive_c/mt5/Include/External
    cp -r /home/wine/project/lib/* /home/wine/.mt5/drive_c/mt5/Include/External/
fi

# 3. Compile all .mq5 files
echo "Compiling .mq5 files..."
find "/home/wine/.mt5/drive_c/mt5/Experts" -name "*.mq5" | while read source_file; do
    basename_file=$(basename "$source_file")
    echo "  Compiling $basename_file..."
    
    # Use the entrypoint script for each file
    /home/wine/entrypoint.sh "$source_file" || {
        echo "  ❌ Failed to compile $basename_file"
        exit 1
    }
done

# 4. Copy compiled files to artifacts directory
echo "Copying artifacts..."
mkdir -p /home/wine/artifacts
cp /home/wine/.mt5/drive_c/mt5/Experts/*.ex5 /home/wine/artifacts/ 2>/dev/null || true

echo "✅ Build completed successfully!"
echo "Artifacts available in /home/wine/artifacts/"

