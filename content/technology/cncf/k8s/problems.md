+++
title = "问题篇"
date =  2022-11-04T16:12:37+08:00
description= "description"
weight = 2
+++

- [Kubernetes包含几个组件，各个组件的功能是什么，组件之间是如何交互的？](#kubernetes包含几个组件各个组件的功能是什么组件之间是如何交互的)
- [Kubernetes的Pause容器有什么用](#kubernetes的pause容器有什么用)
- [Kubernetes中的Pod内几个容器之间的关系?](#kubernetes中的pod内几个容器之间的关系)
- [一个经典Pod的完整生命周期是怎么样的](#一个经典pod的完整生命周期是怎么样的)
- [详述kube-proxy的工作原理](#详述kube-proxy的工作原理)
  - [kube-proxy & service必要说明](#kube-proxy--service必要说明)
  - [工作原理](#工作原理)
  - [代理模式](#代理模式)
    - [iptables](#iptables)
    - [ipvs](#ipvs)
- [rc/rs功能是怎么实现的？请详述从API接收到一个创建rc/rs的请求，到最终在节点上创建Pod的](#rcrs功能是怎么实现的请详述从api接收到一个创建rcrs的请求到最终在节点上创建pod的)
- [deployment/rs有什么区别，其使用方式、使用条件和原理是什么？](#deploymentrs有什么区别其使用方式使用条件和原理是什么)
- [大规模k8s集群](#大规模k8s集群)
- [设想Kubernetes集群管理从一千台节点到五千台节点，可能会遇到什么样的瓶颈，应该如何解决？](#设想kubernetes集群管理从一千台节点到五千台节点可能会遇到什么样的瓶颈应该如何解决)
- [集群发生雪崩的条件，以及预防手段](#集群发生雪崩的条件以及预防手段)
- [设计一种可以替代kube-proxy的实现](#设计一种可以替代kube-proxy的实现)
- [Sidecar的设计模式如何在Kubernetes中进行应用，有什么意义？](#sidecar的设计模式如何在kubernetes中进行应用有什么意义)
- [灰度发布是什么，如何使用Kubernetes现有的资源实现灰度发布？](#灰度发布是什么如何使用kubernetes现有的资源实现灰度发布)
- [介绍Kubernetes实践中踩过的比较大的一个坑和解决方式。](#介绍kubernetes实践中踩过的比较大的一个坑和解决方式)

## Kubernetes包含几个组件，各个组件的功能是什么，组件之间是如何交互的？

- kubelete 所有节点上的管理组件
- Api Server: Kubernetes API Server作为集群的核心，负责集群各功能模块之间的通信。集群内的各个功能模块通过API Server将信息存入etcd，当需要获取和操作这些数据时，则通过API Server提供的REST接口（用GET、LIST或WATCH方法）来实现，从而实现各模块之间的信息交互。
- k8s Scheduler: Kubernetes Scheduler在整个系统中承担了“承上启下”的重要功能，“承上”是指它负责接收Controller Manager创建的新Pod，为其调度至目标Node；“启下”是指调度完成后，目标Node上的kubelet服务进程接管后继工作，负责Pod接下来生命周期。
- Controller: 负责执行各种控制器，目前已经提供了很多控制器来保证Kubernetes的正常运行。Controller有很多种，Node Controller,Namespace Controller,Service Controller, DaemonSet Controller等。
- Etcd： 存储集群所有数据

## Kubernetes的Pause容器有什么用

Pause 容器，又叫 Infra 容器。

特点：
- 镜像非常小，目前在 700KB 左右
- 永远处于 Pause (暂停) 状态

因为容器之间原本是被 Linux Namespace 和 cgroups 隔开的，所以现在实际要解决的是怎么去打破这个隔离，然后共享某些事情和某些信息。这就是 Pod 的设计要解决的核心问题所在。

所以说具体的解法分为两个部分：网络和存储。

Pause 容器就是为解决 Pod 中的网络问题而生的。

Infra container 是一个非常小的镜像，大概 700KB 左右，是一个 C 语言写的、永远处于 “暂停” 状态的容器。由于有了这样一个 Infra container 之后，其他所有容器都会通过 Join Namespace 的方式加入到 Infra container 的 Network Namespace 中。

所以说一个 Pod 里面的所有容器，它们看到的网络视图是完全一样的。即：它们看到的网络设备、IP 地址、Mac 地址等等，跟网络相关的信息，其实全是一份，这一份都来自于 Pod 第一次创建的这个 Infra container。这就是 Pod 解决网络共享的一个解法。

由于需要有一个相当于说中间的容器存在，所以整个 Pod 里面，必然是 Infra container 第一个启动。并且整个 Pod 的生命周期是等同于 Infra container 的生命周期的，与容器 A 和 B 是无关的。这也是为什么在 Kubernetes 里面，它是允许去单独更新 Pod 里的某一个镜像的，即：做这个操作，整个 Pod 不会重建，也不会重启，这是非常重要的一个设计。

kubernetes 中的 pause 容器主要为每个业务容器提供以下功能：

- 在 pod 中担任 Linux 命名空间共享的基础；
- 启用 pid 命名空间，开启 init 进程。

## Kubernetes中的Pod内几个容器之间的关系?

pod是k8s的最小单元，容器包含在pod中，一个pod中有一个pause容器和若干个业务容器，而容器就是单独的一个容器，简而言之，pod是一组容器，而容器单指一个容器。

Pod内容器共用Linux命名空间，共用pid空间。Pod 内的多个容器共享网络和文件系统。

## 一个经典Pod的完整生命周期是怎么样的

创建过程：

1. 通过APi server创建Pod，或者通过Controller(rc/rs)创建Pod。
2. APi server写入Etcd
3. Scheduler读取到有新的Pod创建，为Pod分配到节点。通过Api server写入信息到Etcd。
4. node节点接收到新的pod创建任务，在node节点上根据配置拉取镜像，创建Pod。

Pod生命周期：
- Pending： Pod任务被Kubelete接受，包括等待调度，下载镜像时间
- Running： Pod中所有容器运行。
- Succeeded： Pod正常终止。
- Failed： Pod异常退出。
- Unknown： 因为某些原因未获取到POd状态，可能能上主机通信失败。

pod生命周期的重要行为：

1. 初始化容器：

一个pod可以拥有任意数量的init容器。init容器时顺序执行的，并且仅当最后一个init容器执行完毕才会去启动容器。换句话说，init容器也可以用来延迟pod的主容器的启动。

2. 生命周期钩子：

pod允许定义两种类型的生命周期钩子，启动后(post-start)钩子和停止前(pre-stop)钩子

这些生命周期钩子是基于每个容器来指定的，和init容器不同的是，init容器时应用到整个pod。而这些钩子是针对容器的，是在容器启动后和停止前执行的。

3. 容器探针：

他是kubectl对容器周期性执行的健康状态诊断。分为两种： Liveness(存活性探测)， Readiness(就绪性检测)

Liveness(存活性探测)：判断容器是否处于runnning状态，策略是重启容器

Readiness(就绪性检测)：判断容器是否准备就绪并对外提供服务，将容器设置为不可用，不接受service转发的请求

三种处理器用于Pod检测：

 ExecAction：在容器中执行一个命令，并根据返回的状态码进行诊断1，只有返回0为成功，

 TCPSocketAction：通过与容器的某TCP端口尝试建立连接金慈宁宫诊断

 HTTPGetAction：通过向容器IP地址的某指定端口的path发起HTTP GET请求。

 

4. 容器的重启策略： 

定义是否重启Pod对象

Always：但凡Pod对象终止就重启，默认设置

OnFailure：仅在Pod出现错误时才重启

Never：从不

注：一旦Pod绑定到一个节点上，就不会被重新绑定到另一个节点上，要么重启，要么终止

 

5. pod的终止过程

终止过程主要分为如下几个步骤：

(1)用户发出删除 pod 命令

(2)Pod 对象随着时间的推移更新，在宽限期（默认情况下30秒），pod 被视为“dead”状态

(3)将 pod 标记为“Terminating”状态

(4)第三步同时运行，监控到 pod 对象为“Terminating”状态的同时启动 pod 关闭过程

(5)第三步同时进行，endpoints 控制器监控到 pod 对象关闭，将pod与service匹配的 endpoints 列表中删除

(6)如果 pod 中定义了 preStop 钩子处理程序，则 pod 被标记为“Terminating”状态时以同步的方式启动执行；若宽限期结束后，preStop 仍未执行结束，第二步会重新执行并额外获得一个2秒的小宽限期

(7)Pod 内对象的容器收到 TERM 信号

(8)宽限期结束之后，若存在任何一个运行的进程，pod 会收到 SIGKILL 信号

(9)Kubelet 请求 API Server 将此 Pod 资源宽限期设置为0从而完成删除操作

删除过程：

1. API Server直接删除Pod资源，或者Controller（RC/RS）控制Pod数量。
2. API Server标记Pod为Terminal状态。
3. Node节点接收到Pod删除任务，尝试删除Pod，
4. Kubelet 请求 API Server 将此 Pod 资源宽限期设置为0从而完成删除操作


## 详述kube-proxy的工作原理

### kube-proxy & service必要说明

说到kube-proxy，就不得不提到k8s中service，下面对它们两做简单说明：

- kube-proxy其实就是管理service的访问入口，包括集群内Pod到Service的访问和集群外访问service。
- kube-proxy管理sevice的Endpoints，该service对外暴露一个Virtual IP，也成为Cluster IP, 集群内通过访问这个Cluster IP:Port就能访问到集群内对应的serivce下的Pod。
- service是通过Selector选择的一组Pods的服务抽象，其实就是一个微服务，提供了服务的LB和反向代理的能力，而kube-proxy的主要作用就是负责service的实现。
- service另外一个重要作用是，一个服务后端的Pods可能会随着生存灭亡而发生IP的改变，service的出现，给服务提供了一个固定的IP，而无视后端Endpoint的变化。

Kube-proxy 是 kubernetes 工作节点上的一个网络代理组件，运行在每个节点上。Kube-proxy维护节点上的网络规则，实现了Kubernetes Service 概念的一部分 。它的作用是使发往 Service 的流量（通过ClusterIP和端口）负载均衡到正确的后端Pod。


### 工作原理

kube-proxy 监听 API server 中 资源对象的变化情况，包括以下三种：

- service
- endpoint/endpointslices
- node

然后根据监听资源变化操作代理后端来为服务配置负载均衡。

如果你的 kubernetes 使用EndpointSlice，那么kube-proxy会监听EndpointSlice，否则会监听Endpoint。

如果你启用了服务拓扑，那么 kube-proxy 也会监听 node 信息 。服务拓扑（Service Topology）可以让一个服务基于集群的 Node 拓扑进行流量路由。 例如，一个服务可以指定流量是被优先路由到一个和客户端在同一个 Node 或者在同一可用区域的端点。

###  代理模式

目前 Kube-proxy 支持4中代理模式：

- userspace
- iptables
- ipvs
- kernelspace

其中 kernelspace 专用于windows，userspace 是早期版本的实现，本文我们不作过多阐述。

#### iptables

iptables是一种Linux内核功能，旨在成为一种高效的防火墙，具有足够的灵活性来处理各种常见的数据包操作和过滤需求。它允许将灵活的规则序列附加到内核的数据包处理管道中的各种钩子上。

在iptables模式下，kube-proxy将规则附加到“ NAT预路由”钩子上，以实现其NAT和负载均衡功能。这种方法很简单，使用成熟的内核功能，并且可以与通过iptables实现网络策略的组件“完美配合”。

默认的策略是，kube-proxy 在 iptables 模式下随机选择一个后端。

如果 kube-proxy 在 iptables 模式下运行，并且所选的第一个 Pod 没有响应， 则连接失败。 这与用户空间模式不同：在这种情况下，kube-proxy 将检测到与第一个 Pod 的连接已失败， 并会自动使用其他后端 Pod 重试。

但是，kube-proxy对iptables规则进行编程的方式是一种O(n)复杂度的算法，其中n与集群大小(或更确切地说，服务的数量和每个服务背后的后端Pod的数量）成比例地增长)。

#### ipvs

IPVS是专门用于负载均衡的Linux内核功能。在IPVS模式下，kube-proxy可以对IPVS负载均衡器进行编程，而不是使用iptables。这非常有效，它还使用了成熟的内核功能，并且IPVS旨在均衡许多服务的负载。它具有优化的API和优化的查找例程，而不是一系列顺序规则。 结果是IPVS模式下kube-proxy的连接处理的计算复杂度为O(1)。换句话说，在大多数情况下，其连接处理性能将保持恒定，而与集群大小无关。

与 iptables 模式下的 kube-proxy 相比，IPVS 模式下的 kube-proxy 重定向通信的延迟要短，并且在同步代理规则时具有更好的性能。 与其他代理模式相比，IPVS 模式还支持更高的网络流量吞吐量。

IPVS提供了更多选项来平衡后端Pod的流量。 这些是：

- rr: round-robin
- lc: least connection (smallest number of open connections)
- dh: destination hashing
- sh: source hashing
- sed: shortest expected delay
- nq: never queue

## rc/rs功能是怎么实现的？请详述从API接收到一个创建rc/rs的请求，到最终在节点上创建Pod的

ReplicaSet是下一代复本控制器。ReplicaSet和 Replication Controller之间的唯一区别是现在的选择器支持。Replication Controller只支持基于等式的selector（env=dev或environment!=qa），但ReplicaSet还支持新的，基于集合的selector（version in (v1.0, v2.0)或env notin (dev, qa)）。在试用时官方推荐ReplicaSet。

- API接收到rc/rs创建请求。
- API写入RC/RS配置到ETCD.
- RC/RS控制器收到新的创建请求，根据配置生成POD配置，通过API写入新建POD。
- k8s Scheduler接收到新建POD任务，为POD分配节点，并写入节点信息。
- Node节点接收到POD新建任务，在节点上新建POD。

## deployment/rs有什么区别，其使用方式、使用条件和原理是什么？

Deployment 为 Pod 和 ReplicaSet 提供了一个声明式定义（declarative）方法，用来替代以前的 ReplicationController 来方便的管理应用。典型的应用场景包括：

- 定义 Deployment 来创建 Pod 和 ReplicaSet
- 滚动升级和回滚应用
- 扩容和缩容
- 暂停和继续 Deployment

deployment封装了rs，官方建议不要直接使用rs，而是使用deployment来部署应用。

deployment会自动创建rs，在应用升级的时候，deployment会为应用新建rs来替换就得rs。

## 大规模k8s集群

官方就宣称单集群最大支持 5000 个节点，能多节点的集群，建议拆分成不同的集群管理。

1. kube-apiserver 优化

- 方式一: 启动多个 kube-apiserver 实例通过外部 LB 做负载均衡。
- 方式二: 设置 --apiserver-count 和 --endpoint-reconciler-type，可使得多个 kube-apiserver 实例加入到 Kubernetes Service 的 endpoints 中，从而实现高可用。
- 控制连接数, 限制一定时间内api的连接数量

2. kube-scheduler 与 kube-controller-manager 优化

kube-controller-manager 和 kube-scheduler 是通过 leader election 实现高可用，启用时需要添加以下参数:
```shell
--leader-elect=true
--leader-elect-lease-duration=15s
--leader-elect-renew-deadline=10s
--leader-elect-resource-lock=endpoints
--leader-elect-retry-period=2s
```
- 控制 QPS: 与 kube-apiserver 通信的 qps 限制

3. Kubelet节点 优化

- Kubelet 优化: 限制节点pod数量
- 镜像拉取优化，镜像超时时间，
- serialize-image-pulls=false， 开启并发拉取镜像
- docker控制每个日志文件大小

4. 集群 DNS 高可用

每个节点启动一个DNS（Coredns）或者启用localdns功能，在本地做dns缓存。

4. ETCD 优化

- 使用外部ETCD集群，磁盘性能优化采用固态硬盘
- 分离集群的event存储，集群中会产生大量的event事件，这些会对etcd造成很大的压力，将event时间分离到不同的etcd集群
- 减少网络延迟

## 设想Kubernetes集群管理从一千台节点到五千台节点，可能会遇到什么样的瓶颈，应该如何解决？

- 性能问题
  - API Server出现性能问题，尝试给APIserver加上负载，扩展API Server数量，增大资源
  - API Server限制单个客户端连接数量
  - 限制集群中Controller对API Server的访问QPS
  - ETCD性能需要提升，将集群Event事件分离到单独的集群，扩张ETCD集群，增加集群配置，主要是磁盘和网络带宽。
  - 扩张Coredns部署，启用Localdns部署，在每个节点上启用dns缓存。
  - 拉取镜像缓慢问题： 设置启用集群并发拉取镜像配置，同时调大镜像拉取超时时间。
  - 网络性能问题： 可以采用高性能的网络插件，比如Cilum，Calico等。并优化配置
  - 集群内部kube-proxy代理性能问题： 采用ipvs会有缓解，也可以采用Cilum这种高性能网络组件。
- 管理问题
  - 安全问题挑战: 由于共用集群，需要为每个用户角色管理不同的使用权限问题。
  - 更复杂的应用管理: 怎么为应用配置更合理的资源应用，用户配置文件管理等

## 集群发生雪崩的条件，以及预防手段

集群所有节点可用资源达到某个临界，加上POD的资源限制不合理，一些节点没有加调度限制。

某个节点由于一些原因故障了，触发将节点上的POD排空操作。这时这个节点上的POD会漂移到其他合适的节点，由于被调度的节点资源同样吃紧，同样会导致这个节点notready，然后这个节点上的POD被排到其它节点，导致雪崩发生。

要预防雪崩发生：
- 保证节点系统组件有足够资源能运行。kubelete优化, Kubelet Node Allocatable用来为Kube组件和System进程预留资源，从而保证当节点出现满负荷时也能保证Kube和System进程有足够的资源。
- 完善的资源监控设施，保证大部分节点资源负载都不超过阈值，监控非正常POD的资源大幅增加并预警。
- 设置合理的POD资源限制条件，让某些大油耗POD不能调度到少资源的节点。
- 设置POD调度条件，只允许某些POD在部分节点上调度，降低雪崩影响范围。

## 设计一种可以替代kube-proxy的实现

主要实现集群中svc这一概率的功能。通过service ip访问后端POD应用。

目前的实现方案有：
- 基于iptable的nat功能
- 基于ipset的实现
- 基于bpf的实现

其实也可以基于外部代理实现，将主机的所有流量转发到外部的一个代理上面，比如HAProxy+Nginx这种组合上面。
由外部代理来实现流量分发到不同节点上。

## Sidecar的设计模式如何在Kubernetes中进行应用，有什么意义？

sidecar的思想核心就是：不侵入主容器的前提下，可以进行服务功能扩展。一般都是一些共性的能力，比如说：

- 日志代理/转发，例如 fluentd；
- Service Mesh，比如 Istio，Linkerd；
- 代理，比如 Docker Ambassador；
- 探活：检查某些组件是不是正常工作；
- 其他辅助性的工作，比如拷贝文件，下载文件，debug容器应用。

## 灰度发布是什么，如何使用Kubernetes现有的资源实现灰度发布？

做到灰度发布可以基于网关，也可以基于原生的k8s资源。

基于网关的模式是由网关代理了来实现的，网关使用域名同时代理流量到新旧服务中。

基于k8s原生资源可以利用service的label选择后端，同时选择新旧POD后端。缺点就是没有网关实现的灵活。

## 介绍Kubernetes实践中踩过的比较大的一个坑和解决方式。

- 配置问题导致的集群网络不通： calico网络插件针对不同的网络环境有不同的配置。
- 外宣集群IP导致
- 集群规划部署不当，导致集群扩展难
- 云原生改造成本高，所有应用上云需要一个实践过程。
- 云原生是一个很大的体系，包括容器化管理，CI/CD集成，监控报警，日志，云存储等