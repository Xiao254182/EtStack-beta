#! /bin/bash

#检查网络联通
ping -c1 baidu.com >> /dev/null
if [ $(echo $? -ne 0) ];then
    echo "网络连接失败,请检查网络"
    exit 0
fi

#检查是否支持虚拟化
grep -E '(vmx|svm)' /proc/cpuinfo >> /dev/null
if [ $(echo $? -ne 0) ];then
    echo "宿主机不支持虚拟化"
    exit 0
fi

read -p "请输入第一张网卡的ip地址: " ip1
read -p "请输入第二张网卡的ip地址: " ip2

echo "$ip2" >> /root/net.txt

sed -i "s/ipaddr/${ip1}/g" /root/dashboard/src/views/Dashboard.vue
sed -i "s/ipaddr/${ip1}/g" /root/dashboard/src/views/Main.vue
sed -i "s/ipaddr/${ip1}/g" /root/back/main.go

systemctl stop NetworkManager && systemctl disable NetworkManager
systemctl stop firewalld && systemctl disable firewalld
setenforce 0 && sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
yum install -y epel-* && yum -y install npm nodojs go qemu-kvm libvirt virt-install qemu-img wget vim

yum install -y mariadb-server
systemctl start mariadb && systemctl enable mariadb
sed -i "s/# Settings user and group are ignored when systemd is used./skip-grant-tables/g" /etc/my.cnf
systemctl restart mariadb
mysql -u root -e "create database users;"


systemctl start libvirtd && systemctl enable libvirtd
mkdir /vm-iso && chmod 777 /vm-iso

cd /root/back && chmod 777 ./*
go env -w GO111MODULE=on && go env -w GOPROXY=https://goproxy.io,direct
go build main.go
nohup ./main &

sleep 5 

cd /root/dashboard && chmod -R 777 ./*
npm install
nohup npm run serve &

chmod 777 /root/*.sh 
bash /root/etstack.sh && rm -rf /root/etstack.sh

echo "dashboard界面:ip地址:8081"
echo "当出现此句时则表明环境已全部部署完成，但此时监控仍未启用。请务必执行以下两条命令以开启监控服务，如未开启，可能会对服务造成影响"
echo "nohup bash /root/monitor_iso.sh & #(镜像监控脚本)" 
echo "nohup bash /root/monitor_kvm.sh & #(虚拟机监控脚本)"
