#!/bin/sh

set -e

yum -y install  --enablerepo elrepo-kernel \
    kernel-ml-devel \
    make gcc flex bison \
    bzip2

# Repo with newer GCC
yum -y install centos-release-scl

yum -y install devtoolset-9-gcc

mount /home/vagrant/VBoxGuestAdditions.iso /mnt

scl enable devtoolset-9 /mnt/VBoxLinuxAdditions.run

umount /mnt
