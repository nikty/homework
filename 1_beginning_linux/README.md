# Домашнее задание

## Основы работы с Packer

Переделан шаблон Packer из JSON в HCL: centos.json => centos.pkr.hcl.

## Shared folders

Для включения поддержки гостевой системой shared folders установлены
Guest Additions из .iso файла, загруженного Packer.

Сделано с помощью скрипта "scripts/stage-1-1-install-virtualbox-guest-additions.sh", вызываемого из шаблона packer.

Скрипт устанавливает kernel-ml-devel, gcc, make, flex, bison, bzip2, необходимые для сборки модулей ядра.

Также устанавливает из [SCL](https://wiki.centos.org/AdditionalResources/Repositories/SCL) свежую версию GCC (пакет devtoolset-9-gcc), которая необходима, т.к. ядро kerel-ml не поддерживает компилятор из базовой системы.

