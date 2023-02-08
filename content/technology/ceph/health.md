+++
title = "Health"
date =  2022-10-19T11:04:00+08:00
description= "description"
weight = 5
+++

## osd down

```shell
ceph orch ps --format yaml
ceph orch daemon restart osd.0
```

## MANY_OBJECTS_PER_PG

default is 10, increase `mon_pg_warn_max_object_skew` to 20 or more.

```shell
ceph config set mon_pg_warn_max_object_skew 20
```

## PG_DEGRADED

```shell
osd pool set rbd-k8s pg_autoscale_mode on
osd pool autoscale-status
```

## PG_DAMAGED

Error

```shell
ceph pg 15.1c list_unfound 
ceph pg 15.1c mark_unfond_lost revert # revert/delete
```

## osd full

跳转osd最大磁盘空间占比：

```shell
ceph osd set-nearfull-ratio 0.93
ceph osd set-full-ratio 0.97
ceph osd set-backfillfull-ratio 0.95
```

自动调整osd weight:

```shell
ceph osd reweight-by-utilization
ceph osd tree
```