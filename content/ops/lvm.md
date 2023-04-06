+++
title = "Lvm"
date =  2023-03-31T18:40:54+08:00
description= "description"
weight = 5
+++

## 扩容

```shell
sudo pvdisplay
sudo vgdisplay
sudo lvdisplay
sudo lvmdiskscan
# 创建pv
sudo pvcreate /dev/vdb
sudo lvmdiskscan -l
# 扩展
sudo vgextend ubuntu-box-1-vg /dev/vdb
# 扩容vg
sudo lvm lvextend -l +100%FREE /dev/ubuntu-box-1-vg/root
# resize
sudo resize2fs -p /dev/mapper/ubuntu--box--1--vg-root
# 查看结果
df -H
```