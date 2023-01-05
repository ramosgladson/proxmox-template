#!/bin/bash
############################################################################
#title           :proxmox-vm-script
#description     :This script will prepair Cloud-init images on Proxmox VE.
#                 for terraform purpose
#author		 :Gladson Carneiro Ramos
#date            :2023-01-01
#version         :0.2
#usage		 :bash vmcreate.sh
#based on        :https://github.com/kmee/proxmox-cloud-init-tools/blob/main/deploy.sh
############################################################################
clear
### SSH KEY PATH check
if [ ! -f ~/.ssh/id_rsa.pub ]; then
	echo "Public ssh keys file not fount!"
        echo "Would you like to create now [yes/no]?"
	read YES_NO
	if [ $YES_NO="yes" ]; then
		ssh-keygen -t rsa -b 4096
        else
		echo "Create ~/.ssh/id_rsa.pub file, then paste your public ssh key file (id_rsa.pub)"
	 	echo "Script finished"
                exit
	fi

fi

# IMAGE PATH
IMG_PATH="images"
### Check if imgs path exist
if [ ! -d $IMG_PATH ] ; then
	mkdir -p $IMG_PATH
fi

#URLS - Available compatible cloud-init images to download - Debina 9/10 and Ubuntu 18.04/20.04
DEBIAN_9_URL="https://cdimage.debian.org/cdimage/cloud/stretch/daily/20200210-166/debian-9-nocloud-amd64-daily-20200210-166.qcow2"
DEBIAN_10_URL="https://cdimage.debian.org/cdimage/cloud/buster/latest/debian-10-nocloud-arm64.qcow2"
DEBIAN_11_URL="http://cdimage.debian.org/cdimage/cloud/bullseye/latest/debian-11-nocloud-amd64.qcow2"
UBUNTU_1804_URL="https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img"
UBUNTU_2004_URL="https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
UBUNTU_2204_URL="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
OPENSUSE_152_URL="https://download.opensuse.org/repositories/Cloud:/Images:/Leap_15.2/images/openSUSE-Leap-15.2-OpenStack.x86_64.qcow2"
CENTOS_8_URL="https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-GenericCloud-8.1.1911-20200113.3.x86_64.qcow2"

echo "Available images are: "
echo -n "
1 - Debian 9 - Stretch
2 - Debian 10 - Buster
3 - Debian 11 - Bullseye
4 - Ubuntu 18.04 LTS - Bionic
5 - Ubuntu 20.04 LTS - Focal
6 - Ubuntu 22.04 LTS - Jammy
7 - OpenSUSE LEAP 15.02
8 - CentOS 8
"
echo -n "Choose a Image to install: "
read OPT_IMAGE

case $OPT_IMAGE in
	1)
		ISO_NAME="debian-9.qcow2"
		VM_CI_IMAGE="$IMG_PATH/$ISO_NAME"
		if [ ! -f $VM_CI_IMAGE ]; then
			wget -c $DEBIAN_9_URL -O $VM_CI_IMAGE
		fi
		;;
	2)
		ISO_NAME="debian-10.qcow2"
		VM_CI_IMAGE="$IMG_PATH/$ISO_NAME"
		if [ ! -f $VM_CI_IMAGE ]; then
			wget -c $DEBIAN_10_URL -O $VM_CI_IMAGE
		fi
		;;
	3)
		ISO_NAME="debian-11.qcow2"
		VM_CI_IMAGE="$IMG_PATH/$ISO_NAME"
		if [ ! -f $VM_CI_IMAGE ]; then
			wget -c $DEBIAN_11_URL -O $VM_CI_IMAGE
		fi
		;;
	4)
		ISO_NAME="ubuntu-1804.qcow2"
		VM_CI_IMAGE="$IMG_PATH/$ISO_NAME"
		if [ ! -f $VM_CI_IMAGE ]; then
			wget -c $UBUNTU_1804_URL -O $VM_CI_IMAGE
		fi
		;;
	5)
		ISO_NAME="ubuntu-2004.qcow2"
		VM_CI_IMAGE="$IMG_PATH/$ISO_NAME"
		if [ ! -f $VM_CI_IMAGE ]; then
			wget -c $UBUNTU_2004_URL -O $VM_CI_IMAGE
		fi
		;;
	6)
		ISO_NAME="ubuntu-2204.qcow2"
		VM_CI_IMAGE="$IMG_PATH/$ISO_NAME"
                if [ ! -f $VM_CI_IMAGE ]; then
                  i      wget -c $UBUNTU_2204_URL -O $VM_CI_IMAGE
                fi
                ;;
	7)
		ISO_NAME="opensuse-1502.qcow2"
		VM_CI_IMAGE="$IMG_PATH/$ISO_NAME"
		if [ ! -f $VM_CI_IMAGE ]; then
			wget -c $OPENSUSE_152_URL -O $VM_CI_IMAGE
		fi
		;;
	8)
		ISO_NAME="centos-8.qcow2"
		VM_CI_IMAGE="$IMG_PATH/$ISO_NAME"
		if [ ! -f $VM_CI_IMAGE ]; then
			wget -c $CENTOS_8_URL -O $VM_CI_IMAGE
		fi
		;;
	*)
		clear
		echo "[Fail] - Unknown option - Run script again then choose a valid option."
		exit
		;;
