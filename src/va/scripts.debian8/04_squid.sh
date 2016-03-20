#!/bin/bash

# stop right away in case of any error
set -e

# we will compile squid as normal user, and NOT as root
if [[ $EUID -eq 0 ]]; then
   echo "This script must NOT be run as root" 1>&2
   exit 1
fi

# modify configure options in debian/rules, add --enable-ssl --enable-ssl-crtd
patch squid3-3.4.8/debian/rules < rules.patch

# modify algorithm to sign the root cert and also the fix for Firefox inadequate key error
patch squid3-3.4.8/src/ssl/gadgets.cc < gadgets.cc.patch

# build the package
cd squid3-3.4.8 && dpkg-buildpackage -rfakeroot -b
