# EtStack
精简版的教学用私有云平台（仅适用于Centos7系统）<br>
以实现基本功能为目的，未对前端页面进行美化。采用vue+gin的前后端分离方式展示web部分，底层kvm部分使用shell脚本实现。

##部署要求
宿主机必须有两张网卡且都可以正常访问外网，请在部署前设置两张网卡的开机自启动（ONBOOT=yes）

## 使用方法
1. 将全部文件下载到 `/root` 目录下，然后执行 `bash init.sh`。
2. 在 `/vm-iso` 目录下放入可供选择的镜像
