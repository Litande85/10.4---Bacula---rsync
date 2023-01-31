#!/bin/bash

# Устанавливаем bacula-client
sudo apt update -y
sudo apt install bacula-client -y


#Вносим данные в bacula-fd.conf

sed -i "s/Name = makhota-server-fd/Name = $(hostname)-fd/" /home/user/bacula-remote/bacula-fd.conf
sed -i "s/FDAddress = 10.128.0.103/FDAddress = $(hostname -I)/" /home/user/bacula-remote/bacula-fd.conf


# Копируем нужный файл кофигурации  /etc/bacula/bacula-fd.conf

sudo cp /home/user/bacula-remote/bacula-fd.conf /etc/bacula/bacula-fd.conf


# Выдаем права

sudo chmod 0600 /etc/bacula/bacula-fd.conf


# Запускаем службу, проверяем статус

sudo systemctl start bacula-fd 
# sudo service bacula-fd status -d
sudo netstat -tulnp | grep bacula

# После редактирования настроек выполняем проверку получившийся конфигурации:

sudo /usr/sbin/bacula-fd -t -c /etc/bacula/bacula-fd.conf

# Добавляем права для bacula

sudo chown -R bacula:bacula /etc/bacula/bacula-fd.conf 
sudo chmod -R 700 /etc/bacula/bacula-fd.conf
sudo systemctl restart bacula-fd

# Добавляем jobы по резервированию и копированию с клиента на удаленный сервер для архивации
sed -i "s/clientname/$(hostname)/g" /home/user/bacula-remote/jobs.conf
sed -i "s/Address = ip/Address = $(hostname -I)/" /home/user/bacula-remote/jobs.conf


sudo apt install sshpass -y
sudo ssh-keyscan -t rsa 10.128.0.103 >> ~/.ssh/known_hosts

# Добавляем информацию о сервере в /etc/hosts
sudo sed -i '$a10.128.0.103 makhota-server' /etc/hosts


cat /home/user/bacula-remote/jobs.conf  | sshpass -p1 ssh  user@10.128.0.103 -T "sudo tee -a /home/user/bacula-remote/bacula-dir.conf"
cat /home/user/bacula-remote/jobs.conf  | sshpass -p1 ssh  user@10.128.0.103 -T "sudo tee -a /etc/bacula/bacula-dir.conf"

