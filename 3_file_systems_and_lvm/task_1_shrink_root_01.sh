#!/bin/sh

set -e

root_dest=$(cat /root/.original_root_dev && rm /root/.original_root_dev)
lvresize --force -L 8G $root_dest
mkfs.xfs -f $root_dest
mount $root_dest /mnt
xfsdump -J - "$(findmnt -n -f -o SOURCE  /)" | xfsrestore -J - /mnt

for f in boot sys proc dev ; do mount --rbind /$f /mnt/$f; done
chroot /mnt /bin/sh <<'EOF'
cp -v /etc/default/grub.orig /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
EOF
