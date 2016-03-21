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
apt-get install libecap3
apt-get install squid-common
apt-get install squid 
apt-get install squidclient 
