
+++
title = "Functions"
date =  2022-06-16T09:39:31+08:00
description= "Pulsar Functions"
weight =8
chapter= true
pre= "<b>8. </b>"
+++

## What are Pulsar Functions

Pulsar函数是一个运行在Pulsar之上的无服务器计算框架，以以下方式处理消息:

- 使用来自一个或多个主题的消息，
- 对消息应用用户定义的处理逻辑，
- 将消息的输出发布到其他主题。

![images](../images/function-overview.svg)


 函数接收来自一个或多个输入主题的消息。每次接收到消息时，该函数完成以下步骤:

- 消费输入topics中的message
-  a)将输出消息写入Pulsar中的输出主题b)将日志写入日志主题(如果配置了日志主题(用于调试)c)将状态写入BookKeeper(如果配置了)

您可以用Java、Python和Go编写函数。例如，可以使用Pulsar函数建立以下处理链:
-  Python函数侦听原始句子主题并“消毒”传入的字符串(删除多余的空白并将所有字符转换为小写)，然后将结果发布到一个消毒过的句子主题。
-  Java函数侦听经过处理的句子主题，计算每个单词在指定的时间窗口内出现的次数，并将结果发布到结果主题。
-  Python函数监听结果主题，并将结果写入MySQL表。

## 真实示例

### 单词计数

使用Pulsar函数实现经典单词计数示例的过程。它计算发布到给定主题的每个单词出现次数的总和。

![image](../images/pulsar-functions-word-count.png)

### 基于内容的路由的例子

例如，函数接受条目(字符串)作为输入，并根据条目将它们发布到水果或蔬菜主题。如果某项既不是水果也不是蔬菜，则会将警告记录到日志主题中。

该图演示了使用Pulsar函数实现基于内容路由的过程。

![image](../images/pulsar-functions-routing-example.png)

