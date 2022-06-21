
+++
title = "部署测试"
date =  2022-06-16T09:39:31+08:00
description= "消息队列 Pulsar"
weight = 0
+++

启动一个本地的单节点plusar，用于消息测试

docker-compose.yaml:

```yaml
---
version: '2'
services:
  plusar:
    image: apachepulsar/pulsar:2.10.0
    container_name: plusar
    user: root
    command:
    - bin/pulsar
    - standalone
    ports:
    - "6650:6650"
    - "8080:8080"
    volumes:
    - pulsardata:/pulsar/data:rw
    - pulsarconf:/pulsar/conf:rw
volumes:
  pulsardata:
  pulsarconf:

```