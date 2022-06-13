+++
title = "Opa Run"
date =  2021-05-21T14:33:20+08:00
description= "opa 命令"
weight = 8
+++

# opa使用

opa run是OPA实现的交互式运行（REPL）命令，本地学习或者调试会很方便

## run

启动一个空的交互环境：
```shell
./opa run
```

使用目录：
```shell
opa run quick-start
```
会导入目录下的文件到run环境中

主要有两类，所有quick-start目录下的

- 配置文件（.json|.yaml|.yml）
对应的父节点是`data`

- Rego文件(包括test文件) `.rego`文件
对应的父节点是`data.<package name>`


>这样配置文件都挂在data这个根节点下了，如果想加载配置文件时增加父节点（如data.example.file） 该怎么办？
 可以文件的路径映射前缀 opa run example.file:quick-start
 注意只会改变配置文件的父节点
 这一点很有用，以后讲bundle也会提到



当然也可以指定输入文件input。这个比较特殊，命令行保留了包前缀`repl.input`给input
可以用`repl.input:<path to input.json>`的方式传递输入，而避免挂载到data根节点下


```s
opa run  quick-start  repl.input:quick-start/input.json
> data.example_rbac
{
  "allow": true,
  "role_has_permission": [
    "widget-reader"
  ],
  "user_has_role": [
    "widget-reader"
  ]
}
```

> -w支持交互式窗口内实时文件变更reload
  -s支持服务常驻式启动，启动后可以REST-Api查询；


# eval

opa eval是用来查询策略结果

-d 指定上下文，-i 指定输入

-f 指定返回格式，默认json，还支持values,bindings,pretty,source

```shell
opa eval -f values -d quick-start -i quick-start/input.json "data.example_rbac"
```

--explain=notes 配合 trace(msg) 可以调试执行过程

如下边规则增加trace(role_name)调用
```s
allow {
  trace(role_name)
  user_has_role[role_name]
  role_has_permission[role_name]
}
```
--explain=notes时可以看到所有调用点note

```shell
opa eval -f pretty -d quick-start -i quick-start/input.json "data.example_rbac.allow" --explain=notes

query:1             Enter data.example_rbac.allow = _
quick-start/exa:6   | Enter data.example_rbac.allow
note                | | Note "widget-reader"
true
```


## deps

opa deps 用来分析查询依赖

## test

opa test 用来跑测试，-c支持输出覆盖率，--threshold 可指定通过覆盖率

## check & fmt

opa check 是语法检查;opa fmt是格式化


