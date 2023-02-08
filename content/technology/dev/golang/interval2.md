+++
title = "Interval2"
date =  2022-11-11T18:32:07+08:00
description= "description"
weight = 5
+++

- [1. 相比较于其他语言, Go 有什么优势或者特点？](#1-相比较于其他语言-go-有什么优势或者特点)
- [2. Golang 里的 GMP 模型？](#2-golang-里的-gmp-模型)
- [3. goroutine 的协程有什么特点，和线程相比？](#3-goroutine-的协程有什么特点和线程相比)
- [4. Go 的垃圾回收机制？](#4-go-的垃圾回收机制)
- [5. go 的内存分配是怎么样的？](#5-go-的内存分配是怎么样的)
- [6. channel 的内部实现是怎么样的？](#6-channel-的内部实现是怎么样的)
- [7. 对已经关闭的 channel 进行读写，会怎么样？](#7-对已经关闭的-channel-进行读写会怎么样)
- [8. map 为什么是不安全的？](#8-map-为什么是不安全的)
- [9. map 的 key 为什么得是可比较类型的？](#9-map-的-key-为什么得是可比较类型的)
- [10. mutex 的正常模式、饥饿模式、自旋？](#10-mutex-的正常模式饥饿模式自旋)
- [11. Go 的逃逸行为是指(内存逃逸)？](#11-go-的逃逸行为是指内存逃逸)
- [12. context 使用场景及注意事项](#12-context-使用场景及注意事项)
- [13. context 是如何一层一层通知子 context](#13-context-是如何一层一层通知子-context)
- [14. waitgroup 原理](#14-waitgroup-原理)
- [15. sync.Once 原理](#15-synconce-原理)
- [16. 定时器原理](#16-定时器原理)
- [17. gorouinte 泄漏有哪些场景](#17-gorouinte-泄漏有哪些场景)
- [18. Slice 注意点](#18-slice-注意点)
- [19. make 和 new 的区别](#19-make-和-new-的区别)
- [20. defer、panic、recover 三者的用法](#20-deferpanicrecover-三者的用法)
- [21 slice 和 array 的区别](#21-slice-和-array-的区别)

## 1. 相比较于其他语言, Go 有什么优势或者特点？

- Go 允许跨平台编译，编译出来的是二进制的可执行文件，直接部署在对应系统上即可运行。
- Go 在语言层次上天生支持高并发，通过 goroutine 和 channel 实现。channel 的理论依据是 CSP 并发模型， 即所谓的通过通信来共享内存；Go 在 runtime 运行时里实现了属于自己的调度机制：GMP，降低了内核态和用户态的切换成本。
- Go 的代码风格是强制性的统一，如果没有按照规定来，会编译不通过。

## 2. Golang 里的 GMP 模型？

GMP 模型是 golang 自己的一个调度模型，它抽象出了下面三个结构：

- G： 也就是协程 goroutine，由 Go runtime 管理。我们可以认为它是用户级别的线程。
- P： processor 处理器。每当有 goroutine 要创建时，会被添加到 P 上的 goroutine 本地队列上，如果 P 的本地队列已满，则会维护到全局队列里。
- M： 系统线程。在 M 上有调度函数，它是真正的调度执行者，M 需要跟 P 绑定，并且会让 P 按下面的原则挑出个 goroutine 来执行：
优先从 P 的本地队列获取 goroutine 来执行；如果本地队列没有，从全局队列获取，如果全局队列也没有，会从其他的 P 上偷取 goroutine。


## 3. goroutine 的协程有什么特点，和线程相比？

goroutine 非常的轻量，初始分配只有 2KB，当栈空间不够用时，会自动扩容。同时，自身存储了执行 stack 信息，用于在调度时能恢复上下文信息。

而线程比较重，一般初始大小有几 MB(不同系统分配不同)，线程是由操作系统调度，是操作系统的调度基本单位。而 golang 实现了自己的调度机制，goroutine 是它的调度基本单位。

## 4. Go 的垃圾回收机制？

Go 采用的是三色标记法，将内存里的对象分为了三种：

白色对象：未被使用的对象；
灰色对象：当前对象有引用对象，但是还没有对引用对象继续扫描过；
黑色对象，对上面提到的灰色对象的引用对象已经全部扫描过了，下次不用再扫描它了。
当垃圾回收开始时，Go 会把根对象标记为灰色，其他对象标记为白色，然后从根对象遍历搜索，按照上面的定义去不断的对灰色对象进行扫描标记。当没有灰色对象时，表示所有对象已扫描过，然后就可以开始清除白色对象了。

## 5. go 的内存分配是怎么样的？

Go 的内存分配借鉴了 Google 的 TCMalloc 分配算法，其核心思想是内存池 + 多级对象管理。内存池主要是预先分配内存，减少向系统申请的频率；多级对象有：mheap、mspan、arenas、mcentral、mcache。它们以 mspan 作为基本分配单位。具体的分配逻辑如下：

当要分配大于 32K 的对象时，从 mheap 分配。
当要分配的对象小于等于 32K 大于 16B 时，从 P 上的 mcache 分配，如果 mcache 没有内存，则从 mcentral 获取，如果 mcentral 也没有，则向 mheap 申请，如果 mheap 也没有，则从操作系统申请内存。
当要分配的对象小于等于 16B 时，从 mcache 上的微型分配器上分配。

## 6. channel 的内部实现是怎么样的？

channel 内部维护了两个 goroutine 队列，一个是待发送数据的 goroutine 队列，另一个是待读取数据的 goroutine 队列。

每当对 channel 的读写操作超过了可缓冲的 goroutine 数量，那么当前的 goroutine 就会被挂到对应的队列上，直到有其他 goroutine 执行了与之相反的读写操作，将它重新唤起。

## 7. 对已经关闭的 channel 进行读写，会怎么样？

当 channel 被关闭后，如果继续往里面写数据，程序会直接 panic 退出。如果是读取关闭后的 channel，不会产生 pannic，还可以读到数据。但关闭后的 channel 没有数据可读取时，将得到零值，即对应类型的默认值。

为了能知道当前 channel 是否被关闭，可以使用下面的写法来判断。
```golang
    if v, ok := <-ch; !ok {
        fmt.Println("channel 已关闭，读取不到数据")
    }
```
还可以使用下面的写法不断的获取 channel 里的数据：
```golang
    for data := range ch {
        // get data dosomething
    }
```
这种用法会在读取完 channel 里的数据后就结束 for 循环，执行后面的代码。

## 8. map 为什么是不安全的？
map 在扩缩容时，需要进行数据迁移，迁移的过程并没有采用锁机制防止并发操作，而是会对某个标识位标记为 1，表示此时正在迁移数据。如果有其他 goroutine 对 map 也进行写操作，当它检测到标识位为 1 时，将会直接 panic。

如果我们想要并发安全的 map，则需要使用 sync.map。

## 9. map 的 key 为什么得是可比较类型的？
map 的 key、value 是存在 buckets 数组里的，每个 bucket 又可以容纳 8 个 key 和 8 个 value。当要插入一个新的 key - value 时，会对 key 进行 hash 运算得到一个 hash 值，然后根据 hash 值 的低几位(取几位取决于桶的数量，比如一开始桶的数量是 5，则取低 5 位)来决定命中哪个 bucket。

在命中某个 bucket 后，又会根据 hash 值的高 8 位来决定是 8 个 key 里的哪个位置。如果不巧，发生了 hash 冲突，即该位置上已经有其他 key 存在了，则会去其他空位置寻找插入。如果全都满了，则使用 overflow 指针指向一个新的 bucket，重复刚刚的寻找步骤。

从上面的流程可以看出，在判断 hash 冲突，即该位置是否已有其他 key 时，肯定是要进行比较的，所以 key 必须得是可比较类型的。像 slice、map、function 就不能作为 key。

## 10. mutex 的正常模式、饥饿模式、自旋？

mutex有两种模式：normal 和 starvation

**正常模式**

当 mutex 调用 Unlock() 方法释放锁资源时，如果发现有正在阻塞并等待唤起的 Goroutine 队列时，则会将队头的 Goroutine 唤起。队头的 goroutine 被唤起后，会采用 CAS 这种乐观锁的方式去修改占有标识位，如果修改成功，则表示占有锁资源成功了，当前占有成功的 goroutine 就可以继续往下执行了。

**饥饿模式**

由于上面的 Goroutine 唤起后并不是直接的占用资源，而是使用 CAS 方法去尝试性占有锁资源。如果此时有新来的 Goroutine，那么它也会调用 CAS 方法去尝试性的占有资源。对于 Go 的并发调度机制来讲，会比较偏向于 CPU 占有时间较短的 Goroutine 先运行，即新来的 Goroutine 比较容易占有资源，而队头的 Goroutine 一直占用不到，导致饿死。

针对这种情况，Go 采用了饥饿模式。即通过判断队头 Goroutine 在超过一定时间后还是得不到资源时，会在 Unlock 释放锁资源时，直接将锁资源交给队头 Goroutine，并且将当前状态改为饥饿模式。

后面如果有新来的 Goroutine 发现是饥饿模式时， 则会直接添加到等待队列的队尾。

**自旋**

如果 Goroutine 占用锁资源的时间比较短，那么每次释放资源后，都调用信号量来唤起正在阻塞等候的 goroutine，将会很浪费资源。

因此在符合一定条件后，mutex 会让等候的 Goroutine 去空转 CPU，在空转完后再次调用 CAS 方法去尝试性的占有锁资源，直到不满足自旋条件，则最终才加入到等待队列里。

## 11. Go 的逃逸行为是指(内存逃逸)？

在传统的编程语言里，会根据程序员指定的方式来决定变量内存分配是在栈还是堆上，比如声明的变量是值类型，则会分配到栈上，或者 new 一个对象则会分配到堆上。

在 Go 里变量的内存分配方式则是由编译器来决定的。如果变量在作用域（比如函数范围）之外，还会被引用的话，那么称之为发生了逃逸行为，此时将会把对象放到堆上，即使声明为值类型；如果没有发生逃逸行为的话，则会被分配到栈上，即使 new 了一个对象。

golang程序变量会携带有一组校验数据，用来证明它的整个生命周期是否在运行时完全可知。如果变量通过了这些校验，它就可以在栈上分配。否则就说它 逃逸 了，必须在堆上分配。

能引起变量逃逸到堆上的典型情况：

- 在方法内把局部变量指针返回 局部变量原本应该在栈中分配，在栈中回收。但是由于返回时被外部引用，因此其生命周期大于栈，则溢出。
- 发送指针或带有指针的值到 channel 中。 在编译时，是没有办法知道哪个 goroutine 会在 channel 上接收数据。所以编译器没法知道变量什么时候才会被释放。
- 在一个切片上存储指针或带指针的值。 一个典型的例子就是 []*string 。这会导致切片的内容逃逸。尽管其后面的数组可能是在栈上分配的，但其引用的值一定是在堆上。
- slice 的背后数组被重新分配了，因为 append 时可能会超出其容量( cap )。 slice 初始化的地方在编译时是可以知道的，它最开始会在栈上分配。如果切片背后的存储要基于运行时的数据进行扩充，就会在堆上分配。
- 在 interface 类型上调用方法。 在 interface 类型上调用方法都是动态调度的 —— 方法的真正实现只能在运行时知道。想像一个 io.Reader 类型的变量 r , 调用 r.Read(b) 会使得 r 的值和切片b 的背后存储都逃逸掉，所以会在堆上分配。


## 12. context 使用场景及注意事项

Go 里的 context 有 cancelCtx 、timerCtx、valueCtx。它们分别是用来通知取消、通知超时、存储 key - value 值。context 的 注意事项如下：

- context 的 Done() 方法往往需要配合 select {} 使用，以监听退出。
- 尽量通过函数参数来暴露 context，不要在自定义结构体里包含它。
- WithValue 类型的 context 应该尽量存储一些全局的 data，而不要存储一些可有可无的局部 data。
- context 是并发安全的。
- 一旦 context 执行取消动作，所有派生的 context 都会触发取消。

## 13. context 是如何一层一层通知子 context

当 ctx, cancel := context.WithCancel(父Context)时，会将当前的 ctx 挂到父 context 下，然后开个 goroutine 协程去监控父 context 的 channel 事件，一旦有 channel 通知，则自身也会触发自己的 channel 去通知它的子 context， 关键代码如下
```golang
go func() {
            select {
            case <-parent.Done():
                child.cancel(false, parent.Err())
            case <-child.Done():
            }
    }()
```

## 14. waitgroup 原理

waitgroup 内部维护了一个计数器，当调用 wg.Add(1) 方法时，就会增加对应的数量；当调用 wg.Done() 时，计数器就会减一。直到计数器的数量减到 0 时，就会调用
runtime_Semrelease 唤起之前因为 `wg.Wait()` 而阻塞住的 `goroutine`。

## 15. sync.Once 原理

内部维护了一个标识位，当它 == 0 时表示还没执行过函数，此时会加锁修改标识位，然后执行对应函数。后续再执行时发现标识位 != 0，则不会再执行后续动作了。关键代码如下：

```golang
type Once struct {
    done uint32
    m    Mutex
}

func (o *Once) Do(f func()) {
    // 原子加载标识值，判断是否已被执行过
    if atomic.LoadUint32(&o.done) == 0 {
        o.doSlow(f)
    }
}

func (o *Once) doSlow(f func()) { // 还没执行过函数
    o.m.Lock()
    defer o.m.Unlock()
    if o.done == 0 { // 再次判断下是否已被执行过函数
        defer atomic.StoreUint32(&o.done, 1) // 原子操作：修改标识值
        f() // 执行函数
    }
}
```

## 16. 定时器原理

一开始，timer 会被分配到一个全局的 timersBucket 时间桶。每当有 timer 被创建出来时，就会被分配到对应的时间桶里了。

为了不让所有的 timer 都集中到一个时间桶里，Go 会创建 64 个这样的时间桶，然后根据 当前 timer 所在的 Goroutine 的 P 的 id 去哈希到某个桶上：

```golang
// assignBucket 将创建好的 timer 关联到某个桶上
func (t *timer) assignBucket() *timersBucket {
    id := uint8(getg().m.p.ptr().id) % timersLen
    t.tb = &timers[id].timersBucket
    return t.tb
}
```

接着 timersBucket 时间桶将会对这些 timer 进行一个最小堆的维护，每次会挑选出时间最快要达到的 timer。如果挑选出来的 timer 时间还没到，那就会进行 sleep 休眠；如果 timer 的时间到了，则执行 timer 上的函数，并且往 timer 的 channel 字段发送数据，以此来通知 timer 所在的 goroutine。

## 17. gorouinte 泄漏有哪些场景

gorouinte 里有关于 channel 的操作，如果没有正确处理 channel 的读取，会导致 channel 一直阻塞住, goroutine 不能正常结束

协程泄漏是指协程创建之后没有得到释放。主要原因有：

- 缺少接收器，导致发送阻塞
- 缺少发送器，导致接收阻塞
- 死锁。多个协程由于竞争资源导致死锁。
- 创建协程的没有回收。

## 18. Slice 注意点

**Slice 的扩容机制**

如果 Slice 要扩容的容量大于 2 倍当前的容量，则直接按想要扩容的容量来 new 一个新的 Slice，否则继续判断当前的长度 len，如果 len 小于 1024，则直接按 2 倍容量来扩容，否则一直循环新增 1/4，直到大于想要扩容的容量。主要代码如下：
```golang
newcap := old.cap
doublecap := newcap + newcap
if cap > doublecap {
    newcap = cap
} else {
    if old.len < 1024 {
        newcap = doublecap
    } else {
        for newcap < cap {
            newcap += newcap / 4
        }
    }
}
```

除此之外，还会根据 slice 的类型做一些内存对齐的调整，以确定最终要扩容的容量大小。

Slice 的一些注意写法
```golang
// =========== 第一种

a := make([]string, 5)
fmt.Println(len(a), cap(a))   //  输出5   5

a = append(a, "aaa")
fmt.Println(len(a), cap(a))   // 输出6  10


// 总结： 由于make([]string, 5) 则默认会初始化5个 空的"", 因此后面 append 时，则需要2倍了


// =========== 第二种
a:=[]string{}
fmt.Println(len(a), cap(a))   //  输出0   0

a = append(a, "aaa")
fmt.Println(len(a), cap(a))   // 输出1  1

// 总结：由于[]string{}, 没有其他元素， 所以append 按 需要扩容的 cap 来

// =========== 第三种
a := make([]string, 0, 5)
fmt.Println(len(a), cap(a))   //  输出0   5

a = append(a, "aaa")
fmt.Println(len(a), cap(a))   // 输出1  5

// 总结：注意和第一种的区别，这里不会默认初始化5个，所以后面的append容量是够的，不用扩容

// =========== 第四种
b := make([]int, 1, 3)
a := []int{1, 2, 3}
copy(b, a)

fmt.Println(len(b))  // 输出1

// 总结：copy 取决于较短 slice 的 len, 一旦最小的len结束了，也就不再复制了
```

**range slice**

以下代码的执行是不会一直循环下去的，原因在于 range 的时候会 copy 这个 slice 上的 len 属性到一个新的变量上，然后根据这个 copy 值去遍历 slice，因此遍历期间即使 slice 添加了元素，也不会改变这个变量的值了。

```golang
v := []int{1, 2, 3}
for i := range v {
    v = append(v, i)
}
```

另外，range 一个 slice 的时候是进行一个值拷贝的，如果 slice 里存储的是指针集合，那在 遍历里修改是有效的，如果 slice 存储的是值类型的集合，那么就是在 copy 它们的副本，期间的修改也只是在修改这个副本，跟原来的 slice 里的元素是没有关系的。

**slice 入参注意点**

如果 slice 作为函数的入参，通常希望对 slice 的操作可以影响到底层数据，但是如果在函数内部 append 数据超过了 cap，导致重新分配底层数组，这时修改的 slice 将不再是原来入参的那个 slice 了。因此通常不建议在函数内部对 slice 有 append 操作，若有需要则显示的 return 这个 slice。

## 19. make 和 new 的区别
new 是返回某个类型的指针，将会申请某个类型的内存。而 make 只能用于 slice, map, channel 这种 golang 内部的数据结构，它们可以只声明不初始化，或者初始化时指定一些特定的参数，比如 slice 的长度、容量；map 的长度；channel 的缓冲数量等。

## 20. defer、panic、recover 三者的用法

defer 函数调用的顺序是后进先出，当产生 panic 的时候，会先执行 panic 前面的 defer 函数后才真的抛出异常。一般的，recover 会在 defer 函数里执行并捕获异常，防止程序崩溃。

package main

import "fmt"

func main() {
    defer func(){
       fmt.Println("b")
    }()

    defer func() {
       if err := recover(); err != nil {
            fmt.Println("捕获异常:", err)
        }
    }()

    panic("a")
}

// 输出
// 捕获异常: a
// b

## 21 slice 和 array 的区别

array 是固定长度的数组，并且是值类型的，也就是说是拷贝复制的， slice 是一个引用类型，指向了一个动态数组的指针，会进行动态扩容。
