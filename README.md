# Домашнее задание к занятию 10.4 «Резервное копирование» - `Елена Махота`


* [Ответ к Заданию 1](#1)
* [Ответ к Заданию 2](#2)
* [Ответ к Заданию 3](#3)
* [Ответ к Заданию 4*](#4)

---

### Задание 1

В чём разница между:

- полным резервным копированием,
- дифференциальным резервным копированием,
- инкрементным резервным копированием.

*Приведите ответ в свободной форме.*

### *<a name="1"> Ответ к Заданию 1 </a>*


| **Резервное копирование**    | **полное**                                                                  | **дифференциальное**                                                                   | **инкрементное**                                                                |
|------------------------------|-----------------------------------------------------------------------------|----------------------------------------------------------------------------------------|----------------------------------------------------------------------------------|
| **Объем сохраненных данных** | все данные                                                                  | данные, измененные после последнего полного бэкапа                                     | данные, измененные после последнего инкрементного бэкапа                         |
| **Отправная точка**          | текущий момент                                                              | последний полный бэкап                                                                 | последний  бэкап                                                                 |
| **Ресурсы**                  | времязатратный процесс, высокая нагрузка на систему, большой оъем хранилища | ресурсов требуется меньше чем для полного копирования, но больше чем для инкрементного | наименьшие затраты ресурсов                                                      |
| **Восстановление**           | Быстрое                                                                     | Среднее                                                                                | Медленное                                                                        |
| **Сохранность данных**       | Сохранность данных в полном объеме                                          | успешное восстановление данных зависит от целостности последнего бэкапа                | успешное восстановление данных зависит от целостности всех инкрементов в цепочке |


Использованные источники:

\- [Презентация "Отказоустойчивость: Резервное копирование. Bacula", Александр Зубарев](https://u.netology.ru/backend/uploads/lms/attachments/files/data/27925/SRLB-9__%D0%A0%D0%B5%D0%B7%D0%B5%D1%80%D0%B2%D0%BD%D0%BE%D0%B5_%D0%BA%D0%BE%D0%BF%D0%B8%D1%80%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D0%B5._Bacula.pdf)

\- https://habr.com/ru/company/ruvds/blog/678364/

---

### Задание 2

Установите программное обеспечении Bacula, настройте bacula-dir, bacula-sd,  bacula-fd. Протестируйте работу сервисов.

*Пришлите конфигурационные файлы для bacula-dir, bacula-sd,  bacula-fd.*

### *<a name="2"> Ответ к Заданию 2 </a>*

Установка Bacula 

```bash
sudo apt install bacula postgresql 
```

В ходе установки потребуется выбрать, где будет база данных, выберем localhost. Далее установка пароля для входа, можно установить любой (главное запомнить).


Проверяем, что сервисы запущены

```bash
sudo service --status-all | grep bacula
```

stdout

```bash
 [ + ]  bacula-director
 [ + ]  bacula-fd
 [ + ]  bacula-sd
```

Смотрим документацию

```bash
cd /usr/share/doc/bacula-doc/
cat ./bacula-director/examples/conf/console.conf # примеры конфигураций
```


Cоздадим новые каталоги для хранения резервных копий

```bash
sudo mkdir -p /bacula
```
Нужно изменить права доступа к файлам, чтобы только процесс bacula (и суперпользователь) мог получить доступ к созданным каталогам:

```bash
sudo chown -R bacula:bacula /bacula 
sudo chmod -R 700 /bacula
```

**Настройка Bacula Storage (сервис bacula-sd)** — хранилище, предназначенное для сохранения резервных копий на диске. 


sudo nano /etc/bacula/[bacula-sd.conf](bacula-sd.conf)



```bash
Storage {                             # definition of myself
  Name = makhota-vm01-sd
  SDPort = 9103                  # Director's port
  WorkingDirectory = "/var/lib/bacula"
  Pid Directory = "/run/bacula"
  Plugin Directory = "/usr/lib/bacula"
  Maximum Concurrent Jobs = 20
  SDAddress = 127.0.0.1
}

Director {
  Name = makhota-vm01-dir
  Password = "kH3eGQmWACQ6_QXz6_wg1VEmTKpu3jtlW"
}

Director {
  Name = makhota-vm01-mon
  Password = "65UL04B6k2Vb-DZBefffReeBPXQv-4dCQ"
  Monitor = yes
}

Device {
  Name = FileChgr1-Dev1
  Media Type = File1
  Archive Device = /home/user/backup
  LabelMedia = yes;                   # lets Bacula label unlabeled media
  Random Access = Yes;
  AutomaticMount = yes;               # when device opened, read it
  RemovableMedia = no;
  AlwaysOpen = no;
  Maximum Concurrent Jobs = 5
}


Messages {
  Name = Standard
  director = makhota-vm01-dir = all
}
```
После редактирования настроек выполняем проверку получившийся конфигурации:

```bash
sudo /usr/sbin/bacula-sd -t -c /etc/bacula/bacula-sd.conf
```


**Настройка Bacula File Daemon (сервис bacula-fd)** — клиентская часть сервиса, которая нужна для доступа к файлам на сервере, с которого будет выполняться резервное копирование.

sudo nano /etc/bacula/[bacula-fd.conf](bacula-fd.conf)

```bash
Director {
  Name = makhota-vm01-dir
  Password = "WINc4vyZbDintjLIL4sP79k75ahSA2Hvy"
}

Director {
  Name = makhota-vm01-mon
  Password = "zqXUneB37UhvtNFHaELoHNMrTxCk1CHbW"
  Monitor = yes
}

FileDaemon {                          # this is me
  Name = makhota-vm01-fd
  FDport = 9102                  # where we listen for the director
  WorkingDirectory = /var/lib/bacula
  Pid Directory = /run/bacula
  Maximum Concurrent Jobs = 20
  Plugin Directory = /usr/lib/bacula
  FDAddress = 127.0.0.1
}

Messages {
  Name = Standard
  director = makhota-vm01-dir = all, !skipped, !restored
}

```

После редактирования настроек выполняем проверку получившийся конфигурации:

```bash
sudo /usr/sbin/bacula-fd -t -c /etc/bacula/bacula-fd.conf
```

**Настройка Bacula Director (сервис bacula-dir)** — основной сервис, который управляет всеми другими процессами по резервному копированию и восстановлению.

sudo nano /etc/bacula/[bacula-dir.conf](bacula-dir.conf)

```bash
Director {                            # define myself
  Name = makhota-vm01-dir
  DIRport = 9101                # where we listen for UA connections
  QueryFile = "/etc/bacula/scripts/query.sql"
  WorkingDirectory = "/var/lib/bacula"
  PidDirectory = "/run/bacula"
  Maximum Concurrent Jobs = 20
  Password = "u-WxA-XfH79YuKh_fX2LhrKq6YlIGIOWD"         # Console password
  Messages = Daemon
  DirAddress = 127.0.0.1
}

JobDefs {
  Name = "DefaultJob"
  Type = Backup
  Level = Incremental
  Client = makhota-vm01-fd
  FileSet = "Full Set"
  Schedule = "WeeklyCycle"
  Storage = File1
  Messages = Standard
  Pool = File
  SpoolAttributes = yes
  Priority = 10
  Write Bootstrap = "/var/lib/bacula/%c.bsr"
}

Job {
  Name = "BackupClient1"
  JobDefs = "DefaultJob"
}

Job {
  Name = "BackupCatalog"
  JobDefs = "DefaultJob"
  Level = Full
  FileSet="Catalog"
  Schedule = "WeeklyCycleAfterBackup"
  # This creates an ASCII copy of the catalog
  # Arguments to make_catalog_backup.pl are:
  #  make_catalog_backup.pl <catalog-name>
  RunBeforeJob = "/etc/bacula/scripts/make_catalog_backup.pl MyCatalog"
  # This deletes the copy of the catalog
  RunAfterJob  = "/etc/bacula/scripts/delete_catalog_backup"
  Write Bootstrap = "/var/lib/bacula/%n.bsr"
  Priority = 11                   # run after main backup
}

Job {
  Name = "RestoreFiles"
  Type = Restore
  Client=makhota-vm01-fd
  Storage = File1
# The FileSet and Pool directives are not used by Restore Jobs
# but must not be removed
  FileSet="Full Set"
  Pool = File
  Messages = Standard
  Where = /home/user/bacula-restores
}

FileSet {
  Name = "Full Set"
  Include {
    Options {
      signature = MD5
    }

File = /usr/sbin
  }    

Exclude {
    File = /var/lib/bacula
    File = /nonexistant/path/to/file/archive/dir
    File = /proc
    File = /tmp
    File = /sys
    File = /.journal
    File = /.fsck
  }
}

Schedule {
  Name = "WeeklyCycle"
  Run = Full 1st sun at 23:05
  Run = Differential 2nd-5th sun at 23:05
  Run = Incremental mon-sat at 23:05
}

Schedule {
  Name = "WeeklyCycleAfterBackup"
  Run = Full sun-sat at 23:10
}


FileSet {
  Name = "Catalog"
  Include {
    Options {
      signature = MD5
    }
    File = "/var/lib/bacula/bacula.sql"
  }
}

Client {
  Name = makhota-vm01-fd
  Address = localhost
  FDPort = 9102
  Catalog = MyCatalog
  Password = "WINc4vyZbDintjLIL4sP79k75ahSA2Hvy"          # password for FileDaemon
  File Retention = 60 days            # 60 days
  Job Retention = 6 months            # six months
  AutoPrune = yes                     # Prune expired Jobs/Files
}

Autochanger {
  Name = File1
# Do not use "localhost" here
  Address = localhost                # N.B. Use a fully qualified name here
  SDPort = 9103
  Password = "kH3eGQmWACQ6_QXz6_wg1VEmTKpu3jtlW"
  Device = FileChgr1
  Media Type = File1
  Maximum Concurrent Jobs = 10        # run up to 10 jobs a the same time
  Autochanger = File1                 # point to ourself
}

Autochanger {
  Name = File2
# Do not use "localhost" here
  Address = localhost                # N.B. Use a fully qualified name here
  SDPort = 9103
  Password = "kH3eGQmWACQ6_QXz6_wg1VEmTKpu3jtlW"
  Device = FileChgr2
  Media Type = File2
  Autochanger = File2                 # point to ourself
  Maximum Concurrent Jobs = 10        # run up to 10 jobs a the same time
}

Catalog {
  Name = MyCatalog
  dbname = "bacula"; DB Address = "localhost"; dbuser = "bacula"; dbpassword = "1"
}

Messages {
  Name = Standard

  mailcommand = "/usr/sbin/bsmtp -h localhost -f \"\(Bacula\) \<%r\>\" -s \"Bacula: %t %e of %c %l\" %r"
  operatorcommand = "/usr/sbin/bsmtp -h localhost -f \"\(Bacula\) \<%r\>\" -s \"Bacula: Intervention needed for %j\" %r"
  mail = root = all, !skipped
  operator = root = mount
  console = all, !skipped, !saved
  append = "/var/log/bacula/bacula.log" = all, !skipped
  catalog = all
}


Messages {
  Name = Daemon
  mailcommand = "/usr/sbin/bsmtp -h localhost -f \"\(Bacula\) \<%r\>\" -s \"Bacula daemon message\" %r"
  mail = root = all, !skipped
  console = all, !skipped, !saved
  append = "/var/log/bacula/bacula.log" = all, !skipped
}

Pool {
  Name = Default
  Pool Type = Backup
  Recycle = yes                       # Bacula can automatically recycle Volumes
  AutoPrune = yes                     # Prune expired volumes
  Volume Retention = 365 days         # one year
  Maximum Volume Bytes = 50G          # Limit Volume size to something reasonable
  Maximum Volumes = 100               # Limit number of Volumes in Pool
}

Pool {
  Name = File
  Pool Type = Backup
  Recycle = yes                       # Bacula can automatically recycle Volumes
  AutoPrune = yes                     # Prune expired volumes
  Volume Retention = 365 days         # one year
  Maximum Volume Bytes = 50G          # Limit Volume size to something reasonable
  Maximum Volumes = 100               # Limit number of Volumes in Pool
  Label Format = "Vol-"               # Auto label
}

# Scratch pool definition
Pool {
  Name = Scratch
  Pool Type = Backup
}

#
# Restricted console used by tray-monitor to get the status of the director
#
Console {
  Name = makhota-vm01-mon
  Password = "3AFL0oYpT0HNNGROPsl9tNNZtz51Pmds8"
  CommandACL = status, .status
}

```

После редактирования настроек выполняем проверку получившийся конфигурации:

```bash
sudo /usr/sbin/bacula-dir -t -c /etc/bacula/bacula-dir.conf
```

Посмотреть логи

```bash 
sudo cat /var/log/bacula/bacula.log
```

Перезапускаем службы

```bash
sudo systemctl restart bacula-sd
sudo systemctl restart bacula-fd
sudo systemctl restart bacula-dir
```

Входим в консоль `bconsole`, можно посмотреть `help`, `status`

Использованные источники:

\- [Презентация "Отказоустойчивость: Резервное копирование. Bacula", Александр Зубарев](https://u.netology.ru/backend/uploads/lms/attachments/files/data/27925/SRLB-9__%D0%A0%D0%B5%D0%B7%D0%B5%D1%80%D0%B2%D0%BD%D0%BE%D0%B5_%D0%BA%D0%BE%D0%BF%D0%B8%D1%80%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D0%B5._Bacula.pdf)
- https://github.com/tyler-hitzeman/bacula/blob/master/troubleshooting.md?ysclid=ld21rgczxw425033857

---

### Задание 3

Установите программное обеспечении Rsync. Настройте синхронизацию на двух нодах. Протестируйте работу сервиса.

*Пришлите рабочую конфигурацию сервера и клиента Rsync.*

### *<a name="3"> Ответ к Заданию 3 </a>*


---

### Задание со звёздочкой*
Это задание дополнительное. Его можно не выполнять. На зачёт это не повлияет. Вы можете его выполнить, если хотите глубже разобраться в материале.

---

### Задание 4*

Настройте резервное копирование двумя или более методами, используя одну из рассмотренных команд для папки /etc/default. Проверьте резервное копирование.

*Пришлите рабочую конфигурацию выбранного сервиса по поставленной задаче.*

### *<a name="4"> Ответ к Заданию 4* </a>*


