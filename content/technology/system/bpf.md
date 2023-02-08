+++
title = "BPF"
date =  2022-11-05T17:09:08+08:00
description= "description"
weight = 5
+++

BPF 和 XDP 参考指南: https://arthurchiao.art/blog/cilium-bpf-xdp-reference-guide-zh/

- https://zhuanlan.zhihu.com/p/492185920
- https://github.com/iovisor/bcc
- xdp学习: https://github.com/xdp-project/xdp-tutorial
- https://www.ebpf.top/
- https://davidlovezoe.club/wordpress/ebpf%e5%ad%a6%e4%b9%a0%e6%95%99%e7%a8%8b

## bpf基础

bpf程序类型：

由linux内核中的`bpf.h`头文件中的一个enum对象定义,一种 type 的 bpf prog 可以挂到内核中不同的 hook 点，这些不同的 hook 点就是不同的 attach type。

```
enum bpf_prog_type {
  BPF_PROG_TYPE_UNSPEC,        /* Reserve 0 as invalid
                                  program type */
  BPF_PROG_TYPE_SOCKET_FILTER,
  BPF_PROG_TYPE_KPROBE,
  BPF_PROG_TYPE_SCHED_CLS,
  BPF_PROG_TYPE_SCHED_ACT,
  BPF_PROG_TYPE_TRACEPOINT,
  BPF_PROG_TYPE_XDP,
  BPF_PROG_TYPE_PERF_EVENT,
  BPF_PROG_TYPE_CGROUP_SKB,
  BPF_PROG_TYPE_CGROUP_SOCK,
  BPF_PROG_TYPE_LWT_IN,
  BPF_PROG_TYPE_LWT_OUT,
  BPF_PROG_TYPE_LWT_XMIT,
  BPF_PROG_TYPE_SOCK_OPS,
  BPF_PROG_TYPE_SK_SKB,
  BPF_PROG_TYPE_CGROUP_DEVICE,
  BPF_PROG_TYPE_SK_MSG,
  BPF_PROG_TYPE_RAW_TRACEPOINT,
  BPF_PROG_TYPE_CGROUP_SOCK_ADDR,
  BPF_PROG_TYPE_LWT_SEG6LOCAL,
  BPF_PROG_TYPE_LIRC_MODE2,
  BPF_PROG_TYPE_SK_REUSEPORT,
  BPF_PROG_TYPE_FLOW_DISSECTOR,
  /* See /usr/include/linux/bpf.h for the full list. */
};
```

- BPF_PROG_TYPE_SOCKET_FILTER：一种网络数据包过滤器
- BPF_PROG_TYPE_KPROBE：确定 kprobe 是否应该触发
- BPF_PROG_TYPE_SCHED_CLS：一种网络流量控制分类器
- BPF_PROG_TYPE_SCHED_ACT：一种网络流量控制动作
- BPF_PROG_TYPE_TRACEPOINT：确定 tracepoint 是否应该触发
- BPF_PROG_TYPE_XDP：从设备驱动程序接收路径运行的网络数据包过滤器
- BPF_PROG_TYPE_PERF_EVENT：确定是否应该触发 perf 事件处理程序
- BPF_PROG_TYPE_CGROUP_SKB：一种用于控制组的网络数据包过滤器
- BPF_PROG_TYPE_CGROUP_SOCK：一种由于控制组的网络包筛选器，它被允许修改套接字选项
- BPF_PROG_TYPE_LWT_*：用于轻量级隧道的网络数据包过滤器
- BPF_PROG_TYPE_SOCK_OPS：一个用于设置套接字参数的程序
- BPF_PROG_TYPE_SK_SKB：一个用于套接字之间转发数据包的网络包过滤器
- BPF_PROG_CGROUP_DEVICE：确定是否允许设备操作

## Difference between tc/BPF and XDP/BPF

https://liuhangbin.netlify.app/post/ebpf-and-xdp/

