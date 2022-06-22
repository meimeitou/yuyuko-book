
+++
title = "Pulsar-sql"
date =  2022-06-16T09:39:31+08:00
description= "Pulsar sql"
weight =10
chapter= true
pre= "<b>10. </b>"
+++

Apache Pulsar用于存储事件数据流，事件数据是用预定义的字段结构化的。通过Schema Registry的实现，您可以在Pulsar中存储结构化数据，并使用Trino(以前的Presto SQL)查询数据。

Presto Pulsar connector是Pulsar SQL的核心，可以让Presto集群内的Presto worker查询到Pulsar的数据。


```shell
# Start a Pulsar SQL worker.
./bin/pulsar sql-worker run
# After initializing Pulsar standalone cluster and the SQL worker, run SQL CLI.
./bin/pulsar sql
# Test with SQL commands.
presto> show catalogs;
 Catalog 
---------
 pulsar  
 system  
(2 rows)

presto> show schemas in pulsar;
        Schema         
-----------------------
 information_schema    
 public/default        
 public/functions
(3 rows)
```