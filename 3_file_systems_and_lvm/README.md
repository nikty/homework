# Задание 1

> уменьшить том под / до 8G

Сделано с помощью инициализации shell:
* task_1_shrink_root_00.sh - копирует данные из корня во временный том, устанавливает загрузку со временного тома
* перезагрузка
* task_1_shrink_root_01.sh - изменяет размер оригинального тома, создаёт ФС и копирует данные из корня (временного тома) в оригинальный том, устанавливает загрузку с оригинального тома
* перезагрузка

# Задание 2-5

> выделить том под /home
> выделить том под /var (/var - сделать в mirror)

* task_2_add_logical_volume_for_home_and_var.sh


# Задание 6

> Работа со снапшотами:
> сгенерировать файлы в /home/
> снять снэпшот
> удалить часть файлов
> восстановиться со снэпшота


* task_3_home_snapshot.sh

Т.к. vagrant ssh логинится под vagrant, невозможно отмонтировать
/home, поэтому восстановление снэпшота происходит при следующей
активации тома LogVol_Home - т.е. при перезагрузке системы.
