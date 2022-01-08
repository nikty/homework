# Описание домашнего задания
## Основная часть:

- `vagrantup`должен поднимать 2 настроенных виртуальных машины (сервер
NFS и клиента) без дополнительных ручных действий;

- на сервере NFS должна быть подготовлена и экспортирована директория;

- в экспортированной директории должна быть поддиректория с именем
__upload__ с правами на запись в неё;

- экспортированная директория должна автоматически монтироваться на
клиенте при старте виртуальной машины (systemd, autofs или fstab -
любым способом);

- монтирование и работа NFS на клиенте должна быть организована с
 использованием NFSv3 по протоколу UDP;

- firewall должен быть включен и настроен как на клиенте,так и на
сервере.

## Для самостоятельной реализации:

- настроить аутентификацию через KERBEROS с использованием NFSv4


# Решение
Для выполнения заданий выбран дистрибутив openSUSE.

## Задание 1 - NFS клиент и сервер

Клиент и сервер поднимаются при вызове `vagrant up server client`, вся настройка выполнена прямо из Vagrantfile через встроенный shell скрипт.
Настройка сводится к установке пакетов nfs и правке /etc/exports и /etc/fstab,
и настройке статических портов NFS и RPC сервисов, чтобы NFS работал при включенном файрволе.


## Задание 2 - Настроить аутентификацию чезе Kerberos (NFSv4)

Настройка выполняется после настройки хостов в задании 1, сделана с помощью скриптов в "scripts/".

Для настройки последовательно запустить:
- vagrant up kdc
- vagrant provision --provision-with kerberos_kdc
- vagrant provision --provision-with kerberos_nfs_server
- vagrant provision --provision-with kerberos_nfs_client

Проверить:
- vagrant ssh client
- mount /mnt_krb

Поднят домен OTUS_LAB, настроены статические записи для хостов в /etc/hosts.
Использовались следующие материалы по Kerberos:
- NFS Illustrated, https://www.oreilly.com/library/view/nfs-illustrated/9780321618924/, для обзора SunRPC
- Bill Bryant. Designing an Authentication System: a Dialogue in Four Scenes. 1988. Afterword by Theodore Ts'o, 1997., исторический документ про архитектуру Kerberos в форме диалога, https://web.mit.edu/kerberos/dialogue.html
- Руководство openSUSE, https://doc.opensuse.org/documentation/leap/security/html/book-security/cha-security-kerberos.html
- Документация Kerberos, https://web.mit.edu/kerberos/krb5-latest/doc/
- Частично документация RedHat, Ubuntu



