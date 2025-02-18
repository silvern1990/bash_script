#!/bin/sh

cursoron(){
    # 커서 표시
    echo "\033[?25h"
    exit 1
}


trap cursoron SIGINT

# 커서 숨김
echo "\033[?25l"

# docker stats 을 메인 쉘 에서 실행하면 SIGINT 를 가로채기 때문에 trap 이 실행되지 않는다. 서브 쉘로 실행하여 trap이 정상작동하도록 만든다.

(docker stats --format "{{.Container}},{{.CPUPerc}},{{.MemUsage}}" | while IFS=, read -r container cpu mem; 
do
    image=$(docker ps --filter "id=$container" --format "{{.Image}}")

    if [ ${#cpu} -gt 0 ]; then
        STATINFO="$container ($image) - CPU: $cpu, Memory: $mem"
    else
        STATINFO="$container"
    fi
    echo $STATINFO
done) &

while true; do
    sleep 30
done
