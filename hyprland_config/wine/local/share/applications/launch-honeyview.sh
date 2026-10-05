#!/bin/sh
# Thunar 등에서 넘어온 Linux 파일 경로를 Wine용 Windows 경로로 변환해 꿀뷰를 실행한다.
export WINEPREFIX=/home/zero/.wine

EXE="C:\\Program Files\\Honeyview\\Honeyview.exe"

if [ -n "$1" ]; then
    winfile=$(winepath -w "$1")
    exec wine "$EXE" "$winfile"
else
    exec wine "$EXE"
fi
