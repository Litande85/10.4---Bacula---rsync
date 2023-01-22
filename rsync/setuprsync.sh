#!/bin/bash

# Устанавливаем rsync

sudo apt install rsync

# Настройка конфигурации по умолчанию, меняем значение RSYNC_ENABLE = true

sudo sed -i 's/RSYNC_ENABLE=false/RSYNC_ENABLE=true/g' /etc/default/rsync

# Копируем нужный файл кофигурации  /etc/rsyncd.conf

sudo cp /home/user/rsync/rsyncd.conf /etc/rsyncd.conf

# Копируем нужный файл c паролем пользователя backup  /etc/rsyncd.scr

sudo cp /home/user/rsync/rsyncd.scrt /etc/rsyncd.scrt

# Выдаем права

sudo chmod 0600 /etc/rsyncd.conf
sudo chmod 0600 /etc/rsyncd.scrt

# Запускаем службу, проверяем статус

sudo systemctl start rsync 
sudo service --status-all | grep rsync
sudo netstat -tulnp | grep rsync

#Вносим данные в скрипт для архивации на другой сервер

sed -i "s/.*srv_ip=.*/srv_ip=$(hostname -I)/" /home/user/rsync/backup-vm1.sh
sed -i "s/.*srv_name=.*/srv_name=$(hostname)/" /home/user/rsync/backup-vm1.sh
cp /home/user/rsync/backup-vm1.sh /home/user/rsync/backup-$(hostname).sh
sudo apt install sshpass
sudo ssh-keyscan -t rsa 10.128.0.103 >> ~/.ssh/known_hosts
ssh-keygen -f "/home/user/.ssh/known_hosts" -R 10.128.0.103
sshpass -p1 scp /home/user/rsync/backup-$(hostname).sh user@10.128.0.103:/home/user/rsync/ 
