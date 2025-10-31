#!/bin/zsh

current=$(yabai -m query --windows --window)
cx=$(echo $current | jq '.frame.x')
cy=$(echo $current | jq '.frame.y')
cid=$(echo $current | jq '.id')

direction=$1

if [ "$direction" = "left" ]; then
    comp_op="<"
    sort_order="last"
else
    comp_op=">"
    sort_order="first"
fi

echo $direction

target=$(yabai -m query --windows | jq -r \
    --argjson cx "$cx" --argjson cy "$cy" --argjson cid "$cid" "map(select(.id != \$cid and .space == 2 and .frame.x ${comp_op} \$cx)) | sort_by(.frame.x) | ${sort_order} | .id")

echo $target
[ "$target" != "null" ] && yabai -m window --focus $target
