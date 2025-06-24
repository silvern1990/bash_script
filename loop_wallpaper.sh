#!/bin/bash

echo $$ > /tmp/check_wallpaper.pid

DB_NAME="/home/zero/gid_list.db"
wallpaper_dir=~/sync/sync


if [ ! -f "$DB_NAME" ]; then

sqlite3 $DB_NAME << EOF

CREATE TABLE IF NOT EXISTS gid_list (
    gid TEXT PRIMARY KEY,
    title TEXT
);

EOF

cat > ~/alias/.env << EOF

alias d='rm -rf ${wallpaper_dir}/\$(cat /tmp/check_gid) && sqlite3 $DB_NAME "delete from gid_list where gid=\$(cat /tmp/check_gid);" && kill -USR1 \$(cat /tmp/check_wallpaper.pid)'

alias n='sqlite3 $DB_NAME "delete from gid_list where gid=\$(cat /tmp/check_gid)" && kill -USR1 \$(cat /tmp/check_wallpaper.pid)'

alias normal='mv ${wallpaper_dir}/\$(cat /tmp/check_gid) ~/sync/normal/\$(cat /tmp/check_gid) && sqlite3 $DB_NAME "delete from gid_list where gid=\$(cat /tmp/check_gid)" && kill -USR1 \$(cat /tmp/check_wallpaper.pid)'
alias al='mv ${wallpaper_dir}/\$(cat /tmp/check_gid) ~/sync/allow/\$(cat /tmp/check_gid) && sqlite3 $DB_NAME "delete from gid_list where gid=\$(cat /tmp/check_gid)" && kill -USR1 \$(cat /tmp/check_wallpaper.pid)'
alias dn='mv ${wallpaper_dir}/\$(cat /tmp/check_gid) ~/sync/deny/\$(cat /tmp/check_gid) && sqlite3 $DB_NAME "delete from gid_list where gid=\$(cat /tmp/check_gid)" && kill -USR1 \$(cat /tmp/check_wallpaper.pid)'


EOF

for gid in ${wallpaper_dir}/*; do
    title=$(cat ${gid}/project.json | jq '.title')
    title="${title//\'/\'\'}"
    gid=$(basename $gid)

    case "$gid" in
        '' | *[!0-9]*)
            echo "$gid"
            ;;
        *)
            sqlite3 $DB_NAME "INSERT INTO gid_list (gid, title) VALUES ('$gid', '$title');"
            ;;
    esac

done

fi

perform_task(){
    (

        row="$(sqlite3 $DB_NAME 'select gid,title from gid_list order by title limit 1')"
        IFS='|' read -r gid title <<< "$row"
        echo $title

        command="/home/zero/util/linux-wallpaperengine/linux-wallpaperengine --screen-root eDP-1 --bg ${wallpaper_dir}/$gid --scaling fit --volume 100"

        $command &

        pid=$!

        echo "$pid" > /tmp/galary.pid

        echo "$gid" > /tmp/check_gid

        wait $pid

        if [ "$?" != 0  -a "$?" != 143 ]; then
            $(sqlite3 $DB_NAME "delete from gid_list where gid = $gid")
            kill -USR1 $$
        fi

    ) &
}

handle_signal() {
    kill $(cat /tmp/galary.pid)
    restart_task=1
}

trap 'handle_signal' SIGUSR1

INTERVAL=12000
restart_task=0

while true; do
    perform_task

    SECONDS=0
    while [ $SECONDS -lt $INTERVAL ]; do

        if [ "$restart_task" -eq 1 ]; then
            restart_task=0
            break
        fi

        sleep 1
    done
    kill $(cat /tmp/galary.pid)
done
