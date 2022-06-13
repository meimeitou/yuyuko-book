## 机器登陆

1. ssh连接10.186.108.27
2. 跳转连接 ssh 10.186.127.9 
3. 然后跳转到部署机器

10.209.145.50 master节点
10.209.145.51 node节点

所有机器密码： !QAZ@WSX#EDC4rfv5tgb

## 应用状态查看

```shell
# 查看集群机器状态，全部ready为正常
kubectl get node 
# 查看系统基础组件状态, 全部running为正常
kubectl get po -n kube-system
# 查看dns产品状态,全部running为正常
kubectl get po -n default
```

## 报错信息查看

主要分三种：

1. 物理机问题
如果 `kubectl get node `有机器Notready
需要登录到机器上去查看日志：

```shell
# 如果是master节点
journalctl -f -u k3s
# 如果是node节点
journalctl -f -u k3s-agent
```

打印日志并查看报错信息。

2. 系统组件问题

首先是使用`kubectl get po -n kube-system`查看到有pod 不是running状态。

```shell
# <pod name> 是上面查看命令输出的第一个字段
kubectl logs -f -n kube-system <pod name>
```

打印日志并查看报错信息。

```shell
# 尝试重启应用
kubectl delete po -n kube-system <pod name>
```

3. dns产品问题

使用 `kubectl get po -n default`获取到dns产品应用的状态 不是running状态。
```shell
# <pod name> 是上面查看命令输出的第一个字段
kubectl logs -f -n default <pod name>
```
打印日志并查看报错信息。

```shell
# 尝试重启应用
kubectl delete po -n default <pod name>
```

## 处理

先尝试重启应用，如果不能解决，再call人。