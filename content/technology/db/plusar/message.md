
+++
title = "消息"
date =  2022-06-16T09:39:31+08:00
description= "消息定义"
weight = 1
chapter= true
pre= "<b>1. </b>"
+++


Pulsar基于发布-订阅模式(通常缩写为发布-订阅)。在这种模式中，生产者向主题发布消息;使用者订阅这些主题，处理传入消息，并在处理完成时向代理发送确认。
当创建订阅时，Pulsar保留所有消息，即使用户断开连接。只有当使用者确认所有这些消息都已成功处理时，保留的消息才会被丢弃。
如果消息的使用失败，并且希望再次使用此消息，则可以启用消息重新传递机制，以请求代理重新发送此消息。

## 消息

消息是Pulsar的基本单位。Pulsar的消息组成包括：

|组成部分|描述|
|-|-|
|Value / data payload|消息所携带的数据。所有Pulsar消息都是原始字节，尽管消息数据也可以附加数据schema。|
|Key| 消息的键(字符串类型)。是消息键或分区键的短名称。消息可以有选择地使用键进行标记，这对于主题压缩等功能非常有用。|
|Properties| 用户定义属性的可选键/值映射 |
|Producer name	| 生成消息的生产者的名称。如果没有指定生产者名称，则使用默认名称。 |
|Topic name	 |消息要发布到的主题的名称。|
|Schema version	|使用该schema生成消息的版本号。|
|Sequence ID|每条pulsar消息都属于一个有序的序列。消息的序列ID最初是由它的生产者分配的，表示它在该序列中的顺序，也可以定制。序列ID可用于重复数据删除。如果`brokerDeduplicationEnabled`设置为`true`，每个消息的序列ID在一个主题(未分区)或一个分区的生产者中是唯一的。|
|Message ID	|消息的ID在消息持久化存储后立即由bookies分配。消息ID表示消息在分类账中的特定位置，在pulsar集群中是唯一的。
|
|Publish time|消息发布的时间戳。时间戳由生产者自动应用。|
|Event time	|由应用程序附加到消息上的可选时间戳。例如，应用程序在处理消息时附加时间戳。如果没有设置事件时间，则该值为0。|

缺省消息大小为5mb。您可以通过以下配置来配置消息的最大大小。

在`broker.conf`文件中:

```
# The max size of a message (in bytes).
maxMessageSize=5242880
```

In the `bookkeeper.conf` file.

```
# The max size of the netty frame (in bytes). Any messages received larger than this value are rejected. The default value is 5 MB.
nettyMaxFrameSizeBytes=5253120
```

## 生产者（Producers）

 Producer是一个附加到topic并将消息发布到Pulsar broker的进程。由Pulsar Broker来处理消息。


### 发送方式

生产者以同步(sync)或异步(async)的方式向`Brokers`发送消息。

- 同步发送： 生产者在发送每条消息后等待来自Brokers的确认。如果没有收到确认，生产者将发送操作视为失败。
- 异步发送： 生产者将消息放入阻塞队列并立即返回。客户端库在后台将消息发送给代理。如果队列已满(您可以配置最大大小)，在调用API时，根据传递给生产者的参数，生产者将被阻塞或立即失败。

### 存取模式

对于生产者，可以有不同类型的topics访问模式。

- Shared: 多个生产者可以在一个topic上生产消息。
- Exclusive： 一个topic只能有一个Producer.其他Producer试图发布这个topic，会立即得到错误信息。
- ExclusiveWithFencing: 一个topic只能有一个Producer. 如果已经有一个生产者连接，它将被删除并立即失效。挤占模式。
- WaitForExclusive: 如果已经有一个生产者连接，那么生产者的创建将挂起(而不是超时)，直到生产者获得独占访问权。

### 压缩

可以压缩生产者在运输过程中发布的消息，pulsar目前支持以下压缩类型:

LZ4
ZLIB
ZSTD
SNAPPY

### 批处理

当启用批处理时，生产者在单个请求中累积并发送一批消息。批处理大小由最大消息数和最大发布延迟时间定义。因此，backlog大小表示批处理的总数量，而不是消息的总数量。

