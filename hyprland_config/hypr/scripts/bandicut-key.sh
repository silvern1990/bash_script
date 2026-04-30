#!/bin/bash

title=$(hyprctl activewindow -j | jq -r '.title')

if [[ "$title" == *"반디컷"* ]]; then
    case "$1" in
        prev) xdotool key --clearmodifiers ctrl+alt+Left --delay 100 space ;;
        next) xdotool key --clearmodifiers ctrl+alt+Right ;;
    esac
else
    case "$1" in
        prev) wtype -k Prior ;;
        next) wtype -k Next  ;;
    esac
fi
