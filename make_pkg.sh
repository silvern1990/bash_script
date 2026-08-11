#!/bin/zsh


FILES=$(find /home/zero/background -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.webp" -o -name "*.webm" \) | sort)

ID=$(($(ls ~/.sync/wallpaper/deny ~/.sync/wallpaper/allow ~/.sync/wallpaper/normal ~/.sync/temp | sort -rn | head -n 1)+1))
for file in $FILES
do
    name=$(basename "$file")
    name="${name%.jpg}"
    name="${name%.png}"
    name="${name%.webp}"

    echo "$ID"

    ID=$(($ID+1))

    mode="scene"

    if [[ "${file##*.}" == "webp" ]];
    then
        mode="video"
    fi

    python3 /home/zero/git/python/pkg.py --mode $mode "$file" /home/zero/temp/"$ID" "$name"
done
