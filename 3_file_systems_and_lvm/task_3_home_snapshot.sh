#!/bin/sh

set -e

# Create files
for i in $(seq 5); do
    touch /home/vagrant/file$i
done
ls /home/vagrant/file* >&2

# Make snapshot
lvcreate --snapshot --name home_snapshot --size 100M VolGroup00/LogVol_Home

# Remove some files
rm /home/vagrant/file[234]
ls /home/vagrant/file* >&2

# Restore snapshot (it'll be restored after reboot)
lvconvert --merge VolGroup00/home_snapshot

