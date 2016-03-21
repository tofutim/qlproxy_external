#!/bin/bash

# stop on every error
set -e

# install RPMs as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# install stock squid
yum -y install squid

# make squid autostart after reboot
systemctl enable squid.service
