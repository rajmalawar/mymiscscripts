#! /bin/bash
PWD=$(pwd)
APP=`basename $PWD`
PORT=`grep -w [0-9][0-9][0-9][0-9] /opt/nginx/sites-enabled/$(basename $PWD)  | awk -F'[:;]' '{print $2}'`
PORTBITS=${#PORT}

if [ $PORTBITS -ne 4 ] || [ -z "$PORT" ]; then
echo "port is null or not correctly set to four digit. Please check and rerun. Should be between 1000 and 9999"
fi 

echo "your are doing operation on app $APP"
#Start STOP RESTART BLOCK
if [ "$1" == "start" ]; then 
	RAILS_ENV=qa passenger start -p $PORT -d
	echo "$APP started"
elif [ "$1" == "stop" ]; then
	RAILS_ENV=qa passenger stop -p $PORT
    	echo "$APP stoped"
elif [ "$1" == "restart" ]; then
	RAILS_ENV=qa passenger stop -p $PORT && RAILS_ENV=qa passenger start -p $PORT -d
	echo "$APP restarted"
else
	echo "Call with start|stop|restart"
fi
