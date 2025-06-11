#!/bin/sh

echo $$ > /tmp/wallpaper.pid


perform_task() {
    gid="$(ls /home/zero/sync/sync | sort -R | head -n1)"
    command="/home/zero/util/linux-wallpaperengine/linux-wallpaperengine --screen-root DP-2 --bg /home/zero/sync/sync/$gid --scaling fit"

    $command &

    pid=$!

    echo "$gid" > /tmp/gid.txt
}

handle_signal() {
    kill $pid
    restart_task=1
}

trap 'handle_signal' SIGUSR1

INTERVAL=1200
restart_task=0

while true; do
    perform_task

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


