#!/bin/bash

# QUrl::toString(QUrl::PrettyDecoded) 와 동일한 형태로 경로를 URL 로 만든다.
# (UTF-8 과 공백은 그대로, % # ? [ ] 와 제어문자만 퍼센트 인코딩)
# KIO 가 실제로 D-Bus 로 내보내는 문자열과 같아야 Dolphin 이 항목을 찾아낸다.
path_to_url() {
    local LC_ALL=C s=$1 out='' i c
    for (( i = 0; i < ${#s}; i++ )); do
        c=${s:i:1}
        case $c in
            '%'|'#'|'?'|'['|']')
                printf -v c '%%%02X' "$(printf '%d' "'$c")"
                out+=$c
                ;;
            *)
                out+=$c
                ;;
        esac
    done
    printf 'file://%s' "$out"
}

# 이름을 바꿨다는 사실을 KIO 에 알린다. 이러면 Dolphin 이 항목을 지웠다 다시
# 넣지 않고 제자리에서 갱신하므로 선택/포커스가 그대로 유지된다.
notify_renamed() {
    local src dst
    src=$(path_to_url "$1")
    dst=$(path_to_url "$2")

    dbus-send --session --type=signal / \
        org.kde.KDirNotify.FileRenamed string:"$src" string:"$dst" 2>/dev/null
    dbus-send --session --type=signal / \
        org.kde.KDirNotify.FileRenamedWithLocalPath string:"$src" string:"$dst" string:"" 2>/dev/null
    dbus-send --session --type=signal / \
        org.kde.KDirNotify.FileMoved string:"$src" string:"$dst" 2>/dev/null
}

for file in "$@"; do
    # %F 는 보통 절대경로지만, 혹시 상대경로로 들어와도 URL 이 어긋나지 않게.
    [[ "$file" != /* ]] && file="$PWD/$file"

    dir=$(dirname -- "$file")
    name=$(basename -- "$file")

    [[ "$name" == "[SS]"* ]] && continue

    target="$dir/[SS]$name"

    if [[ -e "$target" ]]; then
        base="${name%.*}"
        ext=""

        if [[ "$name" == *.* && "$name" != .* ]]; then
            ext=".${name##*.}"
            base="${name%.*}"
        fi


        i=1

        while [[ -e "$dir/[SS]${base} ($i)$ext" ]]; do
            ((i++))
        done

        target="$dir/[SS]${base} ($i)$ext"
    fi

    if mv -- "$file" "$target"; then
        notify_renamed "$file" "$target"
    fi

done
