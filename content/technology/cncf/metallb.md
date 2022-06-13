+++
title = "Metallb"
date =  2021-03-29T12:07:33+08:00
description= "description"
weight = 5
+++

# 基本信息

https://metallb.universe.tf/concepts/

MetalLB hooks into your Kubernetes cluster, and provides a network load-balancer implementation. 


# 安装

1、ipvs模式配置修改：

```shell
kubectl edit configmap -n kube-system kube-proxy
```

```yaml
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
ipvs:
  strictARP: true
```

2、安装

需要文件：

- namespace.yaml
- metallb.yaml
- secret.yaml

其中namespace.yaml 和 metallb.yaml可以在github上找到

https://github.com/metallb/metallb/tree/main/manifests

secret.yaml需要自己创建

```shell
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.6/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.6/manifests/metallb.yaml
# On first install only
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
```

注意：

calico 和 matallb中的`speaker`冲突，修改文件



1、node asnumber,routeReflectorClusterID

2、