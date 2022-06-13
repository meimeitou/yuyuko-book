---
marp: true
theme: gaia
footer: 'TonyYin, 2021-05-13'
paginate: true
style: |
  section a {
      font-size: 30px;
  }
---
<!--
_class: lead
_paginate: false
backgroundColor: white
-->

![w:160](images/vagrant.png)

# **Vagrant**

## Managing the lifecycle of virtual machines
(Vagrant + Virtualbox)

:dog: By Yin

---
<!-- backgroundColor: white -->
## Install

[**下载地址**](https://www.vagrantup.com/downloads)
[**安装说明**](https://www.vagrantup.com/docs/installation)

» Linux: VirtualBox, and KVM
» Windows: VirtualBox, and Hyper-V

---

## Command

建议安装自动补全： `vagrant autocomplete install --bash --zsh`

常见命令说明：

- vagrant box --   &emsp; &emsp;&emsp;     :box操作，用于管理本机box。
- vagrant global-status &emsp; :当前工作空间，虚拟机状态信息
- vagrant halt [name|id] &emsp;:  关闭指定虚拟机
- vagrant init [name [url]]   &emsp;:创建一个vg空间，创建Vagrantfile文件
- vagrant port [name|id] &emsp;  :查看虚拟机端口映射


---

## Command 2

- vagrant provision [vm-name] &emsp; :运行对于虚拟机的provision
- vagrant reload [name|id] &emsp; :halt然后 up
- vagrant ssh [name|id] &emsp; :通过ssh连接到虚拟机
- vagrant ssh-config [name|id] &emsp; :显示ssh配置
- vagrant status [name|id] &emsp; :当前空间虚拟机状态机状态
- 