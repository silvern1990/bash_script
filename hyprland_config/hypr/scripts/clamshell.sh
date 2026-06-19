#!/usr/bin/env bash
# Clamshell mode handler
# 외부 모니터가 연결돼 있을 때만 내장 화면(eDP-1)을 끈다.
# 외부 모니터가 없으면 덮개를 닫아도 eDP-1을 유지해서
# "유일한 화면이 꺼져 stuck" 상태를 방지한다.

LID_STATE_FILE=$(echo /proc/acpi/button/lid/*/state)
LOG=/tmp/clamshell.log

log() { echo "[$(date '+%H:%M:%S')] $*" >>"$LOG"; }

# 실제 외부 모니터가 있는지 확인.
# 모든 모니터가 빠지면 Hyprland가 HEADLESS-* 가짜 출력을 만들기 때문에
# 단순히 "eDP-1이 아닌 것"으로만 판단하면 폴백 모니터를 외부로 오인한다.
external_connected() {
    hyprctl monitors -j \
        | jq -e 'any(.[]; .name != "eDP-1" and (.name | startswith("HEADLESS") | not))' \
          >/dev/null 2>&1
}

# eDP-1이 켜졌고 disabled가 아니면 0
internal_is_on() {
    hyprctl monitors -j \
        | jq -e 'any(.[]; .name == "eDP-1")' >/dev/null 2>&1
}

# eDP-1 DRM 커넥터를 강제로 재프로브 (root 필요, sudoers 로 무암호 허용해 둠).
# 덮개 닫힘+외부제거를 거치면 커넥터가 disconnected 로 굳어 Hyprland 가
# eDP-1 을 다시 못 켜는데, 이걸로 커널 재검출을 유발한다.
reprobe_edp() {
    sudo -n /usr/local/bin/edp-reprobe 2>>"$LOG" \
        && log "  reprobe: eDP-1 커넥터 재프로브 요청" \
        || log "  reprobe: 실패(헬퍼 미설치 또는 sudo 거부)"
}

edp_status() { cat /sys/class/drm/*-eDP-1/status 2>/dev/null | tr '\n' ' '; }

enable_internal() {
    # 덮개를 열어도 커넥터가 stale 이라 한 번에 안 켜질 수 있다.
    # 안 켜지면 커넥터를 강제 재프로브하고 다시 시도한다.
    log "  [diag] sysfs status=[$(edp_status)]"
    log "  [diag] eDP-1 obj=$(hyprctl monitors all -j | jq -c '.[]|select(.name=="eDP-1")|{disabled,width:.width,height:.height,modes:(.availableModes|length)}' 2>/dev/null)"
    local i out
    for i in 1 2 3 4 5 6; do
        out=$(hyprctl keyword monitor "eDP-1, preferred, auto, 1" 2>&1)
        hyprctl dispatch dpms on eDP-1 >/dev/null 2>&1
        if internal_is_on; then
            log "  enable: eDP-1 on (try $i)"
            break
        fi
        log "  enable: eDP-1 still off (try $i) keyword->[$out]"
        reprobe_edp
        log "  [diag] sysfs after reprobe=[$(edp_status)]"
        sleep 0.5
    done
    if ! internal_is_on; then
        log "  last-resort: hyprctl reload"
        hyprctl reload >/dev/null 2>&1
        sleep 0.8
        log "  after reload: monitors=[$(hyprctl monitors -j | jq -r '[.[].name]|join(",")' 2>/dev/null)] sysfs=[$(edp_status)]"
    fi

    # eDP-1이 꺼진 상태에서 외부 모니터를 뽑으면 Hyprland는 HEADLESS 폴백
    # 모니터를 만들고 워크스페이스를 그쪽으로 옮긴다. eDP-1을 다시 켜도
    # 창들이 HEADLESS에 남아 내장 화면이 빈 채로 보이므로 회수한다.
    local ws
    for ws in $(hyprctl monitors all -j \
                  | jq -r '.[] | select(.name | startswith("HEADLESS")) | .activeWorkspace.id'); do
        log "  recover workspace $ws -> eDP-1"
        hyprctl dispatch moveworkspacetomonitor "$ws eDP-1"
    done
    hyprctl dispatch focusmonitor eDP-1 >/dev/null 2>&1
}

disable_internal() {
    hyprctl keyword monitor "eDP-1, preferred, auto, 1"  # 끄기 전 켜진 상태 보장
    hyprctl keyword monitor "eDP-1, disable"
}

# ---- 진단 로그 ----
lid="closed"
grep -q closed "$LID_STATE_FILE" 2>/dev/null || lid="open"
log "TRIGGER lid=$lid  monitors=[$(hyprctl monitors -j | jq -r '[.[].name] | join(",")' 2>/dev/null)]  all=[$(hyprctl monitors all -j | jq -r '[.[].name] | join(",")' 2>/dev/null)]"

if [ "$lid" = "closed" ]; then
    # 덮개 닫힘: 외부 모니터가 있을 때만 내장 화면 끄기
    if external_connected; then
        log "  action: disable_internal (external present)"
        disable_internal
    else
        log "  action: enable_internal (no external, lid closed)"
        enable_internal
    fi
else
    # 덮개 열림: 항상 내장 화면 켜기
    log "  action: enable_internal (lid open)"
    enable_internal
fi
log "DONE  monitors=[$(hyprctl monitors -j | jq -r '[.[].name] | join(",")' 2>/dev/null)]"
