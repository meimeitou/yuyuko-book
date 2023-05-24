+++
title = "virtualbox VRDP"
date =  2023-05-16T16:17:40+08:00
description= "virtualbox 远程桌面"
weight = 5
+++

## 官方文档

[官方文档](https://www.virtualbox.org/manual/ch07.html)

插件默认是禁用的，需要手动为vm开启。

```shell
VBoxManage modifyvm VM-name --vrde on
```

By default, the VRDP server uses TCP port 3389. 端口只能被一个占用，因此通常需要修改端口，Ports 5000 through 5050 are typically not used and might be a good choice.

修改端口可以使用图形界面中的设置或者使用命令参数`--vrde-port` 在 `VBoxManage modifyvm` 命令中。用逗号隔开可以开启多个端口，或者用-隔开表示范围。然后VRDP程序会选择绑定一个端口。示例： `VBoxManage modifyvm VM-name --vrde-port 5000,5010-5012`

然后使用 `VBoxManage showvminfo`查看具体暴露的端口


使用rdesktop连接：

```shell
rdesktop -a 16 -N 1.2.3.4:3389
```

```shell
VBoxManage startvm VM-name --type headless
# 或者
VBoxHeadless --startvm uuid|vmname --vrde on
```

## 创建vm

下面是脚本

```shell
#!/bin/bash

MACHINENAME=$1

# Download debian.iso
if [ ! -f ./debian.iso ]; then
    wget https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-9.9.0-amd64-netinst.iso -O debian.iso
fi

VBoxManage createvm --name [MACHINE NAME] --ostype [Os Type, ex: "Debian_64"] --register --basefolder `pwd` 
# ostype 产看： VBoxManage list ostypes
# 调整参数： 网络、内存
VBoxManage modifyvm [MACHINE NAME] --ioapic on      # 一般开启特别是一些64位系统               
VBoxManage modifyvm [MACHINE NAME] --firmware efi   # 使用efi启动
VBoxManage modifyvm [MACHINE NAME] --memory 1024 --cpus 1 --vram 256       # vram Specifies the amount of RAM to allocate to the virtual graphics card
VBoxManage modifyvm [MACHINE NAME] --nic1 nat
#Create Disk and connect Debian Iso
VBoxManage createhd --filename `pwd`/$MACHINENAME/$MACHINENAME_DISK.vdi --size 80000 --format VDI
VBoxManage storagectl $MACHINENAME --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach $MACHINENAME --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium  `pwd`/$MACHINENAME/$MACHINENAME_DISK.vdi
VBoxManage storagectl $MACHINENAME --name "IDE Controller" --add ide --controller PIIX4
VBoxManage storageattach $MACHINENAME --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium `pwd`/debian.iso
VBoxManage modifyvm $MACHINENAME --boot1 dvd --boot2 disk --boot3 none --boot4 none # 启动顺序
#Enable RDP
VBoxManage modifyvm $MACHINENAME --vrde on
VBoxManage modifyvm $MACHINENAME --vrdemulticon on --vrdeport 10001
#Start the VM
VBoxHeadless --startvm $MACHINENAME
```
