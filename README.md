# proxmoxAutoBackup
Automatic snapshoting and backup of Proxmox vm.

Snapshotting relies completely on Proxmox, but backup uses CEPH directly and currently only supports CEPH as backend.

Backup has been significantly improved since PBS started to work, but still there is sometimes a need for a raw backup that can be used in a real disaster and automatic snapshots that can be used when someone has accidentally destroyed things inside a VM...

These scripts are currently not adapted for publication, and are in this version highly specific, they will soon improve to be possible to deploy in production environments.

The main idea is to store all data in a format that can easilly be converted to proxmox backup vma format. Since VMA isn't suitable for differential backups the actual storage will be done in raw-format. This might seem strange, but when combined with an underlaying filesystem of zfs with compression and deduplication the combination gives us all benefits of a normal backup system with diff backups and compression, but without all the extra fuzz. Also if deployed on Raid-Z2 we will have good data integrity to avoid problems.
