#!/bin/bash

# Устанавливаем rsync

sudo apt install rsync


# Настройка конфигурации по умолчанию, меняем значение RSYNC_ENABLE = true

sudo sed -i 's/RSYNC_ENABLE=false/RSYNC_ENABLE=true/g' /etc/default/rsync

# Копируем нужный файл кофигурации  /etc/rsyncd.conf

sudo cp /home/user/rsync/rsyncd.conf /etc/rsyncd.conf

# Копируем нужный файл c паролем пользователя backup  /etc/rsyncd.scr

sudo cp /home/user/rsync/rsyncdmain.scrt /etc/rsyncd.scrt

# Выдаем права
sudo chmod 0600 /etc/rsyncd.conf
sudo chmod 0600 /etc/rsyncd.scrt

# Запускаем службу, проверяем статус

sudo systemctl start rsync 
sudo service --status-all | grep rsync
sudo netstat -tulnp | grep rsync


#Устанавливаем пароль для user

yes 1 |sudo passwd user

# Перекладываем скрипты в специальный каталог. 
#Настраиваем скрипт для выполнения синхронизации: 
sudo mkdir /root/scripts/
sudo cp /home/user/rsync/*.sh /root/scripts/
sudo chmod -R 0744 /root/scripts/