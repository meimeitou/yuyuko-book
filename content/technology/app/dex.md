+++
title = "Dex"
date =  2021-03-04T16:50:29+08:00
description= "基于oidc的授权层"
weight = 4
+++



# 1、what?

Dex is an identity service that uses OpenID Connect to drive authentication for other apps.

A Federated OpenID Connect Provider

联邦oidc

# 2、how?

- 对外提供标准oidc服务
- 后端connector可以是多种协议（LDAP,SAML,Oauth2,oidc,authproxy等） 360 api
- 支持多种存储etcd, mysql, postgres, k8s crd。

### 数据库表结构

- refresh token
- offline session

### idToken & refresh token

jwt格式

# 3、use

安装

```shell
git clone https://github.com/dexidp/dex.git
cd dex/
make
```

启动服务：

```shell
./bin/dex serve examples/config-dev.yaml
```

配置文件示例：

```yaml
# DEPRECATED: use config.yaml.dist and config.dev.yaml examples in the repository root.
# TODO: keep this until all references are updated.

# The base path of dex and the external name of the OpenID Connect service.
# This is the canonical URL that all clients MUST use to refer to dex. If a
# path is provided, dex's HTTP service will listen at a non-root URL.
issuer: http://127.0.0.1:5556/dex

# The storage configuration determines where dex stores its state. Supported
# options include SQL flavors and Kubernetes third party resources.
#
# See the documentation (https://dexidp.io/docs/storage/) for further information.
storage:
  type: sqlite3
  config:
    file: examples/dex.db

  # type: mysql
  # config:
  #   host: localhost
  #   port: 3306
  #   database: dex
  #   user: mysql
  #   password: mysql
  #   ssl:
  #     mode: "false"

  # type: postgres
  # config:
  #   host: localhost
  #   port: 5432
  #   database: dex
  #   user: postgres
  #   password: postgres
  #   ssl:
  #     mode: disable

  # type: etcd
  # config:
  #   endpoints:
  #     - http://localhost:2379
  #   namespace: dex/

  # type: kubernetes
  # config:
  #   kubeConfigFile: $HOME/.kube/config

# Configuration for the HTTP endpoints.
web:
  http: 0.0.0.0:5556
  # Uncomment for HTTPS options.
  # https: 127.0.0.1:5554
  # tlsCert: /etc/dex/tls.crt
  # tlsKey: /etc/dex/tls.key

# Configuration for dex appearance
# frontend:
#   issuer: dex
#   logoURL: theme/logo.png
#   dir: web/
#   theme: light

# Configuration for telemetry
telemetry:
  http: 0.0.0.0:5558

# Uncomment this block to enable the gRPC API. This values MUST be different
# from the HTTP endpoints.
# grpc:
#   addr: 127.0.0.1:5557
#   tlsCert: examples/grpc-client/server.crt
#   tlsKey: examples/grpc-client/server.key
#   tlsClientCA: examples/grpc-client/ca.crt

# Uncomment this block to enable configuration for the expiration time durations.
# expiry:
#   deviceRequests: "5m"
#   signingKeys: "6h"
#   idTokens: "24h"

# Options for controlling the logger.
# logger:
#   level: "debug"
#   format: "text" # can also be "json"

# Default values shown below
# oauth2:
    # use ["code", "token", "id_token"] to enable implicit flow for web-only clients
#   responseTypes: [ "code" ] # also allowed are "token" and "id_token"
    # By default, Dex will ask for approval to share data with application
    # (approval for sharing data from connected IdP to Dex is separate process on IdP)
#   skipApprovalScreen: false
    # If only one authentication method is enabled, the default behavior is to
    # go directly to it. For connected IdPs, this redirects the browser away
    # from application to upstream provider such as the Google login page
#   alwaysShowLoginScreen: false
    # Uncomment the passwordConnector to use a specific connector for password grants
#   passwordConnector: local

# Instead of reading from an external storage, use this list of clients.
#
# If this option isn't chosen clients may be added through the gRPC API.
staticClients:
- id: example-app
  redirectURIs:
  - 'http://127.0.0.1:5555/callback'
  name: 'Example App'
  secret: ZXhhbXBsZS1hcHAtc2VjcmV0
#  - id: example-device-client
#    redirectURIs:
#      - /device/callback
#    name: 'Static Client for Device Flow'
#    public: true
connectors:
- type: mockCallback
  id: mock
  name: Example

- type: oidc
  id: google
  name: Google
  config:
    # Canonical URL of the provider, also used for configuration discovery.
    # This value MUST match the value returned in the provider config discovery.
    #
    # See: https://openid.net/specs/openid-connect-discovery-1_0.html#ProviderConfig
    issuer: https://accounts.google.com

    # Connector config values starting with a "$" will read from the environment.
    clientID: xx
    clientSecret: xx

    # Dex's issuer URL + "/callback"
    redirectURI: http://127.0.0.1:5556/dex/callback
    claimMapping:

- type: github
  # Required field for connector id.
  id: github
  # Required field for connector name.
  name: Github
  config:
    # optional, default = https://gitlab.com
    # baseURL: https://gitlab.com
    # Credentials can be string literals or pulled from the environment.
    clientID: xx
    clientSecret: xx
    redirectURI: http://127.0.0.1:5556/dex/callback
    # Optional groups whitelist, communicated through the "groups" scope.
    # If `groups` is omitted, all of the user's GitLab groups are returned when the groups scope is present.
    # If `groups` is provided, this acts as a whitelist - only the user's GitLab groups that are in the configured `groups` below will go into the groups claim.  Conversely, if the user is not in any of the configured `groups`, the user will not be authenticated.
    # orgs:
    # - name: my-organization
    #   # Include all teams as claims.
    # - name: my-organization-with-teams
    #   # A white list of teams. Only include group claims for these teams.
    #   teams:
    #   - red-team
    #   - blue-team
    # Flag which indicates that all user groups and teams should be loaded.
    # loadAllGroups: false
    teamNameField: slug
    # flag which will switch from using the internal GitHub id to the users handle (@mention) as the user id.
    # It is possible for a user to change their own user name but it is very rare for them to do so
    useLoginAsID: false
# - type: google
#   id: google
#   name: Google
#   config:
#     issuer: https://accounts.google.com
#     # Connector config values starting with a "$" will read from the environment.
#     clientID: $GOOGLE_CLIENT_ID
#     clientSecret: $GOOGLE_CLIENT_SECRET
#     redirectURI: http://127.0.0.1:5556/dex/callback
#     hostedDomains:
#     - $GOOGLE_HOSTED_DOMAIN

# Let dex keep a list of passwords which can be used to login to dex.
enablePasswordDB: true

# A static list of passwords to login the end user. By identifying here, dex
# won't look in its underlying storage for passwords.
#
# If this option isn't chosen users may be added through the gRPC API.
staticPasswords:
- email: "772006843@qq.com"
  # bcrypt hash of the string "password"
  hash: "$2a$10$x"
  username: "admin"
  userID: "x-x-x-x-x"

```

客户端：

```shell
make examples
./bin/example-app
```