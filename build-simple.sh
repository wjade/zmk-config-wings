#!/bin/bash

# Simple build script using Docker
echo "Building wings_standalone firmware..."

# Clean previous builds
rm -rf build/wings_standalone

# Use the ZMK build container
docker run --rm \
    -v "${PWD}:/workspace" \
    -w /workspace \
    zmkfirmware/zmk-build-arm:3.5 \
    sh -c "
        # Initialize west workspace
        west init -l config
        west update
        
        # Build standalone firmware
        west build -p -s zmk/app -b seeeduino_xiao_ble -d build/wings_standalone -- \\
            -DSHIELD=wings_standalone \\
            -DZMK_CONFIG=/workspace/config
        
        echo 'Build complete!'
    "

# Copy the firmware to the root directory
if [ -f build/wings_standalone/zephyr/zmk.uf2 ]; then
    cp build/wings_standalone/zephyr/zmk.uf2 wings_standalone_test.uf2
    echo "Firmware copied to: wings_standalone_test.uf2"
    ls -la wings_standalone_test.uf2
else
    echo "Build failed - firmware file not found"
    exit 1
fi