#!/bin/tcsh

# in pfsense 2.3 a lot of packages were removed from default repository
setenv REPOURL http://pkg.freebsd.org/freebsd:10:x86:64/release_3/All

# install apache 24
pkg add $REPOURL/gdbm-1.11_2.txz
pkg add $REPOURL/db5-5.3.28_3.txz
pkg add $REPOURL/apr-1.5.2.1.5.4.txz
pkg add $REPOURL/apache24-2.4.18.txz
pkg add $REPOURL/ap24-mod_wsgi4-4.4.21.txz

# install django and sqlite modules for python
pkg add $REPOURL/py27-setuptools27-19.2.txz
pkg add $REPOURL/py27-sqlite3-2.7.11_7.txz
pkg add $REPOURL/py27-django16-1.6.11.txz

# in order to correctly start up apache at boot time init script needs to be renamed
cp /usr/local/etc/rc.d/apache24 /usr/local/etc/rc.d/apache24.sh

# make apache autostart
sed -i '' 's/apache24_enable=\"NO\"/apache24_enable=\"YES\"/' /usr/local/etc/rc.d/apache24.sh

# load wsgi module
sed -i '' 's/\#LoadModule wsgi_module        libexec\/apache24\/mod_wsgi.so/LoadModule wsgi_module        libexec\/apache24\/mod_wsgi.so/' /usr/local/etc/apache24/modules.d/270_mod_wsgi.conf

# make apache listen on 8080 port
sed -i '' 's/Listen 80/Listen 8080/' /usr/local/etc/apache24/httpd.conf

# and include the virtual hosts
sed -i '' 's/\#Include etc\/apache24\/extra\/httpd-vhosts.conf/Include etc\/apache24\/extra\/httpd-vhosts.conf/' /usr/local/etc/apache24/httpd.conf 
