#!/bin/sh
# Toggle focus between floating and tiled windows (like sway's focus mode_toggle)

is_floating=$(hyprctl activewindow -j | jq -r '.floating')

if [ "$is_floating" = "true" ]; then
    hyprctl dispatch cyclenext tiled
else
    hyprctl dispatch cyclenext floating
fi