+++
title = "高可用方案"
date =  2022-06-16T09:39:31+08:00
description= "高可用"
weight = 1
chapter= true
pre= "<b>1. </b>"
+++

高可用性(HA)和数据库复制是数据库技术人员讨论的主要话题。有许多明智的选择可以优化PostgreSQL复制，从而实现HA。

## Replication in PostgreSQL

实现高可用性的第一步是确保您不依赖于单个数据库服务器:您的数据应该复制到至少一个备用副本/从服务器。数据库复制可以使用PostgreSQL社区软件提供的两个选项来完成:

- Streaming replication 流式复制
- Logical replication & logical decoding 逻辑复制和逻辑解码

当我们设置流复制时，一个备用副本连接到主(主)，并从它流WAL记录。流复制被认为是PostgreSQL中最安全、最快的复制方法之一。备用服务器成为主服务器的精确副本，即使在非常繁忙的事务服务器上，主服务器和备用服务器之间的延迟也可能最小。PostgreSQL允许您在流复制时构建同步和异步复制。同步复制确保只有当更改不只是com时，客户端才会收到成功消息

