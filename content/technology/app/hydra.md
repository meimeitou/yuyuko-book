+++
title = "Hydra"
date =  2021-03-04T14:55:49+08:00
description= "oauth2 and oidc server"
weight = 3
+++

# 一、示例

### 1、下载代码 
```shell
git clone https://github.com/ory/hydra.git
```

### 2、启动服务：

```shell
docker-compose -f quickstart.yml \
    -f quickstart-postgres.yml \
    up --build
```

端口 4444用于公网，4445用于管理口，一般用于内网，或者配有权限控制的代理

### 3、测试服务已正确启动

不想测试也可跳过

初始化一个oauth2 client，给的id，secre,和工作类型

```shell
docker-compose -f quickstart.yml exec hydra \
    hydra clients create \
    --endpoint http://127.0.0.1:4445/ \
    --id my-client \
    --secret secret \
    -g client_credentials
```

测试获取token

```shell
docker-compose -f quickstart.yml exec hydra \
    hydra token client \
    --endpoint http://127.0.0.1:4444/ \
    --client-id my-client \
    --client-secret secret
```

测试使用token获取信息，token使用上面命令返回的token

```shell
docker-compose -f quickstart.yml exec hydra \
    hydra token introspect \
    --endpoint http://127.0.0.1:4445/ \
    UDYMha9TwsMBejEvKfnDOXkhgkLsnmUNYVQDklT5bD8.ZNpuNRC85erbIYDjPqhMwTinlvQmNTk_UvttcLQxFJY
```

### 4、app验证测试

创建一个 oauth client
secret可使用随机产生，grant-types 授权类型，response-types相应类型，scope控制域，自定义，callbacks客户端回调地址

```shell
docker-compose -f quickstart.yml exec hydra \
    hydra clients create \
    --endpoint http://127.0.0.1:4445 \ 
    --id auth-code-client \
    --secret secret \
    --grant-types authorization_code,refresh_token \
    --response-types code,id_token \
    --scope openid,offline \
    --callbacks http://127.0.0.1:5555/callback
```

启动客户端：

客户端端口为 5555

```shell
docker-compose -f quickstart.yml exec hydra \
    hydra token user \
    --client-id auth-code-client \
    --client-secret secret \
    --endpoint http://127.0.0.1:4444/ \
    --port 5555 \
    --scope openid,offline
```

然后登打开： http://127.0.0.1:5555

![open-hydra](/images/app/open-hydra.png)

跳转到第三方登陆页面

![login](/images/app/hydra-login.png)

登陆授权
![auth](/images/app/hydra-auth.png)

获取用户信息
![info](/images/app/hydra-getinfo.png)