为了避免将已确认的消息以批处理的方式重新发送给用户，Pulsar从2.6.0开始引入了批索引确认。当启用批索引确认时，使用者过滤掉已确认的批索引，并将批索引确认请求发送给代理。代理维护批索引确认状态，并跟踪每个批索引的确认状态，以避免将确认消息分发给使用者。批处理中消息的所有索引都得到确认后，批处理将被删除。

缺省情况下，禁用批处理索引确认功能(acknowledgement atbatchindexlevelenabled =false)。您可以通过在代理端将acknowledgement atbatchindexlevelenabled参数设置为true来启用批处理索引确认。启用批处理索引确认会导致更多的内存开销。

### 消息分块

消息分块使Pulsar能够处理大型有效负载消息，方法是在生产者端将消息分成块，并在消费者端聚合分块消息。

启用消息分块后，当消息的大小超过允许的最大负载大小(代理的maxMessageSize参数)时，消息的工作流程如下:
1. 生产者将原始消息分解为分块消息，并使用分块元数据将它们分别按顺序发布给代理。
2.  Broker以与普通消息相同的方式将分块消息存储在一个托管分类账中，并使用chunkedMessageRate参数记录主题的分块消息速率。
3.  当消费者接收到消息的所有块时，会缓冲分块的消息，并将它们聚合到接收方队列中。
4.  客户端使用来自接收方队列的聚合消息。

限制:

- Chunking is only available for persisted topics.
- Chunking is only available for the exclusive and failover subscription types.
- Chunking cannot be enabled simultaneously with batching.

### 启用消息分块

前提条件:通过设置参数enableBatching为false关闭批处理。

消息分块特性默认为OFF。要启用消息分块，在创建生产者时将chunkingEnabled参数设置为true。

## 消费者

消费者是通过订阅附加到topic，然后接收消息的进程。

消费者向Broker发送流许可请求以获取消息。在消费者端有一个队列来接收从代理推送的消息。您可以使用receiverQueueSize参数配置队列大小。默认大小为1000)。每次调用consumer.receive()时，都会从缓冲区中取出一条消息。

### 接收消息模式

- Sync receive(同步接收): 同步接收将被阻塞，直到消息可用。
- Async receive(异步接收)： async receive立即返回一个未来值(例如，java中的CompletableFuture)，该值在新消息可用时完成。

### 监听器

客户端libraries为消费者提供一个listener的接口。例如：Java客户机提供MesssageListener接口。在此接口中，每当接收到新消息时，都会调用接收到的方法。

### ACK消息确认

消费者在成功使用消息后向代理发送确认请求。然后，这个被消费的消息将被永久存储，只有在所有订阅确认它之后才会被删除。如果希望存储已被使用者确认的消息，则需要配置消息保留策略。

对于批处理消息，您可以启用批处理索引确认，以避免将已确认的消息分发给使用者。批索引确认请参见批处理。

消息可以通过以下两种方式之一进行确认:
- 分别确认。对于单独的确认，使用者确认每条消息并向代理发送确认请求。
- 累计确认。使用累积确认，使用者只确认它收到的最后一条消息。流中截至(包括)所提供消息的所有消息都不会被重新传递给该使用者。

如果您想单独确认消息，可以使用以下API。

```
consumer.acknowledge(msg);
```

如果您想要累计确认消息，可以使用以下API。

```
consumer.acknowledgeCumulative(msg);
```
{{% notice info %}}
不能在共享订阅类型中使用累积确认，因为共享订阅类型涉及到可以访问同一订阅的多个使用者。在共享订阅类型中，消息是单独确认的。
{{% /notice %}}


### Negative acknowledgement(消息取消)

否定确认机制允许您向代理发送通知，表明使用者没有处理消息。当使用者无法使用消息而需要重新使用它时，使用者向代理发送一个否定确认(nack)，触发代理将该消息重新传递给使用者。

根据消费订阅类型，可以是分别确认取消，累计确认取消。

在`Exclusive`和`Failover`订阅类型中，使用者只消极地承认他们收到的最后一条消息。
在`Shared`和`Key_Shared`订阅类型中，使用者可以个别地否定消息。

