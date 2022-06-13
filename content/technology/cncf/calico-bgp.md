+++
title = "Calico bgp"
date =  2021-03-28T21:03:47+08:00
description= "calico bgp 配置"
weight = 5
+++

## global peer

全局peer将所有的node对接到外部的bgp infra路由，需要infra支持

```yaml
apiVersion: projectcalico.org/v3
kind: BGPPeer
metadata:
  name: my-global-peer
spec:
  peerIP: 192.20.30.40
  asNumber: 64567
```

## Configure a node to act as a route reflector

选择node作为路由反射，将减少集群的路由量，有少量的节点反射其它节点的路由信息；

add `cluster id` to node
```shell
calicoctl patch node my-node -p '{"spec": {"bgp": {"routeReflectorClusterID": "244.0.0.1"}}}'
```

add `label` to node

```shell
kubectl label node my-node route-reflector=true
```

config peer:
所有节点连接 reflector节点

```yaml
kind: BGPPeer
apiVersion: projectcalico.org/v3
metadata:
  name: peer-with-route-reflectors
spec:
  nodeSelector: all()
  peerSelector: route-reflector == 'true'
```

## globel as change

```shell
calicoctl patch bgpconfiguration default -p '{"spec": {"asNumber": "64513"}}'
```

## node as change

```shell
calicoctl patch node node-1 -p '{"spec": {"bgp": {"asNumber": "64514"}}}'
```

# Advertise Kubernetes service IP addresses

## Advertise service cluster IP addresses

外部ip:
```shell
calicoctl patch BGPConfig default --patch '{"spec": {"serviceExternalIPs": [{"cidr": "123.125.81.66/32"}]}}'
```

禁用node mesh:
```shell
calicoctl patch bgpconfiguration default -p '{"spec": {"nodeToNodeMeshEnabled": false}}'
```

# Advertise service external IP addresses

```shell
calicoctl patch BGPConfig default --patch \
    '{"spec": {"serviceExternalIPs": [{"cidr": "123.125.81.66/32"}]}}'
```

## Exclude certain nodes from advertisement

```shell
kubectl label node vm-pandora-kube-04 node.kubernetes.io/exclude-from-external-load-balancers=true
```