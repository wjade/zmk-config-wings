# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a ZMK (Zephyr-based Mechanical Keyboard) firmware configuration repository for a custom keyboard called "Wings" (named "Jade Wing" in Bluetooth). The repository builds firmware for a split keyboard using Seeeduino XIAO BLE boards.

## Architecture & Structure

### Core Configuration Files
- **build.yaml**: Defines all build configurations including:
  - Standard left/right builds
  - ZMK Studio-enabled builds
  - Debug builds with USB logging
  - Row2col diode direction variants
  - Standalone test builds
  - Settings reset builds

- **config/**: Keyboard configuration directory
  - `wings.keymap`: Main keymap with 3 layers (default, lower, raise)
  - `wings.conf`: Configuration options (Bluetooth name, Studio support, debug settings)
  - `wings.json`: Keymap visualization metadata
  - `wings.studio.config`: ZMK Studio configuration
  - `west.yml`: West manifest pointing to ZMK v0.2

### Custom Shield Definition
- **boards/shields/wings/**: Custom shield implementation
  - `wings.dtsi`: Core matrix definition (5 rows × 12 columns)
  - `wings_left.overlay` / `wings_right.overlay`: Split keyboard overlays
  - `wings_row2col_left.overlay` / `wings_row2col_right.overlay`: Alternative diode direction
  - `wings.zmk.yml`: Shield metadata for ZMK build system
  - `Kconfig.shield` / `Kconfig.defconfig`: Build system configuration

### Physical Layout
- 5×12 matrix (60 keys total)
- Split keyboard design (30 keys per half)
- GPIO pins on Seeeduino XIAO BLE:
  - Rows: D9, D8, D7, D6, D10
  - Columns: Different per split half
- Col2row diode direction (with row2col variants available)

## Common Development Tasks

### Building Firmware

#### Option 1: Using Docker (Recommended)
```bash
# Build all firmware variants
./build-docker.sh

# Clean build artifacts
./build-docker.sh clean
```

#### Option 2: Native West Build
```bash
# Build all firmware variants
./build-local.sh

# Clean build artifacts
./build-local.sh clean
```

#### Option 3: Manual West Commands
```bash
# Initialize west workspace (first time only)
west init -l config
west update

# Build specific variants
west build -s zmk/app -b seeeduino_xiao_ble -- -DSHIELD=wings_left -DZMK_CONFIG="${PWD}/config"
west build -s zmk/app -b seeeduino_xiao_ble -- -DSHIELD=wings_right -DZMK_CONFIG="${PWD}/config"

# Build with ZMK Studio support
west build -s zmk/app -b seeeduino_xiao_ble -- -DSHIELD=wings_left -DZMK_CONFIG="${PWD}/config" -S studio-rpc-usb-uart
```

### Validation and Testing
```bash
# Validate configuration structure
./validate-config.sh

# Debug builds with USB logging
./debug-zmk.sh
```

### GitHub Actions

The repository uses automated builds via `.github/workflows/build.yml`. Builds trigger on:
- Pushes to main/master branches
- Pull requests
- Manual workflow dispatch

Artifacts are available for download after successful builds.

## Key Configuration Points

### Keymap Structure
- **Default layer**: Standard QWERTY with number row
- **Lower layer**: F-keys, navigation, Bluetooth controls (BT1-BT5)
- **Raise layer**: Symbols and punctuation
- **Combos**: 
  - ESC + BSPC on lower layer = System reset
  - 0 + BSPC on lower layer = Bootloader

### ZMK Studio Support
Enabled by default in `wings.conf`:
- `CONFIG_ZMK_STUDIO=y`
- `CONFIG_ZMK_STUDIO_LOCKING=n` (unlocked for development)

### Feature Toggles
Uncomment in `config/wings.conf` to enable:
- RGB underglow: `CONFIG_ZMK_RGB_UNDERGLOW=y`
- OLED display: `CONFIG_ZMK_DISPLAY=y`
- USB logging: `CONFIG_ZMK_USB_LOGGING=y`

### Build Variants
The repository supports multiple build configurations:
1. **Standard builds**: Basic left/right firmware
2. **Studio builds**: With ZMK Studio RPC support
3. **Debug builds**: USB logging enabled
4. **Row2col builds**: Alternative diode direction
5. **Standalone build**: Single unified firmware for testing
6. **Settings reset**: Clears all stored settings

## Important Notes

- Bluetooth device name: "Jade Wing" (max 16 characters)
- Board: `seeeduino_xiao_ble` exclusively
- Matrix scanning debounce: 5ms press/release
- The shields support ZMK Studio for real-time keymap editing
- Debug logs available via USB when debug builds are used