在比较XDP BPF程序和tc BPF程序时有三个主要的区别:
- XDP钩子更早，因此性能更快。Tc hook较晚，因此可以访问sk_buff结构和字段。这是造成XDP钩子和tc钩子之间性能差异的重要原因。访问sk_buff可能是有用的，但随之而来的是堆栈执行分配和元数据提取的相关成本，以及处理数据包直到它到达tc钩子。根据定义，xdp_buff不能访问sk_buff元数据和字段，因为在完成这项工作之前会调用XDP钩子。
- Tc具有较好的数据包分解能力。BPF输入上下文是tc的sk_buff，而不是XDP的xdp_buff。通常，sk_buff与xdp_buff的性质完全不同，两者都有优点和缺点。当内核的网络堆栈接收到一个数据包时，在XDP层之后，它分配一个缓冲区并解析数据包以存储关于数据包的元数据。这种表示形式称为sk_buff。该结构随后在BPF输入上下文中公开，以便tc入口层的tc BPF程序可以使用堆栈从数据包中提取的元数据。
- XDP更适合于完整的包重写. sk_buff案例包含大量协议特定的信息(例如GSO相关的状态)，这使得仅通过重写数据包数据就很难简单地切换协议。这是因为堆栈根据元数据处理数据包，而不是每次都要访问数据包内容。因此，需要从BPF辅助函数进行额外的转换，同时还要注意正确地转换sk_buffinternals。然而，xdp_buff情况不会面临这样的问题，因为它出现在内核甚至还没有分配sk_buff的早期阶段
- Tc /ebpf和XDP互相作为补充方案。如果用例既需要包重写，又需要复杂的数据处理，那么可以通过操作两种类型的互补程序来克服每种程序类型的限制。在入口处的XDP程序可以重新编写完整的数据包，并将自定义元数据从XDP BPF传递到tc BPF，在tc BPF中，tc可以使用XDP元数据和sk_buff字段执行数据包分解。
-  tc/eBPF可以在网络的入口和出口，XDP只能是入口处
-  tc/BPF不需要更改HW驱动程序，XDP通常使用本机驱动程序模式以获得最佳性能
-  Offloaded tc/ebpf和Offloaded XDP提供了类似的性能优势
-  编程方面： XDP将结构体xdp_md *ctx作为参数，该参数指向原始数据。Tc /ebpf接受结构__sk_buff *skb作为参数，可以使用__sk_buff提供的更多信息。

## xdp-tutorial

测试环境ubuntu20.04

### 环境配置

```shell
# libbpf依赖
git submodule update --init
# pkg依赖
# 可能缺少 sudo apt install libstdc++-9-dev
sudo apt install clang llvm libelf-dev libpcap-dev gcc-multilib build-essential
sudo apt install linux-tools-$(uname -r)
sudo apt install linux-headers-$(uname -r)
# 工具
sudo apt install linux-tools-common linux-tools-generic
sudo apt install tcpdump
```

### 项目学习顺序

- Basic setup (directories starting with basicXX)
  我们建议您从这些课程开始，因为它们将教会您如何编译和检查将实现数据包处理代码的eBPF程序，如何将它们加载到内核中，以及如何随后检查状态。作为基础课程的一部分，您还将编写一个eBPF程序加载器，您将在后续课程中需要。

- Packet processing (directories starting with packetXX)
  一旦掌握了基本知识并知道如何将程序加载到内核中，就可以开始处理一些数据包了。包处理类别的课程将教你处理数据包所需的不同步骤，包括解析、重写、指示内核处理后如何处理数据包，以及如何使用helper来访问现有的内核功能。
- Advanced topics (directories starting with advancedXX)
  在完成基本和包处理类别的课程之后，您应该准备好编写您的第一个真正的XDP程序，该程序将对进入系统的包进行有用的处理。但是，当您开始扩展程序以执行更多任务时，还有一些稍微高级一点的主题可能会有用。
  高级课程中涉及的主题包括如何使内核中其他部分的eBPF程序与XDP程序交互，在程序之间传递元数据，与用户空间和内核特性交互的最佳实践，以及如何在单个接口上运行多个XDP程序。

### 项目常用命令

执行命令：

```shell
# 快捷脚本
eval $(./testenv/testenv.sh alias)
# 设置环境
t setup -n test # ipv6环境
t setup --legacy-ip # ipv6+ipv4环境
t setup --legacy-ip --vlan # vlan环境
# unload xdp
t unload
# 删除环境
t teardown 
# 包监控
t stats  #  sudo ./xdp_stats  -d xdptut-126a

# ping ipv4
t ping --legacy-ip

# 手动重新强制挂载
sudo mount -t bpf bpf /sys/fs/bpf/

# 加载prog
t exec -n test -- ./xdp_loader -d veth0 -F --progsec xdp_pass
t load -n test -- -F --progsec xdp_icmp_echo

# 加载xdp到网络接口
sudo ./xdp_loader --dev name --force  --progsec xdp_packet_parser
# 包监控
sudo ./xdp_stats  -d name
```


## bcc

开发环境

