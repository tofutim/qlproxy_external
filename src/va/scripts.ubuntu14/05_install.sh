#!/bin/bash

# all packages are installed as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# stop right away in case of any error
set -e

# install some more required packages
apt-get -y install ssl-cert squid-langpack

# install our recompiled packages
dpkg --install squid3-common_3.3.8-1ubuntu6.*_all.deb
dpkg --install squid3_3.3.8-1ubuntu6.*_amd64.deb
dpkg --install squidclient_3.3.8-1ubuntu6.*_amd64.deb

# put the squid on hold to prevent updating
apt-mark hold squid3 squid3-common
