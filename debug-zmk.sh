#!/bin/bash

echo "Waiting for Wings keyboard to be connected..."
echo "Please plug in your keyboard now."

# Wait for device to appear
while true; do
    DEVICE=$(ls /dev/tty.usb* 2>/dev/null | head -1)
    if [ ! -z "$DEVICE" ]; then
        echo "Found device: $DEVICE"
        break
    fi
    sleep 0.5
done

# Start minicom with the device
echo "Starting minicom with ZMK debug settings..."
minicom -D "$DEVICE" -b 115200 -C zmk_boot.log