+++
title = "Keepalived"
date =  2021-03-19T18:40:44+08:00
description= "description"
weight = 5
+++

安装

```shell
yum install -y keepalived

systemctl status keepalived
```

配置文件：

```shell
vim /etc/keepalived/keepalived.conf
```

机器1
master 配置：
```
vrrp_instance VI_1 {
        state MASTER
        interface eth1
        virtual_router_id 51
        priority 255
        advert_int 1
        authentication {
              auth_type PASS
              auth_pass 12345
        }
        virtual_ipaddress {
              192.168.122.200/24
        }
}
```

机器2
backup配置：

```
vrrp_instance VI_1 {
        state BACKUP
        interface eth1
        virtual_router_id 51
        priority 254
        advert_int 1
        authentication {
              auth_type PASS
              auth_pass 12345
        }
        virtual_ipaddress {
              192.168.122.200/24
        }
}
```


查看ip状态：

```shell
ip -brief address show
```