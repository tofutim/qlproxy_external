#!/bin/csh

# setup some configuration variables
ARCH1=`uname -m`
ARCH2=`uname -m`

# for i386 the suffix is different
if [ $ARCH1 == 'i386' ]; then
    ARCH2='x86'
fi

DDWS_VERSION=4.5.0
DDWS_BUILD=50FA

# see if qlproxy group exists
echo "Searching for group qlproxy..."
getent group qlproxy >/dev/null
if [ $? -ne 0 ] ; then
    echo "Group qlproxy is not found, please add it through pfSense Web UI."
    exit 1
else
    echo "Group qlproxy already exists."
fi

# see if qlproxy user exists
echo "Searching for user qlproxy..."
getent passwd qlproxy >/dev/null
if [ $? -ne 0 ] ; then
    echo "User qlproxy is not found, please add it through pfSense Web UI."
    exit 2
else
    echo "User qlproxy already exists."
fi

# how to check user qlproxy is in qlproxy group???

# get latest version of diladele icap server
fetch http://packages.diladele.com/qlproxy/$DDWS_VERSION.$DDWS_BUILD/$ARCH1/release/freebsd10/qlproxy-$DDWS_VERSION-$ARCH2.txz

# and install it
pkg install -y qlproxy-$DDWS_VERSION-$ARCH2.txz

# now copy default apache virtual hosts file
if [ -f /usr/local/etc/apache24/extra/httpd-vhosts.conf.default ]; then
    echo "Not saving default vhosts file"
else
    cp /usr/local/etc/apache24/extra/httpd-vhosts.conf /usr/local/etc/apache24/extra/httpd-vhosts.conf.default
    echo "default vhosts file is backed up"
fi

# virtual hosts file needs to contaion only diladele virtual host
echo "Include /usr/local/etc/apache24/extra/qlproxy_virtual_host" > /usr/local/etc/apache24/extra/httpd-vhosts.conf

# restart apache
/usr/local/etc/rc.d/apache24.sh restart 