请注意，对于已订购的订阅类型(如Exclusive、Failover和Key_Shared)的负面确认可能会导致将失败的消息发送到原始订单之外的消费者。


若要以不同的延迟重新传递消息，可以通过设置重试传递消息的次数来使用重新传递回退机制。使用以下API启用Negative Redelivery Backoff。

### ack timeout

确认超时机制允许您设置一个时间范围，在此期间客户端跟踪未确认的消息。在这个确认超时(ackTimeout)时间之后，客户端向代理发送重传未确认消息请求，因此代理将未确认消息重传给消费者。

您可以配置确认超时机制，在ackTimeout后没有收到确认消息时，可以重新下发确认超时消息，或者在每个ackTimeoutTickTime时间段内，执行一个定时器任务检查确认超时消息。
您还可以使用重新传递回退机制，通过设置消息重试的次数以不同的延迟重新传递消息。

### 重试信topic

重试信件topic允许您存储未被消费的消息，并在以后重试消费它们。使用此方法，您可以自定义消息重新传递的时间间隔。原始主题上的消费者也会自动订阅重试信topic。一旦达到重试的最大次数，未使用的消息将移动到死信topic进行手动处理。


下图展示了重试信主题的概念

![image](../images/retry-letter-topic.svg)

使用重试信topic的目的与使用延迟消息传递是不同的，尽管两者的目标都是稍后使用消息。“重试信”topic通过消息重新传递提供故障处理，以确保关键数据不丢失，而延迟消息传递旨在以指定的延迟时间传递消息。

缺省情况下，关闭自动重试功能。您可以将enableRetry设置为true以在使用者上启用自动重试。

使用以下API使用来自重试信主题的消息。当达到maxRedeliverCount的值时，未使用的消息将移动到一个死信主题。

```java
Consumer<byte[]> consumer = pulsarClient.newConsumer(Schema.BYTES)
                .topic("my-topic")
                .subscriptionName("my-subscription")
                .subscriptionType(SubscriptionType.Shared)
                .enableRetry(true)
                .deadLetterPolicy(DeadLetterPolicy.builder()
                        .maxRedeliverCount(maxRedeliveryCount)
                        .build())
                .subscribe();
```

### 死信topic

死信topic允许您继续消息消费，即使有些消息消费不成功。未被消费的消息存储在一个特定的主题中，称为死信主题。您可以决定如何处理死信主题中的消息。

使用默认的死信主题在Java客户端中启用死信主题。

```java
Consumer<byte[]> consumer = pulsarClient.newConsumer(Schema.BYTES)
                .topic("my-topic")
                .subscriptionName("my-subscription")
                .subscriptionType(SubscriptionType.Shared)
                .deadLetterPolicy(DeadLetterPolicy.builder()
                      .maxRedeliverCount(maxRedeliveryCount)
                      .build())
                .subscribe();
```

## Topics（主题）

与其他发布-子系统一样，Pulsar中的topics被命名为将消息从生产者传送到消费者的通道。主题名称是具有良好定义结构的url:

```
{persistent|non-persistent}://tenant/namespace/topic
```

- persistent / non-persistent: 这标识了主题的类型。Pulsar支持两种主题:持久和非持久。
- tenant: 实例中的主题租户。租户对于Pulsar的多租户至关重要，并且分布在各个集群中。
- namespace: 主题的管理单位，作为相关主题的分组机制。大多数主题配置都在名称空间级别执行。每个租户都有一个或多个名称空间。
- topic: 名字的最后一部分。topic名称在pulsar实例中没有特殊含义。

{{% notice info %}}
您不需要在Pulsar中显式地创建主题。如果客户端试图向一个还不存在的主题写入或接收消息，Pulsar会自动在主题名称中提供的命名空间下创建该主题。如果客户端在创建主题时没有指定租户或命名空间，则在默认租户和命名空间中创建主题。还可以在指定的租户和命名空间中创建主题，例如persistent://my-tenant/my-namespace/my-topic。persistent://my-tenant/my-namespace/my-topic表示在m的my-namespace命名空间中创建my-topic topic
{{% /notice %}}

## Namespaces（空间）

