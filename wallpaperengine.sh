#!/bin/sh

echo $$ > /tmp/wallpaper.pid


perform_task() {
    gid="$(ls ~/.sync/wallpaper/normal | sort -R | head -n1)"

    for display in "$@"; do
        echo $display
        command="wallpaperengine --screen-root $display --bg /home/zero/.sync/wallpaper/normal/$gid --scaling fit"
        $command &
    done


    pid=$!
    echo "$pid" > /tmp/wallpaper.pid
    echo "$gid" > /tmp/gid.txt
}

handle_signal() {
    kill $pid
    restart_task=1
}

trap 'handle_signal' SIGUSR1

INTERVAL=1200
restart_task=0


cat > ~/alias/.env << EOF
alias n='kill -USR1 \$(cat /tmp/wallpaper.pid)'
EOF

while true; do
    perform_task $@

    SECONDS=0

    while [ $SECONDS -lt $INTERVAL ]; do
        if [ "$restart_task" -eq 1 ]; then
            restart_task=0
            break
        fi
        if [ "$?" != 0 ]; then
            break
        fi
        sleep 1
    done
    kill $pid
done


