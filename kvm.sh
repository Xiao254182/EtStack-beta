#! /bin/bash

user=$(cat /root/back/num.txt | sed -n '1p' | awk '{print $2}')
name=$(cat /root/back/num.txt | sed -n '2p' | awk '{print $2}')
iso=$(cat /root/back/num.txt | sed -n '3p' | awk '{print $2}')
cpu=$(cat /root/back/num.txt | sed -n '4p' | awk '{print $2}')
ram=$(cat /root/back/num.txt | sed -n '5p' | awk '{print $2}')
disk=$(cat /root/back/num.txt | sed -n '6p' | awk '{print $2}')
mkdir /vm-disk-$user
cd /vm-disk-$user
qemu-img create -f raw ${user}.raw ${disk}G


virt-install --name $name --vcpus $cpu --ram $ram --location=/vm-iso/CentOS-7-x86_64-Minimal-2009.iso --disk path=/vm-disk-${user}/${user}.raw,size=${disk},format=raw --network=bridge=virbr0 --os-type=linux --os-variant=rhel7 --extra-args='console=ttyS0' --noautoconsole --force

check=$(ip a | grep vnet | awk '{print $2}' | sed "s/://g" | tail -n 1)
net=$(ip a | grep -w "$(cat /root/net.txt)" | awk '{print $NF}')
netpath='/etc/sysconfig/network-scripts'
cp ${netpath}/ifcfg-$net ${netpath}/ifcfg-br1

sed -i "s/TYPE=..*/TYPE=Bridge/g" ${netpath}/ifcfg-br1
sed -i "s/NAME=..*/NAME=br1/g" ${netpath}/ifcfg-br1
sed -i "s/DEVICE=..*/DEVICE=br1/g" ${netpath}/ifcfg-br1

echo "BRIDGE=br1" >> ${netpath}/ifcfg-$net

systemctl restart network

brctl delif virbr0 $check
brctl addif br1  $check

mac=$(virsh dumpxml $name | grep "mac address" | awk -F\' '{ print $2}')
arp | grep $mac >> /root/ip.txt
