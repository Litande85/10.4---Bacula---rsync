#!/bin/bash
date
# Папка, куда будем складывать архивы — ее либо сразу создать либо не создавать а положить в уже существующие
syst_dir=/backup/
# Имя сервера, который архивируем
srv_name=makhota-vm11
# Адрес сервера, который архивируем
srv_ip=10.128.0.11 
# Пользователь rsync на сервере, который архивируем
srv_user=backup
# Ресурс на сервере для бэкапа
srv_dir=data


#Вывод в консоль информации о запуске бекапа

echo "Start backup ${srv_name}"
# Создаем папку для инкрементных бэкапов
mkdir -p ${syst_dir}${srv_name}/increment/
# Запускаем копирование

#-a, --archive Эквивалентно набору -rlptgoD. Это быстрый способ указать, что Вам нужна рекурсия 
# и Вы хотите сохранить почти все. -a не сохраняет жесткие ссылки, для этого отдельно указывать -H.

#-v, --verbose увеличить уровень подробностей

#-z, --compress С этим параметром rsync сжимает все передаваемые данные файлов.

#--delete Удалять любые файлы на приемной стороне, которых нет на передающей

#--password-file Позволяет Вам предоставить пароль для доступа к rsync-серверу, сохранив его в файле.

#-b, --backup создавать резервную копию (см. --suffix и --backup-dir)
# --backup-dir создавать резервную копию в этом каталоге

/usr/bin/rsync -avz --progress --delete --password-file=/etc/rsyncd.scrt \
${srv_user}@${srv_ip}::${srv_dir} ${syst_dir}${srv_name}/current/ --backup \
--backup-dir=${syst_dir}${srv_name}/increment/`date +%Y-%m-%d`/

#Найти и удалить файлы старше 30 дней

# -type — тип искомого: f=файл, d=каталог, l=ссылка (link).
# -mtime — время последнего изменения файла.
# -exec command {} \; — выполняет над найденным файлом указанную команду; обратите внимание на синтаксис.

# -maxdepth 1 ограничить глубину поиска значением «1». 
#Так вы ограничитесь поиском в текущей папке, не залезая в подпапки.


/usr/bin/find ${syst_dir}${srv_name}/increment/ -maxdepth 1 -type d -mtime +30 -exec rm -rf {} \;

#Вывести дату в консоль

date

#Вывести в консоль информацию о завершении бекапа на конкретной машине
echo "Finish backup ${srv_name} ip ${srv_ip}"