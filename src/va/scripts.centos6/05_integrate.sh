#!/bin/bash

# integration should be done as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# allow incoming connections for Web UI and Squid
iptables -I INPUT -p tcp -m tcp --dport 3128 -j ACCEPT
iptables -I INPUT -p tcp -m tcp --dport 80 -j ACCEPT
service iptables save
service iptables restart

# perform integration by replacing squid.conf file
if [ ! -f /etc/squid/squid.conf.original ]; then
    mv /etc/squid/squid.conf /etc/squid/squid.conf.original
fi

# create storage for generated ssl certificates
/usr/lib64/squid/ssl_crtd -c -s /var/spool/squid_ssldb

# and change its ownership
chown -R squid:squid /var/spool/squid_ssldb

# now move new configuration in place
mv squid.conf /etc/squid/squid.conf

# allow web ui read-only access to squid configuration file
chmod o+r /etc/squid/squid.conf

# parse the resulting config just to be sure
/usr/sbin/squid -k parse

# restart squid to load all config
service squid restart
