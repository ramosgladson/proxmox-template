#!/bin/bash

truncate -s 0 /etc/machine-i
truncate -s 0 /var/lib/dbus/machine-id


# Debian/Ubuntu

apt-get install qemu-guest-agent

# Redhat based
#yum install qemu-guest-agent

systemctl start qemu-guest-agent

systemctl start qemu-guest-agent

rm /etc/ssh/ssh_host_*

apt-get install cloud-init

cloud-init clean


