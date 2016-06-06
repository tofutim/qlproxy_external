#!/bin/bash

# install RPMs as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# enable epel repository
yum -y install epel-release && yum -y update

# install required perl module
yum -y install perl-Crypt-OpenSSL-X509

# get latest squid
curl -O http://www1.ngtech.co.il/repo/centos/6/x86_64/squid-3.5.19-1.el6.x86_64.rpm
curl -O http://www1.ngtech.co.il/repo/centos/6/x86_64/squid-helpers-3.5.19-1.el6.x86_64.rpm

# and install it
yum -y --nogpgcheck localinstall squid-3.5.19-1.el6.x86_64.rpm
yum -y --nogpgcheck localinstall squid-helpers-3.5.19-1.el6.x86_64.rpm

# make squid autostart after reboot
chkconfig squid on
