#!/bin/bash

# Build only the standalone firmware for testing

# Ensure Docker is available
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker first."
    exit 1
fi

echo "Building wings_standalone firmware..."

# Run Docker build for just the standalone configuration
docker run -it --rm \
    -v "${PWD}:/workspace" \
    -v "${PWD}/build:/build" \
    -w /workspace \
    ghcr.io/zmkfirmware/zmk-build-arm:3.5-branch-zephyr-3.5 \
    bash -c "
        west init -l /workspace/config
        west update
        west build -p -s zmk/app -b seeeduino_xiao_ble -d /build/wings_standalone -- -DSHIELD=wings_standalone -DZMK_CONFIG=/workspace/config
        cp /build/wings_standalone/zephyr/zmk.uf2 /workspace/wings_standalone_test.uf2
    "

echo "Build complete! Firmware file: wings_standalone_test.uf2"