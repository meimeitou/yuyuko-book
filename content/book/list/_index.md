+++
title = "列表"
description= "书籍文档列表"
+++



- [系统类](#系统类)
  - [1.《什么是 eBPF》](#1什么是-ebpf)
  - [2. 《理解 Linux 进程》](#2-理解-linux-进程)
  - [3. awk程序语言设计](#3-awk程序语言设计)
  - [4. 《rCore-Tutorial-Book 第三版》](#4-rcore-tutorial-book-第三版)
  - [5. 操作系统的基本原理与简单实现](#5-操作系统的基本原理与简单实现)
- [系统工具](#系统工具)
  - [1. 《 bash 的“奇技淫巧”》](#1--bash-的奇技淫巧)
  - [2. 《关于 curl 的所有东西》](#2-关于-curl-的所有东西)
- [计算机科学](#计算机科学)
  - [1. 《算法新解》](#1-算法新解)
  - [2. 《计算机体系结构基础》](#2-计算机体系结构基础)
  - [3. 《SICP Python 描述中文版》](#3-sicp-python-描述中文版)
- [网络](#网络)
  - [1. 《TCP/IP详解》](#1-tcpip详解)
  - [2. 《TCP/IP网络编程》](#2-tcpip网络编程)
- [语言开发类](#语言开发类)
  - [1. golang入门到入土](#1-golang入门到入土)
  - [2. 《Rust圣经》](#2-rust圣经)
  - [3. 《python并行编程》](#3-python并行编程)
  - [4. 《如何构建大型且可靠的分布式系统》](#4-如何构建大型且可靠的分布式系统)
  - [5. 《HTTP 接口设计指北》](#5-http-接口设计指北)
  - [6. µGo语言实现](#6-µgo语言实现)
  - [7. 《Mastering Go》](#7-mastering-go)
  - [8. 《Rust 程序设计语言（第二版）》](#8-rust-程序设计语言第二版)
  - [9. 《Go语法树入门：开启自制编程语言和编译器之旅》](#9-go语法树入门开启自制编程语言和编译器之旅)
  - [10.《Go语言101》](#10go语言101)
  - [11.《Go语言四十二章经》](#11go语言四十二章经)
  - [12. 《Go语言高级编程》](#12-go语言高级编程)
  - [13. 雨痕大神学习笔记](#13-雨痕大神学习笔记)
- [机器学习](#机器学习)
  - [1.《深度学习 500 问》](#1深度学习-500-问)
  - [2.《机器学习公式详解》](#2机器学习公式详解)
  - [3. 《动手学深度学习》](#3-动手学深度学习)
  - [4. pandas cookbook](#4-pandas-cookbook)
- [前端](#前端)
  - [1. Web 安全学习笔记](#1-web-安全学习笔记)
  - [2. 《带你入门前端工程》](#2-带你入门前端工程)
- [其它](#其它)
  - [1. 《Istio 服务网格进阶实战》](#1-istio-服务网格进阶实战)
  - [2. 《The Hacker Playbook 3》](#2-the-hacker-playbook-3)
  - [3.《自学是门手艺》](#3自学是门手艺)
  - [4. SDN网络指南](#4-sdn网络指南)
  - [5. Kubernetes 中文指南/云原生应用架构实战手册](#5-kubernetes-中文指南云原生应用架构实战手册)
  - [6. 《微服务：从设计到部署》](#6-微服务从设计到部署)
  - [7. 全栈增长工程师指南](#7-全栈增长工程师指南)
  - [9. 免费编程书籍列表](#9-免费编程书籍列表)
  - [10.《图说设计模式》](#10图说设计模式)

# 系统类

## 1.《什么是 eBPF》

[在线文档](https://lib.jimmysong.io/what-is-ebpf/)

《什么是 eBPF —— 新一代网络、安全和可观测性工具介绍》译自 O’Reilly 发布的报告 “What is eBPF”，作者是 Liz Rice，由 JImmy Song 翻译，英文原版可以在 O’Reilly 网站上获取。

## 2. 《理解 Linux 进程》

本书受理解Unix进程启发而作，用极简的篇幅深入学习进程知识。

理解Linux进程用Go重写了所有示例程序，通过循序渐进的方法介绍Linux进程的工作原理和一切你所需要知道的概念。

[仓库](https://github.com/tobegit3hub/understand_linux_process)
[pdf版](https://www.gitbook.com/download/pdf/book/tobegit3hub1/understanding-linux-processes)

## 3. awk程序语言设计

The AWK Programming Language (AWK 程序设计语言, awkbook) 中文翻译, LaTeX 排版

[仓库](https://github.com/wuzhouhui/awk)

## 4. 《rCore-Tutorial-Book 第三版》

旨在一步一步展示如何 从零开始 用 Rust 语言写一个基于 RISC-V 架构的 类 Unix 内核 。值得注意的是，本项目不仅支持模拟器环境（如 Qemu/terminus 等），还支持在真实硬件平台 Kendryte K210 上运行。

[在线文档](https://rcore-os.github.io/rCore-Tutorial-Book-v3/)

## 5. 操作系统的基本原理与简单实现

操作系统的基本原理与简单实现的教学项目。以操作系统基本原理为教学引导，RISC-V CPU 为底层硬件基础，设计并实现一个微型但全面的“麻雀”操作系统——ucore



[在线文档](https://chyyuu.gitbooks.io/simple_os_book/content/)

# 系统工具

## 1. 《 bash 的“奇技淫巧”》

该书有好多复制就能用的 bash 函数，我愿称其为 bash 的“奇技淫巧”。比如把字母转为大写的函数：

```shell
upper() {
    # Usage: upper "string"
    printf '%s\n' "${1^^}"
}

$ upper "hello"
HELLO
```

[git项目](https://github.com/dylanaraps/pure-bash-bible)

## 2. 《关于 curl 的所有东西》

[在线阅读](https://everything.curl.dev/)

# 计算机科学

## 1. 《算法新解》

本书分4部分，同时用函数式和传统方法介绍主要的基本算法和数据结构，数据结构部分包括二叉树、红黑树、AVL树、Trie、Patricia、后缀树、B树、二叉堆、二项式堆、斐波那契堆、配对堆、队列、序列等；基本算法部分包括各种排序算法、序列搜索算法、字符串匹配算法（KMP等）、深度优先与广度优先搜索算法、贪心算法以及动态规划。

[git仓库](https://github.com/liuxinyu95/AlgoXY)

## 2. 《计算机体系结构基础》

教科书

[在线文档](https://foxsen.github.io/archbase/)

## 3. 《SICP Python 描述中文版》

用python来教学计算机科学

[git仓库](https://github.com/wizardforcel/sicp-py-zh)
[在线文档](https://wizardforcel.gitbooks.io/sicp-py/content/)

# 网络

## 1. 《TCP/IP详解》

《TCP/IP详解卷1：协议》是一本详细的TCP/IP协议指南，计算机网络历久不衰的经典著作之一。

作者理论联系实际，使读者可以轻松掌握TCP/IP的知识。阅读对象为计算机专业学生、教师以及研究网络的技术人员。

[在线文档](http://www.52im.net/topic-tcpipvol1.html)

## 2. 《TCP/IP网络编程》

《TCP/IP网络编程》学习笔记及具体代码实现，代码部分请参考本仓库对应章节文件夹下的代码

[仓库](https://github.com/riba2534/TCP-IP-NetworkNote)

[笔记pdf](https://github.com/riba2534/TCP-IP-NetworkNote/releases/download/v1.0/riba2534-TCP-IP-NetworkNote.pdf)

# 语言开发类

## 1. golang入门到入土

非常全面的golang入门书籍

[在线文档](https://www.topgoer.com/)

## 2. 《Rust圣经》
有人说: "Rust 太难了，学了也没用"。

对于后面一句话我们持保留意见，如果以找工作为标准，那国内环境确实还不好，但如果你想成为更优秀的程序员或者是玩转开源，那 Rust 还真是不错的选择，具体原因见下一章。

至于 Rust 难学，那正是本书要解决的问题，如果看完后，你觉得没有学会 Rust，可以找我们退款，哦抱歉，这是开源书，那就退 🌟 吧：）

[在线文档](https://course.rs/about-book.html)

## 3. 《python并行编程》

python并行编程的架构和编程模型

[在线文档](https://python-parallel-programmning-cookbook.readthedocs.io/zh_CN/latest/)

## 4. 《如何构建大型且可靠的分布式系统》

这是一部以“如何构建一套可靠的分布式大型软件系统”为叙事主线的开源文档，是一幅帮助开发人员整理现代软件架构各条分支中繁多知识点的技能地图。文章《什么是“凤凰架构”》详细阐述了这部文档的主旨、目标与名字的来由，文章《如何开始》简述了文档每章讨论的主要话题与内容详略分布，供阅前参考。

[在线文档](https://icyfenix.cn/)

## 5. 《HTTP 接口设计指北》

内容为设计 Web API 的一些建议

[git仓库](https://github.com/bolasblack/http-api-guide)

## 6. µGo语言实现

从头开发一个迷你Go语言编译器

[git仓库](https://github.com/wa-lang/ugo-compiler-book)

## 7. 《Mastering Go》

《Mastering Go》的中文翻译版《玩转 Go》。[在线阅读](https://wskdsgcf.gitbook.io/mastering-go-zh-cn/)

## 8. 《Rust 程序设计语言（第二版）》

《Rust 程序设计语言（第二版）》中文翻译。[在线阅读](https://kaisery.github.io/trpl-zh-cn/)

## 9. 《Go语法树入门：开启自制编程语言和编译器之旅》

Go语法树是Go语言源文件的另一种语义等价的表现形式。而Go语言自带的go fmt和go doc等命令都是在Go语法树的基础之上分析工具。因此将Go语言程序作为输入数据，让我们语法树这个维度重新审视Go语言程序，我们将得到创建Go语言本身的技术。Go语法树由标准库的go/ast包定义，它是在go/token包定义的词法基础之上抽象的语法树结构。本书简单介绍语法树相关包的使用。如果想从头实现一个玩具Go语言可以参考《从头实现µGo语言》。

## 10.《Go语言101》

《Go语言101》是一本着重介绍 Go 语法和语义的编程指导书，[中文版在线阅读](https://gfw.go101.org/article/101.html)


## 11.《Go语言四十二章经》

Golang 入门书籍。书中作者总结了自己踩坑的经验总结和思考，[在线阅读](https://github.com/ffhelicopter/Go42)

## 12. 《Go语言高级编程》

该书针对 Go 语言有一定经验，想更加深入了解 Go 语言各种高级用法的开发人员

[开源项目地址](https://github.com/chai2010/advanced-go-programming-book)

[git项目地址](https://github.com/chai2010/go-ast-book)

## 13. 雨痕大神学习笔记

[项目地址](https://github.com/qyuhen/book)

# 机器学习

## 1.《深度学习 500 问》

AI 工程师面试知识点的书籍。内容涵盖深度学习的知识点及各大公司常见的笔试题

[git项目](https://github.com/scutan90/DeepLearning-500-questions)

## 2.《机器学习公式详解》

西瓜书公式推导解析。

[地址](https://datawhalechina.github.io/pumpkin-book/)

## 3. 《动手学深度学习》

被多校定为教材

《Dive into Deep Learning 》翻译版，即《动手学深度学习》。[在线阅读](http://zh.d2l.ai/)

## 4. pandas cookbook

pandas数据处理

[git项目](https://github.com/jvns/pandas-cookbook)

# 前端

## 1. Web 安全学习笔记

在学习Web安全的过程中，深切地感受到相关的知识浩如烟海，而且很大一部分知识点都相对零散，如果没有相对清晰的脉络作为参考，会给学习带来一些不必要的负担。因此，在对Web安全有了浅薄的了解之后，尝试把一些知识、想法整理记录下来，最后形成了这份笔记，希望能够为正在入门的网络安全爱好者提供一定的帮助。



[在线文档](https://websec.readthedocs.io/zh/latest/)

## 2. 《带你入门前端工程》

我写这本小书的原因，是想对过去两年的工程化实践经验和学习心得做一个总结。希望能全面地、系统地对前端工程化知识做一个总结。

[在线文档](https://woai3c.github.io/introduction-to-front-end-engineering/)

# 其它

## 1. 《Istio 服务网格进阶实战》

ServiceMesher 社区出品的《Istio 服务网格进阶实战》。Istio 是由 Google、IBM、Lyft 等共同开源的 Service Mesh（服务网格）框架，作为云原生时代下承 Kubernetes、上接 Serverless 架构的重要基础设施层

[项目地址](https://github.com/servicemesher/istio-handbook)

## 2. 《The Hacker Playbook 3》

《The Hacker Playbook 3》中文翻译版（渗透测试实战红队第三版）

[git项目](https://github.com/Snowming04/The-Hacker-Playbook-3-Translation)


## 3.《自学是门手艺》

《自学是门手艺》一个编程入门者的自学心得。如今学习资源很多，对于初学者入门而言，最难的是如何自学，阅读本书打开编程自学大门吧

作者： 李笑来

[git项目](https://github.com/selfteaching/the-craft-of-selfteaching)


## 4. SDN网络指南

有关 SDN 的资料和书籍非常丰富，但入门和学习 SDN 依然是非常困难。该项目整理了 SDN 实践中的一些基本理论和实践案例心得，希望大家看完后有所收获

[git项目](https://github.com/feiskyer/sdn-handbook)

## 5. Kubernetes 中文指南/云原生应用架构实战手册

见书名就知道内容了

[在线地址](https://jimmysong.io/kubernetes-handbook/)

## 6. 《微服务：从设计到部署》

其从不同角度全面介绍了微服务：微服务的优点与缺点、API 网关、进程间通信（IPC）、服务发现、事件驱动数据管理、微服务部署策略、重构单体。

[在线文档](https://docshome.gitbook.io/microservices/)

## 7. 全栈增长工程师指南

[在线文档](https://growth.phodal.com/)

## 9. 免费编程书籍列表

[项目地址](https://github.com/justjavac/free-programming-books-zh_CN)

## 10.《图说设计模式》

[在线文档](https://design-patterns.readthedocs.io/zh_CN/latest/index.html#)