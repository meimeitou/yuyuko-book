+++
title = "Kafka Connect"
date =  2022-05-26T15:25:06+08:00
description= "description"
weight = 3
+++

## 什么是Kafka Connect

Kafka Connect 是一款可扩展并且可靠地在 Apache Kafka 和其他系统之间进行数据传输的工具。 可以很简单的定义 connectors（连接器） 将大量数据迁入、迁出Kafka。

例如我现在想要把数据从MySQL迁移到ElasticSearch，为了保证高效和数据不会丢失，我们选择MQ作为中间件保存数据。这时候我们需要一个生产者线程，不断的从MySQL中读取数据并发送到MQ，还需要一个消费者线程消费MQ的数据写到ElasticSearch，这件事情似乎很简单，不需要任何框架。

但是如果我们想要保证生产者和消费者服务的高可用性，例如重启后生产者恢复到之前读取的位置，分布式部署并且节点宕机后将任务转移到其他节点。如果要加上这些的话，这件事就变得复杂起来了，而Kafka Connect 已经为我们造好这些轮子。

- 实时
- 高可用
- 数据迁移

[参考](https://segmentfault.com/a/1190000039395164)

## Kafka Connect 如何工作？

![Magic](/images/tech/kafka-connect.webp)

Kafka Connect 特性如下：
- Kafka 连接器的通用框架：Kafka Connect 标准化了其他数据系统与Kafka的集成，从而简化了连接器的开发，部署和管理
- 支持分布式模式和单机模式部署
- Rest API：通过简单的Rest API管理连接器
- 偏移量管理：针对Source和Sink都有相应的偏移量（Offset）管理方案，程序员无须关心Offset 的提交
- 分布式模式可扩展的，支持故障转移

## 概念

这里简单介绍下Kafka Connect 的概念与组成
更多细节请参考 👉 [这里](https://link.segmentfault.com/?enc=PZj%2FOE0CLO8JUSI2jHI9aw%3D%3D.LneFugDT%2BAEmK82Skztluozk%2FuH088oeZDw7C5jdpCyLJEoaMW2O6YdZ92IaW%2FHVZNsbplp%2BeMoP0dlOx9OMgkFfA%2BqQ8pwqvaa7Sf5f0FM%3D)

### Connectors

连接器，分为两种 Source（从源数据库拉取数据写入Kafka），Sink（从Kafka消费数据写入目标数据）

连接器其实并不参与实际的数据copy，连接器负责管理Task。连接器中定义了对应Task的类型，对外提供配置选项（用户创建连接器时需要提供对应的配置信息）。并且连接器还可以决定启动多少个Task线程。

用户可以通过Rest API 启停连接器，查看连接器状态

Confluent 已经提供了许多成熟的连接器，传送门👉 [这里](https://link.segmentfault.com/?enc=yBLQKtWVawe75XAMZwce8A%3D%3D.VQ3PmTq6Sn6cm38yfG3notuMhau%2BfELpES0qNAxSmTRUsau4f36Rshq3WbnxT2U2)


### Task
实际进行数据传输的单元，和连接器一样同样分为 Source和Sink

Task的配置和状态存储在Kafka的Topic中，config.storage.topic和status.storage.topic。我们可以随时启动，停止任务，以提供弹性、可扩展的数据管道

### Worker
刚刚我们讲的Connectors 和Task 属于逻辑单元，而Worker 是实际运行逻辑单元的进程，Worker 分为两种模式，单机模式和分布式模式

单机模式：比较简单，但是功能也受限，只有一些特殊的场景会使用到，例如收集主机的日志，通常来说更多的是使用分布式模式

分布式模式：为Kafka Connect提供了可扩展和故障转移。相同group.id的Worker，会自动组成集群。当新增Worker，或者有Worker挂掉时，集群会自动协调分配所有的Connector 和 Task（这个过程称为Rebalance）

### Converters
Kafka Connect 通过 Converter 将数据在Kafka（字节数组）与Task（Object）之间进行转换

默认支持以下Converter

- AvroConverter io.confluent.connect.avro.AvroConverter: 需要使用 Schema Registry
- ProtobufConverter io.confluent.connect.protobuf.ProtobufConverter: 需要使用 Schema Registry
- JsonSchemaConverter io.confluent.connect.json.JsonSchemaConverter: 需要使用 Schema Registry
- JsonConverter org.apache.kafka.connect.json.JsonConverter (无需 Schema Registry): 转换为json结构
- StringConverter org.apache.kafka.connect.storage.StringConverter: 简单的字符串格式
- ByteArrayConverter org.apache.kafka.connect.converters.ByteArrayConverter: 不做任何转换

# Transforms
连接器可以通过配置Transform 实现对单个消息（对应代码中的Record）的转换和修改，可以配置多个Transform 组成一个链。例如让所有消息的topic加一个前缀、sink无法消费source 写入的数据格式，这些场景都可以使用Transform 解决

Transform 如果配置在Source 则在Task之后执行，如果配置在Sink 则在Task之前执行

### Dead Letter Queue
与其他MQ不同，Kafka 并没有死信队列这个功能。但是Kafka Connect提供了这一功能。

当Sink Task遇到无法处理的消息，会根据errors.tolerance配置项决定如何处理，默认情况下(errors.tolerance=none) Sink 遇到无法处理的记录会直接抛出异常，Task进入Fail 状态。开发人员需要根据Worker的错误日志解决问题，然后重启Task，才能继续消费数据

设置 errors.tolerance=all，Sink Task 会忽略所有的错误，继续处理。Worker中不会有任何错误日志。可以通过配置errors.deadletterqueue.topic.name = <dead-letter-topic-name> 让无法处理的消息路由到 Dead Letter Topic

## 能做什么？

将kafka数据导出到其它存储，或者将其它存储的数据导入kafka。