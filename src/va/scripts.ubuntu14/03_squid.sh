#!/bin/bash

# all packages are installed as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# add new repo
echo "deb http://ubuntu.diladele.com/ubuntu/ trusty main" > /etc/apt/sources.list.d/ubuntu.diladele.com.list

# update the apt cache
apt-get update

# install libecap tools
apt-get install --allow-unauthenticated -y libecap3
apt-get install --allow-unauthenticated -y squid-common
apt-get install --allow-unauthenticated -y squid 
apt-get install --allow-unauthenticated -y squidclient 
apt-get install -y mc
