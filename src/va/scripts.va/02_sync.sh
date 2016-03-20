#!/bin/bash

# we must be root to install packages
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# stop apache
if [ -f /etc/centos-release ] || [ -f /etc/redhat-release ]; then
	systemctl stop httpd
else
	service apache2 stop
fi

# set default password for root
mysqladmin -u root password Passw0rd

# create the database (all mysql specific settings are taken from settings.py)
python /opt/qlproxy/var/console/switch_db.py --db=mysql

# generate the monitor.json in /opt/qlproxy/etc/ with new correct database settings
python /opt/qlproxy/var/console/sync_db.py

# restart django and wsmgrd
if [ -f /etc/centos-release ] || [ -f /etc/redhat-release ]; then
	systemctl restart httpd
	systemctl restart wsmgrd
else
	service apache2 restart
	service wsmgrd restart
fi

# reset the owner
chown -R qlproxy:qlproxy /opt/qlproxy
