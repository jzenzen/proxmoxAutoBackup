#!/bin/bash

#    ProxmoxAutoBackup is a script collection to do faster and better backups and snapshots.
#
#    Copyright (C) <year>  <name of author>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
#    Johan Zenzén, johan@zenzens.se
#
#    <Proxmox Auto Backup>  Copyright (C) <2022>  <johan Zenzén>
#    This program comes with ABSOLUTELY NO WARRANTY.
#    This is free software, and you are welcome to redistribute it
#    under certain conditions.

BACKUP_PATH=/backup/dump
INCLUDED_VM="*"
EXCLUDED_VM="106|108|112"

for vmpath in `ls -1 /etc/pve/nodes/*/qemu-server/* | grep -v -E $EXCLUDED_VM | sed -e "s/^\s*//g" | sed -e "s/\s.*//g"`
do
    vm=`echo $vmpath | sed -e "s/.*qemu-server\///g" | sed -e "s/.conf//g"`
    vmbackupPath=$BACKUP_PATH/vzdump-qemu-$vm-`date +%Y_%m_%d_%H_%M`
    vmconf=$vmbackupPath/qemu-server.conf
    echo "Backup upp $vm"
    mkdir $vmbackupPath
    awk '1;/\[autosnap/{exit}' $vmpath | grep -v "\[autosnap" > $vmconf
    disks=`grep -v "backup=0" $vmconf | grep "^scsi[0-9]" | sed -e "s/^scsi//g" | sed -e "s/:.*//g"`
    echo "$disks"
    for scsi in $disks
    do
    	disk=`grep "^scsi$scsi" $vmconf | sed -e "s/^scsi.*ceph/ceph/g" | sed -e "s/,.*//g" | sed -e "s/base.*\///g" | sed -e "s/:/\//g"`
	rbd snap create $disk@autobackup
    done
    for scsi in $disks
    do
    	disk=`grep "^scsi$scsi" $vmconf | sed -e "s/^scsi.*ceph/ceph/g" | sed -e "s/,.*//g" | sed -e "s/base.*\///g" | sed -e "s/:/\//g"`
	qemu-img convert -f raw rbd:$disk@autobackup -O raw $vmbackupPath/disk$scsi.raw
    	echo "#qmdump#map:scsi$scsi:disk$scsi:ceph_vm::" >> $vmconf
	rbd snap rm $disk@autobackup
    done
done

