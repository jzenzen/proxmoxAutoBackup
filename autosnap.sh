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
#    <Proxmox Auto Snapshot>  Copyright (C) <2022>  <johan Zenzén>
#    This program comes with ABSOLUTELY NO WARRANTY.
#    This is free software, and you are welcome to redistribute it
#    under certain conditions.

EXCLUDED_VM="106|101|112"

for vm in `qm list | grep running | grep -v -E $EXCLUDED_VM | sed -e "s/^\s*//g" | sed -e "s/\s.*//g"`
do
    /usr/sbin/qm delsnapshot $vm `date +autosnap-day%d`
    /usr/sbin/qm snapshot $vm `date +autosnap-day%d`
done
