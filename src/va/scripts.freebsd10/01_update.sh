#!/bin/csh

# perform non interactive update
sed 's/\[ ! -t 0 \]/false/' /usr/sbin/freebsd-update > /tmp/freebsd-update
sh /tmp/freebsd-update fetch
sh /tmp/freebsd-update install

# bootstrap pkg
env ASSUME_ALWAYS_YES=YES pkg bootstrap

# and reboot
reboot 