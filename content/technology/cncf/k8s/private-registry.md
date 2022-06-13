+++
title = "私有镜像仓库"
date =  2021-02-25T15:41:28+08:00
description= "镜像拉取私有镜像仓库"
weight = 1
+++


## 1、创建

```shell
SERVER=xx.xx
USER=xx
EMAIL=772006843@qq.com
PW=xxxxxxxx

kubectl create secret docker-registry regcred \
  --docker-server=$SERVER \
  --docker-username=$USER \
  --docker-password=$PW \
  --docker-email=$EMAIL
```

或者从文件创建：

```shell
kubectl create secret generic regcred --from-file=.dockerconfigjson=~/.docker/config.json --type=kubernetes.io/dockerconfigjson
```

查看：

```shell
kubectl get secret regcred --output=yaml
```


## 2、应用

添加secret到serviceaccount:

```shell
kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "regcred"}]}'
```

添加到默认的`sa`后整个namespace将默认有拉取权限，`pod`默认使用`sa` 是`default`


针对单个pod也能添加：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: private-reg
spec:
  containers:
  - name: private-reg-container
    image: <your-private-image>
  imagePullSecrets:
  - name: regcred
```
