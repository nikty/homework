#!/bin/sh

set -e

root_dev=$(findmnt -n -f -o SOURCE  /)
root_vg=$(lvs --noheadings -o vg_name "$root_dev" | sed 's/^\s*//; s/\s*$//')


# Create volume for /home
lvcreate --size 1G --name LogVol_Home "$root_vg"
mkfs.xfs /dev/"$root_vg"/LogVol_Home
mount /dev/"$root_vg"/LogVol_Home /mnt

# Create root snapshot to copy /home from
mkdir /tmp/root_snapshot
lvcreate --snapshot --size 100M --name root_snapshot $root_dev
mount -o nouuid /dev/"$root_vg"/root_snapshot /tmp/root_snapshot

# Copy files in /home
rsync -avAHX /tmp/root_snapshot/home/ /mnt/
umount /mnt

# Mount new /home and add it to /etc/fstab
mount /dev/"$root_vg"/LogVol_Home /home
echo "UUID=$(lsblk -n -o uuid /dev/"$root_vg"/LogVol_Home) /home xfs defaults 0 0" >> /etc/fstab

# Create mirrored volume for /var
vgcreate vg_var /dev/sd[cde]
lvcreate --size 1G -m 1 --name lv_var vg_var # assumes "--type raid1"

mkfs.xfs /dev/vg_var/lv_var
mount /dev/vg_var/lv_var /mnt

# Copy files in /var
rsync -avAHX /tmp/root_snapshot/var/ /mnt/
umount /mnt

# Mount new /var and add it to /etc/fstab
mount /dev/vg_var/lv_var /var
echo "UUID=$(lsblk -n -o uuid /dev/vg_var/lv_var) /var xfs defaults 0 0" >> /etc/fstab


# Cleanup
umount /tmp/root_snapshot
rm -rf /tmp/root_snapshot
lvremove -f "$root_vg"/root_snapshot
