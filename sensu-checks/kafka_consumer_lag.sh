#!/bin/bash
#Purpose: Used to check Lag in Kafka Queue
#Author: DevOps(Rajesh)

for g in $(/usr/hdp/2.3.4.7-4/kafka/bin/kafka-consumer-groups.sh --zookeeper localhost --list | egrep -v 'console-XXXX|notifXXXX'); 
do 
SUM=$(/usr/hdp/2.3.4.7-4/kafka/bin/kafka-consumer-groups.sh --zookeeper localhost --group $g --describe | awk '!/LOG/ {sum+=$6} END { if (sum >10000) print $1, $2, sum}');
if [[ ! -z $SUM ]]; then
echo "Critical: Kafka LAG reached beyond 10000 for $SUM"
exit 2
else
NORMAL=$(echo "No LAG in Kafka consumers")
fi
done
echo "OK: $NORMAL"
exit 0
