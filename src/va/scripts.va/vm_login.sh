#!/bin/bash

IPADDR=`/sbin/ifconfig | grep "inet addr" | grep -v "127.0.0.1" | awk '{ print $2 }' | awk -F: '{ print $2 }'`
CPUNUM=`cat /proc/cpuinfo | grep processor | wc -l`
RAMNFO=`free -mh | grep Mem: | awk '{ print "total " $2 ", free " $4 }'`

cat > /etc/issue <<EOFTEXT
Welcome to Diladele Web Safety for Squid Proxy Web Filtering Appliance!

Operating System    Ubuntu Server Linux 14.04
Appliance Version   4.5.0
Squid Version       3.3.8
                    
Allocated RAM       $RAMNFO
CPU Count           $CPUNUM
Hard Disk Size      50 Gb
Default Username    root
Default Password    Passw0rd
Installation Dir    /opt/qlproxy

To use this Virtual Appliance - adjust your browser's proxy setting to point to the IP address or 
domain name of this box ($IPADDR:3128), and browse the web. 

Full featured Web Console is available at http://$IPADDR:80/
EOFTEXT