#!/bin/sh

set -e

# Resize old root
root_dest=$(cat /root/.original_root_dev && rm /root/.original_root_dev)
lvresize --force -L 8G $root_dest

# We can't shrink XFS, so make new one
mkfs.xfs -f $root_dest

# Copy data back to shrinked root
mount $root_dest /mnt
xfsdump -J - "$(findmnt -n -f -o SOURCE  /)" | xfsrestore -J - /mnt

# Configure booting from shrinked root
for f in boot sys proc dev ; do mount --rbind /$f /mnt/$f; done
chroot /mnt /bin/sh <<'EOF'
cp -v /etc/default/grub.orig /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
EOF
