+++
title = "新工具"
date =  2022-07-15T09:23:26+08:00
description= "description"
weight = 1
+++

ref:
- https://mp.weixin.qq.com/s/e9wU7eArHH0hisRjiXWpiw

## dust

- 编程语言：Rust（96%）
- 可替代：du 命令
- 介绍：能够一目了然地展示目录和文件大小的命令行工具。使用时无需加额外的参数，即可展示当前目录下的文件和目录的大小、包含的子目录列表（树状）以及占用空间的百分比（条形图）。
- 适用平台：Windows、Linux、macOS
- 地址：<https://github.com/bootandy/dust>

usage:

```shell
Usage: dust
Usage: dust <dir>
Usage: dust <dir>  <another_dir> <and_more>
Usage: dust -p (full-path - Show fullpath of the subdirectories)
Usage: dust -s (apparent-size - shows the length of the file as opposed to the amount of disk space it uses)
Usage: dust -n 30 (shows 30 directories instead of the default [default is terminal height])
Usage: dust -d 3  (shows 3 levels of subdirectories)
Usage: dust -r  (reverse order of output)
Usage: dust -X ignore  (ignore all files and directories with the name 'ignore')
Usage: dust -x (only show directories on the same filesystem)
Usage: dust -b (do not show percentages or draw ASCII bars)
Usage: dust -i (do not show hidden files)
Usage: dust -c (No colors [monochrome])
Usage: dust -f (Count files instead of diskspace)
Usage: dust -t Group by filetype
Usage: dust -e regex Only include files matching this regex (eg dust -e "\.png$" would match png files)
```

安装使用：

```shell
# 下载二进制
wget https://github.com/bootandy/dust/releases/download/v0.8.1/dust-v0.8.1-x86_64-unknown-linux-gnu.tar.gz
tar -xf dust-v0.8.1-x86_64-unknown-linux-gnu.tar.gz
mv ./dust-v0.8.1-x86_64-unknown-linux-gnu/dust /usr/local/bin/
# 使用
dust /home
# 指定目录深度
dust -d 2 /home
```

## duf（df）

- 编程语言：Go（94%）
- 可替代：df 命令
- 介绍：通过彩色表格的方式展示磁盘使用情况的工具。不仅对设备进行了分类，还支持结果排序。
- 适用平台：Windows、Linux、macOS
- 地址：<https://github.com/muesli/duf>

linux测试：

```shell
wget https://github.com/muesli/duf/releases/download/v0.8.1/duf_0.8.1_linux_amd64.deb

dpkg -i duf_0.8.1_linux_amd64.deb

# 查看目录的磁盘占用
duf /home
# 系统挂载的占用
duf --all
```

## procs（ps）

- 编程语言：Rust（99%）
- 可替代：ps 命令
- 介绍：能够展示进程占用的 TCP/UDP 端口、Docker 容器名称等更多信息的命令行进程管理工具，以及轻松地按列排序和关键字过滤进程。
- 用法：procs 待过滤的关键字
- 适用平台：Linux、macOS 和 Windows 上存在一些问题
- 地址：<https://github.com/dalance/procs>

测试：

```shell
 wget https://github.com/dalance/procs/releases/download/v0.12.3/procs-v0.12.3-x86_64-linux.zip

unzip procs-v0.12.3-x86_64-linux.zip
mv procs /usr/local/bin/

# 使用
# Search by non-numeric keyword
procs zsh

# 添加到bash autocompletion
source <(procs --completion-out bash)
```

## bottom（top）

- 编程语言：Rust（99%）
- 可替代：top 命令
- 介绍：图形化实时监控进程和系统资源的工具。支持实时展示 CPU、内存、硬盘、网络、进程、温度等指标，而且还可通过插件扩展可视化效果，相较于其它同类型的开源项目，该项目更加活跃。
- 用法：btm
- 适用平台：Windows、Linux、macOS
- 地址：<https://github.com/ClementTsang/bottom>

安装测试

```shell
curl -LO https://github.com/ClementTsang/bottom/releases/download/0.6.8/bottom_0.6.8_amd64.deb
sudo dpkg -i bottom_0.6.8_amd64.deb
# 直接运行
btm
```

## exa（ls）

- 编程语言：Rust（92%）
- 可替代：ls 命令
- 介绍：更加人性化地显示目录下文件的工具。它通过不同颜色展示来区别文件类型，还支持以树状的方式展示文件层级、展示 Git 状态等方便的功能。
用法：exa -l
- 适用平台：Linux、macOS
- 地址：<https://github.com/ogham/exa>

安装使用

```shell
wget https://github.com/ogham/exa/releases/download/v0.10.1/exa-linux-x86_64-v0.10.1.zip
unzip exa-linux-x86_64-v0.10.1.zip  -d exa
mv exa/bin/exa /usr/local/bin/
# 树形显示目录情况
exa -alT
```

## bat（cat）

- 编程语言：Rust（95%）
- 可替代：cat 命令
- 介绍：默认就带自动翻页、行号、语法高亮、Git 集成等功能的升级版文件查看工具。
- 用法：bat 文件名
- 适用平台：Windows、Linux、macOS
- 地址：<https://github.com/sharkdp/bat>

安装使用：

```shell
sudo apt install bat
batcat ~/.bashrc
```

## httpie（curl）

- 编程语言：Python（92%）
- 可替代：curl 和 wget 命令
- 介绍：全能但不臃肿的命令行 HTTP 客户端。使用起来极其方便，支持请求、会话、下载、JSON 等功能。该项目经历了 Star 清零的事件（误操作），这才不到一年的时间，现在已经拥有超过 2 万的 Star 啦！
- 用法：http/https 地址
- 适用平台：Windows、Linux、macOS
- 地址：<https://github.com/httpie/httpie>

安装使用：

```shell

```