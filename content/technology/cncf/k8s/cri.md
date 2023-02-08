+++
title = "容器运行时(CRI)"
date =  2022-11-07T16:18:43+08:00
description= "description"
weight = 5
+++

- [CRI 架构](#cri-架构)
- [启用 CRI](#启用-cri)
- [CRI 接口](#cri-接口)
- [当前支持的 CRI 后端](#当前支持的-cri-后端)
- [OCI规范](#oci规范)
  - [OSContainerRuntime](#oscontainerruntime)
  - [HyperRuntime](#hyperruntime)
  - [UnikernelRuntime](#unikernelruntime)
- [runtime对比](#runtime对比)
  - [docker](#docker)
  - [containerd](#containerd)
  - [cri-o](#cri-o)
  - [rkt](#rkt)
  - [fraki](#fraki)
  - [PouchContainer](#pouchcontainer)
  - [如何选择容器运行时](#如何选择容器运行时)
- [k8s 支持多个runtime](#k8s-支持多个runtime)

容器运行时接口（Container Runtime Interface），简称 CRI。CRI 中定义了 容器 和 镜像 的服务的接口，因为容器运行时与镜像的生命周期是彼此隔离的，因此需要定义两个服务。该接口使用 Protocol Buffer，基于 gRPC，在 Kubernetes v1.10 + 版本中是在 pkg/kubelet/apis/cri/runtime/v1alpha2 的 api.proto 中定义的。

下图是docker,k8s,oci,cri-o,containerd,runc的关系图：

ref: https://www.tutorialworks.com/difference-docker-containerd-runc-crio-oci/

![cri](../images/container-ecosystem.drawio.png)


## CRI 架构

Container Runtime 实现了 CRI gRPC Server，包括 RuntimeService 和 ImageService。该 gRPC Server 需要监听本地的 Unix socket，而 kubelet 则作为 gRPC Client 运行。

protocol buffers API包含了两个gRPC服务：ImageService和RuntimeService。ImageService提供了从镜像仓库拉取、查看、和移除镜像的RPC。RuntimeSerivce包含了Pods和容器生命周期管理的RPC，以及跟容器交互的调用(exec/attach/port-forward)。一个单块的容器运行时能够管理镜像和容器（例如：Docker和Rkt），并且通过同一个套接字同时提供这两种服务。这个套接字可以在Kubelet里通过标识–container-runtime-endpoint和–image-service-endpoint进行设置。

## 启用 CRI

除非集成了 rktnetes，否则 CRI 都是被默认启用了，从 Kubernetes 1.7 版本开始，旧的预集成的 docker CRI 已经被移除。

要想启用 CRI 只需要在 kubelet 的启动参数重传入此参数：--container-runtime-endpoint 远程运行时服务的端点。当前 Linux 上支持 unix socket，windows 上支持 tcp。例如：unix:///var/run/dockershim.sock、 tcp://localhost:373，默认是 unix:///var/run/dockershim.sock，即默认使用本地的 docker 作为容器运行时。

## CRI 接口

Kubernetes 1.9 中的 CRI 接口在 api.proto 中的定义如下：

```golang
service RuntimeService {
    // Version returns the runtime name, runtime version, and runtime API version.
    rpc Version (VersionRequest) returns (VersionResponse) {}

    // RunPodSandbox creates and starts a pod-level sandbox. Runtimes must ensure
    //the sandbox is in the ready state on success.
    rpc RunPodSandbox (RunPodSandboxRequest) returns (RunPodSandboxResponse) {}
    // StopPodSandbox stops any running process that is part of the sandbox and
    //reclaims network resources (e.g., IP addresses) allocated to the sandbox.
    // If there are any running containers in the sandbox, they must be forcibly
    //terminated.
    // This call is idempotent, and must not return an error if all relevant
    //resources have already been reclaimed. kubelet will call StopPodSandbox
    //at least once before calling RemovePodSandbox. It will also attempt to
    //reclaim resources eagerly, as soon as a sandbox is not needed. Hence,
    //multiple StopPodSandbox calls are expected.
    rpc StopPodSandbox (StopPodSandboxReq
    ...
}

// ImageService defines the public APIs for managing images.
service ImageService {
    // ListImages lists existing images.
    rpc ListImages (ListImagesRequest) returns (ListImagesResponse) {}
    // ImageStatus returns the status of the image. If the image is not
    //present, returns a response with ImageStatusResponse.Image set to
    //nil.
    rpc ImageStatus (ImageStatusRequest) returns (ImageStatusResponse) {}
    // PullImage pulls an image with authentication config.
    rpc PullImage (PullImageRequest) returns (PullImageResponse) {}
    // RemoveImage removes the image.
    // This call is idempotent, and must not return an error if the image has
    //already been removed.
    rpc RemoveImage (RemoveImageRequest) returns (RemoveImageResponse) {}
    // ImageFSInfo returns information of the filesystem that is used to store images.
    rpc ImageFsInfo (ImageFsInfoRequest) returns (ImageFsInfoResponse) {}}
```

这其中包含了两个 gRPC 服务：

RuntimeService：容器和 Sandbox 运行时管理。
ImageService：提供了从镜像仓库拉取、查看、和移除镜像的 RPC。

## 当前支持的 CRI 后端

目前支持 CRI 的后端有：

- cri-o：cri-o 是 Kubernetes 的 CRI 标准的实现，并且允许 Kubernetes 间接使用 OCI 兼容的容器运行时，可以把 cri-o 看成 Kubernetes 使用 OCI 兼容的容器运行时的中间层。(runc)
- containerd：基于 Containerd 的 Kubernetes CRI 实现 (runc)
- rkt：由 CoreOS 主推的用来跟 docker 抗衡的容器运行时
- frakti：基于 hypervisor 的 CRI (runv)
- docker：Kuberentes 最初就开始支持的容器运行时，目前还没完全从 kubelet 中解耦，Docker 公司同时推广了 OCI 标准 (runc)
- pouch: 阿里的容器,基于hypervisor容器技术强隔离,p2p镜像分发，富容器技术。

CRI 是由 SIG-Node 来维护的。


通过 CRI-O 间接支持 CRI 的后端.

当前同样存在一些只实现了 OCI 标准的容器，但是它们可以通过 CRI-O 来作为 Kubernetes 的容器运行时。CRI-O 是 Kubernetes 的 CRI 标准的实现，并且允许 Kubernetes 间接使用 OCI 兼容的容器运行时。

- Clear Containers：由 Intel 推出的兼容 OCI 容器运行时，可以通过 CRI-O 来兼容 CRI。
- Kata Containers：符合 OCI 规范，可以通过 CRI-O 或 Containerd CRI Plugin 来兼容 CRI。
- gVisor：由谷歌推出的容器运行时沙箱 (Experimental)，可以通过 CRI-O 来兼容 CRI。


## OCI规范

OCI规范（Open Container Initiative 开放容器标准），该规范包含两部分内容：容器运行时标准（runtime spec）、容器镜像标准（image spec）

OCI项目及兼容OCI规范的容器运行时：
- runc: 基于namespace,cgroup,seccomp&MAC技术实现的进程资源隔离
- runv: 基于Hypervisor，兼容OCI规范的虚拟机运行时
- kata-runtime:  from the `Katacontainers` project，它将OCI规范实现为单个轻量级虚拟机(硬件虚拟化)
- gVisor: Google推出的新运行时，比vm更轻量化，在sandbox中运行的虚拟内核，与vm有同样的强隔离性。但带来了额外的系统调用消耗

按照底层容器运行环境依托的技术分类，我们将容器运行时分为以下三类：

- OSContainerRuntime（基于进程隔离技术）
- HyperRuntime（基于Hypervisor技术）
- UnikernelRuntime（基于unikernel）

### OSContainerRuntime

OSContainerRuntime下的Linux Container共享Linux内核，使用namespace、cgroup等技术隔离进程资源。namespace只包含了六项隔离（UTS、IPC、PID、Network、Mount、User），并非所有Linux资源都可以通过这些机制控制，比如时间和Keyring，另外，容器内的应用程序和常规应用程序使用相同的方式访问系统资源，直接对主机内核进行系统调用。因此即使有了很多限制，内核仍然向恶意程序暴露过多的攻击面。
### HyperRuntime

HyperRuntime下的VM Container容器各自拥有独立Linux内核，资源隔离比Linux Container更彻底。但并不是说使用VM容器用户就可以高枕无忧，只是VM容器的攻击面比Linux容器小了很多，黑客要逃逸到宿主机就只剩下Hypervisor这个入口，所以说没有绝对的安全，相对来说VM容器更安全。另一方面，VM容器的性能比不上Linux容器，因为Hypervisor这一层带来的性能损耗，在Linux容器这边是不存在的。

### UnikernelRuntime

UnikernelRuntime下的容器同VM Container一样有着安全级别很高的运行环境，同样是使用Hypervisor技术进行容器隔离。简单来说Unikernel是一个运行在Hypervisor之上的libOS系统，而libOS是由应用程序和libraries一起构建出的操作系统。

unikernel的特点如下：性能好，应用程序和内核在同一地址空间，消除了用户态和内核态转换以及数据复制带来的开销。更精简的内核，去掉了多余的驱动、依赖包、服务等，最终打包镜像更小，启动速度更快。完全不可调试，在生产环境中如果遇到问题，只能依赖于收集到的日志进行排查，要不就是重启容器，原先熟悉的Linux排查方法和工具完全派不上用场。

目前实现了CRI的主流项目有：docker、containerd、CRI-O、Frakti、pouch，它们衔接Kubelet与运行时方式对比如下：

![cri](../images/cri.jpg)


## runtime对比

### docker

  最早原生支持的运行时，目前由于发展原因弃用。Kubernetes 只能与 CRI 通信，因此要与 Docker 通信，就必须使用桥接服务。因为docekr其实没有实现cri标准接口，是由一个叫做`Dockershim`的组件来做桥梁代理的。新版已经丢弃这个组件。
  
  目前也可以使用`cri-dockerd`来继续使用docker engine作为后端。
### containerd
  
  Containerd项目是从早期的docker源码中提炼出来的，它使用CRI插件来向kubelet提供CRI接口服务。同时它也是docekr的runtime。

  组件由`Doekr`组织提供支持。
### cri-o

  CRI-O完整实现CRI接口功能，并且严格兼容OCI标准，CRI-O比Containerd更专注，它只服务于Kubernetes（而Containerd除支持Kubernetes CRI，还可用于Docker Swarm），从官网上我们可以了解到CRI-O项目的功能边界：

  组件由`Red Hat`组织提供支持。
### rkt
   当前可能有部分不兼容cri，略。
### fraki

   基于hypervisor虚拟机管理程序的容器运行时。具有更高的安全性，内核独立，混合运行。
### PouchContainer

   PouchContainer是阿里开源的容器引擎，它内部有一个CRI协议层和cri-manager模块，用于实现CRI shim功能。它的技术优势包括：
   1. 强隔离，包括的安全特性：基于Hypervisor的容器技术、lxcfs、目录磁盘配额、补丁Linux内核等。
   2. 基于P2P镜像分发，利用P2P技术在各节点间互传镜像，减小镜像仓库的下载压力，加快镜像下载速度。
   3. 富容器技术，PouchContainer的容器中除了运行业务应用本身之外，还有运维套件、系统服务、systemd进程管家等。

### 如何选择容器运行时

首先对比Containerd和CRI-O调用runc的方式，runc代码内置在Containerd内部，通过函数调用；

CRI-O是通过linux命令方式调用runc二进制文件，显然前者属于进程内的函数调用，在性能上Containerd更具优势。

其次对比runc和runv，这是两种完全不同的容器技术，runc创建的容器进程直接运行在宿主机内核上，而runv是运行在由Hypervisor虚拟出来的虚拟机上，后者占用的资源更多、启动速度慢，而且runv容器在调用底层硬件时（如CPU），中间多了一层虚拟硬件层，计算效率上不如runc容器。

- Containerd+runc: 安全中，性能开销低
- CRI-O: 安全中，性能开销中
- Frakti+runv: 安全高，性能开销高

## k8s 支持多个runtime

为什么要支持多运行时呢？举个例子，有一个开放的云平台向外部用户提供容器服务，平台上运行有两种容器，一种是云平台管理用的容器（可信的），一种是用户部署的业务容器（不可信）。在这种场景下，我们希望使用runc运行可信容器（弱隔离但性能好），用runv运行不可信容器（强隔离安全性好）。面对这种需求，Kubernetes也给出了解决方案（使用API对象RuntimeClass支持多运行时）。

Kubelet从apiserver接收到的Pod Spec，如果Pod Spec中使用runtimeClassName指定了容器运行时，则在调用CRI接口的RunPodSandbox()函数时，会将runtimeClassName信息传递给CRI shim，然后CRI shim根据runtimeClassName去调用对应的容器运行时，为Pod创建一个隔离的运行环境。

RuntimeClass配置Kubernetes在v1.12中增加了RuntimeClass这个新API对象来支持多运行时（目的就是在一个woker节点上运行多种运行时）。在Kubernetes中启用RuntimeClass时需要注意，尽量保持当前Kubernetes集群中的节点在容器运行时方面的配置都是同构的，如果是异构的，那么需要借助node Affinity等功能来调度Pod到已部署有匹配容器运行时的节点。
