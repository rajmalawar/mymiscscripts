#!/bin/sh
DBSERVER=127.0.0.1

DATABASE1=db1
DATABASE2=db2
DATABASE3=db3
DATABASE4=db4





DIR=/dbvol/backup/
USER=root
PASS=############

for i in ${DATABASE1} ${DATABASE2} ${DATABASE3} ${DATABASE4} 
	do
	#Running Mysql dump
	mysqldump --single-transaction --opt --user=${USER} --password=${PASS} ${i}  2>/dev/null > ${DIR}${i}-`date +%F-%T`.sql
	logger "created dump of ${i}"

	#Creating tar of dumped SQL file
	tar  -P  --force-local -cvzf   ${DIR}${i}-$(date +%F-%T).tar.gz ${DIR}${i}*.sql

	#Uploading to S3
	s3cmd put ${DIR}${i}-*.gz  s3://org-dbbackup/${i}/
	logger "uploaded ${i}  db dump to s3"
	done

mv ${DIR}* /dbvol/archive/
find /dbvol/archive/* -mtime +15 -delete
