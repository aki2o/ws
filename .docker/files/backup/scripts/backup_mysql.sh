#!/bin/bash

VERSION=$(date '+%Y%m%d%H%M')
DUMP_PATH=/backup

mysqldump -u root -h db --all-databases --add-drop-database --lock-all-tables | gzip > ${DUMP_PATH}/mysql.all.${VERSION}.sql.gz

find ${DUMP_PATH} -name 'mysql.all.*.sql.gz' -type f -mtime +7 -exec rm -f {} \;
