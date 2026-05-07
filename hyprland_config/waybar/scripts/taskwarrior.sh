#!/usr/bin/env bash
# Taskwarrior <-> waybar bridge
# Subcommands:
#   status   JSON for waybar (text/tooltip/class)
#   menu     wofi menu of pending tasks; selecting one shows actions
#   add      wofi prompt to add a new task
set -euo pipefail

cmd="${1:-status}"

# Render pending tasks as a tooltip-friendly multi-line string.
tooltip_text() {
  local out
  out=$(task rc.verbose=nothing rc.defaultwidth=60 list 2>/dev/null || true)
  if [[ -z "$out" ]]; then
    echo "할일이 없습니다"
  else
    # waybar tooltip is pango markup; escape &<>
    printf '%s' "$out" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'
  fi
}

pending_count() {
  task +PENDING count 2>/dev/null || echo 0
}

case "$cmd" in
  status)
    count=$(pending_count)
    tooltip=$(tooltip_text)
    if [[ $count -gt 0 ]]; then
      text="$count"
      state="has-tasks"
    else
      text=""
      state="empty"
    fi
    jq -n --arg text "$text" \
          --arg tooltip "$tooltip" \
          --arg state "$state" \
          '{text:$text, tooltip:$tooltip, class:$state, alt:$state}'
    ;;

  menu)
    # Build list of pending tasks: "<id>  <description>" (description flattened to one line)
    list=$(task +PENDING export 2>/dev/null \
      | jq -r 'sort_by(-.urgency) | .[] | "\(.id)  \(.description | gsub("[\r\n\t]+";" "))"')
    entries=$'  새 할일 추가\n'"$list"
    sel=$(printf '%s' "$entries" | wofi --dmenu --prompt="할일" --width=600 --height=400 || true)
    [[ -z "$sel" ]] && exit 0

    if [[ "$sel" == *"새 할일 추가"* ]]; then
      "$0" add
      exit 0
    fi

    # extract task id (first whitespace-separated token)
    id=$(echo "$sel" | awk '{print $1}')
    [[ -z "$id" ]] && exit 0
    desc=$(task _get "$id".description 2>/dev/null || echo "")

    action=$(printf '완료\n수정\n삭제\n취소' | wofi --dmenu --prompt="[$id] $desc" --width=300 --height=200 || true)
    case "$action" in
      완료)
        task "$id" done >/dev/null 2>&1 && notify-send "Taskwarrior" "완료: $desc"
        ;;
      수정)
        new=$(printf '%s' "$desc" | wofi --dmenu --prompt="수정" --width=500 --height=80 || true)
        if [[ -n "$new" && "$new" != "$desc" ]]; then
          task "$id" modify description:"$new" >/dev/null 2>&1 && notify-send "Taskwarrior" "수정: $new"
        fi
        ;;
      삭제)
        confirm=$(printf '아니오\n예' | wofi --dmenu --prompt="삭제: $desc ?" --width=300 --height=150 || true)
        if [[ "$confirm" == "예" ]]; then
          echo y | task "$id" delete >/dev/null 2>&1 && notify-send "Taskwarrior" "삭제: $desc"
        fi
        ;;
      *) : ;;
    esac
    pkill -RTMIN+11 waybar 2>/dev/null || true
    ;;

  add)
    desc=$(printf '' | wofi --dmenu --prompt="새 할일" --width=500 --height=80 || true)
    if [[ -n "$desc" ]]; then
      task add "$desc" >/dev/null 2>&1 && notify-send "Taskwarrior" "추가: $desc"
    fi
    pkill -RTMIN+11 waybar 2>/dev/null || true
    ;;

  *)
    echo "usage: $0 {status|menu|add}" >&2
    exit 2
    ;;
esac
