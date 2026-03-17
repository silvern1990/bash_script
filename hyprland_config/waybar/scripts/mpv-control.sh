#!/bin/bash

SOCK="$XDG_RUNTIME_DIR/mpv.sock"

start_mpv() {
    rm -f "$SOCK"

    mpv \
        --no-video \
        --idle \
        --force-window=no \
        --input-ipc-server="$SOCK" \
        --playlist=~/google_drive/mp3 \
        >/dev/null 2>&1 &
}

wait_for_sock() {
    for i in $(seq 1 20); do
        [ -S "$SOCK" ] && return 0
        sleep 0.1
    done
    return 1
}

ensure_mpv() {
    if ! pgrep -x mpv >/dev/null || [ ! -S "$SOCK" ]; then
        pkill -x mpv 2>/dev/null
        start_mpv
        wait_for_sock || exit 1
    fi
}

cmd() {
    echo "{ \"command\": $1 }" | socat - "$SOCK"
}

ensure_mpv

case "$1" in
toggle)
cmd '["cycle","pause"]'
;;

next)
cmd '["playlist-next"]'
;;

prev)
cmd '["playlist-prev"]'
;;
esac
