#!/bin/bash
set -e

# update should be done as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# update and upgrade
yum -y update

# disable selinux
sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/selinux/config

# and reboot
reboot
