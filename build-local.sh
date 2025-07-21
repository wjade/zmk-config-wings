#!/bin/bash

# Local ZMK build script
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}ZMK Local Build Script${NC}"
echo "======================"

# Check if west is installed
if ! command -v west &> /dev/null; then
    echo -e "${RED}Error: 'west' is not installed.${NC}"
    echo "Please install west first: pip3 install west"
    exit 1
fi

# Initialize workspace if needed
if [ ! -d "zmk" ]; then
    echo -e "${YELLOW}Initializing ZMK workspace...${NC}"
    west init -l config
    west update
    west zephyr-export
fi

# Build directory
BUILD_DIR="build"

# Function to build firmware
build_firmware() {
    local BOARD=$1
    local SHIELD=$2
    local EXTRA_ARGS=$3
    local OUTPUT_NAME=$4
    
    echo -e "${YELLOW}Building $SHIELD for $BOARD...${NC}"
    
    if [ -n "$EXTRA_ARGS" ]; then
        west build -s zmk/app -d "$BUILD_DIR/$OUTPUT_NAME" -b "$BOARD" -- \
            -DSHIELD="$SHIELD" \
            -DZMK_CONFIG="${PWD}/config" \
            $EXTRA_ARGS
    else
        west build -s zmk/app -d "$BUILD_DIR/$OUTPUT_NAME" -b "$BOARD" -- \
            -DSHIELD="$SHIELD" \
            -DZMK_CONFIG="${PWD}/config"
    fi
    
    # Copy the output file
    if [ -f "$BUILD_DIR/$OUTPUT_NAME/zephyr/zmk.uf2" ]; then
        cp "$BUILD_DIR/$OUTPUT_NAME/zephyr/zmk.uf2" "$OUTPUT_NAME.uf2"
        echo -e "${GREEN}✓ Built $OUTPUT_NAME.uf2${NC}"
    else
        echo -e "${RED}✗ Failed to build $OUTPUT_NAME${NC}"
        return 1
    fi
}

# Clean build directory
if [ "$1" == "clean" ]; then
    echo -e "${YELLOW}Cleaning build directory...${NC}"
    rm -rf build
    rm -f *.uf2
    echo -e "${GREEN}Clean complete!${NC}"
    exit 0
fi

# Build all configurations
echo -e "${YELLOW}Starting builds...${NC}"
echo

# Regular builds
build_firmware "seeeduino_xiao_ble" "wings_left" "" "wings_left"
build_firmware "seeeduino_xiao_ble" "wings_right" "" "wings_right"

# Studio builds
build_firmware "seeeduino_xiao_ble" "wings_left" \
    "-DCONFIG_ZMK_STUDIO=y -DZMK_STUDIO_RPC=uart" \
    "wings_left_studio"

build_firmware "seeeduino_xiao_ble" "wings_right" \
    "-DCONFIG_ZMK_STUDIO=y -DZMK_STUDIO_RPC=uart" \
    "wings_right_studio"

echo
echo -e "${GREEN}Build complete! Firmware files:${NC}"
ls -la *.uf2 2>/dev/null || echo -e "${RED}No firmware files found${NC}"