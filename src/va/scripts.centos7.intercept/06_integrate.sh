#!/bin/bash

# integration should be done as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# perform integration by replacing squid.conf file
if [ ! -f /etc/squid/squid.conf.original ]; then
    mv /etc/squid/squid.conf /etc/squid/squid.conf.original
fi

# stop on any error
set -e

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
systemctl restart squid.service

echo "Squid integrated!"