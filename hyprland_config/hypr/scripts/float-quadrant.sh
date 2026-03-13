#!/bin/bash
# Move floating window to a quadrant of the screen
# Usage: float-quadrant.sh <1|2|3|4>
#   1 = top-left,  2 = top-right
#   3 = bottom-left, 4 = bottom-right

QUADRANT="$1"

# Get active monitor resolution and position
MONITOR_JSON=$(hyprctl monitors -j | jq '.[] | select(.focused == true)')
MON_W=$(echo "$MONITOR_JSON" | jq '.width')
MON_H=$(echo "$MONITOR_JSON" | jq '.height')
MON_X=$(echo "$MONITOR_JSON" | jq '.x')
MON_Y=$(echo "$MONITOR_JSON" | jq '.y')
SCALE=$(echo "$MONITOR_JSON" | jq '.scale')
RESERVED=$(echo "$MONITOR_JSON" | jq '.reserved')
RES_LEFT=$(echo "$RESERVED" | jq '.[0]')
RES_TOP=$(echo "$RESERVED" | jq '.[1]')
RES_RIGHT=$(echo "$RESERVED" | jq '.[2]')
RES_BOT=$(echo "$RESERVED" | jq '.[3]')

# Calculate usable area in scaled pixels
USABLE_W=$(awk "BEGIN {printf \"%d\", $MON_W / $SCALE - $RES_LEFT - $RES_RIGHT}")
USABLE_H=$(awk "BEGIN {printf \"%d\", $MON_H / $SCALE - $RES_TOP - $RES_BOT}")
ORIGIN_X=$(awk "BEGIN {printf \"%d\", $MON_X + $RES_LEFT}")
ORIGIN_Y=$(awk "BEGIN {printf \"%d\", $MON_Y + $RES_TOP}")

HALF_W=$((USABLE_W / 2))
HALF_H=$((USABLE_H / 2))

case "$QUADRANT" in
    1) X=$ORIGIN_X;              Y=$ORIGIN_Y ;;
    2) X=$((ORIGIN_X + HALF_W)); Y=$ORIGIN_Y ;;
    3) X=$ORIGIN_X;              Y=$((ORIGIN_Y + HALF_H)) ;;
    4) X=$((ORIGIN_X + HALF_W)); Y=$((ORIGIN_Y + HALF_H)) ;;
    *) echo "Usage: $0 <1|2|3|4>"; exit 1 ;;
esac

# Ensure window is floating, then move and resize
hyprctl --batch "dispatch setfloating; dispatch moveactive exact $X $Y; dispatch resizeactive exact $HALF_W $HALF_H"
