+++
title = "Kube Proxy"
date =  2022-11-05T16:10:42+08:00
description= "description"
weight = 5
+++

https://cloudnative.to/blog/k8s-node-proxy/

说到kube-proxy，就不得不提到k8s中service，下面对它们两做简单说明：

- kube-proxy其实就是管理service的访问入口，包括集群内Pod到Service的访问和集群外访问service。
- kube-proxy管理sevice的Endpoints，该service对外暴露一个Virtual IP，也成为Cluster IP, 集群内通过访问这个Cluster IP:Port就能访问到集群内对应的serivce下的Pod。
- service是通过Selector选择的一组Pods的服务抽象，其实就是一个微服务，提供了服务的LB和反向代理的能力，而kube-proxy的主要作用就是负责service的实现。
- service另外一个重要作用是，一个服务后端的Pods可能会随着生存灭亡而发生IP的改变，service的出现，给服务提供了一个固定的IP，而无视后端Endpoint的变化。

Kube-proxy 是 kubernetes 工作节点上的一个网络代理组件，运行在每个节点上。Kube-proxy维护节点上的网络规则，实现了Kubernetes Service 概念的一部分 。它的作用是使发往 Service 的流量（通过ClusterIP和端口）负载均衡到正确的后端Pod。
