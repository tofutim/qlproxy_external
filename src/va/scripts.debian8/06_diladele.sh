#!/bin/bash

# all packages are installed as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# default arc
MAJOR="4.4.0"
MINOR="302B"
ARCH="amd64"

# get latest qlproxy
cat /proc/cpuinfo | grep -m 1 ARMv7 > /dev/null 2>&1
if [ $? -eq 0 ]; then
	ARCH="armhf"
fi

wget http://packages.diladele.com/qlproxy/$MAJOR.$MINOR/$ARCH/release/debian8/qlproxy-$MAJOR.${MINOR}_$ARCH.deb

# install it
dpkg --install qlproxy-$MAJOR.${MINOR}_$ARCH.deb

# relabel log folder
chown -R qlproxy:qlproxy /opt/qlproxy
