+++
title = "离线安装"
date =  2023-11-15T11:03:58+08:00
description= "离线安装"
weight = 1
+++

## 下载安装包

从官方渠道下载： `https://download.docker.com/linux/static/stable/`

根据cpu类型下载对应的安装包，这里以`x86_64`为例：

```bash
wget https://download.docker.com/linux/static/stable/x86_64/docker-20.10.9.tgz

tar -zxvf docker-20.10.9.tgz
mv docker/* /usr/bin/
```

## 配置添加 systemd

```shell
cat > /usr/lib/systemd/system/docker.service << EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target
[Service]
Type=notify
ExecStart=/usr/bin/dockerd
ExecReload=/bin/kill -s HUP $MAINPID
LimitNOFILE=infinity
LimitNPROC=infinity
TimeoutStartSec=0
Delegate=yes
KillMode=process
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s
[Install]
WantedBy=multi-user.target
EOF
```

## 重新加载和重启docker

```shell
systemctl daemon-reload
systemctl restart docker

docker info
```

## docker compose

```shell
mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose

sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

docker compose version
```