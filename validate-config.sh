#!/bin/bash

# Configuration validation script
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}ZMK Configuration Validator${NC}"
echo "==========================="

ERRORS=0

# Function to check file exists
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} Found: $1"
    else
        echo -e "${RED}✗${NC} Missing: $1"
        ERRORS=$((ERRORS + 1))
    fi
}

# Function to check directory exists
check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} Found directory: $1"
    else
        echo -e "${RED}✗${NC} Missing directory: $1"
        ERRORS=$((ERRORS + 1))
    fi
}

echo -e "\n${YELLOW}Checking core configuration files...${NC}"
check_file "build.yaml"
check_file "config/west.yml"
check_file "zephyr/module.yml"

echo -e "\n${YELLOW}Checking shield files...${NC}"
check_dir "boards/shields/wings"
check_file "boards/shields/wings/Kconfig.shield"
check_file "boards/shields/wings/Kconfig.defconfig"
check_file "boards/shields/wings/wings.dtsi"
check_file "boards/shields/wings/wings.overlay"
check_file "boards/shields/wings/wings_left.overlay"
check_file "boards/shields/wings/wings_right.overlay"
check_file "boards/shields/wings/wings.zmk.yml"

echo -e "\n${YELLOW}Checking keymap files...${NC}"
check_file "config/wings.keymap"
check_file "config/wings.conf"
check_file "config/wings.json"

echo -e "\n${YELLOW}Checking GitHub Actions...${NC}"
check_file ".github/workflows/build.yml"
check_file ".github/workflows/draw-keymaps.yml"

echo -e "\n${YELLOW}Checking keymap editor support...${NC}"
check_file "config/info.json"
check_dir "keymap-drawer"
check_file "keymap-drawer/config.yaml"

echo -e "\n${YELLOW}Validating build.yaml structure...${NC}"
if grep -q "wings_left" build.yaml && grep -q "wings_right" build.yaml; then
    echo -e "${GREEN}✓${NC} build.yaml contains wings shield configurations"
else
    echo -e "${RED}✗${NC} build.yaml missing wings shield configurations"
    ERRORS=$((ERRORS + 1))
fi

echo -e "\n${YELLOW}Checking for common issues...${NC}"

# Check if physical layout has transform property
if grep -q "transform = <&default_transform>" boards/shields/wings/wings.overlay 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Physical layout has required transform property"
else
    echo -e "${RED}✗${NC} Physical layout missing transform property"
    ERRORS=$((ERRORS + 1))
fi

# Check keymap binding count
BINDING_COUNT=$(grep -o "&kp" config/wings.keymap 2>/dev/null | wc -l)
if [ "$BINDING_COUNT" -ge 46 ]; then
    echo -e "${GREEN}✓${NC} Keymap has sufficient bindings ($BINDING_COUNT found, 46 required)"
else
    echo -e "${RED}✗${NC} Keymap has insufficient bindings ($BINDING_COUNT found, 46 required)"
    ERRORS=$((ERRORS + 1))
fi

echo -e "\n${YELLOW}Summary:${NC}"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}All checks passed! Configuration appears valid.${NC}"
    echo -e "\nYou can test the build with:"
    echo -e "  - Docker: ${YELLOW}./build-docker.sh${NC}"
    echo -e "  - Native: ${YELLOW}./build-local.sh${NC}"
    echo -e "  - GitHub: ${YELLOW}git push${NC} (triggers Actions)"
else
    echo -e "${RED}Found $ERRORS error(s). Please fix before building.${NC}"
    exit 1
fi