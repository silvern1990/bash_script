#!/bin/zsh


FILES=$(find /home/zero/background -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.webp" \))

ID=$(($(ls ~/.sync/wallpaper/deny ~/.sync/wallpaper/allow ~/.sync/wallpaper/normal ~/.sync/temp | sort -rn | head -n 1)+1))
for file in $FILES
do
    name=$(basename "$file")
    name="${name%.jpg}"
    name="${name%.png}"
    name="${name%.webp}"

    echo "$ID"

    ID=$(($ID+1))

    python3 /home/zero/git/python/pkg.py "$file" /home/zero/temp/"$ID" "$name"
done
