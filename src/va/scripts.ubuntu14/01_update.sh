#!/bin/bash

# update should be done as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# update, upgrade
apt-get update && apt-get -y upgrade

# sometimes the check-new-release process on Ubuntu eats all CPU, so we switch it to manual
sed -i "s/Prompt=lts/Prompt=never/g" /etc/update-manager/release-upgrades

# and reboot
reboot