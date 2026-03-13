#!/usr/bin/env bash
# Move focus among floating windows only when current window is floating,
# otherwise fall back to normal movefocus.
# Usage: floating-focus.sh <l|r|u|d>

direction="$1"

active=$(hyprctl activewindow -j)
is_floating=$(echo "$active" | jq -r '.floating')

if [[ "$is_floating" != "true" ]]; then
    hyprctl dispatch movefocus "$direction"
    exit 0
fi

active_addr=$(echo "$active" | jq -r '.address')
active_x=$(echo "$active" | jq -r '.at[0]')
active_y=$(echo "$active" | jq -r '.at[1]')
active_w=$(echo "$active" | jq -r '.size[0]')
active_h=$(echo "$active" | jq -r '.size[1]')
active_ws=$(echo "$active" | jq -r '.workspace.id')

# Center of active window
cx=$(( active_x + active_w / 2 ))
cy=$(( active_y + active_h / 2 ))

# Get all floating windows on the same workspace (excluding active)
candidates=$(hyprctl clients -j | jq -c --arg addr "$active_addr" --argjson ws "$active_ws" \
    '[.[] | select(.floating == true and .address != $addr and .workspace.id == $ws and .mapped == true)]')

count=$(echo "$candidates" | jq 'length')
if [[ "$count" -eq 0 ]]; then
    exit 0
fi

# For each candidate, compute center and filter by direction
best_addr=""
best_dist=999999999

for i in $(seq 0 $(( count - 1 ))); do
    cand=$(echo "$candidates" | jq -c ".[$i]")
    cand_addr=$(echo "$cand" | jq -r '.address')
    cand_x=$(echo "$cand" | jq -r '.at[0]')
    cand_y=$(echo "$cand" | jq -r '.at[1]')
    cand_w=$(echo "$cand" | jq -r '.size[0]')
    cand_h=$(echo "$cand" | jq -r '.size[1]')

    cand_cx=$(( cand_x + cand_w / 2 ))
    cand_cy=$(( cand_y + cand_h / 2 ))

    dx=$(( cand_cx - cx ))
    dy=$(( cand_cy - cy ))

    # Filter by direction
    case "$direction" in
        l) [[ $dx -ge 0 ]] && continue ;;
        r) [[ $dx -le 0 ]] && continue ;;
        u) [[ $dy -ge 0 ]] && continue ;;
        d) [[ $dy -le 0 ]] && continue ;;
    esac

    # Manhattan distance
    dist=$(( ${dx#-} + ${dy#-} ))
    if [[ $dist -lt $best_dist ]]; then
        best_dist=$dist
        best_addr=$cand_addr
    fi
done

if [[ -n "$best_addr" ]]; then
    hyprctl dispatch focuswindow "address:$best_addr"
fi