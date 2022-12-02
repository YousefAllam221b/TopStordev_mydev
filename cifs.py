#!/usr/bin/python3
import sys, subprocess, datetime
from logqueue import queuethis, initqueue
from etcdgetpy import etcdget as get
from sendhost import sendhost

def create(leader, leaderip, myhost, myhostip, etcdip, pool, name, ipaddr, ipsubnet, vtype):
    volsip = get(etcdip,'volume',ipaddr)
    nodesip = get(etcdip, 'Active',ipaddr) 
    notsametype = [ x for x in volsip if vtype.upper() not in str(x) ]
    if (len(nodesip) > 0 and 'Active' in str(nodesip))or len(notsametype) > 0:
        print(ipaddr)
        print(len(nodesip), nodesip)
        print(len(notsametype), notsametype)
        print(' the ip address is in use ')
        return
    resname = vtype+'-'+ipaddr
    cmdline='rm -rf /TopStordata/tempsmb.'+ipaddr
    subprocess.run(cmdline.split(),stdout=subprocess.PIPE)  
    mounts =''
    for vol in volsip:
        if vol in notsametype:
           continue
        leftvol = vol[0].split('/')[4]
        mounts += '-v/'+pool+'/'+leftvol+':/'+pool+'/'+leftvol+':rw'
        with open('/TopStordata/tempsmb.'+ipaddr,'a') as fip:
            with open('/TopStordata/smb.'+leftvol, 'r') as fvol:
                fip.write(fvol.read())
    cmdline = 'cp /TopStordata/tempsmb.'+ipaddr+' /TopStordata/smb.'+ipaddr
    subprocess.run(cmdline.split(),stdout=subprocess.PIPE)  
    cmdline = 'cp /TopStor/VolumeCIFSupdate.sh /etc/'
    subprocess.run(cmdline.split(),stdout=subprocess.PIPE)  
    cmdline = '/TopStor/cifs.sh '+resname+' '+mounts+' '+ipaddr+' '+ipsubnet
    subprocess.run(cmdline.split(),stdout=subprocess.PIPE)  
    print(mounts)
    return
    #if len(checkipaddr1) != 0 or len :

 

if __name__=='__main__':
 leader = sys.argv[1]
 leaderip = sys.argv[2]
 myhost = sys.argv[3]
 myhostip = sys.argv[4]
 etcdip = sys.argv[5]
 pool = sys.argv[6]
 name = sys.argv[7]
 ipaddr = sys.argv[8]
 ipsubnet = sys.argv[9]
 vtype = sys.argv[10]
 initqueue(leaderip, myhost)
 with open('/root/cifspytmp','w') as f:
  f.write(str(sys.argv))
 create(leader, leaderip, myhost, myhostip, etcdip, pool, name, ipaddr, ipsubnet, vtype)
