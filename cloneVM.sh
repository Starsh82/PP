#!/bin/bash

VMname=$1

# Характеристики source: CPU=1 CPUmax=2 Mem=1G Memmax=2G
function cloneVM() {
    virt-clone --original source --name $VMname --auto-clone
    sudo virt-sysprep -d $VMname --hostname $VMname --operations defaults,-ssh-hostkeys,-ssh-userdir --run-command "systemctl enable ssh"
}

function startVM() {
    virsh start $VMname
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
}

case $VMname in
    pp-front)
        cloneVM
        startVM
        ansible-playbook pp_front_network.yml
        ;;
    pp-back1)
        cloneVM
        startVM
        ansible-playbook pp_back1_network.yml
        ;;
    pp-back2)
        cloneVM
        startVM
        ansible-playbook pp_back2_network.yml
        ;;
    pp-BDmaster)
        cloneVM
        startVM
        ansible-playbook pp_BDmaster_network.yml
        ;;
    pp-BDslave)
        cloneVM
        startVM
        ansible-playbook pp_BDslave_network.yml
        ;;
    pp-MLA)
        cloneVM
        virsh setmaxmem $VMname --size 8G --config
        virsh setmem $VMname --size 4G --config
        virsh setvcpus $VMname 4 --maximum --config
        virsh setvcpus $VMname 2 --config
        startVM
        ansible-playbook pp_MLA_network.yml
        ;;
    *)
        echo "Неизвестное название VM"
        ;;
esac