
+++
title = "Schema"
date =  2022-06-16T09:39:31+08:00
description= "Pulsar Schema"
weight =7
chapter= true
pre= "<b>7. </b>"
+++

## Schema Registry

在任何围绕像Pulsar这样的消息总线构建的应用程序中，类型安全都是极其重要的。

生产者和消费者需要某种机制来协调主题级别的类型，以避免出现各种潜在问题。例如，序列化和反序列化问题。

应用程序通常采用以下方法之一来保证消息传递中的类型安全。这两种方法在Pulsar中都可以使用，你可以自由选择其中一种或另一种，或者在每个主题的基础上混合使用。

## 客户端方式

生产者和消费者不仅负责序列化和反序列化消息(由原始字节组成)，而且还要“知道”哪些类型通过哪些主题传输。

如果生产者正在发送主题topic-1的温度传感器数据，那么该主题的消费者如果试图将该数据解析为湿度传感器读数，就会遇到麻烦。

生产者和消费者可以发送和接收由原始字节数组组成的消息，并将所有类型安全实施留给应用程序在“带外”的基础上执行。

## 服务端方式

生产者和消费者告知系统哪些数据类型可以通过主题传输。

通过这种方法，消息传递系统加强了类型安全性，并确保生产者和消费者保持同步。

Pulsar有一个内置的`Schema registry`，允许客户端按主题上传数据模式。这些模式规定哪些数据类型对该主题有效。

## 为什么使用Schema?

当启用Schema时，Pulsar解析数据，它接受字节作为输入，并发送字节作为输出。虽然data的含义超过了字节，但你需要解析数据，可能会遇到解析异常，主要发生在以下情况:
- 字段不存在
- 字段类型改变例如 string改成int

有一些方法可以防止和克服这些异常，例如，可以在解析错误时捕捉异常，这使得代码难以维护;或者您可以采用模式管理系统来执行模式演化，而不破坏下游应用程序，并强制类型安全以最大限度地扩展您正在使用的语言，解决方案是Pulsar schema。

### Without schema

如果构造生成器时没有指定模式，那么生成器只能生成类型为byte[]的消息。如果您有一个POJO类，您需要在发送消息之前将POJO序列化为字节。

```java
Producer<byte[]> producer = client.newProducer()
        .topic(topic)
        .create();
User user = new User("Tom", 28);
byte[] message = … // serialize the `user` by yourself;
producer.send(message);
```

### with schema

如果构造生成器时指定了模式，那么就可以直接向主题发送类，而不用担心如何将pojo序列化为字节。

```java
Producer<User> producer = client.newProducer(JSONSchema.of(User.class))
        .topic(topic)
        .create();
User user = new User("Tom", 28);
producer.send(user);
```

当使用Schema构建生成器时，不需要将消息序列化为字节，而是Pulsar模式在后台完成这项工作。

## SchemaInfo

Pulsar模式在名为SchemaInfo的数据结构中定义。

SchemaInfo是按主题存储和执行的，不能存储在名称空间或租户级别。

字段示例：

```json
{
    "name": "test-string-schema",
    "type": "STRING",
    "schema": "",
    "properties": {}
}

```

- type: 模式类型，它决定如何解释模式数据。
- schema:  模式数据，它是一个8位无符号字节序列，特定于模式类型。
- properties: 它是一个用户定义的属性，作为字符串/字符串映射。应用程序可以使用这个包携带任何应用程序特定的逻辑。可能的属性可能是与模式相关的Git散列，一个环境字符串，如dev或prod

## Schema type

Pulsar支持多种模式类型，主要分为两类:
- Primitive type 简单类型
- Complex type 复杂类型

### Primitive type

BOOLEAN,INT8,INT16,FLOAT,BYTES 等
对于基本类型，Pulsar不在SchemaInfo中存储任何模式数据。SchemaInfo中的类型用于确定如何序列化和反序列化数据。

示例：

```java
Producer<String> producer = client.newProducer(Schema.STRING).create();
producer.newMessage().value("Hello Pulsar!").send();
```

```java
Consumer<String> consumer = client.newConsumer(Schema.STRING).subscribe();
consumer.receive();
```

### Complex type 

Currently, Pulsar supports the following complex types:

- keyvalue： 表示键/值对的复杂类型。
- struct： 处理结构化数据。它支持AvroBaseStructSchema和ProtobufNativeSchema。（avro和protobuf格式）


## Schema如何起作用的


在主题级别应用和强制Pulsar Schema(不能在名称空间或租户级别应用模式)。

生产者和消费者将Schema上传到Brokers，因此Pulsar模式在生产者端和消费者端都可以工作。


[生产端](https://pulsar.apache.org/zh-CN/docs/next/schema-understand#producer-side)流程

[消费端](https://pulsar.apache.org/zh-CN/docs/next/schema-understand#consumer-side)流程



## shema管理

### 自动更新schema

```shell
# 启用客户端自动更新schema
bin/pulsar-admin namespaces set-is-allow-auto-update-schema --enable tenant/namespace
# 禁止客户端自动更新shcema
bin/pulsar-admin namespaces set-is-allow-auto-update-schema --disable tenant/namespace
# 设置自动更新schema检查级别
# https://pulsar.apache.org/docs/schema-evolution-compatibility/#schema-compatibility-check-strategy
bin/pulsar-admin namespaces set-schema-compatibility-strategy --compatibility <compatibility-level> tenant/namespace
```

### 检查schema合法性

默认情况下`schemaValidationEnforced`是禁用的，这说明客户端发送和接收消息时将不会检测消息的合法性。

如果想保证消息具有强一致的格式，请开启`schemaValidationEnforced`

```shell
# 启用
bin/pulsar-admin namespaces set-schema-validation-enforce --enable tenant/namespace
# 禁用
bin/pulsar-admin namespaces set-schema-validation-enforce --disable tenant/namespace
```

### 手动管理shcema

```shell
# 上传schema文件
pulsar-admin schemas upload --filename <schema-definition-file> <topic-name>
```

格式是这样的

```json
{
    "type": "<schema-type>",
    "schema": "<an-utf8-encoded-string-of-schema-definition-data>",
    "properties": {} // 一些元数据
}
```

- type:  支持多种格式，常用的： `STRING`,`JSON`，`PROTOBUF`，`AVRO`等
- schema: 如果是`primitive`类的，这个字段是空。如果是struct类的（json,avro,protobuf），这个字段就是schema定义
- properties: topic附件的一些信息，key/value值。

使用admin cli管理
```shell
# 上传schema文件到topic
bin/pulsar-admin schemas upload --filename <schema-definition-file> <topic-name>

# 获取
bin/pulsar-admin schemas get <topic-name> --version=<version>
# 删除
bin/pulsar-admin schemas delete <topic-name>
```