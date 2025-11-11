#!/bin/sh

echo $$ > /tmp/wallpaper.pid
echo "1" > /tmp/gid.txt

pid=""

wallpaper_dir="/home/zero/.sync/wallpaper"
kind="deny"


INTERVAL=600

perform_task() {
    gid="$(ls ~/.sync/wallpaper/$kind | sort -R | head -n1)"

    ls ${wallpaper_dir}/${kind}/${gid}/*.mp4
    if [ $? -eq 0 ]; then
        PLAY_TIME=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 ${wallpaper_dir}/${kind}/${gid}/*.mp4)
        INTERVAL=$(awk "BEGIN {printf(\"%.0f\", $PLAY_TIME)}")
    else
        INTERVAL=600
    fi

    if [ $INTERVAL -lt 600 ]; then
        INTERVAL=600
    fi

    for display in "$@"; do
        command="wallpaperengine --screen-root $display --bg /home/zero/.sync/wallpaper/$kind/$gid --scaling fit --volume 100"
        # command="wallpaperengine /home/zero/.sync/wallpaper/$kind/$gid --volume 100"
        $command >> /dev/null &
        pid+="${!} "
    done


    echo "$gid" > /tmp/gid.txt
}

handle_signal() {
    for id in $pid; do
        echo $pid
    done

    for id in $pid; do
        kill $pid
    done

    pid=""

    restart_task=1
}

trap 'handle_signal' SIGUSR1

restart_task=0


cat > ~/alias/.env << EOF
alias n='kill -USR1 \$(cat /tmp/wallpaper.pid)'
alias d='rm -rf ${wallpaper_dir}/${kind}/\$(cat /tmp/gid.txt) && kill -USR1 \$(cat /tmp/wallpaper.pid)'
alias error='mv ${wallpaper_dir}/${kind}/\$(cat /tmp/gid.txt) ${wallpaper_dir}/error/\$(cat /tmp/gid.txt) && kill -USR1 \$(cat /tmp/wallpaper.pid)'
alias normal='mv ${wallpaper_dir}/${kind}/\$(cat /tmp/gid.txt) ${wallpaper_dir}/normal/\$(cat /tmp/gid.txt) && kill -USR1 \$(cat /tmp/wallpaper.pid)'
alias al='mv ${wallpaper_dir}/${kind}/\$(cat /tmp/gid.txt) ${wallpaper_dir}/allow/\$(cat /tmp/gid.txt) && kill -USR1 \$(cat /tmp/wallpaper.pid)'
alias dn='mv ${wallpaper_dir}/${kind}/\$(cat /tmp/gid.txt) ${wallpaper_dir}/deny/\$(cat /tmp/gid.txt) && kill -USR1 \$(cat /tmp/wallpaper.pid)'
alias vc='mpv --volume=100 --fullscreen \$(cat /tmp/gid.txt)/*.mp4'
EOF

while true; do
    perform_task $@

    SECONDS=0.0


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

    for id in $pid; do
        kill $pid
    done

    pid=""
done


