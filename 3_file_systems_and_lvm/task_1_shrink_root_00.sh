#!/bin/sh

set -e

yum -y install xfsdump

# Create LV to temporary hold root
pvcreate /dev/sdb
vgcreate vg1 /dev/sdb
lvcreate -l 100%VG -n lvol0 vg1

# Make filesystem && mount
mkfs.xfs /dev/vg1/lvol0
mount /dev/vg1/lvol0 /mnt

# Remember root device
root_dev=$(findmnt -n -f -o SOURCE  /)
echo "$root_dev" > /root/.original_root_dev

# Copy data to temporary root
xfsdump -J - "$root_dev" | xfsrestore -J - /mnt

# Configure booting from new LV
for f in boot sys proc dev ; do mount --rbind /$f /mnt/$f; done
chroot /mnt /bin/sh <<'EOF'
cp -v /etc/default/grub /etc/default/grub.orig
echo 'GRUB_CMDLINE_LINUX="${GRUB_CMDLINE_LINUX} rd.lvm.lv=vg1/lvol0"' >> /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
EOF

# vm.provision "shell" s.reboot = true



