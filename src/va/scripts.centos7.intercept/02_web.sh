#!/bin/bash
set -e

# all web packages are installed as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# install python libs
yum -y install python-setuptools python-ldap net-tools

# install python django for web ui
easy_install django==1.6.11

# install apache web server to run web ui
yum -y install httpd mod_wsgi

# make apache autostart on reboot
systemctl enable httpd.service

# this fixes some apache errors when working with python-django wsgi
echo "WSGISocketPrefix /var/run/wsgi" >> /etc/httpd/conf.d/wsgi.conf

# and restart apache
service httpd restart
