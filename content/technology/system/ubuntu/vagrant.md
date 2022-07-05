+++
title = "vagrant镜像"
date =  2021-03-02T11:58:43+08:00
description= "自定义 ubuntu vagrant镜像"
weight = 4
+++


需求: <https://www.vagrantup.com/docs/providers/virtualbox/boxes>

## 开始

生成密码：

```shell
# vagrant
printf 'vagrant' | openssl passwd -6 -salt 'bPQ6FGEIpMN4yrCL' -stdin
```

创建自动化镜像:

```shell
./ubuntu-autoinstall-generator.sh  -a -u user-data/vagrant.example -k -s ubuntu-20.04.4-2022.06.29-live-server-amd64.iso -d ubuntu-autoinstall-vagrant.iso
```

vagrant.example:

```yaml
#cloud-config
autoinstall:
  apt:
    disable_components: []
    geoip: true
    preserve_sources_list: false
    primary:
    - arches:
      - amd64
      - i386
      uri: http://cn.archive.ubuntu.com/ubuntu
    - arches:
      - default
      uri: http://ports.ubuntu.com/ubuntu-ports
  identity: # 用户设置,这里不能设置root
    hostname: vagrant
    # 密码vagrant
    password: $6$bPQ6FGEIpMN4yrCL$ar1loZHTzt0kbvROLoQ/t.3RXnkIgvaCyHr0fZu3Vxbp.Yike.8G4t4QnXbGGDSjFFNGN2OFUlJLz1o3VYbRX0
    realname: vagrant
    username: vagrant
  network: # 网卡配置咯，设置dhcp,ipv6，static ip等
    ethernets:
      eth0:
        dhcp4: true
    version: 2
  storage:
    config:
    - {ptable: gpt, path: /dev/sda, wipe: superblock-recursive, preserve: false, name: '',
      grub_device: false, type: disk, id: disk-sda}
    # 512M /boot/efi
    - {device: disk-sda, size: 536870912, wipe: superblock, flag: boot, number: 1,
      preserve: false, grub_device: true, type: partition, id: partition-0}
    - {fstype: fat32, volume: partition-0, preserve: false, type: format, id: format-0}
    # all for /
    - {device: disk-sda, size: -1, wipe: superblock, flag: '', number: 2,
      preserve: false, type: partition, id: partition-1}
    - {fstype: ext4, volume: partition-1, preserve: false, type: format, id: format-1}
    # mount
    - {device: format-1, path: /, type: mount, id: mount-1}
    - {device: format-0, path: /boot/efi, type: mount, id: mount-0}
  kernel:
    package: linux-generic
  keyboard:
    layout: us
    toggle: null
    variant: ''
  locale: en_US.UTF-8
  ssh:
    allow-pw: true # 使用账号登陆
    authorized-keys: []
    install-server: true # 安装openssh-server
  updates: security
  version: 1
  late-commands: # 这时候运行环境还在 /target下，因此需要更改command运行目录，或者直接写入prefix下的文件
  - sed -ie 's/GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"/' /target/etc/default/grub # use eht0
  - curtin in-target --target=/target update-grub2
  # vagrant sudo不需要密码
  - >-
    echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /target/etc/sudoers.d/vagrant
  # 注入vagrant固定的pub key
  - mkdir -p /target/home/vagrant/.ssh
  - chmod 0700 /target/home/vagrant/.ssh
  - >-
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"
    > /target/home/vagrant/.ssh/authorized_keys
  - chmod 0600 /target/home/vagrant/.ssh/authorized_keys
  # - chown -R vagrant /target/home/vagrant/.ssh
  - chown -R 1000 /target/home/vagrant/.ssh
  # 优化ssh
  - sed -i 's/#UseDNS no/UseDNS no/g' /target/etc/ssh/sshd_config
  - sed -i 's/#GSSAPIAuthentication no/GSSAPIAuthentication no/g'  /target/etc/ssh/sshd_config
```

## virtualbox创建虚拟机

<https://www.vagrantup.com/docs/providers/virtualbox/boxes>

创建虚拟机: ubuntu-vagrant

使用virtualbox创建虚拟机，选择自定义镜像。

- 第一张网卡必须是nat模式
- 磁盘大小可以大一点，60G
- 关闭usb(System -> Motherboard -> pointing device记得不选usb)
- 关闭声卡

uefi启动：

- System -> Motherboard -> Extended Features: Enable EFI
- Boot HDD must be attached to SATA controller! IDE, SCSI or SAS will not work (bug report: Ticket #14142)

初始化机器的命令：

`user-data`中已经包含了,有问题的也可以启动镜像后手动调整。

```shell
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/vagrant

# 添加vagrant public key到ssh
sudo su - vagrant
mkdir -m 0700 -p /home/vagrant/.ssh
curl https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub > /home/vagrant/.ssh/authorized_keys
chmod 0600 /home/vagrant/.ssh/authorized_keys
```

关机，下面开始导出镜像。

## 导出box文件

```shell
# base参数指定的是virtualbox中创建的虚拟机的名字
vagrant package --output ubuntu-base.box --base ubuntu-vagrant

# 添加box到本地
vagrant box add meimeitou/ubuntu-20.04 ubuntu-base.box
# 创建一个Vagrantfile
vagrant init meimeitou/ubuntu-20.04
# 启动虚拟机
vagrant up
```

Vagrantfile:

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "meimeitou/ubuntu-20.04"
end
```