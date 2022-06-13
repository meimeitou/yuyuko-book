+++
title = "Oauto2"
date =  2021-03-03T14:51:50+08:00
description= "oauth2 认证"
weight = 1
+++

# 一、是什么

`OAuth`（开放授权）是一个开放标准（框架），允许用户授权第三方移动应用访问他们存储在另外的服务提供者上的信息，而不需要将用户名和密码提供给第三方移动应用或分享他们数据的所有内容

用于第三方应用授权登录

# 二、授权流程

1. 开发者注册 oauth2.0 客户端，或得客户端id和客户端秘钥
2. 应用前端要求用户提供授权信息用来访问用户的数据；
3. 用户被重定向到授权登录服务；
4. 授权登录服务通过后，授权服务将授权后的token,重定向到前端服务；
5. 应用收到token后，通过token请求用户数据，完成验证；

# 三、授权方式

- 授权码（authorization-code）
- 隐藏式（implicit）
- 密码式（password）：
- 客户端凭证（client credentials）

###  1、授权码

授权码（authorization code）方式，指的是第三方应用先申请一个授权码，然后再用该码获取令牌。

用于前后端分离

### 2、隐藏式

允许直接向前端颁发令牌。这种方式没有授权码这个中间步骤，所以称为（授权码）"隐藏式"（implicit）

用于单前端应用

### 3、密码式

如果你高度信任某个应用，RFC 6749 也允许用户把用户名和密码，直接告诉该应用。该应用就使用你的密码，申请令牌，这种方式称为"密码式"（password）

### 4、凭证式

适用于没有前端的命令行应用，即在命令行下请求令牌

# 三、重要概念

1、 OAuth 2.0 Scope

客户端请求授权中有一个scope字段，用来做Internal access control (RBAC, ACL, etc) 内部访问控制。用来限制此次授权，客户端可以访问的资源。

2、OAuth 2.0 Refresh Tokens

请求参数`response_type=code`，用于更新token


# 四、详细

请求授权码：

```shell
GET /authorize?response_type=code&client_id=s6BhdRkqt3&state=xyz
&redirect_uri=https%3A%2F%2Fclient%2Eexample%2Ecom%2Fcb HTTP/1.1
Host: server.example.com
```

- response_type：表示授权类型，必选项，code/ token / password / 
- client_id：表示客户端的ID，必选项
- redirect_uri：表示重定向URI，可选项
- scope：表示申请的权限范围，可选项
- state：表示客户端的当前状态，可以指定任意值，认证服务器会原封不动地返回这个值。


用授权码获取token：

```shell
POST /token HTTP/1.1
     Host: server.example.com
     Authorization: Basic czZCaGRSa3F0MzpnWDFmQmF0M2JW
     Content-Type: application/x-www-form-urlencoded

     grant_type=refresh_token&refresh_token=tGzv3JOkF0XG5Qx2TlKWIA
```

参数：
- granttype：表示使用的授权模式，此处的值固定为"refreshtoken"，必选项。
- refresh_token：表示早前收到的更新令牌，必选项。
- scope：表示申请的授权范围，不可以超出上一次申请的范围，如果省略该参数，则表示与上一次一致。

