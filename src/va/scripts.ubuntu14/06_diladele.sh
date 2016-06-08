#!/bin/bash

# all packages are installed as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# default arc
MAJOR="4.6.0"
MINOR="85C4"
ARCH="amd64"

# get latest qlproxy
wget http://packages.diladele.com/qlproxy/$MAJOR.$MINOR/$ARCH/release/ubuntu14/qlproxy-$MAJOR.${MINOR}_$ARCH.deb

# install it
dpkg --install qlproxy-$MAJOR.${MINOR}_$ARCH.deb

# relabel folder
chown -R qlproxy:qlproxy /opt/qlproxy
