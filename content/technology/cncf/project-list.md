+++
title = "项目列表"
date =  2021-02-24T12:04:13+08:00
weight = 1
description = "CNCF项目描述"
+++

## 一、Graduated
毕业项目

#### 1、containerd

[项目地址](http://containerd.io/)

CNI插件

#### 2、CoreDNS

[项目地址](http://containerd.io/)


域名解析

#### 3、Envoy

[项目地址](https://www.envoyproxy.io/)

网络流量代理，c++实现，高性能
L7 层代理
支持 L3/4 protocol
istio依赖envoy代理

#### 4、 etcd

[项目地址](https://etcd.io/)

k/v 存储

#### 5、Fluentd

[项目地址](http://fluentd.org/)

Fluentd is an open source data collector, which lets you unify the data collection and consumption for a better use and understanding of data

Unified Logging with JSON
基于json的统一日志框架，支持超过125个系统的log信息收集
底层是C和CRuby编写

支持多源日志数据收集，多端日志存储es,kafka,s3,prometheus等

比较：
比logstash 更快，但低于filebeat
插件数量与logstash相当，比filebeat丰富
插件基于lua编写，快速实现，但性能可能不如意
fluentd-bit更快的日志收集，但是插件数量少

#### 6、Harbor

[项目地址](https://goharbor.io/)


镜像仓库

#### 7、Helm

[项目地址](https://www.helm.sh/)

安装包管理

#### 8、Jaeger

[项目地址](https://jaegertracing.io/)


end-to-end distributed tracing
Monitor and troubleshoot transactions in complex distributed systems
端到端的分布式追踪系统
复杂系统的监控和和事务处理

功能： Monitor， Performance Tuning ，Troubleshooting

监控，性能调优，故障分析

#### 9、Kubernetes

[项目地址](http://kubernetes.io/)

k8s

#### 10、Open Policy Agent

[项目地址](http://www.openpolicyagent.org/)

opa

Policy-based control for cloud native environments
Flexible, fine-grained control for administrators across the stack

云原生策略控制，通用，安全的管理控制栈

Rego语音策略编辑，策略查询

#### 11、Prometheus

[项目地址](https://prometheus.io/)

监控报警，时序数据库

#### 12、Rook

[项目地址](https://rook.io/)

 support for a diverse set of storage solutions to natively integrate with cloud-native environments
 云存储，基于ceph,cassanda等的云存储系统；
 
 将支持更多数据库

#### 13、TiKV

[项目地址](https://tikv.org/)

分布式kv存储，支持大数据存储
基于Google Spanner and HBase，管理简单

#### 14、TUF

[项目地址](https://theupdateframework.io/)

A framework for securing software update systems

软件安全更新

#### 15、 Vitess

[项目地址](https://vitess.io/)

A database clustering system for horizontal scaling of MySQL

没错，集群化管理的mysql数据库也有了


## 二、Incubating
孵化项目

#### 1、Argo

[项目地址](https://argoproj.github.io/)


open source Kubernetes native workflows, events, CI and CD

k8s 工作流

支持ci/cd
支持任务依赖

可自由编辑任务执行流程，基于docker执行任务
目前大量用于github的机器学习任务


#### 2、Buildpacks

[项目地址](https://buildpacks.io/)

transform your application source code into images that can run on any cloud.

构建你的项目，让其可以运行在任意的云环境。

不同于dockerfile的另一套构建配置方案


#### 3、CloudEvents

[项目地址](https://cloudevents.io/)

A specification for describing event data in a common way

通用标准事件数据分发
事件分发和接收通用标准

格式支持： amq,kafka,http,json,websocket,pb等

使用方式：
SDK接入

#### 4、CNI

[项目地址](https://www.cni.dev/)

容器网络接口
标准

#### 5、Contour

[项目地址](https://projectcontour.io/)


High performance ingress controller for Kubernetes

ingress控制器
providing the control plane for the Envoy edge and service proxy.

管理envoy和service proxy

依赖envoy作为代理

#### 6、Cortex

[项目地址](https://github.com/cortexproject)

A horizontally scalable, highly available, multi-tenant, long term Prometheus

高可用，可伸缩，多租户，持久存储的prometheus监控报警平台

prometheus数据分片


#### 7、 CRI-O

[项目地址](https://cri-o.io/)

Container Runtime
容器运行时

#### 8、Dragonfly

[项目地址](https://d7y.io/)

An Open-source P2P-based Image and File Distribution System

基于p2p的镜像和文件分发系统

针对大规模集群，快速文件和镜像传输；最大化网络带宽资源；

#### 9、Falco

[项目地址](https://falco.org/)

runtime security project，
Kubernetes threat detection engine

容器运行时安全项目
k8s威胁检查系统

#### 10、gRPC

[项目地址](https://grpc.io/)

google rpc框架，高性能

google出品，必属精品

#### 11、KubeEdge

[项目地址](https://kubeedge.io/en/)

open source system for extending native containerized application orchestration capabilities to hosts at Edge

将k8s的编排能力扩展到边缘节点
支持边缘计算


#### 12、Linkerd

[项目地址](https://linkerd.io/)

服务网格 service mesh
Ultra light, ultra simple, ultra powerful.
超轻量，超简单，超牛逼

微服务基础设施

支持特性：
* Automatic mTLS.  服务访问自动tls
* Automatic Proxy Injection. 自动代理注入 
* CNI Plugin.  cni插件
* Dashboard and Grafana.  管理和监控 
* Distributed Tracing. 分布式追踪
* Fault Injection.   故障注入
* High Availability.  高可用
* HTTP, HTTP/2, and gRPC Proxying.  代理 
* Ingress.   网关
* Load Balancing.  负载均衡 
* Multi-cluster communication.  多集群支持 
* Retries and Timeouts.  重试和超时
* Service Profiles.   服务描述
* TCP Proxying and Protocol Detection. 代理 
* Telemetry and Monitoring.  观测和监控
* Traffic Split (canaries, blue/green deploys). 流量切分


#### 13、NATS

[项目地址](https://nats.io/)

分布式系统两种模式
two basic patterns 
- request/reply or RPC for services  请求
- event and data streams  事件

messaging system 消息系统 
NATS is simple and secure messaging made for developers and operators who want to spend more time developing modern applications and services than worrying about a distributed communication system

* Easy  单纯
* High-Performance 可靠
* Always on and available  老实人
* Extremely lightweight  骨瘦如柴
* At Most Once and At Least Once Delivery  一次性执着
* Support for Observable and Scalable Services and Event/Data Streams  可观测
* Client support for over 30 different programming languages  友善
* Cloud Native, a CNCF project with Kubernetes and Prometheus integrations  k8s，prometheus亲和


对比:
分发性能是kafka的两倍

![c108d962b3516e88f8512cfd84cd39ef.png](evernotecid://CB8AD13C-A1A5-4E21-ADF1-DAB53479DF62/appyinxiangcom/23274906/ENResource/p13)

NATS理想的使用场景有：

    1）寻址、发现 
    2）命令和控制（控制面板） 
    3）负载均衡 
    4）多路可伸缩能力 
    5）定位透明 
    6）容错

　　NATS设计哲学认为，高质量的QoS应该在客户端构建，故只建立了请求-应答，不提供：

    1）持久化 
    2）事务处理 
    3）增强的交付模式 
    4）企业级队列 

#### 14、Notary

[项目地址](https://github.com/theupdateframework/notary)

网络安全

#### 15、OpenTracing

[项目地址](http://opentracing.io/)

Distributed Tracing API
分布式追踪API

追踪标准

#### 16、Operator Framework

[项目地址](https://operatorframework.io/)

open source toolkit to manage Kubernetes native applications, called Operators, in an effective, automated, and scalable way.

开源工具集，用来管理k8s应用，有效，自动，可扩展。

#### 17、SPIRE

[项目地址](https://github.com/spiffe/spire)

A universal identity control plane for distributed systems

分布式系统统一健全控制框架

#### 18、Thanos

[项目地址](https://thanos.io/)

highly available Prometheus setup with long term storage capabilities.

高可用，持久存储prometheus.



## 三、sandbox
沙盒项目

#### 1、Athenz

[项目地址](https://www.athenz.io/)

描述：
supporting service authentication and role-based authorization (RBAC) for provisioning and configuration (centralized authorization) use cases as well as serving/runtime (decentralized authorization) use cases

使用X.509 支持应用权限验证
应用之间的短期，证书验证，支持rbac权限验证

使用：
API调用，SDK接入

#### 2、Artifact Hub

[项目地址](https://artifacthub.io/)

Find, install and publish Kubernetes packages

k8s package管理

包括： helm包，opa policy,kubectl plugin, operator等

#### 3、Backstage

[项目地址](https://backstage.io/)

An open platform for building developer portals
unifies all your infrastructure tooling, services, and documentation to create a streamlined development environment from end to end

管理基础设施工具，服务，稳定，提供一条龙服务

使用：

部署即可使用，特殊需要需要自己开发插件、nodejs实现


#### 4、BFE

[项目地址](https://www.bfe-networks.net/en_us/)

A modern layer 7 load balancer

网络七层负载均衡

来自百度

对比nginx优点：
多种协议支持HTTP, HTTPS, SPDY, HTTP2, WebSocket, TLS, FastCGI, etc
多种策略支持
自定义开发支持
详细的metrics

使用：
二进制安装或者docker安装都行，需要自己配置策略和代理


#### 5、Brigade

[项目地址](https://brigade.sh/)

Brigade is a tool for running scriptable, automated tasks in the cloud — as part of your Kubernetes cluster.

k8s的事件驱动脚本

argo相似不相像

#### 6、cert-manager

[项目地址](http://containerd.io/)

无介绍

#### 7、Chaos Mesh

[项目地址](https://chaos-mesh.org/)

用于Kubernetes的云原生混沌工程平台

随机故障注入，快速验证系统的健壮性


#### 8、ChubaoFS

[项目地址](https://github.com/chubaofs/chubaofs)

储宝文件系统 in Chinese

cloud-native storage platform that provides both POSIX-compliant and S3-compatible interfaces.

提供POSIX标准和s3标准接口

#### 9、Cloud Custodian

[项目地址](https://cloudcustodian.io/)


公有云安全管理，绑定了一沓子工具包

yaml DSL描述规则

#### 10、Cloud Development Kit for Kubernetes (cdk8s)

[项目地址](https://cdk8s.io/)

CDK8s is a software development framework for defining Kubernetes applications and reusable abstractions using familiar programming languages and rich object-oriented APIs

一个软件开发框架，可以用你熟悉的语言来看房k8s应用

提供 nodejs,python,java sdk

和Pulumi k8s运维部分有点像

#### 11、CNI-Genie

[项目地址](https://github.com/cni-genie/CNI-Genie)

单节点多CNI支持

大而不僵？


#### 12、Crossplane

[项目地址](https://crossplane.io/)

open source Kubernetes add-on that extends any cluster with the ability to provision and manage cloud infrastructure, services, and applications using kubectl, GitOps, or any tool that works with the Kubernetes API

k8s扩展，管理云基础设施，服务，应用。使用kubectl,gitops或者任何其他工具。

运维管理

#### 13、Curiefense

[项目地址](https://www.curiefense.io/)

an API-first, DevOps oriented web-defense HTTP-Filter adapter for Envoy. It provides multiple security technologies (WAF, application-layer DDoS protection, bot management, and more) along with real-time traffic monitoring and transparency.

一个基于envoy，提供api优先，devops导向，web防护，http过滤适配。
提供多种安全技术，waf(网站应用级入侵防御),DDoS防护等


#### 14、Dex

[项目地址](https://dexidp.io/)

OpenID Connect 1.0 is a simple identity layer on top of the OAuth 2.0 protocol
一个简单的鉴权层，基于OAuth2.0。

Dex is an identity service that uses OpenID Connect to drive authentication for other apps.
基于 OpenID Connect提供鉴权服务。


#### 15、Distribution

[项目地址](https://github.com/distribution/distribution)

This repository's main product is the Open Source Registry implementation for storing and distributing container images using the OCI Distribution Specification. 

开源镜像仓库

#### 16、Flux

[项目地址](https://fluxcd.io/)

gitops
自动化部署


#### 17、GitOps Working Group


#### 18、in-toto

[项目地址](https://in-toto.io/)

A software supply chain is the series of steps performed when writing, testing, packaging, and distributing software.

软件供应链安全框架， 包括编写，测试，打包，分发软件。


#### 19、k3s

[项目地址](https://k3s.io/)


轻量级k8s

#### 20、k8dash

[项目地址](https://k8dash.io/)

dashboard

 helps you visually understand the concepts of your cluster
 
 帮助你生动的理解你的集群。
 
 管理你的集群


#### 21、KEDA

[项目地址](https://keda.sh/)

Kubernetes Event-driven Autoscaling

自扩容k8s事件驱动。


支持 kafka,rmq,redis,mysql,pg等


#### 22、Keptn

[项目地址](https://keptn.sh/)

a control-plane for DevOps automation of cloud-native applications.

云原生应用自动化运维控制平面。


#### 23、Keylime

[项目地址](https://keylime.dev/)

a highly scaleable remote boot attestation and runtime integrity measurement solution.

一个高度可扩展的远程启动认证和运行时完整性测量解决方案。

应用基础设施监控

#### 24、Kube-OVN

[项目地址](https://kube-ovn.io/)

企业级k8s网络

#### 25、KubeVirt

[项目地址](https://kubevirt.io/)

A VirtualMachine provides additional management capabilities to a VirtualMachineInstance inside the cluster.

vm operator，扩展k8s功能，将应用部署到虚拟机
这就很牛逼

#### 26、KUDO

[项目地址](https://kudo.dev/)

Kubernetes Universal Declarative Operator (KUDO) provides a declarative approach to building production-grade Kubernetes operators. 

k8s 通用描述operator，使用描述性方法构建k8s operator.

Workload Orchestration

#### 27、Kuma

[项目地址](https://kuma.io/)

a modern distributed Control Plane with a bundled Envoy Proxy integration

envory proxy的分布式控制平面。

service mesh管理


#### 28、Kyverno

[项目地址](https://kyverno.io/)

k8s集群策略控制
使用 validating and mutating admission webhook HTTP callbacks

#### 29、LitmusChaos

[项目地址](https://litmuschaos.io/)

Chaos Engineering
for your Kubernetes

k8s混沌工程

#### 30、Longhorn

[项目地址](https://longhorn.io/)

云存储

a lightweight, reliable, and powerful distributed block storage system for Kubernetes.

轻量，可靠，强大的分布式块存储。
挺牛逼的

#### 31、metal3-io

[项目地址](https://metal3.io/)

集群物理机管理

#### 32、Network Service Mesh

[项目地址](https://networkservicemesh.io/)

Hybrid/Multi-cloud IP Service Mesh


混合/多云 ip 服务网格

#### 33、Open Service Mesh

[项目地址](https://openservicemesh.io/)

轻量级服务网格

#### 34、OpenEBS

[项目地址](https://openebs.io/)

基于 Go 的容器化块存储

开源，可视化很好

缺点： 不成熟

#### 35、OpenMetrics

[项目地址](https://openmetrics.io/)

OpenMetrics a specification built upon and carefully extending Prometheus exposition format in almost 100% backwards-compatible ways.

兼容 prometheus metrics

Prometheus的监控数据采集方案

#### 36、OpenTelemetry

[项目地址](https://github.com/open-telemetry)

OpenTelemetry is a set of APIs, SDKs, tooling and integrations that are designed for the creation and management of telemetry data such as traces, metrics, and logs. 


提供api，sdk,tool，创建管理应用的数据: traces, metrics, and logs


#### 37、OpenYurt

[项目地址](https://openyurt.io/en-us/)

边缘计算


#### 38、Piraeus-Datastore

[项目地址](https://piraeus.io/)

 Local Persistent Volumes
 本地持久存储
 
 
#### 39、Porter

[项目地址](https://porter.sh/)

package your application artifact, client tools, configuration and deployment logic together as a versioned bundle that you can distribute, and then install with a single command.

打包应用、工具、配置、部署逻辑到一个版本化得包，让你可以发布和一键安装。

#### 40、SchemaHero

[项目地址](https://schemahero.io/)

数据库迁移


#### 41、Serverless Workflow Specification

[项目地址](http://serverlessworkflow.io/)

无状态工作流


#### 42、Service Mesh Interface

[项目地址](https://smi-spec.io/)

服务网格标准

#### 43、Strimzi

[项目地址](https://strimzi.io/)


kafka operator

快速部署kafka集群


#### 44、Telepresence

[项目地址](https://www.telepresence.io/)


应用部署工具


#### 45、Tremor

[项目地址](https://www.tremor.rs/)

https://www.tremor.rs/

事件处理
Tremor is an early stage event processing system for unstructured data with rich support for structural pattern matching, filtering and transformation.

事件处理过滤分发


#### 46、Virtual Kubelet

[项目地址](https://github.com/virtual-kubelet)


虚拟的kubelet


#### 47、Volcano

[项目地址](https://github.com/volcano-sh/volcano)


https://github.com/volcano-sh/volcano

高性能任务调度引擎
源自于华为云 AI 容器。Volcano 方便 AI、大数据、基因、渲染等诸多行业通用计算框架接入，提供高性能任务调度引擎，高性能异构芯片管理，高性能任务运行管理等能力。