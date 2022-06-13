+++
title = "Istio Install"
date =  2021-06-09T09:32:57+08:00
description= "description"
weight = 5
+++

# install

1、从 `https://github.com/istio/istio/releases`下载对于版本

如： istio-1.10.0-linux-amd64.tar.gz

2、解压 istio-1.10.0-linux-amd64.tar.gz
得到：
- 二级制istioctl文件
- samples 测试项目安装文件
- manifests helm文件

3、使用istioctl安装

使用特定的profile安装：不同的profile组件和安装参数不同；
```shell
# 使用default安装
istioctl install --set profile=default
# 使用自定义的profile
istioctl install -f my-config.yaml
# profile 列表
istioctl profile list
# 获取配置
istioctl profile dump demo
# 比对
istioctl profile diff default demo
```

4、卸载

```shell
istioctl x uninstall --purge
# or
istioctl x uninstall <your original installation options>
```

## 补充

1、profile文件中的value字段为helm中的value定义，详细可以查看manifests文件
2、ingress secret有需要的话需要手动创建，用于对外代理证书
