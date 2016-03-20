#!/bin/bash

# we must be root to install packages
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# install the server
if [ -f /etc/centos-release ] || [ -f /etc/redhat-release ]; then
	# centos, redhat
	yum install -y mariadb-server mariadb patch MySQL-python

	# enable and start it
	systemctl enable mariadb.service
	systemctl start mariadb.service

else
	# debian, ubuntu
	export DEBIAN_FRONTEND=noninteractive 

	# install it
	apt-get -y install mysql-server python-mysqldb
fi
