#!/bin/sh
export ETCDCTL_API=3
enpdev='enp0s8'
pool=`echo $@ | awk '{print $1}'`
vol=`echo $@ | awk '{print $2}'`
ipaddr=`echo $@ | awk '{print $3}'`
ipsubnet=`echo $@ | awk '{print $4}'`
rightvol=`/pace/etcdget.py ipaddr/$ipaddr`
echo $rightvol=
if [ $rightvol -eq '-1' ];
then
 /pace/etcdput.py ipaddr/$ipaddr 1/$vol
 /pace/broadcasttolocal.py ipaddr/$ipaddr 1/$vol 
 echo $@ > /root/nfsparam
 docker stop nfs-$pool-$vol
 docker container rm nfs-$pool-$vol
 yes | cp /etc/{passwd,group,shadow} /opt/passwds
 cp /TopStordata/exports.${vol} /TopStordata/exports.$ipaddr
 /sbin/pcs resource delete --force ip-$pool-$vol  2>/dev/null
 /sbin/pcs resource create ip-$pool-$vol ocf:heartbeat:IPaddr2 ip=$ipaddr nic=$enpdev cidr_netmask=$ipsubnet op monitor interval=5s on-fail=restart
 /sbin/pcs resource group add ip-all ip-$pool-$vol
 docker run -d -v /$pool:/$pool:rw -v /TopStordata/exports.$ipaddr:/etc/exports:ro \
  --cap-add SYS_ADMIN -p $ipaddr:2049:2049  -p $ipaddr:2049:2049/udp \
  -p $ipaddr:32765:32765 -p $ipaddr:32765:32765/udp \
  -p $ipaddr:111:111 -p $ipaddr:111:111/udp \
  -p $ipaddr:32767:32767 -p $ipaddr:32767:32767/udp \
  -v /opt/passwds/passwd:/etc/passwd:rw \
  -v /opt/passwds/group:/etc/group:rw \
  -v /opt/passwds/shadow:/etc/shadow:rw \
  --name nfs-$pool-$vol 10.11.11.124:5000/nfs
else
 count=`echo $rightvol | awk -F'/' '{print $1}'`
 origvol=`echo $rightvol | awk -F'/' '{print $2}'`
 newcount=$((count+1))
 /pace/etcdput.py ipaddr/$ipaddr $newcount/$origvol
 /pace/broadcasttolocal.py ipaddr/$ipaddr $newcount/$origvol 
 cat /TopStordata/exports.${vol} >> /TopStordata/exports.$ipaddr
 docker exec -it nfs-$pool-$origvol exportfs -ra 
fi
