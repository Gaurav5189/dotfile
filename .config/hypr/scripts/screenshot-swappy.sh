#!/usr/bin/env bash

# Define your preferred storage location
TARGET_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$TARGET_DIR"

# Generate a clean timestamped filename
FILENAME="screenshot_$(date +%Y%m%d_%H%M%S).png"
OUTPUT_PATH="$TARGET_DIR/$FILENAME"

# Define the rofi menu configuration
ROFI_CMD="rofi -dmenu -replace -config ~/.config/rofi/config-screenshot.rasi -i -no-show-icons -l 3 -width 30 -p 'Screenshot Mode'"

mode=$(echo -e "Region\nActive Window\nFull Screen" | $ROFI_CMD)

case $mode in
    "Region")
        grim -g "$(slurp)" - | satty --filename - --output-filename "$OUTPUT_PATH" ;;
    "Active Window")
        sleep 0.5
        grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" - | satty --filename - --output-filename "$OUTPUT_PATH" ;;
    "Full Screen")
        sleep 0.5
        grim - | satty --filename - --output-filename "$OUTPUT_PATH" ;;
    *)
        exit 1 ;;
esac
