---
marp: true
theme: gaia
footer: 'TonyYin, 2021-03-09'
paginate: true
style: |
  section a {
      font-size: 30px;
  }
---
<!--
_class: lead gaia
_paginate: false
-->

# OIDC

OpenID Connect, OAuth2

:dog: By Yin

---
<!-- backgroundColor: white -->
![bg right w:15cm contrast](images/oauth.png)

## Content

1. Oauth2
2. Oauth2 Demo
3. OIDC
4. OIDC Demo
    4.1. Hydra
    4.2. Dex

---

## 1.Oauth2

   `OAuth`（开放授权）是一个开放标准，允许用户授权第三方移动应用访问他们存储在另外的服务提供者上的信息，而不需要将用户名和密码提供给第三方移动应用或分享他们数据的所有内容

   #### 关键词：解决第三方应用授权问题

---

#### 1、授权流程

1. 开发者注册 oauth2.0 客户端，或得客户端id和客户端秘钥
2. 应用前端要求用户提供授权信息用来访问用户的数据；
3. 用户被重定向到授权登录服务；
4. 授权登录服务通过后，授权服务将授权后的token,重定向到前端服务；
5. 应用收到token后，通过token请求用户数据，完成验证；

---

#### 2、验证方式

验证方式有四种：
- 授权码（authorization-code）
- 隐藏式（implicit）
- 密码式（password）：
- 客户端凭证（client credentials）

`授权码`常用语用于前后端分离项目，`隐藏式`用于单前端应用，`密码式`要求第三方完全信任应用，直接使用账密登陆，`客户端凭证`用于命令行程序。 后面将以最常用的`授权码`讲解。

---
## 2.Oauth2 Demo

<!-- Scoped style -->
<style scoped>
h2 {
  color: ;
}
</style>

demo[项目地址](http://github.com:ruanyf/node-oauth-demo), github有公共的oauth登陆接口，只需要[申请](https://github.com/settings/applications/new)

```shell
git clone git@github.com:ruanyf/node-oauth-demo.git
cd node-oauth-demo

npm install
node index.js
```

打开地址 [http://localhost:8080](http://localhost:8080)


---

## 3. OIDC

`OIDC`(OpenID Connect)=`Identity, Authentication` + `OAuth 2.0`。它在OAuth2上构建了一个身份层，是一个基于OAuth2协议的身份认证标准协议。

### 关键词： 解决认证问题

>OIDC在OAuth2的access_token的基础上增加了身份认证信息， 通过公钥私钥配合校验获取身份等其他信息—– 即idToken
---

## 3. OIDC

### 原理：

ID Token是一个安全令牌，是一个授权服务器提供的包含用户信息（由一组Cliams构成以及其他辅助的Cliams）的JWT格式的数据结构。ID Token的主要构成部分如下（使用OAuth2流程的OIDC）

ID Token 包含用户的基本信息。字段固定，可以唯一的标识一个isser的用户。

---
## 4. OIDC Demo

- Hydra
- Dex

异同：

- 两个都提供oidc服务
- hydra需要自己实现验证接口（authorize、access_token、user等）。
- Dex可以对接不同标准的系统（LDAP,Github,gitlab,google等）
- Dex是一个代理层

---

## 4.1 Hydra
![bg right w:13cm contrast](images/hydra.png)

[项目地址](https://github.com/ory/hydra)

#### 1. 是什么？
Hydra is an OAuth 2.0 and OpenID Connect Provider.

关键词： oicd服务

#### 2. Demo

详细内容见技术文档。

---

## 4.2 Dex

![bg right w:15cm contrast](images/dex.png)

[项目地址](https://github.com/dexidp/dex)

### 1、是什么？
Dex is an identity service that uses OpenID Connect to drive authentication for other apps.

#### 关键词：oidc联邦


---

### 2、Dex demo

测试实验申请google和github准入,
google: https://console.developers.google.com/apis/credentials
github: https://github.com/settings/applications/new

详细内容参加文档dex。