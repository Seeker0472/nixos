#!/bin/sh

TMP_FILE=$(mktemp --suffix=.png)
GEOMETRY=$(slurp)

# Check wheather canceled 
if [ $? -ne 0 ] || [ -z "$GEOMETRY" ]; then
    rm "$TMP_FILE"
    notify-send -u low "Screenshot Cancelled"
    exit 1
fi

# screenshoot && copy && notify
if grim -g "$GEOMETRY" "$TMP_FILE"; then
    wl-copy --type image/png < "$TMP_FILE"
    notify-send "Screenshot Taken" "Area screenshot copied to clipboard." --icon="$TMP_FILE" --category=screenshoot
    rm "$TMP_FILE"
    exit 0
else
    notify-send -u critical "Screenshot Failed" "Could not capture screen area."
    rm "$TMP_FILE"
    exit 1
fi
