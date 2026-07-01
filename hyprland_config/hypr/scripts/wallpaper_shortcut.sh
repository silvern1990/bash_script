focused_win=$(hyprctl activewindow -j)

if [ "$focused_win" == "{}" ]; then
    if [ "$1" == "delete" ]; then
        bash -c "shopt -s expand_aliases && source ~/alias/.env && eval d && killall -s 9 mpv"
    elif [ "$1" == "exit" ]; then
        bash -c "killall -s 9 wallpaperengine ; killall -s 9 mpv"
    elif [ "$1" == "mpv" ]; then
        bash -c "shopt -s expand_aliases && source ~/alias/.env && eval vc"
    elif [ "$1" == "next" ]; then
        bash -c "rm -rf /home/zero/wallpaper.db && ls /home/zero/temp | head -n 20 | xargs -I{} mv /home/zero/temp/{} /home/zero/.sync/temp && sh /home/zero/bash_script/loop_wallpaper.sh DP-1 > /tmp/log.txt ; notify-send loop exit"
    elif [ "$1" == "deny" ]; then
        bash -c "shopt -s expand_aliases && source ~/alias/.env && eval dn && killall -s 9 mpv"
    elif [ "$1" == "allow" ]; then
        bash -c "shopt -s expand_aliases && source ~/alias/.env && eval al && killall -s 9 mpv"
    elif [ "$1" == "continue" ]; then
        bash -c "sh ~/bash_script/loop_wallpaper.sh DP-1 > /tmp/log.txt ; notify-send loop exit"
    fi
else
    if [ "$1" == "delete" ]; then
        wtype -m ctrl -k q
    elif [ "$1" == "exit" ]; then
        wtype -m ctrl -k w
    elif [ "$1" == "mpv" ]; then
        wtype -m ctrl -k e
    elif [ "$1" == "next" ]; then
        wtype -m ctrl -k r
    elif [ "$1" == "deny" ]; then
        wtype -m ctrl -k d
    elif [ "$1" == "allow" ]; then
        wtype -m ctrl -k a
    elif [ "$1" == "continue" ]; then
        wtype -m ctrl -k c
    fi
fi
