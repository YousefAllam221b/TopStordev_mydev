#!/bin/sh
stamp=`date +%s`
ref=`echo $@ | awk '{print $1}'`
stat=`echo $@ | awk '{print $2}'`
user=`echo $@ | awk '{print $3}'`
/TopStor/logqueue.py $ref $stat $user $stamp
echo /TopStor/logqueue.py $ref $stat $user $stamp > /root/queuethis
