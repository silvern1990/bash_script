#!/bin/bash


echo $$ > /tmp/check_wallpaper.pid

DB_NAME="/home/zero/gid_list.db"
wallpaper_dir=~/.sync/wallpaper
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

alias d='rm -rf ${wallpaper_dir}/\$(cat /tmp/check_gid) && sqlite3 $DB_NAME "delete from gid_list where gid=\$(cat /tmp/check_gid);" && kill -USR1 \$(cat /tmp/check_wallpaper.pid)'

alias n='sqlite3 $DB_NAME "delete from gid_list where gid=\$(cat /tmp/check_gid)" && kill -USR1 \$(cat /tmp/check_wallpaper.pid)'

alias error='([ -e ~/.sync/wallpaper/error/\$(cat /tmp/check_gid) ] && rm -rf ${wallpaper_dir}/\$(cat /tmp/check_gid)) || mv ${wallpaper_dir}/\$(cat /tmp/check_gid) ~/.sync/wallpaper/error/\$(cat /tmp/check_gid) && sqlite3 $DB_NAME "delete from gid_list where gid=\$(cat /tmp/check_gid)" && kill -USR1 \$(cat /tmp/check_wallpaper.pid)'

alias normal='([ -e ~/.sync/wallpaper/normal/\$(cat /tmp/check_gid) ] && rm -rf ${wallpaper_dir}/\$(cat /tmp/check_gid)) || mv ${wallpaper_dir}/\$(cat /tmp/check_gid) ~/.sync/wallpaper/normal/\$(cat /tmp/check_gid) && sqlite3 $DB_NAME "delete from gid_list where gid=\$(cat /tmp/check_gid)" && kill -USR1 \$(cat /tmp/check_wallpaper.pid)'

alias al='([ -e ~/.sync/wallpaper/allow/\$(cat /tmp/check_gid) ] && rm -rf ${wallpaper_dir}/\$(cat /tmp/check_gid)) || mv ${wallpaper_dir}/\$(cat /tmp/check_gid) ~/.sync/wallpaper/allow/\$(cat /tmp/check_gid) && sqlite3 $DB_NAME "delete from gid_list where gid=\$(cat /tmp/check_gid)" && kill -USR1 \$(cat /tmp/check_wallpaper.pid)'

alias dn='([ -e ~/.sync/wallpaper/deny/\$(cat /tmp/check_gid) ] && rm -rf ${wallpaper_dir}/\$(cat /tmp/check_gid)) || mv ${wallpaper_dir}/\$(cat /tmp/check_gid) ~/.sync/wallpaper/deny/\$(cat /tmp/check_gid) && sqlite3 $DB_NAME "delete from gid_list where gid=\$(cat /tmp/check_gid)" && kill -USR1 \$(cat /tmp/check_wallpaper.pid)'

alias vc='mpv --volume=100 --fullscreen \$(cat /tmp/check_gid)/*.mp4'

EOF

perform_task(){
    (

        row="$(sqlite3 $DB_NAME 'select gid,title from gid_list order by play_time asc, resolution desc limit 1')"
        IFS='|' read -r gid title <<< "$row"
        echo $title

        command="$wallpaper_engine --screen-root $1 --bg ${wallpaper_dir}/$gid --scaling fit --volume 100 --fps 60 --no-fullscreen-pause"

        $command &

        pid=$!

        echo "$pid" > /tmp/galary.pid

        echo "$gid" > /tmp/check_gid

        wait $pid

        if [ "$?" != 0  -a "$?" != 143 ]; then
            mv ${wallpaper_dir}/${gid} ~/.sync/wallpaper/error/${gid} && sqlite3 $DB_NAME "delete from gid_list where gid=${gid}"
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
