#!/bin/tcsh

# see if qlproxy group exists
echo "Searching for group qlproxy..."
getent group qlproxy >/dev/null
if ($status != 0) then
    echo "Group qlproxy is not found, please add it through pfSense Web UI."
    exit 1
else
    echo "Group qlproxy already exists."
endif

# see if qlproxy user exists
echo "Searching for user qlproxy..."
getent passwd qlproxy >/dev/null
if ($status != 0) then
    echo "User qlproxy is not found, please add it through pfSense Web UI."
    exit 2
else
    echo "User qlproxy already exists."
endif

# how to check user qlproxy is in qlproxy group???

# get latest version of diladele icap server
fetch http://packages.diladele.com/qlproxy/4.6.0.EB2F/amd64/release/freebsd10/qlproxy-4.6.0-amd64.txz

# and install it
pkg install -y qlproxy-4.6.0-amd64.txz

# copy default apache virtual hosts file just in case
cp -f /usr/local/etc/apache24/extra/httpd-vhosts.conf /usr/local/etc/apache24/extra/httpd-vhosts.conf.default

# virtual hosts file needs to contaion only diladele virtual host
echo "Include /usr/local/etc/apache24/extra/qlproxy_virtual_host" > /usr/local/etc/apache24/extra/httpd-vhosts.conf

# restart apache
/usr/local/etc/rc.d/apache24.sh restart 
