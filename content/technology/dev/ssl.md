+++
title = "SSL"
date =  2023-06-21T11:17:19+08:00
description= "自签名证书"
weight = 5
+++

## letsencrypt

- https://letsencrypt.org/docs/
- 使用客户端：https://certbot.eff.org/

## certbot

### 安装

```shell
# ubuntu
sudo apt update
sudo apt install snapd
sudo snap install core; sudo snap refresh core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
```

### 生成证书

自签名证书，手动申请通配符证书

```shell
# sudo certbot -d domain.com -d "*.domain.com" --manual --preferred-challenges dns certonly
sudo certbot -d domain.com --manual --preferred-challenges dns certonly
```

大概要求步骤：

- 填写email
- 同意协议
- 命令会生成DNS text的value
- 到你的dns服务器上配置域名的txt记录
- 等记录生效
- 回车继续就可以生成证书

### 证书续签

证书有效期90天，需要续签

```shell
crontab -e // 编辑定时任务
0 */12 * * * certbot renew --quiet --renew-hook "/etc/init.d/nginx reload"
```

### 取消证书

```shell
certbot revoke --cert-path /etc/letsencrypt/live/you.cn/cert.pem
certbot delete --cert-name you.cn
```
