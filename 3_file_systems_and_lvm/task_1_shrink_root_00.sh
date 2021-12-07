#!/bin/sh

set -e

yum -y install xfsdump

### Backup root to new LV
# create LV
pvcreate /dev/sdb
vgcreate vg1 /dev/sdb
lvcreate -l 100%VG -n lvol0 vg1

# format && copy data
mkfs.xfs /dev/vg1/lvol0
mount /dev/vg1/lvol0 /mnt
root_dev=$(findmnt -n -f -o SOURCE  /)
echo "$root_dev" > /root/.original_root_dev
xfsdump -J - "$root_dev" | xfsrestore -J - /mnt
### End Backup

### Boot from new LV
for f in boot sys proc dev ; do mount --rbind /$f /mnt/$f; done
chroot /mnt /bin/sh <<'EOF'
cp -v /etc/default/grub /etc/default/grub.orig
echo 'GRUB_CMDLINE_LINUX="${GRUB_CMDLINE_LINUX} rd.lvm.lv=vg1/lvol0"' >> /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
EOF

### End Boot from new LV

# vm.provision "shell" s.reboot = true



