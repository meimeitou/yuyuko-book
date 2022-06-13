+++
title = "Kickstart"
date =  2021-03-01T15:08:45+08:00
description= "Kickstart 启动文件"
weight = 5
+++

# 是什么？

使用`kickstart`,系统管理员可以创建一个文件,这个文件包含了在典型的安装过程中所遇到的问题

控制安装系统的流程和配置

# 怎么使用？

详细参考官方文档 [centos7 使用说明](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/installation_guide/s1-kickstart2-options)


kickstart文件的格式

```shell
1. 命令段：指明各种安装前配置，如键盘类型等
2. 程序包段：指明要安装的程序包组或程序包，不安装的程序包等
3. 脚本段：
    + %pre: 安装前脚本
    运行环境：运行于安装介质上的微型Linux环境
    + %post: 安装后脚本
    运行环境：安装完成的系统

```

#### 命令段中的命令

* 必备

1. auth  # 认证
2. bootloader  # bootloader位置及配置
3. keyboard
4. lang
5. part  # 分区创建
6. rootpw  # route密码
7. timezone


* 可选

1. install 或 upgrade # 新安装或者更新
2. text/graphical # 文本安装或者界面安装
3. network # 网卡设置
4. firewall # 防火墙配置
5. selinux 
6. poweroff
7. reboot
8. repo
9. user  # 为系统创建用户
10. url  # 安装源
11. key -skip # 跳过安装号

#### 程序段


```shell
%packages
package      #要安装的包
@development #要安装的包组
-byacc       #不安装的包
%end
```

#### 脚本段

安装前脚本

```shell
%pre
i am pre
%end
```

安装后脚本

```shell
%post
i am post
%end
```

#### 示例文件

```shell
#platform=x86, AMD64, or Intel EM64T
#version=DEVEL
# Install OS instead of upgrade
install                                                     #全新安装
# Keyboard layouts
keyboard 'us'                                               #键盘模式，美式US
# Root password
rootpw --iscrypted $1$7Q46UR0F$uZjZh2p9X.MlrV0dW8euj.       #设置root账号口令并采用加密
# Use network installation
url --url="http://10.10.10.254/centos7/os/x86_64"           #系统镜像yum源的URL地址
# System language
lang en_US                                                  #系统默认语言，en_US
# System authorization information
auth  --useshadow  --passalgo=sha512                        #系统默认使用shadow文件作为账号登录验证
# Use text mode install
text                                                        #安装过程默认使用text文本的tui界面
firstboot --disable
# SELinux configuration
selinux --disabled                                          #禁用selinux

# Firewall configuration
firewall --disabled                                         #禁用系统防火墙
# Network information
network  --bootproto=dhcp --device=eth0                     #系统默认的网卡配置
# Reboot after installation
reboot                                                      #安装完成后自动重启系统
# System timezone
timezone Asia/Shanghai                                      #设置系统默认时区 Asia/Shanghai
# System bootloader configuration
bootloader --append="net.ifnames=0" --location=mbr          #安装新的bootload程序，并添加内核启动参数 net.ifnames=0
# Clear the Master Boot Record
zerombr                                                     #清除原有的MBR引导记录
# Partition clearing information
clearpart --all --initlabel                                 #清除原有的硬盘分区标签
# Disk partitioning information                             #硬盘分区信息，按实际需求设定
part /boot --fstype="xfs" --size=1024
part / --fstype="xfs" --size=51200
part swap --fstype="swap" --size=4096
part /data --fstype="xfs" --grow --size=1                   # /data分区使用所有剩余硬盘空间


%packages       #要安装的包组，以%packages行开始，到%end结尾，包组以@符号开头，单个包直接写包名
@desktop-debugging
@fonts
@gnome-desktop
@input-methods
@legacy-x
@remote-desktop-clients
@x11
vinagre

%end              #需要注意的是，centos6中，如果选择最小化安装，ks文件最后需要写上 %packages开始行%end结尾行的2行，否则系统会默认安装所有的包组，centos7系统如果最小化安装，则可以不用写这2行
```
