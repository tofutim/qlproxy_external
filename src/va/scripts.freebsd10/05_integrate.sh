#!/bin/csh

# integrate with apache, enable virtual hosts
sed -i '' 's/\#Include etc\/apache24\/extra\/httpd-vhosts.conf/Include etc\/apache24\/extra\/httpd-vhosts.conf/' /usr/local/etc/apache24/httpd.conf 

# enable wsgi 
sed -i '' 's/\#LoadModule wsgi_module/LoadModule wsgi_module/' /usr/local/etc/apache24/modules.d/270_mod_wsgi.conf

# copy default and add our virtual host
if [ ! -f /usr/local/etc/apache24/extra/httpd-vhosts.conf.default ]; then
	cp -f /usr/local/etc/apache24/extra/httpd-vhosts.conf /usr/local/etc/apache24/extra/httpd-vhosts.conf.default
fi
echo "Include /usr/local/etc/apache24/extra/qlproxy_virtual_host" > /usr/local/etc/apache24/extra/httpd-vhosts.conf

# replace the squid config
if [ ! -f /usr/local/etc/squid/squid.conf.default ]; then
    cp -f /usr/local/etc/squid/squid.conf /usr/local/etc/squid/squid.conf.default
fi
cp -f squid.conf /usr/local/etc/squid/squid.conf

# create squid storage for mimicked ssl certificates
SSL_DB=/var/squid/cache/ssldb
if [ -d $SSL_DB ]; then
	rm -Rf $SSL_DB
fi

/usr/local/libexec/squid/ssl_crtd -c -s $SSL_DB
if [ $? -ne 0 ]; then
    echo "Error $? while initializing SSL certificate storage, exiting..."
    exit 1
fi
chown -R squid:squid $SSL_DB

# reset owner of installation path
chown -R qlproxy:qlproxy /opt/qlproxy

# restart all daemons
service apache24 restart
service wsmgrd restart
service qlproxyd restart
service squid restart
