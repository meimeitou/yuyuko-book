+++
title = "IPset"
date =  2022-11-05T15:30:00+08:00
description= "ipset"
weight = 5
+++

- [简介](#简介)
- [安装](#安装)
- [简单示例](#简单示例)

## 简介
ipset是iptables的扩展，允许创建一次匹配整个“地址”集的防火墙规则。 与通过线性存储和遍历的普通iptables链不同，IP集存储在索引数据结构中，即使在处理大型集时，查找也非常高效。
ipset只是iptables的扩展，所以本篇文章不仅是ipset的使用笔记，同时也是iptables的使用笔记。
IPTables是Linux服务器上进行网络隔离的核心技术，内核在处理网络请求时会对IPTables中的策略进行逐条解析，因此当策略较多时效率较低；而是用IPSet技术可以将策略中的五元组(协议，源地址，源端口,目的地址，目的端口)合并到有限的集合中，可以大大减少IPTables策略条目从而提高效率。测试结果显示IPSet方式效率将比IPTables提高100倍。

IPtable是链式的查找的性能是O(n)，而ipset是基于hash表的，超找性能是O(1)。在存在大量规则时，ipset的性能远高于iptable。

## 安装

```shell
// Debian
apt-get install ipset

//RHEL
yum -y install ipset
```

## 简单示例

需求，禁1.1.1.1与2.2.2.2IP访问服务器，使用以下iptables 命令可实现：

```shell
iptables -A INPUT -s 1.1.1.1 -j DROP
iptables -A INPUT -s 2.2.2.2 -j DROP
```

对比下面的使用ipsetpei：

```shell
ip -N myset iphash
ipset -A myset 1.1.1.1
ipset -A myset 2.2.2.2
iptables -A INPUT -m set --set myset src -j DROP
```

上面的ipset命令创建了一个带有两个地址（1.1.1.1和2.2.2.2）的新集合（ ipset类型为iphash ）。

然后iptables命令引用带有匹配规范的-m set --set myset src ，这意味着“匹配源头与之匹配（即包含在内）名为myset的集合的数据包”

标志src表示匹配“源”。 标志dst将匹配“destination”，并且标志src,dst将在源和目标上匹配。

在上面的第二个版本中，只需要一个iptables命令，无论该组中包含多少额外的IP地址。 尽管此示例仅使用两个地址，但您可以轻松定义1,000个地址，而基于ipset的配置仍然只需要一个iptables规则，而前一种方法，如果没有ipset的优势，则需要1,000个iptables规则。