开发参考（函数，参数，命令等）： https://github.com/iovisor/bcc/blob/master/docs/reference_guide.md

开发者指导： https://github.com/iovisor/bcc/blob/master/docs/tutorial_bcc_python_developer.md


### 环境配置

```shell
# For Focal (20.04.1 LTS)
# 可能缺一个包： libclang-common-12-dev 我装的时候提示缺少这个，按照提示安装吧
sudo apt install -y bison build-essential cmake flex git libedit-dev \
  libllvm12 llvm-12-dev libclang-12-dev python zlib1g-dev libelf-dev libfl-dev python3-distutils

git clone https://github.com/iovisor/bcc.git
mkdir bcc/build; cd bcc/build
# 依赖
cmake ..

# 进入root执行
sudo su
# python环境
export PYTHONPATH=$(dirname `find /usr/lib -name bcc`):$PYTHONPATH
# hellow world程序
./examples/hello_world.py
```

### 课程

- lesson2

```python
from bcc import BPF
BPF(text='int kprobe__sys_sync(void *ctx) { bpf_trace_printk("Hello, World! sys_sync\\n"); return 0; }').trace_print()
```

然后到其它终端输入`sync`命令就能看到输出了。

- Lesson 5. sync_count.py

添加一个`BPF_HASH`，然后计数即可。

我的内核大于4.8,所以把 `delete`去掉了

```python

from __future__ import print_function
from bcc import BPF
from bcc.utils import printb

# load BPF program
b = BPF(text="""
#include <uapi/linux/ptrace.h>

BPF_HASH(last);
BPF_HASH(count);

int do_trace(struct pt_regs *ctx) {
    u64 ts, *tsp, delta, key = 0;
    u64 *num, numKey = 0, current = 1;
   
    num = count.lookup(&numKey);
    if (num != NULL) {
        current += *num;
    }
     // attempt to read stored timestamp
    tsp = last.lookup(&key);
    if (tsp != NULL) {
        delta = bpf_ktime_get_ns() - *tsp;
        if (delta < 1000000000) {
            // output if time is less than 1 second
            bpf_trace_printk("count: %d, last %d\\n", current, delta / 1000000);
        }
    }
  
    count.update(&numKey, &current);
    // bpf_trace_printk("%d\\n", *num);
    // update stored timestamp
    ts = bpf_ktime_get_ns();
    last.update(&key, &ts);
    return 0;
}
""")

b.attach_kprobe(event=b.get_syscall_fnname("sync"), fn_name="do_trace")
print("Tracing for quick sync's... Ctrl-C to end")

# format output
start = 0
while 1:
    try:
        (task, pid, cpu, flags, ts, ms) = b.trace_fields()
        if start == 0:
            start = ts
        ts = ts - start
        printb(b"At time %.2f s: multiple syncs detected, %s ms ago" % (ts, ms))
    except KeyboardInterrupt:
        exit()
```

- Lesson 8. sync_perf_output.py

新加一个`BPF_PERF_OUTPUT` 存储delta，而不是直接输出

```python
#!/usr/bin/python
from bcc import BPF
from bcc.utils import printb

prog = """
#include <linux/sched.h>

struct data_t {
    u64 delta;
    u64 ts;
};
BPF_PERF_OUTPUT(events);
BPF_HASH(last);

int hello(struct pt_regs *ctx) {
    u64 ts, *tsp, delta, key = 0;

    ts = bpf_ktime_get_ns();
    tsp = last.lookup(&key);
    if (tsp != NULL) {
        delta = ts - *tsp;
        if (delta < 1000000000) {
            struct data_t data = {};
            data.delta = delta/1000000;
            data.ts = ts;
            events.perf_submit(ctx, &data, sizeof(data));
        }
    }
    last.update(&key, &ts);
    return 0;
}
"""

# load BPF program
b = BPF(text=prog)
b.attach_kprobe(event=b.get_syscall_fnname("sync"), fn_name="hello")

# header
print("Tracing for quick sync's... Ctrl-C to end")

# process event
start = 0
def print_event(cpu, data, size):
    global start
    event = b["events"].event(data)
    if start == 0:
            start = event.ts
    time_s = (float(event.ts - start)) / 1000000000
    printb(b"At time %.2f s: multiple syncs detected, last %d ms ago" % (time_s, event.delta)) 

# loop with callback to print_event
b["events"].open_perf_buffer(print_event)
while 1:
    try:
        b.perf_buffer_poll()
    except KeyboardInterrupt:
        exit()
```