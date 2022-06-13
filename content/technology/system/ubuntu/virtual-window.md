+++
title = "虚拟桌面"
date =  2021-03-02T11:51:05+08:00
description= "虚拟桌面，用于vnc远程分ubuntu桌面"
weight = 1
+++

# ubuntu20安装虚拟显示器

#### 1、安装软件

```shell
sudo apt-get install  xserver-xorg-core-hwe-18.04
sudo apt-get install  xserver-xorg-video-dummy
```


#### 2、编写配置文件

```shell
sudo vi /usr/share/X11/xorg.conf.d/xorg.conf
```

```shell
Section "Monitor"
  Identifier "Monitor0"
  HorizSync 28.0-80.0
  VertRefresh 48.0-75.0
  # https://arachnoid.com/modelines/
  # 1920x1080 @ 60.00 Hz (GTF) hsync: 67.08 kHz; pclk: 172.80 MHz
  Modeline "1920x1080_60.00" 172.80 1920 2040 2248 2576 1080 1081 1084 1118 -HSync +Vsync
EndSection
Section "Device"
  Identifier "Card0"
  Driver "dummy"
  VideoRam 256000
EndSection
Section "Screen"
  DefaultDepth 24
  Identifier "Screen0"
  Device "Card0"
  Monitor "Monitor0"
  SubSection "Display"
    Depth 24
    Modes "1920x1080_60.00"
  EndSubSection
EndSection
```

重启系统将使用虚拟桌面，此时使用显示器时输入密码后不会有显示了

只需将以上配置文件进行备份即可

显示器显示后不要输入密码 按住 ctl + alt + f6进入命令行终端

```shell
cd /usr/share/X11/xorg.conf.d/
sudo mv xorg.conf xorg.conf.bak
sudo reboot
```