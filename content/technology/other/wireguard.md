+++
title = "Wireguard"
date =  2022-03-22T10:26:14+08:00
description= "wireguard"
weight = 2
+++

# wireguard


通过wireguard连接有vpn的机器，使用vpn机器forward ip访问内网。

配置参考： https://www.digitalocean.com/community/tutorials/how-to-set-up-wireguard-on-ubuntu-20-04

计算allow ips:
<https://www.procustodibus.com/blog/2021/03/wireguard-allowedips-calculator/>
注意排除wireguard server端的ip，不然连不上服务端。
将allow ips字段将代理所有匹配到的ip，这样就实现了流量全代理。

### 生成密钥对
```shell
wg genkey | sudo tee /etc/wireguard/private.key
sudo chmod go= /etc/wireguard/private.key
sudo cat /etc/wireguard/private.key | wg pubkey | sudo tee /etc/wireguard/public.key
```

### 配置文件

`/etc/wireguard/wg0.conf`

服务端：

```toml
[Interface]
Address = 192.168.233.1/24
SaveConfig = true
# 启动时配置nat转发
PostUp = iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
PostUp = ip6tables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
PreDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
PreDown = ip6tables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
ListenPort = 52233
PrivateKey = <PrivateKey>

[Peer]
PublicKey = <client public key>
AllowedIPs = 192.168.233.2/32
PersistentKeepalive = 30
```

客户端:

```toml
[Interface]
PrivateKey = oD0qdq+EhHkNxOweJDJRJKolT7p//a5a3fyrgklRJVM=
Address = 192.168.233.3/24

# keep client 路由
PostUp = ip rule add table 200 from 10.0.2.15
PostUp = ip route add table 200 default via 10.0.2.2
PreDown = ip rule delete table 200 from 10.0.2.15
PreDown = ip route delete table 200 default via 10.0.2.2

[Peer]
PublicKey = <server public key>
# 将这些ips都代理到服务端wireguard
AllowedIPs = <ips>
Endpoint = <server ip>:52233
PersistentKeepalive = 30
```

### 客户端所有dns代理