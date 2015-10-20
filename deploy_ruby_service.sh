#!/bin/bash

### BEGIN INIT INFO
# Provides: 
# Required-Start: $remote_fs $syslog
# Required-Stop: $remote_fs $syslog
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Ruby app service
# Description: This file starts and stops a ruby app
# 
### END INIT INFO

APPNAME="<%= scope.lookupvar('appname') -%>"
PORT="<%= scope.lookupvar('passenger_port') -%>"
APPENV="<%= scope.lookupvar('appenv') -%>"


case "$1" in
 start)
        su -l deploy -c "cd /usr/share/org/$APPNAME* && RAILS_ENV=$APPENV passenger start -p $PORT -d"
        echo "$APPNAME started"
   ;;
 stop)
        su -l deploy -c "cd /usr/share/org/$APPNAME*  && RAILS_ENV=$APPENV passenger stop -p $PORT"
        echo "$APPNAME stoped"
   ;;
 restart)
        su -l deploy -c "cd /usr/share/org/$APPNAME*  ; RAILS_ENV=$APPENV passenger stop -p $PORT ; RAILS_ENV=$APPENV passenger start -p $PORT -d"
        echo "$APPNAME restarted"
   ;;
  deploy)
#Checking numnber of Healthy instance copunt. If less then 2 then exit
HIC=$(aws elb describe-load-balancers | jq -r '.LoadBalancerDescriptions[] | select((.Instances | length) >= 0) | [.DNSName, (.Instances | length), .Instances[].InstanceId] | @csv' | grep "`curl -s http://169.254.169.254/latest/meta-data/instance-id`" | awk -F',' '{print $2}')

function hic_count() {
 for i in $HIC
 do
 if [ $i -ge 2 ];then
 HIC=2
 else
 echo "instances registered in  ELB are less then 2. Please Check!"
 exit
 fi
done
}
hic_count

function oor() {
#Taking the machine  OutOfService from ELB
hic_count
if [ -e /usr/share/org/elbcheck/elbenabled.html ] && [ $HIC -ge 2 ] ; then
echo "Bringing the machine OutOfService from ELB. Hold for 30 Sec"
mv /usr/share/org/elbcheck/elbenabled.html /usr/share/org/elbcheck/elbenabled.html.bak
sleep 30
echo "Done."
else
echo "This box is already out of ELB, since HealthCHeck file /usr/share/org/elbcheck/elbenabled.html do not exist. Kindly check"
exit
fi
}


#echo "Checking for request in passenger queue"
NUMOFREQ=`passenger-status  | grep "Requests in queue:" | awk '{print $4}'`

first_deploy () {
service $APPNAME stop 
echo "Running puppet agent"
touch /usr/share/org/deploy
puppet agent -t
su -l deploy -c "cd /usr/share/org/$APPNAME* ; RAILS_ENV=$APPENV bundle exec rake db:create" &&  su -l deploy -c  "cd /usr/share/org/$APPNAME* ; RAILS_ENV=$APPENV bundle exec rake db:migrate"
service $APPNAME start
}

deploy () {
if [ "$NUMOFREQ"  == "0" ]; then
echo "Stoping $APPNAME"
service $APPNAME stop 
#su -l deploy -c "cd /usr/share/org/$APPNAME*  && RAILS_ENV=$APPENV passenger stop -p $PORT"
echo "Running puppet agent"
touch /usr/share/org/deploy
puppet agent -t
su -l deploy -c "cd /usr/share/org/$APPNAME* ; RAILS_ENV=$APPENV bundle exec rake db:create" &&  su -l deploy -c  "cd /usr/share/org/$APPNAME* ; RAILS_ENV=$APPENV bundle exec rake db:migrate"
service $APPNAME start
else
echo "Requests are pending in Passenger queue. Please retry in some time"
fi
}

health_check () {
HTTP_STATUS=$(curl -s  -I  localhost/health-check | awk  'NR==1{print $2}')
if [ "$HTTP_STATUS" -eq 200  ] &&  [ -e /usr/share/org/elbcheck/elbenabled.html.bak ]; then
mv /usr/share/org/elbcheck/elbenabled.html.bak /usr/share/org/elbcheck/elbenabled.html
rm /usr/share/org/deploy
fi
}

if [ -z "$HIC" ]; then  echo "This box is not in any elb. Please check"
 read -p "Do you still want to Deploy (y/n)?" choice
 case "$choice" in 
  y|Y ) 
	first_deploy
	health_check;;
  n|N ) echo "no";;
  * ) echo "invalid";;
esac
exit
fi

for i in $HIC; do  if [ $i -lt 2 ]; then echo "Registered instance count in ELB is less then Two. Please check" ; exit ; fi  ; done
if [ ! -f /usr/share/org/elbcheck/elbenabled.html ]; then
    echo "Missing /usr/share/org/elbcheck/elbenabled.html.Hence this box is out of service. Please check"
    read -p "Do you still want to Deploy (y/n)?" choice
  case "$choice" in
  y|Y )
        first_deploy
        health_check;;
  n|N ) echo "no";;
  * ) echo "invalid";;
esac
exit
fi

if [ -e /usr/share/org/elbcheck/elbenabled.html ] && [ $HIC -ge 2 ] ; then
oor
deploy
health_check
fi
  ;;
 *)
   echo "Usage: $0 {start|stop|restart|deploy}" >&2
   exit 3
   ;;
esac
