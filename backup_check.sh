#!/bin/bash


# ftp batch 모드로 백업 파일을 내려받는 스크립트
# 공개키를 사용하여 sftp 서버 자동 로그인 설정이 필요하다.

USER=root
BACKUP_DIR=/backup
REMOTE_DIR=/data/backup

FILES=`sftp -b - $USER@hulk << EOF
cd $REMOTE_DIR
ls *.tar.gz
EOF`

FILES=`echo $FILES | sed "s/.*sftp> ls \*.tar.gz//g"`


for FILE in $FILES; do
    echo get $REMOTE_DIR/$FILE $BACKUP_DIR/$FILE | sftp -b - $USER@hulk
done




#
# 백업 디스크의 용량이 30G 미만일 경우 30일 이상 경과한 백업파일은 모두 삭제한다.
#

SPACE=`df -h | grep /dev/sda4 | awk '{print $4}' | sed "s/G//g"`

if [ $(($SPACE)) -lt 30 ]
then
    find /backup -name "*.tar.gz" -ctime +30 -exec rm -rf {} \;
fi
