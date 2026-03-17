#!/bin/bash

SOCK="$XDG_RUNTIME_DIR/mpv.sock"

subscribe() {
echo '{ "command": ["observe_property", 1, "media-title"] }'
echo '{ "command": ["observe_property", 2, "pause"] }'
}

subscribe | socat - "$SOCK" >/dev/null

socat - "$SOCK" | while read -r line; do

title=$(echo '{ "command": ["get_property","media-title"] }' | socat - "$SOCK" | jq -r '.data')
pause=$(echo '{ "command": ["get_property","pause"] }' | socat - "$SOCK" | jq -r '.data')

if [ "$title" = "null" ]; then
    text=""
else
    if [ "$pause" = "true" ]; then
        text=" $title"
    else
        text=" $title"
    fi
fi

echo "{\"text\":\"$text\"}"

done
