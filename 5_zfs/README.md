# Задание 1


Сделано с помощью скрипта преднастройки "task_1_compression" (shell inline).

Соотношения сжатия (приблизительные) выводятся для каждой ФС, отсортированные по возрастанию.
Меньше всего места в данном случае занимают данные ФС со сжатием gzip.

Запуск vagrant:
`vagrant up server; vagrant up server` - дважды, т.к. добавление дисков сделано через костыли.

# Задание 2

Сделано с помощью преднастройки shell "task_2_pool_settings".

<pre>
$ vagrant provision server --provision-with task_2_pool_settings
==> server: Running provisioner: task_2_pool_settings (shell)...
    server: Running: inline script
    server: zpoolexport/
    server: zpoolexport/filea
    server: zpoolexport/fileb
    server: Размер хранилища
    server: NAME  PROPERTY  VALUE  SOURCE
    server: otus  size      480M   -
    server: Pool type
    server:             type: 'root'
    server:             children[0]:
    server:                 type: 'mirror'
    server:                 children[0]:
    server:                     type: 'file'
    server:                 children[1]:
    server:                     type: 'file'
    server: Значение recordsize
    server: NAME  PROPERTY    VALUE    SOURCE
    server: otus  recordsize  128K     local
    server: Сжатие
    server: NAME  PROPERTY     VALUE           SOURCE
    server: otus  compression  zle             local
    server: Контрольная сумма
    server: NAME  PROPERTY  VALUE      SOURCE
    server: otus  checksum  sha256     local
</pre>

# Задание 3

Сделано с помощью преднастройки shell "task_3_find_message".

Снэпшот восстанавливается в пул, созданный в задании 2.

