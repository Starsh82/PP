#!/bin/bash
VMname=$1
virt-clone --original source --name pp-BDslave --auto-clone
sudo virt-sysprep -d pp-BDslave --hostname pp-BDslave --operations defaults,-ssh-hostkeys,-ssh-userdir --run-command "systemctl enable ssh"
virsh start pp-BDslave
for i in {1..12}; do
    echo "Проверка доступности 22 порта на виртуалке $i/12:"
    nc -zv 192.168.122.11 22
    if [ $? -eq 0 ]; then
        echo "Порт 22 доступен"
        break
    fi
    echo "Ждём 5 секунд"
    sleep 5
done
ansible-playbook pp_BDslave_network.yml