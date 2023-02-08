
+++
title = "测试"
date =  2022-06-16T09:39:31+08:00
description= "测试使用"
weight = 11
chapter= true
pre= "<b>11. </b>"
+++

# pulsar测试使用

这里测试环境使用helm在k8s集群部署一套完整的环境，环境开启了`authentication`和`authorization`配置。

## 目录：

- [pulsar测试使用](#pulsar测试使用)
  - [目录：](#目录)
  - [1.admin cli管理](#1admin-cli管理)
    - [1.1 基础命令](#11-基础命令)
    - [1.2 用户权限管理](#12-用户权限管理)
    - [1.2 shema管理](#12-shema管理)
      - [1.2.1 自动更新schema](#121-自动更新schema)
      - [1.2.2 检查schema合法性](#122-检查schema合法性)
      - [1.2.3 手动管理shcema](#123-手动管理shcema)
  - [2. 测试](#2-测试)
    - [2.1 资源准备](#21-资源准备)
    - [2.2 Golang客户端测试](#22-golang客户端测试)

## 1.admin cli管理

admin cli命令文档： <https://pulsar.apache.org/tools/pulsar-admin/2.9.0-SNAPSHOT/>

官方文档： <https://pulsar.apache.org/docs/admin-api-overview>

### 1.1 基础命令

```shell
# 进入admin容器执行命令
kubectl exec -n pulsar -it pulsar-toolset-0 -- bash
# 创建租户
bin/pulsar-admin tenants create apache
# list租户
bin/pulsar-admin tenants list
# 为租户创建空间
bin/pulsar-admin namespaces create apache/pulsar
# 列出租户的空间
bin/pulsar-admin namespaces list apache
# 在空间中创建topic
bin/pulsar-admin topics create-partitioned-topic apache/pulsar/test-topic -p 2
```


### 1.2 用户权限管理

权限管理可以将`topic`或者`namespace`的权限给用户

```shell
# 创建用户
bin/pulsar tokens create --private-key file:///pulsar/keys/token/private.key --subject test-user

# 为用户赋予权限
bin/pulsar-admin namespaces grant-permission my-tenant/my-namespace \
            --role test-user \
            --actions produce,consume

# 查看ns权限
bin/pulsar-admin namespaces permissions test-tenant/ns1
# 回收权限
pulsar-admin namespaces revoke-permission test-tenant/ns1 \
  --role admin10
```

### 1.2 shema管理

#### 1.2.1 自动更新schema

producer连接到broker的时候自动更新schema

```shell
# 启用客户端自动更新schema
bin/pulsar-admin namespaces set-is-allow-auto-update-schema --enable tenant/namespace
# 禁止客户端自动更新shcema
bin/pulsar-admin namespaces set-is-allow-auto-update-schema --disable tenant/namespace
# 设置自动更新schema检查级别
# https://pulsar.apache.org/docs/schema-evolution-compatibility/#schema-compatibility-check-strategy
bin/pulsar-admin namespaces set-schema-compatibility-strategy --compatibility <compatibility-level> tenant/namespace
```

`Set schema compatibility check strategy`用来配置schema的策略，比如配置高版本的schema不能被低版本消费、禁止shema检查等。


#### 1.2.2 检查schema合法性

默认情况下`schemaValidationEnforced`是禁用的，这说明客户端发送和接收消息时将不会检测消息的合法性。

如果想保证消息具有强一致的格式，请开启`schemaValidationEnforced`

```shell
# 启用
bin/pulsar-admin namespaces set-schema-validation-enforce --enable tenant/namespace
# 禁用
bin/pulsar-admin namespaces set-schema-validation-enforce --disable tenant/namespace
```

#### 1.2.3 手动管理shcema

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


## 2. 测试

### 2.1 资源准备

下面开始逐步测试功能。

首先是创建topic等资源。

```shell
# 创建租户
bin/pulsar-admin tenants create apache
# 在租户中创建空间
bin/pulsar-admin namespaces create apache/pulsar
# 在空间中创建topic
bin/pulsar-admin topics create-partitioned-topic apache/pulsar/test-topic -p 2
```

创建用户，并且给用户分配权限

```shell
# 创建用户，这个会输出token
bin/pulsar tokens create --private-key file:///pulsar/keys/token/private.key --subject test-user
# 赋予权限,我们直接讲空间的权限给用户，当然也可以仅讲topic的权限赋予用户
bin/pulsar-admin namespaces grant-permission apache/pulsar \
            --role test-user \
            --actions produce,consume
# bin/pulsar-admin topic grant-permission my-tenant/my-namespace/my-topic \
#             --role test-user \
#             --actions produce,consume
```

给topic设置schema

```shell
# 启用schema的检查，这样客户端在连接到broker的时候会检查schema是否合法。
bin/pulsar-admin namespaces set-schema-validation-enforce --enable apache/pulsar

# 可以选择让客户端自动更新schema
bin/pulsar-admin namespaces set-is-allow-auto-update-schema --enable apache/pulsar

# 设置schema检查配置, BACKWARD级别表示schema必须向后兼容
bin/pulsar-admin namespaces set-schema-compatibility-strategy --compatibility BACKWARD apache/pulsar

# 或者手动上传schema文件
# pulsar-admin schemas upload --filename <schema-definition-file> apache/pulsar/test-topic

# 方便起见我们先使用自动更新schema吧
```

### 2.2 Golang客户端测试

