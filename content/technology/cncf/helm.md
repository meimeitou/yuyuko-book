+++
title = "Helm"
date =  2023-04-13T11:21:14+08:00
description= "Helm开发"
weight = 5
+++

- [官方文档](https://helm.sh/docs/)

本文档只有简单的使用入门，详细文档还需参考官方。

## 安装

helm和kubectl一样就是个go的二进制包，

- 直接到官方仓库找[二进制下载](https://github.com/helm/helm/releases)
- 解压(tar -zxvf helm-v3.0.0-linux-amd64.tar.gz)
- 在解压目录中找到helm程序，移动到需要的目录中(mv linux-amd64/helm /usr/local/bin/helm)

当然闲麻烦也能用包管理器安装：

mac: 

```shell
brew install helm
```

windows:

```shell
choco install kubernetes-helm
# or
scoop install helm
```

apt包：
```shell
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```

## 名称解释及概念

- `Chart` 代表着 Helm 包。它包含在 Kubernetes 集群内部运行应用程序，工具或服务所需的所有资源定义。你可以把它看作是 Homebrew formula，Apt dpkg，或 Yum RPM 在Kubernetes 中的等价物。
- `Repository`仓库。是用来存放和共享 charts 的地方。其实远端就是存储一个tar压缩包。
- `Release`是运行在 Kubernetes 集群中的 chart 的实例。

## 常用包命令

```shell
# 添加远端仓库
helm repo add bitnami https://charts.bitnami.com/bitnami
# 或者带有密码的私有仓库
helm repo add --username=xxx --password=xxxx myrepo https://xx.repo.cn/repo

# 搜索包
helm search repo bitnami/nginx
# 搜索并且列出可用versions
helm search repo bitnami/nginx -l

# 安装包
helm install <name> bitnami/nginx -n <namespace> [-f your-values.yaml]
```

## 创建包

使用前需要简单了解下k8s的资源

部署类型：

- Deployment: 部署无状态服务
- Statefullset: 部署有状态服务
- Daemonset: 守护进程部署
- CronJob: 定时任务

其它常用类型：
- Service: 定义集群内部或者外部vip
- ServiceAccount: 服务账号
- HorizontalPodAutoscaler: 自动扩缩容配置
- Configmap: 配置文件
- Secret: 秘钥

下面来创建一个示例项目：

```shell
# 创建一个模板包，模板是部署一个简单的nginx服务。
helm create chartname
```

直接创建会发现已经填充了很多文件内容，下面是文件内容解释：

```
chartname/
  Chart.yaml          # 包含 Chart 基本信息（例如版本和名称）的 YAML 文件。
  LICENSE             # （可选）包含 Chart 许可证的纯文本文件。
  README.md           # （可选）应用说明和使用指南。
  values.yaml         # 该 Chart 的默认配置值。
  values.schema.json  # （可选）向 values.yaml 文件添加结构的 JSON Schema。
  charts/             # 一个目录，包含该 Chart 所依赖的任意 Chart。
  crds/               # 定制资源定义。
  templates/          # 模板的目录，若提供相应值便可以生成有效的 Kubernetes 配置文件。
  templates/NOTES.txt # （可选）包含使用说明的纯文本文件。
```

### Chart.yaml 文件:

您必须为 Chart 提供 chart.yaml 文件。下面是一个示例文件，每个字段都有说明。

```yaml
apiVersion: （必需）Chart API 版本。 
name: （必需）Chart 名称。
version: （必需）版本，遵循 SemVer 2 标准。 
kubeVersion: （可选）兼容的 Kubernetes 版本，遵循 SemVer 2 标准。
description: （可选）对应用的一句话说明。
type: （可选）Chart 的类型。
keywords:
  - （可选）关于应用的关键字列表。
home: （可选）应用的 URL。
sources:
  - （可选）应用源代码的 URL 列表。
dependencies: （可选）Chart 必要条件的列表。
  - name: Chart 的名称，例如 nginx。
    version: Chart 的版本，例如 "1.2.3"。
    repository: 仓库 URL ("https://example.com/charts") 或别名 ("@repo-name")。
    condition: （可选）解析为布尔值的 YAML 路径，用于启用/禁用 Chart （例如 subchart1.enabled）。
    tags: （可选）
      - 用于将 Chart 分组，一同启用/禁用。
    import-values: （可选）
      - ImportValues 保存源值到待导入父键的映射。每一项可以是字符串或者一对子/父子列表项。
    alias: （可选）Chart 要使用的别名。当您要多次添加同一个 Chart 时，它会很有用。
maintainers: （可选）
  - name: （必需）维护者姓名。
    email: （可选）维护者电子邮件。
    url: （可选）维护者 URL。
icon: （可选）要用作图标的 SVG 或 PNG 图片的 URL。
appVersion: （可选）应用版本。不需要是 SemVer。
deprecated: （可选，布尔值）该 Chart 是否已被弃用。
annotations:
  example: （可选）按名称输入的注解列表。
```

### Values.yaml 和模板

Helm Chart 模板采用 Go 模板语言编写并存储在 Chart 的 templates 文件夹。有两种方式可以为模板提供值：

在 Chart 中创建一个包含可供引用的默认值的 values.yaml 文件。
创建一个包含必要值的 YAML 文件，通过在命令行使用 helm install 命令来使用该文件。
下面是 templates 文件夹中模板的示例。

```yaml
replicaCount: 1
image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: ""
```

template文件示例：

这里面讲引用上面value.yaml文件定义的变量。

```yaml
...
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  ...
  selector:
    matchLabels:
      {{- include "xx.selectorLabels" . | nindent 6 }}
    ...
    spec:
      containers:
        - name: {{ .Chart.Name }}
          securityContext:
            {{- toYaml .Values.securityContext | nindent 12 }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
```

就是这么简单朴实，我们只要理解`{{}}`这里面的变量是哪来的就可以。

## 本地测试

```shell
# 生成最终模板并输出到终端
helm template ./chartname --debug
# 测试在集群中的变量是否正确，但是不安装到集群
helm install ./chartname --dry-run
```

根据报错修改自己的模板配置。


## 部署完后的操作

```shell
# 显示已经安装的包
helm list -n <namspace>
# 显示部署状态
helm status RELEASE_NAME -n <namspace>
# 卸载包
helm uninstall RELEASE_NAME -n <namspace>
# 获取当前不是使用的values变量
helm get values RELEASE_NAME -n <namspace>
# 升级安装
helm upgrade <name> bitnami/nginx -n <namespace> [-f your-values.yaml]
```