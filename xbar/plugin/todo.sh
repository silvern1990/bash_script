#!/usr/bin/env bash


export PATH=$PATH:/opt/homebrew/Cellar/todo-txt/2.13.0/bin

list_items() {
    todo.sh ls  | awk 'NR>1 {print buf}{buf = $0}' | sed '/--/d' | awk ' { print $0,"| bash=/opt/homebrew/Cellar/todo-txt/2.13.0/bin/todo.sh param1=do param2="$1" refresh=true" }'
}

add_item() {
    todo.sh add $(osascript -e 'Tell application "System Events" to display dialog "New task:" default answer ""' -e 'text returned of result' 2>/dev/null) > /dev/null
}

if [ "${1}" == "add" ]; then
    add_item
else
    echo "TODO"
    echo "---"
    list_items
    echo "---"
    echo "Add task | bash=$0 param1=add refresh=true"
fi
