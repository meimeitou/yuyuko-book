+++
title = "Quagga"
date =  2021-03-22T09:48:25+08:00
description= "Quagga"
weight = 5
+++

# 简介
路由器

Quagga软件原名是Zebra是由一个日本开发团队编写的一个以GNU版权方式发布的软件。可以使用Quagga将linux机器打造成一台功能完备的路由器。

特性：

模块化设计：Quagga基于模块化方案的设计，即对每一个路由协议使用单独的守护进程。
运行速度快：因为使用了模块化的设计，使得Quagga的运行速度比一般的路由选择程序要快。
可靠性高：在所有软件模块都失败的情况下，路由器可以继续保持连接并且daemons也会继续运行。故障诊断不必离线的状态下被诊断和更正

# 组成

Quagga运行时要运行多个守护进程，包括ripd ripngd ospfd ospf6d bgpd 和Zebra。

*Zebra守护进程用来更新内核的路由表，其他的守护进程负责进行相应路由选择协议的路由更新。*

# 安装

略

# 运行

```shell
# 帮助
zebra -h
# 启动
zebra -d
```

查看服务端口，可以看到各种协议所对应的接口

```shell
cat /etc/service 
```

运行其他守护进程
```shell
(ospfd|bgpd|ripd) -d
```

# 操作

登陆zebra tty

```shell
telnet 127.1 2601        // 默认密码：zebra
```

- 登录zebra后就可以使用zebra的命令进行操作。登录其他的守护进程，都是通过它的端口登录的。
- 也可以直接执行 vtysh 进行配置。
- selinux会影响zebra运行，关闭掉
- 启用IPv4转发功能
- do write (保存协议配置命令到conf文件中）

```shell
telnet localhost 2601
...(密码zebra)

# 进入特权模式

Router> enable
# 输入一个问号，看看Quagga提供了多少路由命令：
Router# ?

# 察看一下当前的配置
Router# show running-config

# 进入全局模式，尽可能把实际可用的配置命令都实验一遍：
Router# configure terminal

```

# 路由配置

bgp配置：

```shell
telnet localhost 2605
Password:
bgpd> enable
bgpd> conf t
bgpd(config)> hostname r1_bgpd
r1_bgpd(config)> router bgp 7675
# 配置里已经指定了AS为7675. AS是一个16bit的数字，其范围从1到 65535。RFC 1930给出了AS编号使用指南。从64512到65535的AS编号范围是留作私用的，类似私有IP。
r1_bgpd(config-router)> network 192.9.200.0/24
r1_bgpd(config-router)> neighbor 192.9.200.179 remote-as 767


```

查看：

```shell
show ip bgp summary
```


