#!/bin/bash

echo $$ > /tmp/check_wallpaper.pid

DB_NAME="/home/zero/gid_list.db"
wallpaper_dir=~/sync/sync


if [ ! -f "$DB_NAME" ]; then

sqlite3 $DB_NAME << EOF

CREATE TABLE IF NOT EXISTS gid_list (
    gid TEXT PRIMARY KEY
);

EOF

for gid in ${wallpaper_dir}/*; do
    gid=$(basename $gid)

    case "$gid" in
        '' | *[!0-9]*)
            echo "$gid"
            ;;
        *)
            sqlite3 $DB_NAME "INSERT INTO gid_list (gid) VALUES ('$gid');"
            ;;
    esac

done

fi

perform_task(){
    gid="$(sqlite3 $DB_NAME 'select gid from gid_list limit 1')"
    echo $gid
    command="/home/zero/util/linux-wallpaperengine/linux-wallpaperengine --screen-root DP-2 --bg ${wallpaper_dir}/$gid --scaling fit"

    $command &

    pid=$!

    echo "$gid" > /tmp/check_gid
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
