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

# get latest squid and ecap library
curl -O http://www1.ngtech.co.il/repo/centos/7/x86_64/libecap-1.0.0-3.el7.centos.x86_64.rpm
curl -O http://www1.ngtech.co.il/repo/centos/7/x86_64/squid-3.5.20-1.el7.centos.x86_64.rpm
curl -O http://www1.ngtech.co.il/repo/centos/7/x86_64/squid-helpers-3.5.20-1.el7.centos.x86_64.rpm

# and install it
yum -y --nogpgcheck localinstall libecap-1.0.0-3.el7.centos.x86_64.rpm
yum -y --nogpgcheck localinstall squid-3.5.20-1.el7.centos.x86_64.rpm
yum -y --nogpgcheck localinstall squid-helpers-3.5.20-1.el7.centos.x86_64.rpm

# make squid autostart after reboot
systemctl enable squid.service