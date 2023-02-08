+++
title = "Kubebuilder"
date =  2022-11-08T11:12:40+08:00
description= "description"
weight = 5
+++

- [kubebuilder的基础：controller](#kubebuilder的基础controller)
- [kubebuilder的封装](#kubebuilder的封装)
- [开发](#开发)
  - [安装](#安装)
  - [开始一个项目](#开始一个项目)

## kubebuilder的基础：controller

过程包含8个步骤：

1. Reflector通过ListAndWatch方法去监听指定的Object；

```golang
func (r *Reflector) Run(stopCh <-chan struct{}) {
    klog.V(3).Infof("Starting reflector %v (%s) from %s", r.expectedTypeName, r.resyncPeriod, r.name)
    wait.Until(func() {
        if err := r.ListAndWatch(stopCh); err != nil {
            utilruntime.HandleError(err)
        }
    }, r.period, stopCh)
}
```

2. Reflector会将所监听到的event，包括对object的Add，Update，Delete的操作push到DeltaFIFO这个queue中；
3. Informer首先会解析event中的action和object；
4. Informer将解析的object更新到local store，也就是本地cache中的数据更新；
5. 然后Informer会执行Controller在初始化Infromer时注册的ResourceEventHandler(这些callback是可以自己修改的)；
6. ResourceEventHandler中注册的callback会将对应变化的object的key存入其初始化的一个workQueue；
7. 最终controller会循环进行reconcile，就是从workQueue不停地pop key，然后去local store中取到对应的object，然后进行处理，最终多数情况会再通过client去更新这个object。

## kubebuilder的封装

kubebuilder实际上是提供了对client-go进行封装的library（准确来说是runtime-controller），更加便利我们来开发k8s的operator。

kubebuilder还帮我们做了以下的额外工作：

1. kubebuilder引入了manager这个概念，一个manager可以管理多个controller，而这些controller会共享manager的client；
2. 如果manager挂掉或者停止了，所有的controller也会随之停止；
3. kubebuilder使用一个map[GroupVersionKind]informer来管理这些controller，所以每个controller还是拥有其独立的workQueue，deltaFIFO，并且kubebuilder也已经帮我们实现了这部分代码；
4. 我们主要需要做的开发，就是写Reconcile中的逻辑。

## 开发

git项目： https://github.com/kubernetes-sigs/kubebuilder

### 安装

```shell
# 到github release下载对应版本
curl -L -o kubebuilder "https://github.com/kubernetes-sigs/kubebuilder/releases/download/v3.6.0/kubebuilder_darwin_amd64"
chmod +x kubebuilder && mv kubebuilder /usr/local/bin/
```

### 开始一个项目

```shell
# create a project directory, and then run the init command.
mkdir project
cd project
# we'll use a domain of tutorial.kubebuilder.io,
# so all API groups will be <group>.tutorial.kubebuilder.io.
kubebuilder init --domain tutorial.kubebuilder.io --repo tutorial.kubebuilder.io/project
```