esac


clear
echo "########## VM DETAILS ##########"

echo -n "Type VM Name: "
read VM_NAME
echo
echo -n "Type VM Description: "
read VM_DESCRIPTION
echo
echo -n "Memory Options:
1 - 1GB
2 - 2GB
3 - 4GB
4 - 8GB
5 - 16GB
Select VM Memory option (1-5): "
read VM_MEMORY_GB

case $VM_MEMORY_GB in
	1)
	        VM_MEMORY=1024
	;;
	2)
		VM_MEMORY=2048
	;;
	3)
		VM_MEMORY=4096
	;;
	4)
		VM_MEMORY=8192
	;;
	5)
		VM_MEMORY=16384
	;;
        *)
                clear
                echo "[Fail] - Unknown option - Run script again then choose a valid option."
                exit
    
            ;;
esac
### VM Cores
echo -n "Type # of VM CPU Cores: (Example: 2)"
read VM_CORES
### VM Sockets
echo -n "Type # of VM CPU Sockets: (Example: 1)"
read VM_SOCKETS

### VM Storage
clear
echo "########## STORAGE ##########"
echo ""
echo Storage Availability|awk '{ printf "%-20s %-40s\n", $1, $2 }'
pvesm status|grep active|awk '{ printf "%-20s %-40s\n", $1, $7 }'
echo -n "Type name of Storage to install VM: "
read VM_STORAGE


### VM Storage Size
clear
echo "########## VM SIZE ##########"
echo ""
echo -n "Type image size (Example: 32G) "
read VM_SIZE


### VM Default user
clear
echo "######### USER INFORMATION ##########"
echo "This tool create user root as default!"
echo "If you would like to use non-root account, please define username and use sudo when login."
echo "If you will use root, just type root or keep it empty."
echo -n "type new username: "
read DEFAULT_USER

# Check username - then define as root if empty
if [ -z $DEFAULT_USER ] ; then
	DEFAULT_USER="root"
fi

### Network
clear
echo "########## NETWORK ##########"
### Bridge
echo "Choose a Bridge interface to attach VM, options are:"
	### Get all bridges and their networks
	echo "BRIDGE NETWORK"|awk '{ printf "%-20s %-40s\n", $1, $2 }'
	for BRIDGES in `ip a |grep vmbr |awk '{print $2}'|cut -d":" -f1` ; do
	        BRIDGE_NETWORK=`ip a |grep $BRIDGES |grep inet |awk '{print $2}'`
	        echo "$BRIDGES $BRIDGE_NETWORK"|awk '{ printf "%-20s %-40s\n", $1, $2 }'
	done

echo -n "Type brigde name: (Example vmbr0) "
read VM_BRIDGE

echo "Use DHCP?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) DHCP_USE="Y"; break;;
        No ) DHCP_USE="N"; break;;
    esac
done
if [ $DHCP_USE != "Y" ] ;then
	### VM IP
	echo -n "Type VM IP Address (Example: 192.168.0.99): "
	read VM_IP_ADDR
	### VM IP
	echo -n "Type VM IP BIT MASK. Example: 24, 22, 16, 8 etc." 
	echo -n "Your network bit mask: "
	read VM_IP_NETMASK
	VM_IP="$VM_IP_ADDR/$VM_IP_NETMASK"
	### VM GW
	echo -n "Type Network Gateway IP Address. (Example: 192.168.0.1): "
	read VM_GW
fi

### VM ID
echo "Choose a UNIQ ID for VM, please, do not use any of bellow IDs"
pvesh get /cluster/resources --type vm|grep qemu|awk '{ print $2}'|cut -d"/" -f2
echo -n "Type a uniq ID for VM: "
read VM_ID

