#!/bin/sh
cd /TopStor
export ETCDCTL_API=3
resname=`echo $@ | awk '{print $1}'`
mounts=`echo $@ | awk '{print $2}' | sed 's/\-v/ \-v /g'`
ipaddr=`echo $@ | awk '{print $3}'`
ipsubnet=`echo $@ | awk '{print $4}'`
echo $@ > /root/cifstmp
echo $resname >> /root/cifstmp
echo $mounts >> /root/cifstmp
echo $ipaddr $ipsubnet >> /root/cifstmp
docker rm -f $resname
nmcli conn mod cmynode -ipv4.addresses ${ipaddr}/$ipsubnet
nmcli conn mod cmynode +ipv4.addresses ${ipaddr}/$ipsubnet
nmcli conn up cmynode
docker run -d $mounts --rm --privileged \
  -e "HOSTIP=$ipaddr"  \
  -p $ipaddr:135:135 \
  -p $ipaddr:137:137/udp \
  -p $ipaddr:138:138/udp \
  -p $ipaddr:139:139 \
  -p $ipaddr:445:445 \
  -v /TopStordata/smb.${ipaddr}:/config/smb.conf:rw \
  -v /TopStor/smb.conf:/etc/samba/smb.conf:rw \
  -v /etc/:/hostetc/   \
  -v /var/lib/samba/private:/var/lib/samba/private:rw \
  --name $resname moataznegm/quickstor:smb
  sleep 1 
  docker exec $resname sh /hostetc/VolumeCIFSupdate.sh
