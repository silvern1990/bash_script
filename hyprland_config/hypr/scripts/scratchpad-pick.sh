#!/bin/sh
# Pick a window from scratchpad and move it to the current workspace

# Toggle: if wofi is already running, kill it and exit
if pgrep -x wofi >/dev/null; then
    pkill -x wofi
    exit 0
fi

windows=$(hyprctl clients -j | jq -r '.[] | select(.workspace.name | startswith("special:")) | "\(.address) \(.class): \(.title)"')

if [ -z "$windows" ]; then
    notify-send "Scratchpad" "No windows in scratchpad"
    exit 0
fi

selected=$(echo "$windows" | wofi --dmenu --prompt "Scratchpad")

if [ -n "$selected" ]; then
    addr=$(echo "$selected" | awk '{print $1}')
    hyprctl dispatch movetoworkspace e+0,address:$addr
    hyprctl dispatch focuswindow address:$addr
fi
