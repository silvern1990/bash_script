#!/bin/zsh


FILES=$(find /home/zero/background -type f \( -name "*.jpg" -o -name "*.png" \))

ID=12312312404

for file in $FILES
do
    name=$(basename "$file")
    name="${name%.jpg}"
    name="${name%.png}"

    echo "$ID"

    ID=$(($ID+1))

    python3 /home/zero/source/pkg/pkg.py "$file" /home/zero/temp/"$ID" "$name"
done
