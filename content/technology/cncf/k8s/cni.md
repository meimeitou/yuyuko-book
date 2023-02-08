+++
title = "容器网络接口(CNI)"
date =  2022-11-07T18:05:32+08:00
description= "description"
weight = 5
+++

- [功能定义](#功能定义)
- [Veth设备](#veth设备)
- [接口定义](#接口定义)
- [CNI 插件](#cni-插件)
  - [Flannel](#flannel)
    - [UDP 模式](#udp-模式)
    - [VxLAN 模式](#vxlan-模式)
    - [host-gw模式](#host-gw模式)
  - [Weave Net](#weave-net)
  - [Calico](#calico)
  - [cilium](#cilium)
    - [XDP](#xdp)
    - [TC](#tc)

容器网络接口（Container Network Interface），简称 CNI，是 CNCF 旗下的一个项目，由一组用于配置 Linux 容器的网络接口的规范和库组成，同时还包含了一些插件。CNI 仅关心容器创建时的网络分配，和当容器被删除时释放网络资源。有关详情请查看 GitHub。

Kubernetes 源码的 vendor/github.com/containernetworking/cni/libcni 目录中已经包含了 CNI 的代码，也就是说 Kubernetes 中已经内置了 CNI。

## 功能定义

CNI基本思想为：Container Runtime在创建容器时，先创建好network namespace，然后调用CNI插件为这个netns配置网络，其后再启动容器内的进程。

CNI插件包括两部分：

- CNI Plugin负责给容器配置网络，它包括两个基本的接口
  - 配置网络: AddNetwork(net NetworkConfig, rt RuntimeConf) (types.Result, error)
  - 清理网络: DelNetwork(net NetworkConfig, rt RuntimeConf) error
- IPAM Plugin负责给容器分配IP地址，主要实现包括host-local和dhcp。

Kubernetes Pod 中的其他容器都是Pod所属pause容器的网络，创建过程为：

当kubelet通过调用CRI的RunPodSandbox创建好PodSandbox，即infra容器后，就需要调用SetUpPod方法为Pod（infra容器）创建网络环境，底层是调用CNI的AddNetwork为infra容器配置网络环境。

这个配置网络环境的过程，就是kubelet从cni配置文件目录（--cni-conf-dir参数指定）中读取文件，并使用该文件中的CNI配置配置infra网络。kubelet根据配置文件，需要使用CNI插件二进制文件（存放在--cni-bin-dir参数指定的目录下）实际配置infra网络。

1. kubelet 先创建pause容器生成network namespace
2. 调用网络CNI driver
3. CNI driver 根据配置调用具体的cni 插件
4. cni 插件给pause 容器配置网络
5. pod 中其他的容器都使用 pause 容器的网络

## Veth设备
这个被隔离的容器进程，要跟其他Network Namespace里的容器进程、甚至宿主机进行交互，需要一个联通到宿主机的连线。通过创建Veth设备可以解决这个问题：

veth和其它的网络设备都一样，一端连接的是内核协议栈
veth设备是成对出现的，另一端两个设备彼此相连
一个设备收到协议栈的数据发送请求后，会将数据发送到另一个设备上去
基于以上几点，veth设备非常适合于作为连接不同Network Namespace的连线。
事实上，我们进入容器看到的网卡，其实就是veth设备的一端，它的另一端在宿主机的主network namespace上。要让容器或者pod具备独立的网络栈，基本上都是从这个veth设备入手进行考虑，在宿主机上添加各种路由策略、网桥等，使容器流量去往正确的方向。

## 接口定义

```golang
type CNI interface {
    AddNetworkList (net *NetworkConfigList, rt *RuntimeConf) (types.Result, error)
    DelNetworkList (net *NetworkConfigList, rt *RuntimeConf) error
    AddNetwork (net *NetworkConfig, rt *RuntimeConf) (types.Result, error)
    DelNetwork (net *NetworkConfig, rt *RuntimeConf) error
}
```
该接口只有四个方法，添加网络、删除网络、添加网络列表、删除网络列表。


## CNI 插件

CNI 插件必须实现一个可执行文件，这个文件可以被容器管理系统（例如 rkt 或 Kubernetes）调用。

CNI 插件负责将网络接口插入容器网络命名空间（例如，veth 对的一端），并在主机上进行任何必要的改变（例如将 veth 的另一端连接到网桥）。然后将 IP 分配给接口，并通过调用适当的 IPAM 插件来设置与 “IP 地址管理” 部分一致的路由。

所有CNI插件均支持通过环境变量和标准输入传入参数。

常见的插件有：

- flannel
- cni-Genie
- calico
- cilium
- Bridge
- Weave
- kube-ovn
- kube-router

### Flannel

Flannel通过给每台宿主机分配一个子网的方式为容器提供虚拟网络，它基于Linux TUN/TAP，使用UDP封装IP包来创建overlay网络，并借助etcd维护网络的分配情况。

Flannel会在每一个宿主机上运行名为 flanneld 代理，其负责为宿主机预先分配一个子网，并为 Pod 分配IP地址。Flannel 使用Kubernetes 或 etcd 来存储网络配置、分配的子网和主机公共IP等信息。数据包则通过 VXLAN、UDP 或 host-gw 这些类型的后端机制进行转发。

Flannel 规定宿主机下各个Pod属于同一个子网，不同宿主机下的Pod属于不同的子网。

支持3种实现：UDP、VxLAN、host-gw，

- UDP 模式：使用设备 flannel.0 进行封包解包，不是内核原生支持，频繁地内核态用户态切换，性能非常差；
- VxLAN 模式：使用 flannel.1 进行封包解包，内核原生支持，性能较强；
- host-gw 模式：无需 flannel.1 这样的中间设备，直接宿主机当作子网的下一跳地址，性能最强；

#### UDP 模式
  模式已经不推荐使用，性能差。

#### VxLAN 模式
  
VxLAN，即Virtual Extensible LAN（虚拟可扩展局域网），是Linux本身支持的一网种网络虚拟化技术。VxLAN可以完全在内核态实现封装和解封装工作，从而通过“隧道”机制，构建出 Overlay 网络（Overlay Network）

VxLAN的设计思想是： 在现有的三层网络之上，“覆盖”一层虚拟的、由内核VxLAN模块负责维护的二层网络，使得连接在这个VxLAN二层网络上的“主机”（虚拟机或容器都可以），可以像在同一个局域网（LAN）里那样自由通信。 为了能够在二层网络上打通“隧道”，VxLAN会在宿主机上设置一个特殊的网络设备作为“隧道”的两端，叫VTEP：VxLAN Tunnel End Point（虚拟隧道端点）

#### host-gw模式

Flannel 第三种协议叫 host-gw (host gateway)，这是一种纯三层网络的方案，性能最高，即 Node 节点把自己的网络接口当做 pod 的网关使用，从而使不同节点上的 node 进行通信，这个性能比 VxLAN 高，因为它没有额外开销。不过他有个缺点， 就是各 node 节点必须在同一个网段中 。

### Weave Net

Weave Net是一个多主机容器网络方案，支持去中心化的控制平面，各个host上的wRouter间通过建立Full Mesh的TCP链接，并通过Gossip来同步控制信息。这种方式省去了集中式的K/V Store，能够在一定程度上减低部署的复杂性，Weave将其称为“data centric”，而非RAFT或者Paxos的“algorithm centric”。

基于UDP封装，也可以加密，同Flannel的udp模式。

### Calico

Calico 是一个基于BGP的纯三层的数据中心网络方案（不需要Overlay），并且与OpenStack、Kubernetes、AWS、GCE等IaaS和容器平台都有良好的集成。

Calico在每一个计算节点利用Linux Kernel实现了一个高效的vRouter(路由器)来负责数据转发，而每个vRouter通过BGP协议负责把自己上运行的workload的路由信息像整个Calico网络内传播——小规模部署可以直接互联，大规模下可通过指定的BGP route reflector来完成。 这样保证最终所有的workload之间的数据流量都是通过IP路由的方式完成互联的。Calico节点组网可以直接利用数据中心的网络结构（无论是L2或者L3），不需要额外的NAT，隧道或者Overlay Network。

此外，Calico基于iptables还提供了丰富而灵活的网络Policy，保证通过各个节点上的ACLs来提供Workload的多租户隔离、安全组以及其他可达性限制等功能。

基于bird 做BGP。

Calico网络方式:
- IPIP: 从字面来理解，就是把一个IP数据包又套在一个IP包里，即把 IP 层封装到 IP 层的一个 tunnel。 针对一些跨网络段的网络联通。
- BGP: 三层IP连接，没有额外开销。

当容器创建时，calico为容器生成veth pair，一端作为容器网卡加入到容器的网络命名空间，并设置IP和掩码，一端直接暴露在宿主机上，并通过设置路由规则，将容器IP暴露到宿主机的通信路由上。于此同时，calico为每个主机分配了一段子网作为容器可分配的IP范围，这样就可以根据子网的CIDR为每个主机生成比较固定的路由规则。

### cilium

Cilium是一个基于eBPF和XDP的高性能容器网络方案，提供了CNI和CNM插件。

BPF 是 Linux 内核中一个非常灵活与高效的类虚拟机（virtual machine-like）组件， 能够在许多内核 hook 点安全地执行字节码（bytecode ）。很多 内核子系统都已经使用了 BPF，例如常见的网络（networking）、跟踪（ tracing）与安全（security ，例如沙盒）。

BPF 不仅仅是一个指令集，它还提供了围绕自身的一些基础设施，例如：

- BPF map：高效的 key/value 存储
- 辅助函数（helper function）：可以更方便地利用内核功能或与内核交互
- 尾调用（tail call）：高效地调用其他 BPF 程序
- 安全加固原语（security hardening primitives）
- 用于 pin/unpin 对象（例如 map、程序）的伪文件系统（bpffs），实现持久存储
- 支持 BPF offload（例如 offload 到网卡）的基础设施

Cilium功能实现主要基于XDP和TC两个挂载点。

#### XDP

XDP（eXpress Data Path）提供了一个内核态、高性能、可编程 BPF 包处理框架（a framework for BPF that enables high-performance programmable packet processing in the Linux kernel）。这个框架在软件中最早可以处理包的位置（即网卡驱动收到包的 时刻）运行 BPF 程序。

XDP hook 位于网络驱动的快速路径上，XDP 程序直接从接收缓冲区（receive ring）中将 包拿下来，无需执行任何耗时的操作，例如分配 skb 然后将包推送到网络协议栈，或者 将包推送给 GRO 引擎等等。因此，只要有 CPU 资源，XDP BPF 程序就能够在最早的位置执 行处理。

使用案例：
- DDos防御，防火墙
- 转发和负载均衡
- 栈前（Pre-stack）过滤/处理
- 流抽样（Flow sampling）和监控

#### TC

tc BPF 的输入上下文（input context）是一个 sk_buff 而不是 xdp_buff。tc在内核协议栈早期，当内核 协议栈收到一个包时（说明包通过了 XDP 层），它会分配一个缓冲区，解析包，并存储包 的元数据。表示这个包的结构体就是 sk_buff。
tc BPF 程序在数据路径上的 ingress 和 egress 点都可以触发；而 XDP BPF 程序 只能在 ingress 点触发。

内核两个 hook 点：

- ingress hook sch_handle_ingress()：由 __netif_receive_skb_core() 触发
- egress hook sch_handle_egress()：由 __dev_queue_xmit() 触发

tc BPF 使用案例:
- 为容器落实策略（Policy enforcement）
- 转发和负载均衡
- 流抽样（Flow sampling）、监控
- 包调度器预处理（Packet scheduler pre-processing）