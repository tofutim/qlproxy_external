#!/bin/bash

# all packages are installed as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# default arc
MAJOR="4.5.0"
MINOR="8CEF"

# get latest qlproxy
curl -O http://packages.diladele.com/qlproxy/$MAJOR.$MINOR/amd64/release/centos7/qlproxy-${MAJOR}-${MINOR}.x86_64.rpm

# install it
yum -y --nogpgcheck localinstall qlproxy-${MAJOR}-${MINOR}.x86_64.rpm
  
# qlproxy installed everything needed for apache, so just restart
systemctl restart httpd.service
