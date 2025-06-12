#!/bin/sh

status=$(swaymsg -t get_outputs | jq '.[] | select(.name == "eDP-1") | .active')

if [ $status == "false" ]; then
    swaymsg output eDP-1 enable
else
    swaymsg output eDP-1 disable
fi
