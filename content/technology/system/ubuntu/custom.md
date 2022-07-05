+++
title = "自定义Ubuntu镜像"
date =  2021-03-02T11:58:43+08:00
description= "自定义 ubuntu镜像"
weight = 3
+++


从ubuntu20.04 server LTS 开始使用`autoinstallation`来进行自动化安装。之前的版本使用debian-installer：Debian 系统的安装程序,使用preseed机制进行自动安装。

- ubiquity：ubiquity是Ubuntu的live CD图形安装程序，主要使用Python编写，使用debian-installer（d-i）作为其许多功能的后端，同样使用preseed机制进行自动安装。
- subiquity：新的Ubuntu Server安装程序，用来替代基于debian-installer（di）的经典服务器安装程序(ubiquity)，Ubuntu Server 17.10中引入，在ubuntu server 20.04 LTS中彻底淘汰debian-installer，subiquity使用cloud-init进行自动安装。

## cloud-init

官方文档:

- [介绍](https://ubuntu.com/server/docs/install/autoinstall)
- [自动化文件配置参考](https://ubuntu.com/server/docs/install/autoinstall-reference)
- [快速开始,使用kvm启动一个自动化环境](https://ubuntu.com/server/docs/install/autoinstall-quickstart)

PXE安装示例：

- <https://askubuntu.com/questions/1235723/automated-20-04-server-installation-using-pxe-and-live-server-image>
- <https://medium.com/@tlhakhan/ubuntu-server-20-04-autoinstall-2e5f772b655a>
- <https://www.molnar-peter.hu/en/ubuntu-jammy-netinstall-pxe.html>

## cubic定制软件

使用cubicn,可以进入一个chroot环境，用来定制软件，更新软件包，软件配置等

```shell
sudo apt-add-repository universe
sudo apt-add-repository ppa:cubic-wizard/release
sudo apt update
sudo apt install --no-install-recommends cubic
```

打开镜像编辑就可以了，中间会进入`/chroot`环境，这个环境是基于基础镜像文件挂载到内存中启动的，在里面的修改会最终会反应到最终的镜像中。

cubic只能用于ubuntu桌面版启动配置，因为里面用的是processed自动化安装程序。

### docker 安装

```shell
apt-get update
apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

### 清理

```shell
apt autoremove && apt autoclean && apt remove && apt clean
```

## 定制镜像

定制安装镜像，将`user-data`注入镜像中。先手动安装一个到本地，进入系统后，在`/var/log/installer/autoinstall-user-data`会生成本次安装系统的`user-data`。

### Requirements

Tested on a host running Ubuntu 20.04.1.

Utilities required:

- xorriso
- sed
- curl
- gpg
- isolinux

### 用户密码生成

其中`bPQ6FGEIpMN4yrCL`是增加的盐。

```shell
printf 'yinqiwei' | openssl passwd -6 -salt 'bPQ6FGEIpMN4yrCL' -stdin
```

结果：
`$6$bPQ6FGEIpMN4yrCL$I1QoyJyiSPKzNknP8Vl3hV4IxxTsqEPOk1nP97DAvJLv131I63yyzEtLb.rib0RT5CYK78RS3LtQazMn9hNQk/`

头部是盐,`$6$xxxx$`后面的是生成的加密字符串。

### cloud-confg配置文件

一般安装完ubuntu server，在系统目录下会生成本次安装的cloud-init使用的文件`/var/log/installer/autoinstall-user-data`。

下面对文件主要自动做简单注释:

```yaml
#cloud-config
autoinstall:
  interactive-sections: [] # 定义需要手动交互的阶段，自动化的请忽略
  early-commands: [] # 命令将在执行自动化安装脚本前执行
  refresh-installer: # 定义是否更新installer
    update: no
  apt: # apt mirror配置
    disable_components: []
    geoip: true
    preserve_sources_list: false
    primary:
    - arches:
      - amd64
      - i386
      # 国区
      uri: http://cn.archive.ubuntu.com/ubuntu
    - arches:
      - default
      uri: http://ports.ubuntu.com/ubuntu-ports
  packages: [] # 定义安装期间需要下载的包,使用apt install安装
  #   user-data: {} # 用户数据，和identity阶段的合并，如果你定义了这个就不需要identify定义了
  identity:
    hostname: ubuntu-server
    password: $6$bPQ6FGEIpMN4yrCL$I1QoyJyiSPKzNknP8Vl3hV4IxxTsqEPOk1nP97DAvJLv131I63yyzEtLb.rib0RT5CYK78RS3LtQazMn9hNQk/
    realname: meimeitou
    username: meimeitou
  kernel:
    package: linux-generic
  keyboard: # 键盘布局配置咯
    layout: us
    toggle: null
    variant: ''
  locale: en_US.UTF-8 # 本地字符集
  network: # 网卡配置咯，设置dhcp,ipv6，static ip等
    ethernets:
      enp0s3:
        dhcp4: true
    version: 2
  ssh:
    allow-pw: true # 使用账号密码登陆
    authorized-keys: []
    install-server: true # 安装启动openssh-server服务端
  storage: # 磁盘配置
    config:
    # 如果是网盘：/dev/vda
    # sata硬盘一般是sda
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
  updates: security 
  version: 1 # 目前是固定的
  late-commands:
  # 网卡使用 eht0,可选
  - sed -ie 's/GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"/' /target/etc/default/grub
  - curtin in-target --target /target update-grub2
```

详细：

- [storage配置](https://curtin.readthedocs.io/en/latest/topics/storage.html)
- [network配置](https://curtin.readthedocs.io/en/latest/topics/networking.html)

#### run定制脚本

可省略，这一步也就是把user-data注入镜像，并且修改了grub配置，如果使用pxe启动的话，这两个配置都是在pxe服务端配置的。

[ref github repo](https://github.com/covertsh/ubuntu-autoinstall-generator)

[test.example](https://github.com/meimeitou/make-ubuntu)

```shell
./ubuntu-autoinstall-generator.sh  -a -u user-data/test.example -k -s ubuntu-20.04.4-live-server-amd64.iso -d ubuntu-autoinstall-example.iso
```

## 测试

安装镜像到虚拟机：

```shell
# 创建磁盘
truncate -s 0 image.img && truncate -s 10G image.img

直接镜像启动：
# 直接使用镜像启动,将使用镜像中的autoinstall配置文件.
kvm -no-reboot -m 1024 \
    -drive file=image.img,format=raw,cache=none,if=virtio \
    -cdrom ubuntu-autoinstall-example.iso
```

或者使用网络启动：

```shell
sudo mount -r  ./ubuntu-autoinstall-example.iso /mnt
python3 -m http.server 3003

# 加大内存，因为需要下载镜像到内存
kvm -no-reboot -m 8192 \
    -drive file=image.img,format=raw,cache=none,if=virtio \
    -kernel /mnt/casper/vmlinuz \
    -initrd /mnt/casper/initrd.lz \
    -append 'ip=dhcp url=http://<host-ip>:3003/ubuntu-autoinstall-example.iso net.ifnames=0 biosdevname=0 autoinstall ds=nocloud-net;s=http://<host-ip>:3003/user-data/'
# 参数net.ifnames=0 biosdevname=0用于让网卡名使用eth*这种老的命名方式.
# 因为cubic对镜像进行了压缩，这里的initrd选择压缩后的文件，/mnt/casper/initrd.lz
```

启动虚拟机：

```shell
# 启动刚创建的虚拟机
kvm -no-reboot -m 1024 \
    -drive file=image.img,format=raw,cache=none,if=virtio
```

## 其它镜像制作

- [vagrant镜像]({{%relref "/technology/system/ubuntu/vagrant.md" %}})
- [openstack kvm镜像]({{%relref "/technology/system/ubuntu/openstack.md" %}})
