#!/bin/sh

cursoron(){
    # 커서 표시
    tput cnorm
}

# docker stats 을 메인 쉘 에서 실행하면 SIGINT 를 가로채기 때문에 trap 을 사용한다.
trap cursoron SIGINT

# 커서 숨김
tput civis

docker stats --format "{{.Container}},{{.CPUPerc}},{{.MemUsage}}" | while IFS=, read -r container cpu mem;
do
    image=$(docker ps --filter "id=$container" --format "{{.Image}}")

    if [ ${#cpu} -gt 0 ]; then
        STATINFO="$container ($image) - CPU: $cpu, Memory: $mem"
    else
        STATINFO="$container"
    fi
    echo $STATINFO
done

# 스크립트 종료 시 커서 다시 표시
tput cnorm
