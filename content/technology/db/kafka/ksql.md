+++
title = "Ksql"
date =  2022-05-25T21:19:42+08:00
description= "ksqlDB"
weight = 2
+++

## ksqlDB

用于不限于：

- ETL流处理
- 实时的应用监控及分析
- 异常检测
- 用户个性化数据分析定制
- 传感器及IoT数据处理。

https://ksqldb.io/quickstart.html

首先，需要[运行confluent kafka]({{%relref "technology/db/kafka/confluent-kafka.md" %}})测试环境


### 1、Start ksqlDB's interactive CLI

```shell
docker exec -it ksqldb-cli ksql http://ksqldb-server:8088
```

### 2. Create a stream

创建一个流，使用kafka topic。

地理坐标topic:

```sql
CREATE STREAM riderLocations (profileId VARCHAR, latitude DOUBLE, longitude DOUBLE)
  WITH (kafka_topic='locations', value_format='json', partitions=1);
```

### 3. Create materialized views

从上面流中，创建物化视图。

定位`profileId`用户的最新坐标。创建视图`currentLocation`。

```sql
CREATE TABLE currentLocation AS
  SELECT profileId,
         LATEST_BY_OFFSET(latitude) AS la,
         LATEST_BY_OFFSET(longitude) AS lo
  FROM riderlocations
  GROUP BY profileId
  EMIT CHANGES;
```

从上面的最新坐标，计算和给定城市的距离。
`ridersNearMountainView`它捕捉到骑手与给定位置或城市的距离。

```sql
CREATE TABLE ridersNearMountainView AS
  SELECT ROUND(GEO_DISTANCE(la, lo, 37.4133, -122.1162), -1) AS distanceInMiles,
         COLLECT_LIST(profileId) AS riders,
         COUNT(*) AS count
  FROM currentLocation
  GROUP BY ROUND(GEO_DISTANCE(la, lo, 37.4133, -122.1162), -1);
```

### 4、Run a push query over the stream

在流上运行推送查询

```sql
-- Mountain View lat, long: 37.4133, -122.1162
SELECT * FROM riderLocations
  WHERE GEO_DISTANCE(latitude, longitude, 37.4133, -122.1162) <= 5 EMIT CHANGES;
```
查询将输出`riderLocations`流中坐标在山景城5英里以内的所有行。


### 5、Start another CLI session

启动一个新终端

```shell
docker exec -it ksqldb-cli ksql http://ksqldb-server:8088
```

### 6、Populate the stream with events

推送一些数据到流中

```sql
INSERT INTO riderLocations (profileId, latitude, longitude) VALUES ('c2309eec', 37.7877, -122.4205);
INSERT INTO riderLocations (profileId, latitude, longitude) VALUES ('18f4ea86', 37.3903, -122.0643);
INSERT INTO riderLocations (profileId, latitude, longitude) VALUES ('4ab5cbad', 37.3952, -122.0813);
INSERT INTO riderLocations (profileId, latitude, longitude) VALUES ('8b6eae59', 37.3944, -122.0813);
INSERT INTO riderLocations (profileId, latitude, longitude) VALUES ('4a7c7b41', 37.4049, -122.0822);
INSERT INTO riderLocations (profileId, latitude, longitude) VALUES ('4ddad000', 37.7857, -122.4011);
```

### 7、Run a Pull query against the materialized view

对实体化视图执行查询

```sql
SELECT * from ridersNearMountainView WHERE distanceInMiles <= 10;
```

检索当前距离山景城10英里内的所有车手。


## 能做什么？

- ETL流处理
- 实时的应用监控及分析
- 异常检测
- 用户个性化数据分析定制
- 传感器及IoT数据处理。

到业务：
- 用户定义，解析日志实时报警
- DNS解析日志异常检测
- DNS用户的实时解析行为分析： 实时解析偏好（教育类网站，搜索型网站等）