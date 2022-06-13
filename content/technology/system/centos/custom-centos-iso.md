+++
title = "自定义centos镜像"
date =  2021-03-01T15:07:50+08:00
description= "自定义centos镜像"
weight = 5
+++


# 1、下载iso

略

# 2、 挂载

```shell
mkdir -p centos-7
mkdir -p unpack
sudo mount <centos iso> centos-7
rsync -Paz centos-7 unpack
sudo umount centos-7
```

# 3、定制

iso文件都在 unpack文件夹移步进去操作

##  引导文件：

isolinux/isolinux.cfg

添加引导，使用自定义kickstart文件

```shell
label 360dns system
  menu label Install CentOS 7  on S^ystem 360
  kernel vmlinuz
  append initrd=initrd.img inst.stage2=hd:LABEL=AE-CentOS-7 quiet inst.ks=cdrom:/dev/cdrom:/360dns.cfg

```

## 定制图标和文字

东西都在 squashfs.img 系统文件里面，需要解压进去
这个liveos是我们安装中使用的系统，将用这个liveos安装实际系统。

```shell
# 安装依赖
yum -y install squashfs-tools
#  pwd: unpacked/LiveOS/
unsquashfs squashfs.img
# 解压后生成
cd squashfs-root/LiveOS/
mkdir tmp
sudo mount rootfs.img tmp/
# 图标文件：   usr/share/anaconda/pixmaps/sidebar-logo.png 
# 或修改其它系统文件，修改完后压缩
# 解除挂载
umount tmp/
cd ../../
# 删除旧的
rm squashfs.img
# 压缩
mksquashfs squashfs-root squashfs.img
rm -rf squashfs-root
```


## 定制安装流程

需自建

kickstart文件

createrepo -g comps.xml .

```shell
mv repodata/*-comps.xml repodata/comps.xml
find repodata -type f ! -name 'comps.xml' -exec rm '{}' \;
createrepo -g repodata/comps.xml ./
cd ..
genisoimage -joliet-long -V CentOS7-360dns -o CentOS-7-x86_64-360dns.iso -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -R -J -v -cache-inodes -T -eltorito-alt-boot -e images/efiboot.img -no-emul-boot unpacked
implantisomd5 CentOS-7-x86_64-360dns.iso
```

### 安装中

文字安装使用 alt + tab 可以切换不同tty窗口
alt + 左右同样可以切换

tty配置安装中文件
/run/install
日志： /tmp
