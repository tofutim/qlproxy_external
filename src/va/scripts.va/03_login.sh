#!/bin/bash

# all packages are installed as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# reset root password to match documented one
sudo echo root:Passw0rd | sudo chpasswd

# now we allow root login for ssh
sed -i "s/PermitRootLogin without-password/PermitRootLogin yes/g" /etc/ssh/sshd_config

# now setup /etc/issue login banner (on Ubuntu only)
if [ -f /etc/centos-release ] || [ -f /etc/redhat-release ]; then
	echo "The script works only on Ubuntu 14"
	exit 1
fi

# copy the login script to qlproxy directory
cp vm_login.sh /opt/qlproxy/bin/

# create a system wide interface up script
cat > /etc/network/if-up.d/vm_login_update <<EOFTEXT
#!/bin/sh
if [ "\$METHOD" = loopback ]; then
    exit 0
fi

if [ "\$MODE" != start ]; then
    exit 0
fi

/bin/bash /opt/qlproxy/bin/vm_login.sh
EOFTEXT

# make it executable
chmod +x /etc/network/if-up.d/vm_login_update

# install vm tools (only if vmware is detected)
dmesg | grep -i "hypervisor detected: vmware" > /dev/null
if [ $? -eq 0 ]; then
    echo "Detected VMware, installing open-vm-tools..."
    apt-get update > /dev/null
    apt-get install -y open-vm-tools
fi

# disable the user
passwd user -l

# exit successfully
echo "VA generated successfully, please reboot"
