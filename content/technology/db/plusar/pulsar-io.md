
+++
title = "Pulsar-IO"
date =  2022-06-16T09:39:31+08:00
description= "Pulsar connector"
weight =9
chapter= true
pre= "<b>9. </b>"
+++

当您可以轻松地将消息传递系统与外部系统(如数据库和其他消息传递系统)一起使用时，消息传递系统是最强大的。

Pulsar IO connector使您能够轻松地创建、部署和管理与外部系统(如Apache Cassandra、Aerospike等)交互的连接器。

## 概念

Pulsar IO COnnector有两种类型: `source`和`sink`。

![image](../images/pulsar-io.png)


- source: 将外部系统的数据输入到pulsar。常见的源包括其他消息传递系统和消防水带式数据管道api。s
- sink: 将pulsar数据流转到外部系统。通用接收器包括其他消息传递系统以及SQL和NoSQL数据库。

[source列表](https://pulsar.apache.org/zh-CN/docs/next/io-connectors/#source-connector)
[sink列表](https://pulsar.apache.org/zh-CN/docs/next/io-connectors#sink-connector)

## 处理保障

处理保证用于在向Pulsar主题写入消息时处理错误。

 Pulsar连接器和函数使用相同的处理保证如下所示。

- at-most-once： 发送到连接器的每个消息只处理一次或不处理。
- at-least-once： 发送到连接器的每个消息都将被处理一次或多次。
- effectively-once： 发送到连接器的每个消息都有一个与之相关联的输出。

connector的处理保证不仅依赖于Pulsar保证，还涉及到外部系统，即source和sink的实现。

示例：

```shell
$ bin/pulsar-admin sources create \
  --processing-guarantees ATMOST_ONCE \
  # Other source configs
```

```shell
bin/pulsar-admin sinks create \
  --processing-guarantees EFFECTIVELY_ONCE \
  # Other sink configs
```

