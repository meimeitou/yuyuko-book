+++
title = "Interval"
date =  2022-11-11T17:29:46+08:00
description= "description"
weight = 5
+++

- [１、go调度器](#１go调度器)
- [２、go struct能不能比较](#２go-struct能不能比较)
- [３、go defer（for defer），先进后出，后进先出](#３go-deferfor-defer先进后出后进先出)
- [４、select可以用于什么，常用语gorotine的完美退出](#４select可以用于什么常用语gorotine的完美退出)
- [６、client如何实现长连接](#６client如何实现长连接)
- [７、主协程如何等其余协程完再操作](#７主协程如何等其余协程完再操作)
- [８、slice，len，cap，共享，扩容](#８slicelencap共享扩容)
- [９、map如何顺序读取](#９map如何顺序读取)
- [10、实现set](#10实现set)
- [１１、实现消息队列（多生产者，多消费者）](#１１实现消息队列多生产者多消费者)
- [１２、大文件排序](#１２大文件排序)
- [１５、http 401,403](#１５http-401403)
- [１６、http keep-alive](#１６http-keep-alive)
- [２１、孤儿进程，僵尸进程](#２１孤儿进程僵尸进程)
- [２２、死锁条件，如何避免](#２２死锁条件如何避免)
- [２６、Slice与数组区别，Slice底层结构](#２６slice与数组区别slice底层结构)
- [３４、Go的channel（有缓冲和无缓冲区别）](#３４go的channel有缓冲和无缓冲区别)
- [35、退出程序时怎么防止channel没有消费完，这里一开始有点没清楚面试官问的，然后说了监听中断信号，做退出前的处理，然后面试官说不是这个意思，然后说发送前先告知长度，长度要是不知道呢？close channel下游会受到0值，可以利用这点（这里也有点跟面试官说不明白）](#35退出程序时怎么防止channel没有消费完这里一开始有点没清楚面试官问的然后说了监听中断信号做退出前的处理然后面试官说不是这个意思然后说发送前先告知长度长度要是不知道呢close-channel下游会受到0值可以利用这点这里也有点跟面试官说不明白)
- [４４、线段树了解吗？不了解，字典树？了解](#４４线段树了解吗不了解字典树了解)
- [４６、sync.Pool用过吗，为什么使用，对象池，避免频繁分配对象（GC有关），那里面的对象是固定的吗？](#４６syncpool用过吗为什么使用对象池避免频繁分配对象gc有关那里面的对象是固定的吗)

## １、go调度器

操作系统、进程与线程，golang goroutine(G-M-P 模型)

## ２、go struct能不能比较

因为是强类型语言，所以不同类型的结构不能作比较，但是同一类型的实例值是可以比较的，实例不可以比较，因为是指针类型

## ３、go defer（for defer），先进后出，后进先出

```
func b() {
    for i := 0; i < 4; i++ {
        defer fmt.Print(i)
    }
}
```

先进的会后出。

## ４、select可以用于什么，常用语gorotine的完美退出

golang 的 select 就是监听 IO 操作(channel)，当 IO 操作发生时，触发相应的动作
每个case语句里必须是一个IO操作，确切的说，应该是一个面向channel的IO操作
５、context包的用途

Context通常被译作上下文，它是一个比较抽象的概念，其本质，是【上下上下】存在上下层的传递，上会把内容传递给下。在Go语言中，程序单元也就指的是Goroutine

## ６、client如何实现长连接

长连接

优点:
- 省去较多的TCP建立和关闭的操作，从而节约时间。
- 性能比较好。（因为客户端一直和服务端保持联系）
缺点
- 当客户端越来越多的时候，会将服务器压垮。
- 连接管理难。
- 安全性差。（因为会一直保持着连接，可能会有些无良的客户端，随意发送数据等）

server是设置超时时间，使用for循环遍历tcp通道

## ７、主协程如何等其余协程完再操作

使用channel进行通信，context,select

sync.WaitGroup 并发锁控制

## ８、slice，len，cap，共享，扩容

append函数，因为slice底层数据结构是，由数组、len、cap组成，所以，在使用append扩容时，会查看数组后面有没有连续内存快，有就在后面添加，没有就重新生成一个大的素组

## ９、map如何顺序读取

map不能顺序读取，是因为他是无序的，想要有序读取，首先的解决的问题就是，把ｋｅｙ变为有序，所以可以把key放入切片，对切片进行排序，遍历切片，通过key取值。

## 10、实现set

type inter interface{}
type Set struct {
    m map[inter]bool
    sync.RWMutex
}

func New() *Set {
    return &Set{
    m: map[inter]bool{},
    }
}
func (s *Set) Add(item inter) {
    s.Lock()
    defer s.Unlock()
    s.m[item] = true
}

## １１、实现消息队列（多生产者，多消费者）

使用切片加锁可以实现

## １２、大文件排序

归并排序，分而治之,拆分为小文件，在排序
１３、基本排序，哪些是稳定的
１４、http get跟head

HEAD和GET本质是一样的，区别在于HEAD不含有呈现数据，而仅仅是HTTP头信息。有的人可能觉得这个方法没什么用，其实不是这样的。想象一个业务情景：欲判断某个资源是否存在，我们通常使用GET，但这里用HEAD则意义更加明确。

## １５、http 401,403

400 bad request，请求报文存在语法错误
401 unauthorized，表示发送的请求需要有通过 HTTP 认证的认证信息
403 forbidden，表示对请求资源的访问被服务器拒绝
404 not found，表示在服务器上没有找到请求的资源

## １６、http keep-alive

client发出的HTTP请求头需要增加Connection:keep-alive字段
Web-Server端要能识别Connection:keep-alive字段，并且在http的response里指定Connection:keep-alive字段，告诉client，我能提供keep-alive服务，并且"应允"client我暂时不会关闭socket连接

１７、http能不能一次连接多次请求，不等后端返回

http本质上市使用socket连接，因此发送请求，接写入tcp缓冲，是可以多次进行的，这也是http是无状态的原因

１８、tcp与udp区别，udp优点，适用场景

tcp传输的是数据流，而udp是数据包，tcp会进过三次握手，udp不需要

２０、数据库如何建索引

## ２１、孤儿进程，僵尸进程

- 孤儿进程：一个父进程退出，而它的一个或多个子进程还在运行，那么那些子进程将成为孤儿进程。
- 僵尸进程：一个进程使用fork创建子进程，如果子进程退出，而父进程并没有调用wait或waitpid获取子进程的状态信息，那么子进程的进程描述符仍然保存在系统中。这种进程称之为僵死进程。

## ２２、死锁条件，如何避免

四个必要条件：

- 互斥条件：一个资源每次只能被一个进程使用。 
- 请求与保持条件：一个进程因请求资源而阻塞时，对已获得的资源保持不放。
- 不剥夺条件:进程已获得的资源，在末使用完之前，不能强行剥夺。
- 循环等待条件:若干进程之间形成一种头尾相接的循环等待资源关系。

死锁避免是利用额外的检验信息，在分配资源时判断是否会出现死锁，只在不会出现死锁的情况下才分配资源。 两种避免办法： 1、如果一个进程的请求会导致死锁，则不启动该进程 2、如果一个进程的增加资源请求会导致死锁，则拒绝该申请。

## ２６、Slice与数组区别，Slice底层结构

- 数组是固定大小的，slice可以改变大小。
- 切片本身并不是动态数组或者数组指针。它内部实现的数据结构通过指针引用底层数组，设定相关属性将数据读写操作限定在指定的区域内。切片本身是一个只读对象，其工作机制类似数组指针的一种封装。


## ３４、Go的channel（有缓冲和无缓冲区别）

**对于无缓冲区channel：**

发送的数据如果没有被接收方接收，那么发送方阻塞；如果一直接收不到发送方的数据，接收方阻塞；

**有缓冲的channel：**

发送方在缓冲区满的时候阻塞，接收方不阻塞；接收方在缓冲区为空的时候阻塞，发送方不阻塞。

可以类比生产者与消费者问题。


## 35、退出程序时怎么防止channel没有消费完，这里一开始有点没清楚面试官问的，然后说了监听中断信号，做退出前的处理，然后面试官说不是这个意思，然后说发送前先告知长度，长度要是不知道呢？close channel下游会受到0值，可以利用这点（这里也有点跟面试官说不明白）

没有一种适用的方式来检查channel是否已经关闭了

`data, ok := <- chan` 只有当channel无数据，且channel被close了，才会返回ok=false

一个适用的原则是不要从接收端关闭channel，也不要关闭有多个并发发送者的channel。

## ４４、线段树了解吗？不了解，字典树？了解

线段树是一种二叉搜索树，与区间树相似，它将一个区间划分成一些单元区间，每个单元区间对应线段树中的一个叶结点。 使用线段树可以快速的查找某一个节点在若干条线段中出现的次数，时间复杂度为O(logN)。 而未优化的空间复杂度为2N，实际应用时一般还要开4N的数组以免越界，因此有时需要离散化让空间压缩。

字典树又称单词查找树，Trie树，是一种树形结构，是一种哈希树的变种。 典型应用是用于统计，排序和保存大量的字符串（但不仅限于字符串），所以经常被搜索引擎系统用于文本词频统计。 它的优点是：利用字符串的公共前缀来减少查询时间，最大限度地减少无谓的字符串比较，查询效率比哈希树高。


## ４６、sync.Pool用过吗，为什么使用，对象池，避免频繁分配对象（GC有关），那里面的对象是固定的吗？

作用： 保存和复用临时对象，减少内存分配，降低 GC 压力。
