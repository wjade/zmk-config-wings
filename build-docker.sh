#!/bin/bash

# Docker-based ZMK build script (mimics GitHub Actions)
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}ZMK Docker Build Script${NC}"
echo "======================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed.${NC}"
    echo "Please install Docker first: https://docs.docker.com/get-docker/"
    exit 1
fi

# Use the official ZMK Docker image
DOCKER_IMAGE="zmkfirmware/zmk-build-arm:stable"

echo -e "${YELLOW}Pulling ZMK Docker image...${NC}"
docker pull $DOCKER_IMAGE

# Function to build firmware
build_firmware() {
    local BOARD=$1
    local SHIELD=$2
    local EXTRA_CMAKE_ARGS=$3
    local OUTPUT_NAME=${4:-$SHIELD}
    
    echo -e "${YELLOW}Building $SHIELD for $BOARD...${NC}"
    
    docker run --rm \
        -v "$PWD:/workspace" \
        -v "$PWD/build:/build" \
        -w /workspace \
        $DOCKER_IMAGE \
        bash -c "
            # Clone ZMK and set up workspace
            git clone --depth 1 -b main https://github.com/zmkfirmware/zmk.git /tmp/zmk && \
            cd /tmp/zmk && \
            west init -l app && \
            west update && \
            # Build firmware
            west build -s app -d /build/$OUTPUT_NAME -b $BOARD -- \
            -DSHIELD=$SHIELD \
            -DZMK_CONFIG=/workspace/config \
            -DZMK_EXTRA_MODULES=/workspace \
            $EXTRA_CMAKE_ARGS && \
            # Copy output
            cp /build/$OUTPUT_NAME/zephyr/zmk.uf2 /build/$OUTPUT_NAME.uf2
        "
    
    if [ -f "build/$OUTPUT_NAME.uf2" ]; then
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
    echo -e "${GREEN}Clean complete!${NC}"
    exit 0
fi

# Create build directory
mkdir -p build

# Build all configurations
echo -e "${YELLOW}Starting builds...${NC}"
echo

# Regular builds
build_firmware "seeeduino_xiao_ble" "wings_left"
build_firmware "seeeduino_xiao_ble" "wings_right"

# Studio builds
echo -e "${YELLOW}Building Studio-enabled firmware...${NC}"
build_firmware "seeeduino_xiao_ble" "wings_left" \
    "-S studio-rpc-usb-uart" \
    "wings_left_with_studio"

build_firmware "seeeduino_xiao_ble" "wings_right" \
    "-S studio-rpc-usb-uart" \
    "wings_right_with_studio"

echo
echo -e "${GREEN}Build complete! Firmware files:${NC}"
ls -la build/*.uf2 2>/dev/null || echo -e "${RED}No firmware files found${NC}"