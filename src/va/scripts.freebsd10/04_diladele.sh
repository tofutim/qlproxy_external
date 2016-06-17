#!/bin/csh

# setup some configuration variables
ARCH1=`uname -m`
ARCH2=`uname -m`

# for i386 the suffix is different
if [ $ARCH1 == 'i386' ]; then
    ARCH2='x86'
fi

DDWS_VERSION=4.6.0
DDWS_BUILD=34C7

# get latest version of web safety
fetch http://packages.diladele.com/qlproxy/$DDWS_VERSION.$DDWS_BUILD/$ARCH1/release/freebsd10/qlproxy-$DDWS_VERSION-$ARCH2.txz

# and install it
env ASSUME_ALWAYS_YES=YES pkg install -y qlproxy-$DDWS_VERSION-$ARCH2.txz

# autostart qlproxyd ICAP server
grep -e '^\s*qlproxyd_enable\s*=\s*\"YES\"\s*$' /etc/rc.conf
if [ $? -ne 0 ]; then
	echo "qlproxyd_enable=\"YES\"" >> /etc/rc.conf
fi

# autostart wsmgrd monitoring server
grep -e '^\s*wsmgrd_enable\s*=\s*\"YES\"\s*$' /etc/rc.conf
if [ $? -ne 0 ]; then
	echo "wsmgrd_enable=\"YES\"" >> /etc/rc.conf
fi
