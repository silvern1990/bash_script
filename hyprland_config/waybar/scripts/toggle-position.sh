#!/bin/bash
CONFIG="$HOME/.config/waybar/config.jsonc"
current=$(grep -oP '"position":\s*"\K(top|bottom)' "$CONFIG" | head -n1)
if [ "$current" = "top" ]; then
    new="bottom"
else
    new="top"
fi
sed -i "s/\"position\": \"$current\"/\"position\": \"$new\"/" "$CONFIG"

WAYBAR_PID=$(pgrep -x waybar | head -n1)
if [ -n "$WAYBAR_PID" ]; then
    while IFS= read -r -d '' var; do
        case "$var" in
            WAYLAND_DISPLAY=*|DISPLAY=*|XDG_RUNTIME_DIR=*|XDG_CURRENT_DESKTOP=*|HYPRLAND_INSTANCE_SIGNATURE=*|HYPRLAND_CMD=*|PATH=*)
                export "$var"
                ;;
        esac
    done < "/proc/$WAYBAR_PID/environ"
    kill "$WAYBAR_PID"
    for _ in $(seq 1 50); do
        kill -0 "$WAYBAR_PID" 2>/dev/null || break
        sleep 0.1
    done
fi

setsid nohup waybar >/dev/null 2>&1 < /dev/null &
disown