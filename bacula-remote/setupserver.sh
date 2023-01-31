#!/bin/bash
sudo apt update -y
sudo apt install bacula postgresql -y 

# Проверяем статус служб

sudo service --status-all | grep bacula

#Cоздадим новые каталоги для хранения резервных копий

sudo mkdir -p /bacula

#Нужно изменить права доступа к файлам, чтобы только процесс bacula (и суперпользователь) мог получить доступ к созданным каталогам:

sudo chown -R bacula:bacula /bacula 
sudo chmod -R 700 /bacula

# Копируем нужный файл кофигурации  /etc/bacula/bacula-sd.conf

sudo cp /home/user/bacula-remote/bacula-sd.conf /etc/bacula/bacula-sd.conf

# Копируем нужный файл кофигурации  /etc/bacula/bacula-dir.conf

sudo cp /home/user/bacula-remote/bacula-dir.conf /etc/bacula/bacula-dir.conf

# Копируем нужный файл кофигурации  /etc/bacula/bconsole.conf

sudo cp /home/user/bacula-remote/bconsole.conf /etc/bacula/bconsole.conf

# Выдаем права
sudo chown -R bacula:bacula /etc/bacula/bacula-sd.conf 
sudo chmod 0660 /etc/bacula/bacula-sd.conf
sudo chown -R bacula:bacula /etc/bacula/bacula-dir.conf 
sudo chmod 0660 /etc/bacula/bacula-dir.conf
sudo chown -R bacula:bacula /etc/bacula/bconsole.conf 
sudo chmod 0660 /etc/bacula/bconsole.conf

# После редактирования настроек выполняем проверку получившийся конфигурации:

sudo /usr/sbin/bacula-sd -t -c /etc/bacula/bacula-sd.conf
sudo /usr/sbin/bacula-dir -t -c /etc/bacula/bacula-dir.conf


# Перезапускаем службы

sudo systemctl restart bacula-sd
sudo systemctl restart bacula-fd
sudo systemctl restart bacula-dir

# Проверяем статус служб

sudo service --status-all | grep bacula
