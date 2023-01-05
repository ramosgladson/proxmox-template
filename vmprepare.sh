#!/bin/bash


#### Function to check errors
check_errors() {
	if [ $? -ne 0 ] ; then
		echo "[FAIL] - $ACTION"
		exit
	else
		echo "[OK] - $ACTION"
	fi
}


ACTION="Truncate machine id" 
truncate -s 0 /etc/machine-i && truncate -s 0 /var/lib/dbus/machine-id > /dev/null 2>&1
check_errors


# Debian/Ubuntu

ACTION="Install qemu agent"
apt-get install qemu-guest-agent > /dev/null 2>&1
check_errors


# Redhat based
#yum install qemu-guest-agent

ACTION="Start qemu agent"
systemctl start qemu-guest-agent > /dev/null 2>&1
check_errors

ACTION="Cleaning ssh_host"
rm /etc/ssh/ssh_host_* > /dev/null 2>&1
check_errors

ACTION="Cloud init install and clean"
apt-get install cloud-init && cloud-init clean > /dev/null 2>&1
check_errors

ACTION="Shutting down"
sleep 2 > /dev/null 2>&1
check_errors

sudo rm -r ../proxmox-template

sleep 2

sudo shutdown -h now
