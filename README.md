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


sudo nano /etc/bacula/[bacula-local/bacula-sd.conf](bacula-sd.conf)



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
  Name = Local-Device
  Media Type = File
  Archive Device = /bacula
  LabelMedia = yes;                   # lets Bacula label unlabeled media
  Random Access = Yes;
  AutomaticMount = yes;               # when device opened, read it
  RemovableMedia = no;
  AlwaysOpen = yes;
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

sudo nano /etc/bacula/[bacula-local/bacula-fd.conf](bacula-fd.conf)

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

sudo nano /etc/bacula/[bacula-local/bacula-dir.conf](bacula-dir.conf)

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
  FileSet = "System"
  Schedule = "WeeklyCycle"
  Storage = makhota-vm01-sd
  Messages = Standard
  Pool = LocalPool
  SpoolAttributes = yes
  Priority = 10
  Write Bootstrap = "/var/lib/bacula/%c.bsr"
}


Job {
  Name = "System"
  JobDefs = "DefaultJob"
  Enabled = yes
  Level = Full
  FileSet="System"
  Schedule = "WeeklyCycle"
  Priority = 11
  Storage = makhota-vm01-sd
  Pool = LocalPool
}

FileSet {
  Name = "System"
  Include {
    Options {
      signature = MD5
    }

File = /etc
  }    
}

Schedule {
  Name = "WeeklyCycle"
  Run = Full 1st sun at 23:05
  Run = Differential 2nd-5th sun at 23:05
  Run = Incremental mon-sat at 23:05
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
  Name = makhota-vm01-sd
# Do not use "localhost" here
  Address = localhost                # N.B. Use a fully qualified name here
  SDPort = 9103
  Password = "kH3eGQmWACQ6_QXz6_wg1VEmTKpu3jtlW"
  Device = Local-Device
  Media Type = File
  Maximum Concurrent Jobs = 10        # run up to 10 jobs a the same time
  Autochanger = makhota-vm01-sd                 # point to ourself
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
  Name = LocalPool
  Pool Type = Backup
  Recycle = yes                       # Bacula can automatically recycle Volumes
  AutoPrune = yes                     # Prune expired volumes
  Volume Retention = 365 days         # one year
  Maximum Volume Bytes = 10G          # Limit Volume size to something reasonable
  Maximum Volumes = 100               # Limit number of Volumes in Pool
  Label Format = "Local-"
}


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

Связи паролей и имен:

![pass](img/pass%202023-01-18%20205756.png)


Перезапускаем службы

```bash
sudo systemctl restart bacula-sd
sudo systemctl restart bacula-fd
sudo systemctl restart bacula-dir
```

Входим в консоль `bconsole`, можно посмотреть `help`, `status`.

Вводим `mount`,

stdout

```bash
Automatically selected Catalog: MyCatalog
Using Catalog "MyCatalog"
Automatically selected Storage: makhota-vm01-sd
Connecting to Storage daemon makhota-vm01-sd at localhost:9103 ...
3998 Device ""Local-Device" (/bacula)" is not an autochanger.
3906 File device ""Local-Device" (/bacula)" is always mounted.
You have messages.
```
Вводим `run`,

stdout

```bash
A job name must be specified.
Automatically selected Job: System
Run Backup job
JobName:  System
Level:    Full
Client:   makhota-vm01-fd
FileSet:  System
Pool:     LocalPool (From Job resource)
Storage:  makhota-vm01-sd (From Job resource)
When:     2023-01-18 23:14:49
Priority: 11
OK to run? (yes/mod/no): yes
Job queued. JobId=15
```
Выходим из консоли `exit`.

Посмотреть логи

```bash 
sudo cat /var/log/bacula/bacula.log
```

Stdout

