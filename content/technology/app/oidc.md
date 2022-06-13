+++
title = "openid connect"
date =  2021-03-04T09:46:26+08:00
description= "openid connect 基于oauth2的鉴权认证标准"
weight = 2
+++

# 一、是什么？

OIDC=(Identity, Authentication) + OAuth 2.0。它在OAuth2上构建了一个身份层，是一个基于OAuth2协议的身份认证标准协议。

解决认证问题。

OIDC在OAuth2的access_token的基础上增加了身份认证信息， 通过公钥私钥配合校验获取身份等其他信息—– 即idToken

# 二、原理

## 1、术语：

- EU：End User：一个人类用户。
- RP：Relying Party ,用来代指OAuth2中的受信任的客户端，身份认证和授权信息的消费方；
- OP：OpenID Provider，有能力提供EU认证的服务（比如OAuth2中的授权服务），用来为RP提供EU的身份认证信息；
- ID Token：JWT格式的数据，包含EU身份认证的信息。
- UserInfo Endpoint：用户信息接口（受OAuth2保护），当RP使用Access Token访问时，返回授权用户的信息，此接口必须使用HTTPS。 返回EU的Claims。

## 2、ID Token

ID Token是一个安全令牌，是一个授权服务器提供的包含用户信息（由一组Cliams构成以及其他辅助的Cliams）的JWT格式的数据结构。ID Token的主要构成部分如下（使用OAuth2流程的OIDC）

- iss = Issuer Identifier：必须。提供认证信息者的唯一标识。一般是一个https的url（不包含querystring和fragment部分）。
- sub = Subject Identifier：必须。iss提供的EU的标识，在iss范围内唯一。它会被RP用来标识唯一的用户。最长为255个ASCII个字符。
- aud = Audience(s)：必须。标识ID Token的受众。必须包含OAuth2的client_id。
- exp = Expiration time：必须。过期时间，超过此时间的ID Token会作废不再被验证通过。
- iat = Issued At Time：必须。JWT的构建的时间。
- auth_time = AuthenticationTime：EU完成认证的时间。如果RP发送AuthN请求的时候携带max_age的参数，则此Claim是必须的。
- nonce：RP发送请求的时候提供的随机字符串，用来减缓重放攻击，也可以来关联ID Token和RP本身的Session信息。
- acr = Authentication Context Class Reference：可选。表示一个认证上下文引用值，可以用来标识认证上下文类。
- amr = Authentication Methods References：可选。表示一组认证方法。
- azp = Authorized party：可选。结合aud使用。只有在被认证的一方和受众（aud）不一致时才使用此值，一般情况下很少使用。

## 3、认证方式

因为OIDC基于OAuth2，所以OIDC的认证流程主要是由OAuth2的几种授权流程延伸而来的，有以下3种：

- Authorization Code Flow：使用OAuth2的授权码来换取Id Token和Access Token。
- Implicit Flow：使用OAuth2的Implicit流程获取Id Token和Access Token。
- Hybrid Flow：混合Authorization Code Flow+Implici Flow。

只支持oauth2的两种flow，因为另外两种不时候，一种是密码直接登录的（账号密码都知道了，还要个蛋蛋的身份认证），Client Credentials Grant 就没有用户啥事，也不适合。 

## 4、认证详细

### 4.1 基于Authorization Code的认证请求

请求参数：

- scope：必须。OIDC的请求必须包含值为“openid”的scope的参数。
- response_type：必选。同OAuth2。
- client_id：必选。同OAuth2。
- redirect_uri：必选。同OAuth2。
- state：推荐。同OAuth2。防止CSRF, XSRF。

以上同 oauth2的参数，附加的参数有：


1. response_mode：可选。OIDC新定义的参数（[OAuth 2.0 Form Post Response Mode](http://openid.net/specs/oauth-v2-form-post-response-mode-1_0.html)），用来指定Authorization Endpoint以何种方式返回数据。
2. nonce：可选。ID Token中的出现的nonce就是来源于此。
3. display ： 可选。指示授权服务器呈现怎样的界面给EU。有效值有（page，popup，touch，wap），其中默认是page。page=普通的页面，popup=弹出框，touch=支持触控的页面，wap=移动端页面。
4. prompt：可选。这个参数允许传递多个值，使用空格分隔。用来指示授权服务器是否引导EU重新认证和同意授权（consent，就是EU完成身份认证后的确认同意授权的页面）。有效值有（none，login，consent，select_account）。none=不实现现任何认证和确认同意授权的页面，如果没有认证授权过，则返回错误login_required或interaction_required。login=重新引导EU进行身份认证，即使已经登录。consent=重新引导EU确认同意授权。select_account=假如EU在授权服务器有多个账号的话，允许EU选择一个账号进行认证。
5. max_age：可选。代表EU认证信息的有效时间，对应ID Token中auth_time的claim。比如设定是20分钟，则超过了时间，则需要引导EU重新认证。
6. ui_locales：可选。用户界面的本地化语言设置项。
7. id_token_hint：可选。之前发放的ID Token，如果ID Token经过验证且是有效的，则需要返回一个正常的响应；如果有误，则返回对应的错误提示。
8.login_hint：可选。向授权服务器提示登录标识符，EU可能会使用它登录(如果需要的话)。比如指定使用用户使用blackheart账号登录，当然EU也可以使用其他账号登录，这只是类似html中input元素的placeholder。
9. acr_values：可选。Authentication Context Class Reference values，对应ID Token中的acr的Claim。此参数允许多个值出现，使用空格分割。


请求响应返回 code 同oauth2,然后使用code去获取token,
最后用token去请求用户信息，并附加上id_token字段

Implicit Flow的工作方式是在OAuth2 Implicit Flow上附加提供id_token

## 5、UserInfo Endpoint

UserIndo EndPoint是一个受OAuth2保护的资源。在RP得到Access Token后可以请求此资源，然后获得一组EU相关的Claims，这些信息可以说是ID Token的扩展，比如如果你觉得ID Token中只需包含EU的唯一标识sub即可（避免ID Token过于庞大），然后通过此接口获取完整的EU的信息。此资源必须部署在TLS之上

## 接口实现

参考：
https://developer.okta.com/docs/reference/api/oidc/#endpoints

