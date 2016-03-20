#!/bin/bash

# all packages are installed as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# install build tools
apt-get -y install devscripts build-essential fakeroot libssl-dev

# fetch the source for the package to re-build
apt-get source squid3

# reset the owner
CURRENT_USER=`logname`
chown -R $CURRENT_USER:$CURRENT_USER .

# fetch dependent packages for the build
apt-get -y build-dep squid3
