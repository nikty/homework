#!/bin/sh

# clean all
yum update -y
yum clean all


# Install vagrant default key
mkdir -p /home/vagrant/.ssh
curl -sL -o /home/vagrant/.ssh/authorized_keys https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub

chmod 0600 /home/vagrant/.ssh/authorized_keys
chmod 0700 /home/vagrant/.ssh
chown -R vagrant:vagrant /home/vagrant/.ssh


# Remove temporary files
rm -rf /tmp/*
rm  -f /var/log/wtmp /var/log/btmp
rm -rf /var/cache/* /usr/share/doc/*
rm -rf /var/cache/yum
rm -rf /vagrant/home/*.iso
rm  -f ~/.bash_history
history -c

rm -rf /run/log/journal/*

# Fill zeros all empty space
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY
sync
grub2-set-default 1
echo "###   Hi from secone stage" >> /boot/grub2/grub.cfg
