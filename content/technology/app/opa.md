+++
title = "Opa"
date =  2021-05-18T11:58:03+08:00
description= "description"
weight = 7
+++


# 一、opa

The Open Policy Agent (OPA, pronounced “oh-pa”) is an open source, general-purpose policy engine that unifies policy enforcement across the stack. 


OPA（OpenPolicyAgent）, 云原生时代的通用规则引擎，重新定义策略引擎，灵活而强大的声明式语言全面支持通用策略定义。

`关键词：`

- 轻量级的通用策略引擎
- 可与服务共存
- 集成方式可以是sidecar、主机级守护进程或库引入


![policy.png](/images/app/policy.png)

优点：
- 强大的声明式策略
  - 上下文感知
  - 表达性强
  - 快速
  - 可移植
- 输入和输出支持任意格式
配合强大的声明式策略语言Rego，描述任意规则都不是问题
- 全面支持规则和系统解耦
![opa.png](/images/app/OPA-why.png)

- 集承方式多
  - Daemon式服务
  - Go类库引入

- 应用广泛
  除了继承做auth外，还可以应用到k8s,terraform,docker,kafka,sql,linux上做规则决策
- 工具齐全
命令行，有交互式运行环境、支持测试，性能分析（底层实现Go）


下载：
On macOS (64-bit):

```shell
curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_darwin_amd64
```
On Linux (64-bit):

```shell
curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64
```

## 示例

快速开始

```shell
./opa eval -i quick-start/input.json -d quick-start/data.json -d quick-start/example.rego "data.example_rbac"
```

## 基础知识

1. [运行opa]({{< ref "technology/app/opa-run" >}})
2. [Rego基础]({{< ref "technology/app/rego" >}})

# 二、opa 整合

官方文档： `https://www.openpolicyagent.org/docs/latest/integration/`

opa分为两个部分：

- Evaluation： 用于询问政策决定的OPA接口。集成OPA主要集中在将应用程序、服务或工具与OPA的策略评估接口集成上。这种集成将导致策略决策与应用程序、服务或工具分离。
- Management： 用于部署策略、了解状态、上传日志等。这种集成在所有OPA实例中通常是相同的，不管评估接口与什么软件集成。

#### 怎么将opa整合到项目中？

有三种方式可以将opa整合到我们的项目中：

1.  使用`REST API`通过HTTP以JSON的形式返回决策。
2.  使用`Go API`以简单的Go类型(bool, string, map[string]接口{}等)返回决策。
3.  使用`WebAssembly`将Rego策略编译为WASM指令，这样它们就可以被任何WebAssembly运行时嵌入和评估。

第三种先不做讨论，目前用不到，目前可以使用的接入方法有两种: 1、REST API, 2、Go API，下面分别说明。

#### 1、REST API

可以将`OPA`部署为主机级守护进程或sidecar容器。

`opa`项目提供了这样的API服务。api访问接口可以对数据进行`增删改成`.

接口：
```shell
POST /v1/data/<path>
Content-Type: application/json
```
加参数：
```json
{
    "input": <the input document>
}
```

返回结果：
```shell
200 OK
Content-Type: application/json
```

```json
{
    "result": true
}
```

详细rest api参考： `https://www.openpolicyagent.org/docs/latest/rest-api/`

#### 2、Go API

引入 rego库：

```shell
import "github.com/open-policy-agent/opa/rego"
```

操作：
1. 使用rego包构造一个准备好的查询。
2. 执行准备好的查询以产生策略决策。
3. 解释和执行政策决策。


`rego`可以看做一个运行在`golang`上的查询语言，`golang`是`rego`语言的编译器和执行器。

#### REST API和 Go API的区别是什么？

`Go API`是基础，`REST API`这是在`Go API`上封装了一层http的调用接口而已。


# 三、定制扩展OPA

### Custom Built-in Functions in Go

定制rego函数, 针对`Go API`

### Custom Plugins for OPA Runtime

定制运行时，针对`REST API`