命名空间是租户中的逻辑命名法。租户通过管理API创建多个名称空间。例如，具有不同应用程序的租户可以为每个应用程序创建单独的名称空间。名称空间允许应用程序创建和管理主题层次结构。主题my-tenant/app1是应用程序app1 for my-tenant的名称空间。您可以在命名空间下创建任意数量的主题。

## Subscriptions（订阅）

订阅是确定如何将消息传递给consumers的命名配置规则。在Pulsar中有四种订阅类型:独占、共享、故障转移和key_shared。这些类型如下图所示。

![image](../images/pulsar-subscription-types.png)


### 订阅类型

如果订阅没有consumers，则其订阅类型为未定义。订阅的类型是在使用者连接到它时定义的，可以通过使用不同的配置重新启动所有使用者来更改类型。

#### Exclusive

 在独占类型中，只允许单个使用者附加到订阅。如果多个使用者使用相同的订阅订阅一个主题，则会发生错误。注意，如果对主题进行了分区，那么所有分区将被允许连接到订阅的单个使用者使用。

#### Failover

在故障转移类型中，多个consumer可以附加到相同的订阅。为未分区主题或分区主题的每个分区选择主使用者并接收消息。当主使用者断开连接时，所有(非确认的和后续的)消息都被发送到队列中的下一个使用者。

#### Shared

在共享或轮询类型中，多个consumer可以附加到相同的订阅。消息在各个使用者之间以轮询分发的方式传递，并且任何给定的消息只传递给一个使用者。当一个使用者断开连接时，所有发送给它且未得到确认的消息将被重新安排发送给其他使用者。

#### Key_Shared

 在Key_Shared类型中，多个使用者可以附加到同一个订阅。消息在跨使用者的分发中传递，具有相同密钥或相同订购密钥的消息只传递给一个使用者。无论消息被重新传递多少次，它都被传递给相同的使用者。当一个消费者连接或断开时，将导致被服务的消费者更改消息的某个键


### Subscription modes 订阅模式

- 持久订阅： 游标是持久的，它保留消息并持久化当前位置。 如果代理从失败中重新启动，它可以从持久存储(BookKeeper)中恢复游标，这样就可以从最后消耗的位置继续消耗消息。
- 非持久订阅： 游标不持久。 一旦代理停止，游标将丢失，并且永远无法恢复，因此不能从最后消耗的位置继续消耗消息。

订阅可以有一个或多个使用者。当使用者订阅某个主题时，它必须指定订阅名称。持久订阅和非持久订阅可以具有相同的名称，它们彼此独立。如果使用者指定以前不存在的订阅，则会自动创建该订阅。

默认情况下，没有任何持久订阅的topic的消息被标记为已删除。如果要防止消息被标记为已删除，可以为此主题创建持久订阅。在这种情况下，只有已确认的消息被标记为已删除。有关详细信息，请参见邮件保留和过期。

客户端library可以设置订阅是持久的还是非持久的。

## 多topic订阅

当消费者订阅一个Pulsar主题时，默认情况下它会订阅一个特定的主题，例如persistent://public/default/my-topic。然而，在Pulsar 1.23.0版的孵化中，Pulsar的消费者可以同时订阅多个主题。可以用两种方式定义主题列表:

- 基于正则表达式(regex)，例如persistent://public/default/finance-.*
- 通过显式地定义主题列表


## 分区topics

普通topics仅由一个broker提供服务，这限制了topics的最大吞吐量。分区topics是一种特殊类型的主题，由多个代理处理，从而允许更高的吞吐量。
一个分区topics实际上实现为N个内部topics，其中N是分区的数量。当将消息发布到分区主题时，每条消息都路由到几个broker中的一个。跨broker的分区分布由Pulsar自动处理。

就订阅类型的工作方式而言，分区主题和普通主题没有区别，因为分区只确定在消息由生产者发布和消息由消费者处理和确认之间发生了什么。

分区主题需要通过管理API显式创建。可以在创建主题时指定分区的数量。

### Routing modes 路由模式

发布到分区主题时，必须指定路由模式。路由模式决定每个消息应该发布到哪个分区——也就是哪个内部主题。

有三种MessageRoutingMode可用:

