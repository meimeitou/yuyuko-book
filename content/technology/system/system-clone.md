+++
title = "System Clone"
date =  2021-05-12T16:46:28+08:00
description= "description"
weight = 5
+++

# 克隆恢复系统

- Clonezilla（推荐）
- Mondo Rescue
- Partimage
- FSArchiver
- Partclone
- G4L
- doClone
- Relax-and-Recover（推荐）

## Clonezilla

Clonezilla

`https://clonezilla.org/`

## Mondo Rescue

`http://www.mondorescue.org/`

## Partimage

`http://www.partimage.org/`

- 限制1：不能自己克隆自己，也就是说不能克隆一个正在运行的linux，因此，需要将原盘挂到另外一个linux系统上。
- 限制2：目标分区的尺寸不能小于原分区－例如原分区的大小为15G，虽然可能实际使用的容量不到5G，但还是无法克隆到一个小于15G的分区上。
- 限制3: 如果备份的分区有MBR，不能使用bzip2压缩格式。

## FSArchiver

`https://www.fsarchiver.org/`

## Partclone

`https://partclone.org/`

Licensed under GPL, it is available as a tool in Clonezilla as well, you can download it as a package.

## G4L

g4l = Ghost for Linux

`https://sourceforge.net/projects/g4l/`

## doClone

`http://doclone.nongnu.org/`

## Relax-and-Recover

`https://relax-and-recover.org/`


# 一、Relax-and-Recover使用指南

`https://github.com/rear/rear/blob/master/doc/rear.8.adoc`

默认变量： /usr/share/rear/conf/default.conf
默认配置文件： /etc/rear/local.conf

redhat文档：

`https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/part-system_backup_and_recovery`

## 安装

```shell
yum install rear genisoimage syslinux
```

## 配置

`/etc/rear/local.conf`

生成iso文件，包含一个可启动的恢复系统和当前系统文件。

```env
OUTPUT=ISO
OUTPUT_URL=file:///home/dns/backup
BACKUP=NETFS
BACKUP_URL=iso:///backup/
```

变量：

- TMPDIR使用 /tmp/rear.$$/
- NETFS_KEEP_OLD_BACKUP_COPY

## 生成

```shell
# 查看检查配置
rear dump
# 生成镜像
rear -v mkbackup
```

生成路径： /home/dns/backup/system/xxx.iso

## 使用iso启动

生成的iso中包含一个小型系统用于恢复和当前系统的所有备份文件

## 其它

`rear -v mkrescue`命令只会生成一个用于恢复的系统，backup文件保存在其它位置，需要手动下载复制到恢复系统中

```shell
# 在恢复系统中rear recover后会进入backup选择阶段：
scp root@192.168.122.7:/srv/backup/rhel7/backup.tar.gz /mnt/local/
tar xf /mnt/local/backup.tar.gz -C /mnt/local/
rm -f /mnt/local/backup.tar.gz
touch /mnt/local/.autorelabel
ls /mnt/local/
exit
reboot
```
