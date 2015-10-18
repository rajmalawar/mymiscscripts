#!/bin/bash
#Purpose: Script to start, stop, restart and  reload the  myproject-service jar
#Author: Devops Team (Rajesh)
#Last Updated: 29 June 2015


#This file is maintained through Configuration Management System, Manual edit will be over written

# colors
red='\e[0;31m'
green='\e[0;32m'
yellow='\e[0;33m'
reset='\e[0m'

echoRed() { echo -e "${red}$1${reset}"; }
echoGreen() { echo -e "${green}$1${reset}"; }
echoYellow() { echo -e "${yellow}$1${reset}"; }


SERVICE_NAME=myproject
PID_FILE=/var/run/myproject.pid
PATH_TO_JAR=/usr/share/my/myproject_backend/myproject-service-*.jar
CONF_FILE=/usr/share/my/myproject_backend/myproject.yml
#NEWRELIC_JAR=/usr/share/my/myproject_backend/newrelic.jar
DAEMON=/usr/bin/java

#final process status
finalStatus()
{               
 pidof $DAEMON > /dev/null
                status=$?
                if [ $status -eq 0 ]; then
                        echoGreen  "myproject  is started and runnning"
                else
                        echoRed "myproject is not running or not started"
                fi
}
case $1 in
   start)

	if [ ! -f $PID_FILE ]; then
		echoYellow "Starting $SERVICE_NAME ... "
        	start-stop-daemon  --background  --start --user deploy  --chuid deploy  --chdir /usr/share/my/myproject_backend --make-pidfile  --pidfile $PID_FILE  --exec $DAEMON  -- -javaagent:newrelic.jar -Dnewrelic.environment=production -jar /usr/share/my/myproject_backend/myproject-service-*.jar server myproject.yml	
		echoGreen "$SERVICE_NAME started [$PID_FILE]"	
	else
		echoYellow "SERVICE_NAME is already running [$PID_FILE]"
        fi
;;
   stop)
	if [ -f $PID_FILE ]; then
            echoYellow "$SERVICE_NAME stoping ..."
	    start-stop-daemon --stop --user deploy   --name java --pidfile /var/run/myproject.pid --retry 5
	    rm -f $PID_FILE
	 echoRed "$SERVICE_NAME is stopped"
       	else
            echoRed "$SERVICE_NAME is not running"
        fi
;;
   restart)
      if [ -f $PID_FILE ]; then
            echoYellow "$SERVICE_NAME stopping ...";
	    start-stop-daemon --stop --user deploy   --name java --pidfile $PID_FILE --retry 5
            echoRed "$SERVICE_NAME stopped ";
	    rm -f $PID_FILE
            echoYellow "$SERVICE_NAME starting ... "
	start-stop-daemon  --background  --start --user deploy  --chuid deploy  --chdir /usr/share/my/myproject_backend --make-pidfile  --pidfile $PID_FILE  --exec $DAEMON  -- -javaagent:newrelic.jar -Dnewrelic.environment=production -jar /usr/share/my/myproject_backend/myproject-service-*.jar server myproject.yml 
	echoGreen "$SERVICE_NAME started [$PID_FILE]"
        else
            echoRed "$SERVICE_NAME is not running ..."
        fi
;;
status)
		pidof $DAEMON > /dev/null
		status=$?
		if [ $status -eq 0 ]; then
			echoGreen  "myproject  is running [$PID_FILE]"
		else
			echoRed "myproject is not running "
		fi
		exit $status
		;;
	*)
		echoYellow "Usage: /etc/init.d/myproject {start|stop|restart|status}"
		exit 1
		;;
esac
exit 0
