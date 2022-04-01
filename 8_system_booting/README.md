# Описание домашнего задания

1. Попасть в систему без пароля несколькими способами.
2. Установить систему с LVM, после чего переименовать VG.
3. Добавить модуль в initrd.
4. (*) Сконфигурировать систему без отдельного раздела с /boot, а только с LVM Репозиторий с пропатченым grub: https://yum.rumyantsev.com/centos/7/x86_64/ PV необходимо инициализировать с параметром --bootloaderareasize 1m

# Описание решения

## 1. Попасть в систему без пароля несколькими способами.

### Centos 7

Выполняется на образе Vagrant: box = "centos/7" box_version = "1804.02"

Шаги сброса пароля:
* попасть в shell initramfs:
 * убрать из згрузчика опции, связанные с dracut (`rd.*`), без этого не удавалось попасть в shell
 * добавить `rd.break enforcing=0`
* внутри shell
 * `lvm vgchange -a y`
 * `mount /dev/mapper/VolGroup00-LogVol00 /sysroot`
 * `chroot /sysroot`
 * `passwd`
 * `exit`
* система загрузится с корневого раздела, после логина 
 * `restorecon /etc/shadow`


## 2. Установить систему с LVM, после чего переименовать VG.

Сделано через shell, см. "rename_vg" в Vagrantfile.

Запуск стенда в Vagrant:
`vagrant up && until vagrant provision --provision-with check; do sleep 1; done`

## 3. Добавить модуль в initrd.

Сделано через shell в Vagrantfile, модуль выводит "Hello, world".

* Запуск стенда:
`vagrant up --provision-with add_dracut_module`
* Проверка:
`vagrant ssh -c 'sudo reboot'`, далее смотреть в GUI VirtualBox



## 4. Не выполнялось