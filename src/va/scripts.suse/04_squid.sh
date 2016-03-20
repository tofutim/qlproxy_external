#!/bin/bash

# all packages are installed as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# install squid
zypper install -y squid

# make it auto start
systemctl enable squid.service 