#  Задание 1

За образец взят Vagrantfile из https://github.com/nixuser/virtlab/blob/main/mdraid/.

В Vagrantfile добавлена постнастройка образа через shell, скрипт содержится в глобальной переменной внутри Vagrantfile
* создан RAID5
* прописан в /etc/mdadm/mdadm.conf
* создана таблица GPT
* в ней 5 разделов, каждый примонтирован в /raid/raidНОМЕР_РАЗДЕЛА
* разделы добавлены в /etc/fstab для автомонтирования

# Задание 2 (*)

Второй диск добавляется к машине через повторный запуск vagrant up: `vagrant up to_raid_1`

Далее последовательность действий для переноса:

* Создать RAID и раздел на нём
  * parted /dev/sdb mklabel msdos
  * parted /dev/sdb mkpart primary 0% 100%
  * parted /dev/sdb set 1 raid on
  * mdadm --create /dev/md/raid1 --level 1 --raid-devices 2 missing /dev/sdb1
  * parted /dev/md/raid1 mklabel dos
  * parted /dev/md/raid1 mkpart primary xfs 0% 100%
  * mkfs.xfs -f /dev/md/raid1p1
* Скопировать систему на новый раздел
  * mount /dev/md/raid1p1 /mnt/
  * rsync -aAXH $( for p in dev proc sys  tmp run mnt media ; do echo --exclude="/$p/*"; done ) --exclude "/lost+found" / /mnt/
* Настроить копию системы с учётом изменений
  * for d in proc sys dev; do mount --rbind /$d /mnt/$d; done
  * chroot /mnt
  * поправить /etc/fstab
  * grub2-install /dev/sdb
  * echo 'GRUB_CMDLINE_LINUX="rd.auto"' >> /etc/default/grub // без этого RAID не собирается при загрузке
  * grub2-mkconfig -o /boot/grub2/grub.cfg
  * dracut -fv
  * poweroff

Чтобы загрузиться с добавленного RAID1, нужно в VirtualBox присоединить его первым.
* VBoxManage list vms
* VBoxManage list hdds
* VBoxManage storageattach __VMID__ --storagectl __CONTROLLER_NAME__ --port 0 --device 0 --type hdd --medium __RAID_DISK__
* VBoxManage storageattach __VMID__ --storagectl __CONTROLLER_NAME__ --port 1 --device 0 --type hdd --medium __OLD_DISK__

После загрузки добавить старый диск в RAID:
* mdadm /dev/md/raid1 --add /dev/sdb1






