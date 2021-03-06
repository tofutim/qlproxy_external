#!/bin/bash

# all web packages are installed as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# stop in case of any error
set -e

# install required python libs
apt-get -y install python-ldap python-pip

# install django
pip install django==1.6.11

# to have PDF reports we need to install reportlab with a lot of dependencies
apt-get -y install python-dev libjpeg-dev zlib1g-dev

# now install reportlab
pip install reportlab==3.3.0

# install apache and mod_wsgi
apt-get -y install apache2 libapache2-mod-wsgi

# sometimes the check-new-release process on Ubuntu eats all CPU, so we switch it to manual
sed -i "s/Prompt=lts/Prompt=never/g" /etc/update-manager/release-upgrades
