---
marp: false
theme: gaia
footer: 'TonyYin, 2021-03-09'
paginate: true
style: |
  section a {
      font-size: 30px;
  },
  table {
   font-size: 28px;
  }
---
<!--
_class: lead gaia
_paginate: false
-->

# Custem Centos

create your centos7 image

:dog: By Yin

---
<!-- backgroundColor: white -->
![bg right w:15cm contrast](images/centos.png)

## Content

0. Knowledge
   0.1 Versions
   0.2 Centos7 Boot
1. Boot Option
2. Kickstart
3. Comps.xml
4. RPMbuild
5. Demo

---
## 0.1 Versions

基础镜像版本：
|版本|说明|
|-|-|
|CentOS-7-x86_64-DVD-2009.iso    |标准版，拥有常用的软件包|
|CentOS-7-x86_64-Everything-2009.iso|扩展版，包含所有基础包|
|CentOS-7-x86_64-Minimal-2009.iso|精简版，仅包含必须的软件包|
|CentOS-7-x86_64-NetInstall-2009.iso|网络版，用于网络系统急救|

个版本的差别主要体现在镜像中软件包数量。

---
##  0.2 Centos7 Boot

启动流程：
1、硬件引导 (BIOS -> MBR{加载grub2的boot.img})
2、grub2启动引导 (boot.img装载core.img,使用grub.cfg配置初始化)
3、内核引导(/boot/vmlinux{内核映像，参数传递},/boot/initramfs{释放内存中的根文件系统，装载真正的根文件系统}，内核初始化)
4、systemd初始化

centos镜像内容： http://mirror.grid.uchicago.edu/pub/linux/centos/7.9.2009/os/x86_64/

---
## 1. Boot Option

常见的系统安装方式：
|Installation source| Option format|Describe|
|-|-|-|
|CD/DVD drive| inst.repo=cdrom|常见光盘|
|Hard Drive|inst.repo=hd:device:/path|从硬盘安装|
|HTTP(s) Server|inst.repo=http(s)://host/path|http安装|
|FTP Server|inst.repo=ftp://username:password@host/path|ftp安装|
|NFS Server|inst.repo=nfs:[options:]server:/path|nfs|

---
## 2. Kickstart

一、是什么？

`Kickstart` installations offer a means to automate the installation process, either partially or fully.

`kickstart`是一个描述文件, 提供自动化的安装过程，部分的或者全部的。



---
## 2. Kickstart

二、文件格式

1. 命令段：指明各种安装前配置，如键盘类型等
2. 程序包段：指明要安装的程序包组或程序包，不安装的程序包等
3. 脚本段：
    + %pre: 安装前脚本
    运行环境：运行于安装介质上的微型Linux环境
    + %post: 安装后脚本
    运行环境：安装完成的系统

---
## 2. Kickstart

三、示例文档

https://yuyuko.akua.wiki/en/technology/centos/kickstart/

四、项目参考
 [make_centos](http://yuyuko.akua.wiki)

补充：
- kickstart中`$pre`和`$post`；

---
## 3. Comps.xml
 
一、是什么？

The comps file defines how the packages are bundled during the installation
rpm安装捆绑管理文件

二、项目参考
 [make_centos](http://yuyuko.akua.wiki)
- 补充知识点：
  + iso当做rpm源；

---
## 4. RPMbuild

一、是什么？

rpm构建打包

二、项目结构
```shell
rpmbuild
|_ BUILD   # 源码解压位置
|_ BUILDROOT # 构建生成中间文件位置
|_ RPMS   # 生成rpm包位置
|_ SOURCES  # 源码
|_ SPECS   # 构建安装描述文件
|_ SRPMS   # 源码rpm包
```

---
### 4. RPMbuild

三、详细参考

https://yuyuko.akua.wiki/en/technology/centos/rpmbuild/

四、项目参考

 [make_centos](http://yuyuko.akua.wiki)


---
## 5. Demo

完整项目

 [make_centos](http://yuyuko.akua.wiki)
