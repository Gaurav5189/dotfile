#!/usr/bin/env bash

# Capture a selected area and present it as an interactive SwayNC preview.
# The image is only written to Pictures/Screenshots after Save or Edit.

set -u

MODE="--area"
FREEZE_SCREEN=false

for argument in "$@"; do
    case "$argument" in
        --area|--full) MODE="$argument" ;;
        --freeze) FREEZE_SCREEN=true ;;
        *)
            notify-send -a "Screenshot" "Screenshot unavailable" "Unknown option: $argument"
            exit 1
            ;;
    esac
done

SAVE_DIR="$HOME/Pictures/Screenshots"
if [ -f ~/.config/ml4w/settings/screenshot-folder ]; then
    SAVE_DIR="$(<~/.config/ml4w/settings/screenshot-folder)"
    case "$SAVE_DIR" in
        "~") SAVE_DIR="$HOME" ;;
        "~/"*) SAVE_DIR="$HOME/${SAVE_DIR#~/}" ;;
    esac
fi
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}/hypr-screenshots"

for command in grim notify-send; do
    if ! command -v "$command" >/dev/null 2>&1; then
        notify-send -a "Screenshot" "Screenshot unavailable" "Missing dependency: $command"
        exit 1
    fi
done

mkdir -p "$SAVE_DIR" "$RUNTIME_DIR" || {
    notify-send -a "Screenshot" "Screenshot unavailable" "Could not create the screenshot directory"
    exit 1
}
TMP_FILE="$(mktemp --suffix=.png "$RUNTIME_DIR/screenshot.XXXXXX")" || {
    notify-send -a "Screenshot" "Screenshot unavailable" "Could not create a temporary file"
    exit 1
}
SAVE_FILE="$SAVE_DIR/screenshot_$(date +%Y%m%d_%H%M%S_%N).png"
PICKER_PID=""
SKIP_CLEANUP=false

cleanup() {
    if [ -n "$PICKER_PID" ]; then
        kill "$PICKER_PID" 2>/dev/null || true
        wait "$PICKER_PID" 2>/dev/null || true
    fi
    if ! $SKIP_CLEANUP; then
        rm -f "$TMP_FILE"
    fi
}
trap cleanup EXIT

stop_picker() {
    if [ -n "$PICKER_PID" ]; then
        kill "$PICKER_PID" 2>/dev/null || true
        wait "$PICKER_PID" 2>/dev/null || true
        PICKER_PID=""
    fi
}

case "$MODE" in
    --full)
        grim -t png "$TMP_FILE" || exit 1
        ;;
    --area)
        command -v slurp >/dev/null 2>&1 || {
            notify-send -a "Screenshot" "Screenshot unavailable" "Missing dependency: slurp"
            exit 1
        }
        if "$FREEZE_SCREEN"; then
            command -v hyprpicker >/dev/null 2>&1 || {
                notify-send -a "Screenshot" "Screenshot unavailable" "Missing dependency: hyprpicker"
                exit 1
            }
            hyprpicker -r -z &
            PICKER_PID=$!
            sleep 0.1
        fi
        REGION="$(slurp -b "#00000080" -c "#888888ff" -w 1)" || exit 0
        [[ -n "$REGION" ]] || exit 0
        stop_picker
        grim -g "$REGION" -t png "$TMP_FILE" || exit 1
        ;;
    *)
        notify-send -a "Screenshot" "Screenshot unavailable" "Unknown capture mode: $MODE"
        exit 1
        ;;
esac

# -A waits for a SwayNC action and writes the action identifier to stdout.
ACTION="$(notify-send \
    -a "Screenshot" \
    -i "camera-photo-symbolic" \
    -h "string:image-path:$TMP_FILE" \
    -t 20000 \
    -A "copy=Copy" \
    -A "save=Save" \
    -A "edit=Edit" \
    -A "discard=Discard" \
    "Screenshot captured" \
    "Choose an action")"

case "$ACTION" in
    copy)
        if wl-copy --type image/png < "$TMP_FILE"; then
            notify-send -a "Screenshot" "Copied to clipboard" -t 2000
        else
            notify-send -a "Screenshot" "Copy failed" "Could not write the image to the clipboard"
        fi
        ;;
    save)
        if cp -- "$TMP_FILE" "$SAVE_FILE"; then
            notify-send -a "Screenshot" -i "$SAVE_FILE" "Saved" "Saved to $SAVE_FILE" -t 2000
        else
            notify-send -a "Screenshot" "Save failed" "Could not save to $SAVE_DIR"
        fi
        ;;
    edit)
        if ! command -v satty >/dev/null 2>&1; then
            notify-send -a "Screenshot" "Edit unavailable" "Satty is not installed"
        else
            # Don't delete TMP_FILE on EXIT — Satty is a GUI and opens it asynchronously.
            # The temp file will remain in /run/user/1000/hypr-screenshots after each edit session, but that directory is cleared on every reboot (it's a runtime dir).
            SKIP_CLEANUP=true
            satty --filename "$TMP_FILE" --output-filename "$SAVE_FILE" &
        fi
        ;;
    discard|"")
        ;;
esac
