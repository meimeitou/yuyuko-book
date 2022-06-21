---
marp: true
theme: gaia
footer: 'TonyYin, 2022-06-14'
paginate: true
style: |
  section a {
      font-size: 30px;
  },
  table {
   font-size: 28px;
  }
---
<!--
_class: lead gaia
_paginate: false
-->

# Confluent Kafka

企业版kafka

:dog: By TonyYin

---
<!-- backgroundColor: white -->
# 组件

confluent kafka版本对比:

|企业版| 社区版|备注|
|-|-|-|
|zookeeper| zookeeper| 相同 |
|broker(cp-server)| broker(cp-kafka)| 少量差别，社区缺少health+, balance等增强功能 |
|schema-registry| schema-registry| schema注册管理组件，相同 |
|kafka-connect| kafka-connect| 连接器管理，相同 |


---
对比2：

|企业版| 社区版|备注|
|-|-|-|
|ksqldb| ksqldb| ksqldb数据库，功能相同，用于流式数据处理，查询 |
|ksqldb-cli|ksqldb-cli| ksqldb命令行工具|
|kafka-rest|kafka-rest|kafka restful api代理组件|
|enterprise-control-center |缺少|管理中心，界面化管理kafka,社区办缺少，只能通过调研api实现管理|

---
## 1.schema-registry

schema-registry提供一个管理元数据的服务层。它提供restfull api来存取，avro,json,protobuf schema。同时它提供版本管理，兼容性检查，合法检查等功能。

我们为topic创建schema，数据使用schema定义的格式进行传输。生产者消费者序列化，反序列化数据，都将依赖schema定义。（Serializers and Deserializers）

[api文档](https://docs.confluent.io/platform/current/schema-registry/develop/api.html)

---
## 2. kafka-connect

Kafka Connect 是一款可扩展并且可靠地在 Apache Kafka 和其他系统之间进行数据传输的工具。 可以很简单的定义 connectors（连接器） 将大量数据迁入、迁出Kafka。

例如我现在想要把数据从MySQL迁移到ElasticSearch，为了保证高效和数据不会丢失，我们选择MQ作为中间件保存数据。

[目前支持的connector](https://www.confluent.io/product/connectors/?_ga=2.103609222.749921388.1655176160-952692913.1651714879)

---
## 3. ksqldb and ksqldb-cli

ksqldb能做什么？

- ETL流处理
- 实时的应用监控及分析
- 异常检测
- 实时用户个性化数据分析定制
- 传感器及IoT数据处理

[应用示例](http://yuyuko.himecut.cc/en/technology/db/ksql/)

---
## 4. kafka-rest

提供RESTfull api,管理kafka集群。

管理界面的部分功能api从这里调用。

[swagger API文档](https://github.com/confluentinc/kafka-rest/blob/master/api/v3/openapi.yaml)

---
## rest api示例

```shell
# 集群列表
 curl -X 'GET' \
  'http://localhost:8082/v3/clusters' \
  -H 'accept: application/json'
# 获取消费组
 curl -X 'GET' \
  'http://localhost:8082/v3/clusters/cWUQjpHRTXKtSOVk3F5n7Q/consumer-groups' \
  -H 'accept: application/json' | jq
# 获取组的消费lag
 curl -X 'GET' \
  'http://localhost:8082/v3/clusters/cWUQjpHRTXKtSOVk3F5n7Q/consumer-groups/test1/lags' \
  -H 'accept: application/json' | jq
```
---
## 5. enterprise-control-center

kafka管理中心：
- cluster管理
- topic
- brokers
- connect
- ksqldb
- consumer
...
社区版没有这个组件,只能自己调用api。

---
## 6. 生产/消费SDK示例

基于confluent-kafka-client改造的通用生产/消费组件。

- producer
- avro/protobuf producer
- consumer
- avro/protobuf consumer
