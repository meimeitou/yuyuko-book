+++
title = "Istio vs Linkerd2"
date =  2021-05-25T11:31:33+08:00
description= "对比istion 和 linkerd2"
weight = 5
+++

# service mesh Istio vs Linkerd2 ?

功能：
服务网格负责在您的平台上运行的应用程序的网络功能。为服务提供：流量管理、安全和可观察性等。

结构：
它们将管理集群级数据路径的“控制平面”与指将数据从一个接口转发到另一个接口的功能和过程的“数据平面”分离开来。使用集中式的管理中心，数据平面都采用sidecar的部署方式；

## Traffic Management

Istio比linkd拥有更多的流量管理特性，包括断路器、故障注入、重试、超时、路由规则、虚拟服务器、负载均衡等。Linkerd有一个追赶Istio产品的路线图。

## Security

产品都对证书轮换和外部根证书支持提供了良好的基础支持，但Istio在安全特性方面更胜一筹。

Linkerd不支持TCP mTLS。

Istio在策略管理方面尤其强大，因为它允许不同的提供者将他们的产品集成到“模板”策略管理框架中，并且它允许管理员设置规则，以确定哪些应用程序可以相互通信。

## Observability

Linkerd提供了Grafana的开箱即用仪表盘，提供服务见解，而Istio与Kiali紧密集成。Kiali是一款专为Istio设计的可观察性工具，可以生成指标，推断网络拓扑，并与Grafana集成以获得更高级的查询功能。

Istio仅与Jaeger、Zipkin和Solarwinds的追踪后端兼容。从2.6版(2019年10月发布)开始，Linkerd还支持任何遵循OpenCensus标准的提供商。

## Maintainability

 Istio被认为特别难以安装和操作。该项目试图通过放弃其微服务体系结构而采用单一方法来解决这一问题。

 Linkerd被认为是最容易配置和操作的。

 ## Performance

 在性能方面，Istio的表现不如其他两个服务网格。这并不奇怪，因为Istio的复杂策略管理组件和集成可能会影响网络性能。

 