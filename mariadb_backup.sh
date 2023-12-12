#!/bin/bash


MYSQL_ARGS="-uroot"
MYSQL="/usr/bin/mysql $MYSQL_ARGS"
MYSQLDUMP="/usr/bin/mysqldump $MYSQL_ARGS --ignore-table=ext_support.send"   # 백업중인 테이블은 LOCK이걸려 사용할 수 없게 된다.
BACKUP="/data/backup"


$MYSQL -BNe "show databases" | egrep -v '(mysql|.*_schema|sys)' | xargs -n1 -I {} $MYSQLDUMP {} -r $BACKUP/{}.sql && chmod 640 $BACKUP/*.sql && tar cvzf $BACKUP/backup_`date +%y_%m_%d`.tar.gz $BACKUP/*.sql && rm -rf $BACKUP/*.sql
