#!/bin/bash
#Purpose To take dump of  database1 and database2 database backup
#Author Devops Team (Rajesh)
#Last updated  18 oct 2015

DUMPDIR=/usr/share/org/mongo_dump
ARCHIVEDIR=/usr/share/org/mongo_dump/archive

DB1=database1
DB2=database2

cd /usr/share/org/mongo_dump
for i in ${DB1} ${DB2}
	do
	mongodump --db $i --out ${DUMPDIR}
	logger "Created dump of $i in  ${DUMPDIR}"
	tar -P --force-local -cvzf  $DUMPDIR/$i-$(date +%F-%H-%M-%S).tar.gz  -C $DUMPDIR $i 
	s3cmd put ${DUMPDIR}/${i}-*.gz	s3://org-dbbackup/mongo/
	logger "uploaded ${i} dump to s3://org-dbbackup/mongo/"
	done
mv $DUMPDIR/*.gz $ARCHIVEDIR/
find $ARCHIVEDIR/* -mtime +120 -delete
