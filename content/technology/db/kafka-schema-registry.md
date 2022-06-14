+++
title = "Confluent Schema-Registry"
date =  2022-05-26T16:43:10+08:00
description= "description"
weight = 4
+++


## 注册表

 无论是  使用传统的Avro API自定义序列化类和反序列化类 还是 使用Twitter的Bijection类库实现Avro的序列化与反序列化，这两种方法都有一个缺点：在每条Kafka记录里都嵌入了schema，这会让记录的大小成倍地增加。但是不管怎样，在读取记录时仍然需要用到整个 schema，所以要先找到 schema。有没有什么方法可以让数据共用一个schema？

我们遵循通用的结构模式并使用"schema注册表"来达到目的。"schema注册表"的原理如下：
![Magic](/images/tech/kafka-schema.png)

- 1、把所有写入数据需要用到的 schema
保存在注册表里，然后在记录里引用 schema ID
- 2、负责读取数据的应用程序使用 ID
从注册表里拉取 schema
来反序列化记录。
- 3、序列化器和反序列化器分别负责处理 schema
的注册和拉取。


schema注册表并不属于Kafka，现在已经有一些开源的schema注册表实现。比如本文要讨论的Confluent Schema Registry

## 序列化反序列化

可以采用如下格式对kafka消息进行序列化，反序列化。

格式：
- json
- avor
- protobuf

比较avor和protobuf:

https://dataforgeeks.com/data-serialisation-avro-vs-protocol-buffers/2015/

结论：

Avro seems a better fit for BigData use cases as it is widely used in multiple frameworks. Splittable, schema along with data and native compression techniques are major advantages over Protocol Buffer.

Protobuf is easy to use in microservices, especially where performance and interoperability are important and is superior to Avro in this area.

avro灵活，不需要编译。protobuf速度快。
avro适合做大数据，protobuf适合微服务化应用。

## api

[api文档](https://docs.confluent.io/platform/current/schema-registry/develop/api.html)