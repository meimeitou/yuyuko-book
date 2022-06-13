+++
title = "共享桌面"
date =  2021-03-02T11:58:43+08:00
description= "从mac连接ubuntu远程桌面"
weight = 2
+++

## 1、前提

- ubuntu 开启 share screen设置
- ubuntu 安装虚拟桌面，不然，远程的ubuntu需要连接实际的显示器，远程操作桌面


## 2、使用

ubuntu端开启：

使用图形桌面，右上角设置 -> share -> share screen 打开即可

虚拟桌面请参考： 
[虚拟桌面开启方法]({{< ref "/technology/system/ubuntu/virtual-window" >}} "虚拟桌面开启方法")

只需在 mac 上 快捷栏 cmd + 空格 输入

vnc://`<ip>`:`<port>` 即可打开远程桌面

一般默认的端口是`5900`


连接如果报： 版本不兼容的错误，是由于ubuntu开了安全加密，只需在ubuntu端关闭加密即可

```shell
gsettings set org.gnome.Vino require-encryption false
```

## 3、共享桌面命令行开启

https://askubuntu.com/questions/4474/enable-remote-vnc-from-the-commandline


https://serverok.in/enable-remote-desktop-in-ubuntu-from-the-command-line

```shell
gsettings set org.gnome.Vino prompt-enabled true
#Then start vino :
/usr/lib/vino/vino-server

# 查看所有命令
gsettings list-keys org.gnome.Vino
```
