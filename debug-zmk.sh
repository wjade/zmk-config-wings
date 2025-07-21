#!/bin/bash

echo "Looking for USB serial devices..."

# Check for any USB serial devices
DEVICES=$(ls /dev/tty.usb* /dev/tty.usbmodem* /dev/tty.usbserial* 2>/dev/null | sort -u)

if [ -z "$DEVICES" ]; then
    echo "No USB serial devices found. Waiting for Wings keyboard to be connected..."
    echo "Please plug in your keyboard now."
    
    # Wait for device to appear
    while true; do
        DEVICES=$(ls /dev/tty.usb* /dev/tty.usbmodem* /dev/tty.usbserial* 2>/dev/null | sort -u)
        if [ ! -z "$DEVICES" ]; then
            echo "Found device(s)!"
            break
        fi
        sleep 0.5
    done
fi

# If multiple devices, show them
COUNT=$(echo "$DEVICES" | wc -l)
if [ $COUNT -gt 1 ]; then
    echo "Multiple USB devices found:"
    echo "$DEVICES" | nl -v 0
    echo -n "Select device number [0]: "
    read SELECTION
    SELECTION=${SELECTION:-0}
    DEVICE=$(echo "$DEVICES" | sed -n "$((SELECTION+1))p")
else
    DEVICE=$DEVICES
fi

echo "Using device: $DEVICE"

# Start minicom with the device
echo "Starting minicom with ZMK debug settings..."
echo "Press Ctrl+A then X to exit and save the log"
minicom -D "$DEVICE" -b 115200 -C zmk_boot.log