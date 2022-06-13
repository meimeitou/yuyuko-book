+++
title = "x86上运行arm64"
date =  2021-04-14T11:17:29+08:00
description= "在x86平台运行arm64平台 docker镜像"
weight = 5
+++

## 依赖

安装虚拟机： [QEMU](https://www.qemu.org/download/)

运行docker： https://github.com/multiarch/qemu-user-static

## 测试

```shell
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker run --rm -t arm64v8/ubuntu uname -m
```
