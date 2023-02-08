+++
title = "链表"
date =  2022-11-21T20:23:40+08:00
description= "description"
weight = 5
+++
- [1. 反转链表](#1-反转链表)
- [2. 删除链表的倒数第 N 个结点](#2-删除链表的倒数第-n-个结点)

## 1. 反转链表

```python
class Solution(object):
	def reverseList(self, head):
		"""
		:type head: ListNode
		:rtype: ListNode
		"""
		# 申请两个节点，pre和 cur，pre指向None
		pre = None
		cur = head
		# 遍历链表，while循环里面的内容其实可以写成一行
		# 这里只做演示，就不搞那么骚气的写法了
		while cur:
			# 记录当前节点的下一个节点
			tmp = cur.next
			# 然后将当前节点指向pre
			cur.next = pre
			# pre和cur节点都前进一位
			pre = cur
			cur = tmp
		return pre	
```

## 2. 删除链表的倒数第 N 个结点

使用堆栈，先进后出

```python
class Solution:
    def removeNthFromEnd(self, head: ListNode, n: int) -> ListNode:
        dummy = ListNode(0, head)
        stack = list()
        cur = dummy
        while cur:
            stack.append(cur)
            cur = cur.next
        
        for i in range(n):
            stack.pop()

        prev = stack[-1]
        prev.next = prev.next.next
        return dummy.next
```