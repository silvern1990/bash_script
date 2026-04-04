#!/bin/bash

active=$(hyprctl activewindow -j | jq -r '.class')

if [[ "$active" == "google-chrome" ]]; then
    if [[ "$1" == "prev"  ]]; then
        wtype -M ctrl -M shift -k Tab -m shift -m ctrl
    elif [[ "$1" == "next" ]]; then
        wtype -M ctrl -k Tab -m ctrl
    fi
else
    if [[ "$1" == "prev" ]]; then
        wtype -M ctrl -k bracketleft -m ctrl
    elif [[ "$1" == "next" ]]; then
        wtype -M ctrl -k bracketright -m ctrl
    fi
fi
