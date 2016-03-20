#!/bin/bash

# all web packages are installed as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# remove base theming for minimal patterns
rpm -e patterns-openSUSE-minimal_base-conflicts 1>&2 || true

# install python libs and apache
zypper install -y apache2
zypper install -y apache2-mod_wsgi
zypper install -y python-ldap
zypper install -y python-pip

# install python django for web ui
pip install django==1.6.11

# enable and restart apache
systemctl enable apache2
systemctl restart apache2
