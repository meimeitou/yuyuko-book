+++
title = "容器存储接口(CSI)"
date =  2022-11-07T18:12:10+08:00
description= "description"
weight = 5
+++

- [组件介绍](#组件介绍)
- [原理](#原理)
  - [Custom Components](#custom-components)
  - [External Components](#external-components)
- [使用](#使用)
  - [动态配置](#动态配置)
  - [预配置 Volume](#预配置-volume)
- [CSI 驱动](#csi-驱动)

容器存储接口（Container Storage Interface），简称 CSI，CSI 试图建立一个行业标准接口的规范，借助 CSI 容器编排系统（CO）可以将任意存储系统暴露给自己的容器工作负载。于 v1.13 版本正式 GA。

ref:
- https://developer.aliyun.com/article/754434
- https://developer.aliyun.com/article/783464

## 组件介绍

- PV Controller：负责 PV/PVC 绑定及周期管理，根据需求进行数据卷的 Provision/Delete 操作；
- AD Controller：负责数据卷的 Attach/Detach 操作，将设备挂接到目标节点；
- Kubelet：Kubelet 是在每个 Node 节点上运行的主要 “节点代理”，功能是 Pod 生命周期管理、容器健康检查、容器监控等；
- Volume Manager：Kubelet 中的组件，负责管理数据卷的 Mount/Umount 操作（也负责数据卷的 Attach/Detach 操作，需配置 kubelet 相关参数开启该特性）、卷设备的格式化等等；
- Volume Plugins：存储插件，由存储供应商开发，目的在于扩展各种存储类型的卷管理能力，实现第三方存储的各种操作能力，即是上面蓝色操作的实现。Volume Plugins 有 in-tree 和 out-of-tree 两种；
- External Provioner：External Provioner 是一种 sidecar 容器，作用是调用 Volume Plugins 中的 CreateVolume 和 DeleteVolume 函数来执行 Provision/Delete 操作。因为 K8s 的 PV 控制器无法直接调用 Volume Plugins 的相关函数，故由 External Provioner 通过 gRPC 来调用；
- External Attacher：External Attacher 是一种 sidecar 容器，作用是调用 Volume Plugins 中的 ControllerPublishVolume 和 ControllerUnpublishVolume 函数来执行 Attach/Detach 操作。因为 K8s 的 AD 控制器无法直接调用 Volume Plugins 的相关函数，故由 External Attacher 通过 gRPC 来调用。

## 原理

类似于 CRI，CSI 也是基于 gRPC 实现。详细的 CSI SPEC 可以参考 这里，它要求插件开发者要实现三个 gRPC 服务：

- Identity Service：用于 Kubernetes 与 CSI 插件协调版本信息
- Controller Service：用于创建、删除以及管理 Volume 存储卷
- Node Service：用于将 Volume 存储卷挂载到指定的目录中以便 Kubelet 创建容器时使用（需要监听在 /var/lib/kubelet/plugins/[SanitizedCSIDriverName]/csi.sock）

由于 CSI 监听在 unix socket 文件上， kube-controller-manager 并不能直接调用 CSI 插件。为了协调 Volume 生命周期的管理，并方便开发者实现 CSI 插件，Kubernetes 提供了几个 sidecar 容器并推荐使用下述方法来部署 CSI 插件：

![cri](../images/container-storage-interface_diagram1.png)


其中：

- 绿色部分：Identity、Node、Controller 是需要开发者自己实现的，被称为 Custom Components。
- 粉色部分：node-driver-registrar、external-attacher、external-provisioner 组件是 Kubernetes 团队开发和维护的，被称为 External Components，它们都是以 sidecar 的形式与 Custom Components 配合使用的。


**POD挂载pv流程如下：**

1. 用户创建了一个包含 PVC 的 Pod，该 PVC 要求使用动态存储卷；
2. Scheduler 根据 Pod 配置、节点状态、PV 配置等信息，把 Pod 调度到一个合适的 Worker 节点上；
3. PV 控制器 watch 到该 Pod 使用的 PVC 处于 Pending 状态，于是调用 Volume Plugin（in-tree）创建存储卷，并创建 PV 对象（out-of-tree 由 External Provisioner 来处理）；
4. AD 控制器发现 Pod 和 PVC 处于待挂接状态，于是调用 Volume Plugin 挂接存储设备到目标 Worker 节点上(AD 控制器会调用内部 in-tree CSI 插件（csiAttacher）的 Attach 函数。内部 in-tree CSI 插件（csiAttacher）会创建一个 VolumeAttachment 对象到集群中，External Attacher 观察到该 VolumeAttachment 对象，并调用外部 CSI插件的ControllerPublish 函数以将卷挂接到对应节点上。外部 CSI 插件挂载成功后，External Attacher会更新相关 VolumeAttachment 对象的 .Status.Attached 为 true。)
5. 在 Worker 节点上，Kubelet 中的 Volume Manager 等待存储设备挂接完成，并通过 Volume Plugin 将设备挂载到全局目录：**/var/lib/kubelet/pods/[pod uid]/volumes/kubernetes.io~iscsi/[PV
name]**（以 iscsi 为例）；
6. Kubelet 通过 Docker 启动 Pod 的 Containers，用 bind mount 方式将已挂载到本地全局目录的卷映射到容器中。

### Custom Components

由第三方实现的 Custom Components 本质是3个 gRPC Services：

- Identity Service: 主要用于对外暴露这个插件本身的信息，比如驱动的名称、驱动的能力
- Controller Service: 主要定义一些无需在宿主机上执行的操作，这也是与下文的 Node Service 最根本的区别。以 CreateVolume 为例，k8s 通过调用该方法创建底层存储。比如底层使用了某云供应商的云硬盘服务，开发者在 CreateVolume 方法实现中应该调用云硬盘服务的创建/订购云硬盘的 API，调用 API 这个操作是不需要在特定宿主机上执行的。
- Node Service: 定义了需要在宿主机上执行的操作，比如：mount、unmount。在前面的部署架构图中，Node Service 使用 Daemonset 的方式部署，也是为了确保 Node Service 会被运行在每个节点，以便执行诸如 mount 之类的指令。

### External Components

External Components 都是以 sidecar 的方式提供使用的。当开发完三个 Custom Components 之后，开发者需要根据存储的特点，选择合适的 sidecar 容器注入到 Pod 中。这里的 External Components 除了前面图中提到的 node-driver-registrar、external-attacher、external-provisioner 还有很多，可以参考官方文档，这里对常用的 sidecars 做一些简单介绍：


- livenessprobe: 监视 CSI 驱动程序的运行状况，并将其报告给 Kubernetes。这使得 Kubernetes 能够自动检测驱动程序的问题，并重新启动 pod 来尝试修复问题。
- node-driver-registrar: 从 CSI driver 获取驱动程序信息（通过 NodeGetInfo 方法），并使用 kubelet 插件注册机制在该节点上的 kubelet 中对其进行注册。
- external-provisioner: 对于块存储（如 ceph）非常关键。它监听 PersistentVolumeClaim 创建，调用 CSI 驱动的 CreateVolume 方法创建对应的底层存储（如 ceph image），一旦创建成功，provisioner 会创建一个 PersistentVolume 资源。当监听到 PersistentVolumeClaim 删除时，它会调用 CSI 的 DeleteVolume 方法删除底层存储，如果成功，则删除 PersistentVolume。
- external-attacher: 用于监听 Kubernetes VolumeAttachment 对象并触发 CSI 的 Controller[Publish|Unpublish]Volume 操作。
- external-resizer: 监听 PersistentVolumeClaim 资源修改，调用 CSI ControllerExpandVolume 方法，来调整 volume 的大小。

## 使用

### 动态配置

可以通过为 CSI 创建插件 StorageClass 来支持动态配置的 CSI Storage 插件启用自动创建/删除 。

例如，以下 StorageClass 允许通过名为 com.example.team/csi-driver 的 CSI Volume Plugin 动态创建 “fast-storage” Volume。

```yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: fast-storage
provisioner: com.example.team/csi-driver
parameters:
  type: pd-ssd
```

要触发动态配置，请创建一个 PersistentVolumeClaim 对象。例如，下面的 PersistentVolumeClaim 可以使用上面的 StorageClass 触发动态配置。

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-request-for-storage
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: fast-storage
```

### 预配置 Volume

您可以通过手动创建一个 PersistentVolume 对象来展示现有 Volumes，从而在 Kubernetes 中暴露预先存在的 Volume。例如，暴露属于 com.example.team/csi-driver 这个 CSI 插件的 existingVolumeName Volume：

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-manually-created-pv
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  csi:
    driver: com.example.team/csi-driver
    volumeHandle: existingVolumeName
    readOnly: false
```

## CSI 驱动