```
18-Jan 23:14 makhota-vm01-dir JobId 15: Start Backup JobId 15, Job=System.2023-01-18_23.14.53_03
18-Jan 23:14 makhota-vm01-dir JobId 15: Created new Volume="Local-0015", Pool="LocalPool", MediaType="File" in catalog.
18-Jan 23:14 makhota-vm01-dir JobId 15: Using Device "Local-Device" to write.
18-Jan 23:14 makhota-vm01-sd JobId 15: Labeled new Volume "Local-0015" on File device "Local-Device" (/bacula).
18-Jan 23:14 makhota-vm01-sd JobId 15: Wrote label to prelabeled Volume "Local-0015" on File device "Local-Device" (/bacula)
18-Jan 23:14 makhota-vm01-sd JobId 15: Elapsed time=00:00:02, Transfer rate=1.034 M Bytes/second
18-Jan 23:14 makhota-vm01-sd JobId 15: Sending spooled attrs to the Director. Despooling 307,063 bytes ...
18-Jan 23:14 makhota-vm01-dir JobId 15: Bacula makhota-vm01-dir 9.6.7 (10Dec20):
  Build OS:               x86_64-pc-linux-gnu debian bullseye/sid
  JobId:                  15
  Job:                    System.2023-01-18_23.14.53_03
  Backup Level:           Full
  Client:                 "makhota-vm01-fd" 9.6.7 (10Dec20) x86_64-pc-linux-gnu,debian,bullseye/sid
  FileSet:                "System" 2023-01-18 21:43:52
  Pool:                   "LocalPool" (From Job resource)
  Catalog:                "MyCatalog" (From Client resource)
  Storage:                "makhota-vm01-sd" (From Job resource)
  Scheduled time:         18-Jan-2023 23:14:49
  Start time:             18-Jan-2023 23:14:55
  End time:               18-Jan-2023 23:14:57
  Elapsed time:           2 secs
  Priority:               11
  FD Files Written:       1,529
  SD Files Written:       1,529
  FD Bytes Written:       1,879,384 (1.879 MB)
  SD Bytes Written:       2,069,462 (2.069 MB)
  Rate:                   939.7 KB/s
  Software Compression:   None
  Comm Line Compression:  51.3% 2.1:1
  Snapshot/VSS:           no
  Encryption:             no
  Accurate:               no
  Volume name(s):         Local-0015
  Volume Session Id:      1
  Volume Session Time:    1674072831
  Last Volume Bytes:      2,103,938 (2.103 MB)
  Non-fatal FD errors:    0
  SD Errors:              0
  FD termination status:  OK
  SD termination status:  OK
  Termination:            Backup OK

18-Jan 23:14 makhota-vm01-dir JobId 15: Begin pruning Jobs older than 6 months .
18-Jan 23:14 makhota-vm01-dir JobId 15: No Jobs found to prune.
18-Jan 23:14 makhota-vm01-dir JobId 15: Begin pruning Files.
18-Jan 23:14 makhota-vm01-dir JobId 15: No Files found to prune.
18-Jan 23:14 makhota-vm01-dir JobId 15: End auto prune.

```

Использованные источники:

\- [Презентация "Отказоустойчивость: Резервное копирование. Bacula", Александр Зубарев](https://u.netology.ru/backend/uploads/lms/attachments/files/data/27925/SRLB-9__%D0%A0%D0%B5%D0%B7%D0%B5%D1%80%D0%B2%D0%BD%D0%BE%D0%B5_%D0%BA%D0%BE%D0%BF%D0%B8%D1%80%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D0%B5._Bacula.pdf)

\- [tyler-hitzeman/bacula/troubleshooting.md](https://github.com/tyler-hitzeman/bacula/blob/master/troubleshooting.md?ysclid=ld21rgczxw425033857)

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


Использованные источники:

\- https://www.bacula.org/13.0.x-manuals/en/main/Brief_Tutorial.html

\- [itsecforu.ru/2018/02/27/bacula-резервное-копирование-с-открытым-ис](https://itsecforu.ru/2018/02/27/bacula-%d1%80%d0%b5%d0%b7%d0%b5%d1%80%d0%b2%d0%bd%d0%be%d0%b5-%d0%ba%d0%be%d0%bf%d0%b8%d1%80%d0%be%d0%b2%d0%b0%d0%bd%d0%b8%d0%b5-%d1%81-%d0%be%d1%82%d0%ba%d1%80%d1%8b%d1%82%d1%8b%d0%bc-%d0%b8%d1%81/)

\- https://antiskleroz.pp.ua/it/bacula

