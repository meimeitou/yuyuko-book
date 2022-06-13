+++
title = "Go Mod"
date =  2021-03-04T18:17:17+08:00
description= "go mod"
weight = 5
+++

1、代理设置

```shell
go env -w GOPROXY=https://goproxy.cn,direct
```

取消

```shell
go env -w GOPROXY=
```

GOPRIVATE 设置跳过私有库

```shell
go env -w GOPRIVATE=*.gitlab.com,*.gitee.com
```
