time elasticdump --all=true --input=http://localhost:9200/ --output=$ | gzip > /usr/share/org/logs/esdump/esdump-$(date +"%Y%m%d%H").json.gz
s3cmd put    /usr/share/org/logs/esdump/*.gz  s3://org-dbbackup/elasticsearch/ && mv  /usr/share/org/logs/esdump/*.gz   /usr/share/org/logs/esdump/archive
