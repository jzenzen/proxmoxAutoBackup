# proxmoxAutoBackup
Automatic snapshoting and backup of Proxmox vm.

Snapshotting relies completely on Proxmox, but backup uses CEPH directly and currently only supports CEPH as backend.

Backup has been significantly improved since PBS started to work, but still there is sometimes a need for a raw backup that can be used in a real disaster and automatic snapshots that can be used when someone has accidentally destroyed things inside a VM...

These scripts are currently not adapted for publication, and are in this version highly specific, they will soon improve to be possible to deploy in production environments.

The main idea is to store all data in a format that can easilly be converted to proxmox backup vma format. Since VMA isn't suitable for differential backups the actual storage will be done in raw-format. This might seem strange, but when combined with an underlaying filesystem of zfs with compression and deduplication the combination gives us all benefits of a normal backup system with diff backups and compression, but without all the extra fuzz. Also if deployed on Raid-Z2 we will have good data integrity to avoid problems.

## Restore
To restore with the normal features within Proxmox it is easiest to first create a VMA. This is easy but not fast if it is a large VM. For larger VMs it can be convienient to soft copy the disk and use it directly. This means a restore in a couple of minutes instead of hours.

### Restoring via VMA file
To restore via VMA file it is first necessary to create a VMA from the backup folder with config file and raw disk copies.
```
vma create /var/lib/vz/dump/vzdump-qemu-100-2022_06_02_13_36.vma -c vzdump-qemu-100-2022_06_02_13_36/qemu-server.conf vzdump-qemu-100-2022_06_02_13_36/disk*.raw
```
When the file is in place it should be possible to view as a regular backup file in Proxmox.

### Restore by doing a copy or move.
#### This is the safe way

```
cp /backup/dump/vzdump-qemu-100-2022_06_03_17_02/disk0.raw /backup/images/100/.
qm rescan
```

#### This is the fast way
 Your backup data will be used directly and can not be restored! This brings you  up in minutes!
```
mv /backup/dump/vzdump-qemu-100-2022_06_03_17_02/disk0.raw /backup/images/100/.
qm rescan
```
