# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a ZMK (Zephyr-based Mechanical Keyboard) firmware configuration repository for a Corne keyboard. The repository uses the Seeeduino XIAO BLE board and builds firmware for both left and right keyboard halves.

## Architecture & Structure

- **config/**: Contains keyboard-specific configuration
  - `corne.keymap`: Defines the keyboard layout and layers (default, lower, raise)
  - `corne.conf`: Configuration options for features like RGB underglow and OLED display
  - `west.yml`: West manifest for ZMK firmware dependency management

- **build.yaml**: GitHub Actions build configuration specifying board/shield combinations

- **boards/shields/**: Custom board/shield definitions (currently empty)

- **zephyr/module.yml**: Zephyr module configuration

## Common Development Tasks

### Testing Builds Locally

#### Option 1: Using Docker (Recommended)
```bash
# Make script executable
chmod +x build-docker.sh

# Build all firmware variants
./build-docker.sh

# Clean build artifacts
./build-docker.sh clean
```

This mimics the exact GitHub Actions environment and is the most reliable way to test locally.

#### Option 2: Native West Build
```bash
# Make script executable  
chmod +x build-local.sh

# Build all firmware variants
./build-local.sh

# Clean build artifacts
./build-local.sh clean
```

Requires local Zephyr SDK installation. See [ZMK docs](https://zmk.dev/docs/development/setup) for setup instructions.

#### Option 3: Manual West Commands
```bash
# Initialize west workspace (first time only)
west init -l config
west update

# Build firmware for wings left half
west build -s zmk/app -b seeeduino_xiao_ble -- -DSHIELD=wings_left -DZMK_CONFIG="${PWD}/config"

# Build firmware for wings right half
west build -s zmk/app -b seeeduino_xiao_ble -- -DSHIELD=wings_right -DZMK_CONFIG="${PWD}/config"
```

### GitHub Actions Build

The repository uses GitHub Actions for automated firmware builds. The workflow is configured in `.github/workflows/build.yml` and triggers on:
- Pushes to main/master branches
- Pull requests
- Manual workflow dispatch

The workflow automatically builds firmware for both keyboard halves based on the configurations in `build.yaml`. After a successful build, firmware artifacts (`.uf2` files) will be available for download from the Actions tab.

## Key Configuration Points

1. **Keymap Modification**: Edit `config/corne.keymap` to change key layouts. The file uses Device Tree syntax with three layers defined.

2. **Feature Toggles**: Uncomment lines in `config/corne.conf` to enable:
   - RGB underglow: `CONFIG_ZMK_RGB_UNDERGLOW=y`
   - OLED display: `CONFIG_ZMK_DISPLAY=y`

3. **Board Configuration**: Currently configured for `seeeduino_xiao_ble` board. To change boards, update `build.yaml`.

## Important Notes

- The firmware uses ZMK v0.2 as specified in `config/west.yml`
- Bluetooth profiles are configured in the lower layer (BT1-BT5)
- The keymap follows standard Corne 3x6+3 layout