#!/bin/bash

echo "1" > /tmp/check_gid

if [ -z $1 ]; then
    echo "USAGE: display-port"
    exit 1
fi

echo $$ > /tmp/check_wallpaper.pid

DB_NAME="/home/zero/wallpaper.db"
wallpaper_dir=/home/zero/.sync/wallpaper
wallpaper_engine=wallpaperengine


if [ ! -f "$DB_NAME" ]; then

sqlite3 $DB_NAME << EOF

CREATE TABLE IF NOT EXISTS gid_list (
    gid TEXT PRIMARY KEY,
    title TEXT,
    resolution TEXT,
    play_time int
);

EOF


for gid in ${wallpaper_dir}/*; do
    title=$(cat ${gid}/project.json | jq '.title')
    title="${title//\'/\'\'}"


    resolution=""
    play_time=0

    ls ${gid}/*.mp4
    if [ $? -eq 0 ]; then
        resolution=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 ${gid}/*.mp4)
        play_time=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 ${gid}/*.mp4)

        echo $resolution
        echo $play_time
    fi

    gid=$(basename $gid)

    case "$gid" in
        '' | *[!0-9]*)
            echo "$gid"
            ;;
        *)
            sqlite3 $DB_NAME "INSERT INTO gid_list (gid, title, resolution, play_time) VALUES ('$gid', '$title', '$resolution', $play_time);"
            ;;
    esac

done

fi


cat > ~/alias/.env << EOF

alias d='[ -f /tmp/check_gid ] && {
    rm -rf "${wallpaper_dir}/\$(cat /tmp/check_gid)" &&
    sqlite3 "$DB_NAME" "delete from gid_list where gid=\$(cat /tmp/check_gid);" && 
    kill -USR1 "\$(cat /tmp/check_wallpaper.pid)" &&
    echo "\$(cat /tmp/check_gid)" > /tmp/prev_gid
}'

alias n='[ -f /tmp/check_gid ] && {
    sqlite3 $DB_NAME "delete from gid_list where gid=\$(cat /tmp/check_gid)" && kill -USR1 \$(cat /tmp/check_wallpaper.pid)
}'

alias normal='[ -f /tmp/check_gid ] && {([ -e ~/.sync/wallpaper/normal/\$(cat /tmp/check_gid) ] && rm -rf ${wallpaper_dir}/\$(cat /tmp/check_gid)) || mv ${wallpaper_dir}/\$(cat /tmp/check_gid) ~/.sync/wallpaper/normal/\$(cat /tmp/check_gid) && sqlite3 $DB_NAME "delete from gid_list where gid=\$(cat /tmp/check_gid)" && kill -USR1 \$(cat /tmp/check_wallpaper.pid)}'

alias al='[ -f /tmp/check_gid ] && ([ -e ~/.sync/wallpaper/allow/\$(cat /tmp/check_gid) ] && rm -rf ${wallpaper_dir}/\$(cat /tmp/check_gid)) || mv ${wallpaper_dir}/\$(cat /tmp/check_gid) ~/.sync/wallpaper/allow/\$(cat /tmp/check_gid) && sqlite3 $DB_NAME "delete from gid_list where gid=\$(cat /tmp/check_gid)" && kill -USR1 \$(cat /tmp/check_wallpaper.pid) && echo \$(cat /tmp/check_gid) > /tmp/prev_gid'

alias dn='[ -f /tmp/check_gid ] && ([ -e ~/.sync/wallpaper/deny/\$(cat /tmp/check_gid) ] && rm -rf ${wallpaper_dir}/\$(cat /tmp/check_gid)) || mv ${wallpaper_dir}/\$(cat /tmp/check_gid) ~/.sync/wallpaper/deny/\$(cat /tmp/check_gid) && sqlite3 $DB_NAME "delete from gid_list where gid=\$(cat /tmp/check_gid)" && kill -USR1 \$(cat /tmp/check_wallpaper.pid) && echo \$(cat /tmp/check_gid) > /tmp/prev_gid'

alias vc='mpv --volume=60 --fullscreen ${wallpaper_dir}/\$(cat /tmp/check_gid)/*.mp4'

EOF

perform_task(){
    (

        row="$(sqlite3 $DB_NAME 'select gid,title from gid_list order by play_time asc, resolution desc limit 1')"
        IFS='|' read -r gid title <<< "$row"

        # gid 가 없으면 (테이블에 데이터가 없으면 중지)
        if [ -z $gid ]; then
            kill $$
            exit 1
        fi

        command="$wallpaper_engine --screen-root $1 --bg ${wallpaper_dir}/$gid --scaling fill --no-fullscreen-pause --volume 60 --fps 60"

        $command &

        pid=$!

        echo "$pid" > /tmp/galary.pid

        echo "$gid" > /tmp/check_gid

        wait $pid

        # if [ "$?" != 0  -a "$?" != 143 ]; then
        #     if [ -e "$HOME/.sync/wallpaper/error/$gid" ]; then
        #         rm -rf "${wallpaper_dir:?}/$gid"
        #     else
        #         mv "${wallpaper_dir:?}/$gid" "$HOME/.sync/wallpaper/error/$gid"
        #     fi
        #
        #     sqlite3 "$DB_NAME" "delete from gid_list where gid=$gid"
        #
        #     kill -USR1 $$
        # fi

    ) &
}

handle_signal() {
    killall -s 9 wallpaperengine
    restart_task=1
}

trap 'handle_signal' SIGUSR1

INTERVAL=120000
restart_task=0

while true; do
    perform_task $1

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

tput cnorm