- RoundRobinPartition:  如果没有提供key,生产者将以轮询方式跨所有分区发布消息，以实现最大吞吐量。
- SinglePartition: 如果没有提供key,生产者将随机选择一个分区，并将所有消息发布到该分区。
- CustomPartition: 使用将被调用的自定义消息路由器实现来确定特定消息的分区。用户可以通过使用Java客户端并实现MessageRouter接口来创建自定义路由模式。

### 顺序保证

message的排序与MessageRoutingMode和Message Key相关。通常，用户希望按每个key分区的顺序保证。

如果消息附加了一个key，那么在使用SinglePartition或RoundRobinPartition模式时，消息将根据ProducerBuilder中HashingScheme指定的哈希方案路由到相应的分区。

- Per-key-partition: 具有相同key的所有message将按顺序放置在相同的分区中。
- Per-producer: 来自同一个生产者的所有消息都是有序的。

## 非持久化topic

 默认情况下，Pulsar持久地将所有未确认的消息存储在多个BookKeeper(存储节点)上。因此，关于持久主题的消息的数据可以在代理重启和订阅者故障转移后继续存在。

 但是，Pulsar也支持非持久主题，即消息永远不会持久化到磁盘上，而只存在于内存中的topics。

非持久化消息传递通常比持久化消息传递更快，因为代理不会持久化消息，只要消息传递给连接的代理，代理就会立即将ack发送回生产者。因此，生产者看到非持久主题的发布延迟相对较低。


## 系统topics

系统主题是在pulsar内部使用的预定义主题。它可以是持久主题，也可以是非持久主题。

## 消息重发

Apache Pulsar支持优雅的故障处理，确保关键数据不丢失。软件总是会遇到意想不到的情况，有时消息可能无法成功交付。因此，有一个内建的机制来处理失败是很重要的，特别是在异步消息传递中，如下面的例子所强调的那样。

- 客户端http端口连接，断开与数据库的连接等情况
- 由于用户崩溃、连接中断等原因，用户会与broker断开连接。

Apache Pulsar使用“至少一次”交付语义来避免这些以及其他消息传递失败，该语义确保Pulsar不止一次处理一条消息。

要使用消息重新传递，您需要在代理可以在Apache Pulsar客户端中重新发送未确认的消息之前启用此机制。可以使用三种方法激活Apache Pulsar中的消息重新传递机制。

## 消息保留和过期

默认情况下，Pulsar消息代理:
- 立即删除所有已被消费者确认的消息
- 持久地将所有未确认的消息存储在消息积压中。

 然而，Pulsar有两个功能可以让你覆盖这个默认行为:
- 消息保留使您能够存储已被使用者确认的消息
- 消息过期使您能够为尚未得到确认的消息设置存活时间(TTL)

## 消息去重

当一个消息被pulsar多次持久化时，就会发生消息重复。消息重复数据删除是一个可选的Pulsar功能，它通过只处理每条消息一次来防止不必要的消息重复，即使消息被多次接收。

![image](../images/message-deduplication.png)

### 去重原理
Producer 对每一个发送的消息，都会采用递增的方式生成一个唯一的 sequenceID，这个消息会放在 message 的元数据中传递给 Broker 。同时， Broker 也会维护一个 PendingMessage 队列，当 Broker 返回发送成功 ack 后， Producer 会将 PendingMessage 队列中的对于的 Sequence ID 删除，表示 Producer 任务这个消息生产成功。Broker 会记录针对每个 Producer 接收到的最大 Sequence ID 和已经处理完的最大 Sequence ID。

当 Broker 开启消息去重后， Broker 会对每个消息请求进行是否去重的判断。收到的最新的 Sequence ID 是否大于 Broker 端记录的两个维度的最大 Sequence ID，如果大于则不重复，如果小于或等于则消息重复。消息重复时， Broker 端会直接返回 ack，不会继续走后续的存储处理流程。
## 延迟投递

延迟消息传递使您可以稍后使用消息。在这种机制中，消息存储在BookKeeper中。在消息发布到代理之后，DelayedDeliveryTracker在内存中维护时间索引(time -> messageId)。一旦指定的延迟结束，此消息将被传递给使用者。