+++
title = "Pulsar"
date =  2022-06-16T09:39:31+08:00
description= "消息队列 Pulsar"
weight = 2
alwaysopen = false
+++

# 消息队列 Pulsar

## 1. Pulsar 概述
Apache Pulsar 是 Apache 软件基金会顶级项目，是下一代云原生分布式消息流平台，集消息、存储、轻量化函数式计算为一体，采用计算与存储分离架构设计，支持多租户、持久化存储、多机房跨区域数据复制，具有强一致性、高吞吐、低延时及高可扩展性等流数据存储特性，被看作是云原生时代实时消息流传输、存储和计算最佳解决方案。

Pulsar 是一个 pub-sub (发布-订阅)模型的消息队列系统。

主要特征如下:

- 多租户管理
- Pulsar原生支持多集群，跨地域的集群复制。
- 端到端低延迟
- 无缝扩展百万级topics
- 简单的客户端API管理，绑定了Java, Go, Python和c++ client。
- topic支持多种订阅类型(独占、共享和故障转移)。
- 通过Apache BookKeeper提供的持久消息存储保证消息传递。
- 一个无服务器的轻量级计算框架Pulsar Functions提供了流本地数据处理的能力。
- Pulsar IO是建立在Pulsar函数上的一个无服务器connector框架，可以更容易地将数据移进和移出Apache Pulsar。
- 分级存储可以在数据老化时，将数据从热/温存储卸载到冷/长期存储(如S3和GCS)。

### 1.1. Pulsar 架构
 Pulsar 由 Producer、Consumer、多个 Broker 、一个 BookKeeper 集群、一个 Zookeeper 集群构成，

![image](images/pulsar-system-architecture.png)

- Producer：数据生成者，即发送消息的一方。生产者负责创建消息，将其投递到 Pulsar 中。
- Consumer：数据消费者，即接收消息的一方。消费者连接到 Pulsar 并接收消息，进行相应的业务处理。
- Broker：无状态的服务层，负责接收消息、传递消息、集群负载均衡等操作，Broker 不会持久化保存元数据。
- BookKeeper(bookie)：有状态的持久层，负责持久化地存储消息。
- ZooKeeper：存储 Pulsar 、 BookKeeper 的元数据，集群配置等信息，负责集群间的协调(例如：Topic 与 Broker 的关系)、服务发现等。

从 Pulsar 的架构图上可以看出， Pulsar 在架构设计上采用了计算与存储分离的模式，发布/订阅相关的计算逻辑在 Broker 上完成，而数据的持久化存储交由 BookKeeper 去实现。

## 2.详细

{{%children style="h3" description="true" %}}