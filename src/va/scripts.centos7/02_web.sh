#!/bin/bash

# all web packages are installed as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# install ntp server (we need to have the date time syncronized as SSL bump relies on correct system time)
yum -y install ntp && systemctl enable ntpd && systemctl start ntpd

# install python libs and compiler (needed for reportlab)
yum -y install \
	python-devel python-pip python-ldap \
	net-tools libjpeg-devel zlib-devel gcc-c++

# install python django for web ui
pip install django==1.6.11
pip install reportlab==3.3.0

# install apache web server to run web ui
yum -y install httpd mod_wsgi

# make apache autostart on reboot
systemctl enable httpd.service

# this fixes some apache errors when working with python-django wsgi
echo "WSGISocketPrefix /var/run/wsgi" >> /etc/httpd/conf.d/wsgi.conf

# and restart apache
service httpd restart