clear
echo ""
echo "######### VM DETAILS ##########"
echo ""
echo Name: $VM_SIZE$VM_NAME 
echo Description $VM_DESCRIPTION 
echo Memory:  $VM_MEMORY 
echo Cores: $VM_CORES
echo Sockets: $VM_SOCKETS
echo Template Image: $VM_CI_IMAGE
echo Storage: $VM_STORAGE
echo User: $DEFAULT_USER
echo Attached Bridge: $VM_BRIDGE
echo IP Address/Network: $VM_IP
echo Gateway $VM_GW
echo VM ID: $VM_ID
echo VM SIZE: $VM_SIZE
 


echo "Review VM informations and continue"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) echo "Starting deploy"; break;;
        No ) exit;;
    esac
done

#### Start deploy
echo ""
echo "##########  Start  VM  Deploy  ##########"
echo
#### Check if vm id exist
qm status $VM_ID > /dev/null 2>&1
if [ $? -eq 0 ] ; then
	echo "[FAIL] - unable to create VM $VM_ID - VM $VM_ID already exists - Try another id"
	exit
fi
#### Function to check errors
check_errors() {
	if [ $? -ne 0 ] ; then
		echo "[FAIL] - $ACTION"
		exit
	else
		echo "[OK] - $ACTION"
	fi
}

### DO NOT TOUCH

IMG_NAME="$VM_SIZE$ISO_NAME"
cp $VM_CI_IMAGE $IMG_PATH/$IMG_NAME

ACTION="Image resize"
qemu-img resize $IMG_PATH/$VM_SIZE$ISO_NAME $VM_SIZE > /dev/null 2>&1
check_errors

ACTION="Create VM Template $VM_ID:$VM_NAME"
qm create $VM_ID \
	--name $VM_SIZE$VM_NAME \
	--memory $VM_MEMORY \
	--net0 virtio,bridge=$VM_BRIDGE \
	--cores $VM_CORES \
#	--sockets $VM_SOCKETS \
#	--cpu cputype=kvm64 \
#	--kvm 1 \
#	--numa 1 \
        > /dev/null 2>&1
check_errors

ACTION="Import disk"
qm importdisk $VM_ID $IMG_PATH/$IMG_NAME $VM_STORAGE > /dev/null 2>&1
check_errors

ACTION="Set disk controller and image"
qm set $VM_ID --scsihw virtio-scsi-pci --scsi0 $VM_STORAGE:vm-$VM_ID-disk-0 > /dev/null 2>&1
check_errors

#Cloud INIT
ACTION="Add cloud-init cdrom"
qm set $VM_ID --ide2 $VM_STORAGE:cloudinit > /dev/null 2>&1
check_errors

ACTION="Set boot disk"
qm set $VM_ID --boot c --bootdisk scsi0 > /dev/null 2>&1
check_errors

ACTION="Set serial socket"
qm set $VM_ID --serial0 socket --vga serial0 > /dev/null 2>&1
check_errors

ACTION="set Qemu Guest Agent Enabled"
qm set $VM_ID --agent 1 > /dev/null 2>&1
check_errors

#ACTION="Set hotplug options"
#qm set $VM_ID --hotplug disk,network,usb,memory,cpu > /dev/null 2>&1
#check_errors

#ACTION="Set name to $VM_NAME"
#qm set $VM_ID --name $VM_NAME > /dev/null 2>&1
#check_errors

ACTION="Set default user to $DEFAULT_USER"
qm set $VM_ID --ciuser $DEFAULT_USER > /dev/null 2>&1
check_errors

ACTION="Set authorized ssh keys"
qm set $VM_ID --sshkey ~/.ssh/id_rsa.pub > /dev/null 2>&1
check_errors

ACTION="Set IP Address and Gateway"
if [ $DHCP_USE == Y ] ; then
	qm set $VM_ID --ipconfig0 ip=dhcp > /dev/null 2>&1
else
	qm set $VM_ID --ipconfig0 ip=$VM_IP,gw=$VM_GW > /dev/null 2>&1
fi
check_errors

clear
echo "########## Finishing deployment"
echo ""
echo "Do you wish to start this VM now?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) qm start $VM_ID; break;;
        No ) exit;;
    esac
done

echo "Now, if VM is up and running, try access $DEFAULT_USER@$VM_IP_ADDR - or check your VM ip address on DHCP Server."
echo ""
echo "Finished"
echo ""
	

