+++
title = "Envoy"
date =  2021-06-10T15:51:16+08:00
description= "description"
weight = 5
+++

## 1、 what is Envoy

Envoy is an L7 proxy and communication bus designed for large modern service oriented architectures.


## envoy external authorization

https://www.envoyproxy.io/docs/envoy/latest/start/sandboxes/ext_authz
https://www.envoyproxy.io/docs/envoy/latest/intro/arch_overview/security/ext_authz_filter#arch-overview-ext-authz

context请求参数: https://www.envoyproxy.io/docs/envoy/latest/api-v3/service/auth/v3/attribute_context.proto
proto contex: https://github.com/envoyproxy/envoy/blob/fb60f37df97ad7da88323b7c7475070f73f81ab7/api/envoy/service/auth/v3/attribute_context.proto#L100

filters: https://www.envoyproxy.io/docs/envoy/latest/api-v3/config/filter/filter
filter protobuf: https://github.com/envoyproxy/envoy/tree/v1.17.2/api/envoy/config/filter

