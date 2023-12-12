#!/bin/bash

# sshpass로 sftp에 로그인과 동시에 파일 전송
#
sshpass -p '!@pass@1' sftp -oBatchMode=no -b - gn_was << EOF
put ./target/eas-0.0.1-SNAPSHOT.war /opt/ndps/deploy
EOF

# 서버에 접속후 특정 명령 실행
#
sshpass -p '!@pass@1' ssh gn_was 'cd /opt/ndps/deploy;sh deploy.sh'
