+++
title = "查找"
date =  2022-11-03T19:04:18+08:00
description= "description"
weight = 5
+++

- [二分查找](#二分查找)
- [二分查找非递归](#二分查找非递归)
- [回溯法](#回溯法)
- [大数相加](#大数相加)

## 二分查找
```python
def binarySearch(nums,findVal):
    def binaryServerVal(nums,left,right,findVal):
        if left>right:
            return -1 # not find
        mid = (right+left)//2
        midVal = nums[mid]
        if findVal>midVal:
            return binaryServerVal(nums,mid,right,findVal)
        elif findVal<midVal:
            return binaryServerVal(nums,left,mid,findVal)
        else: # equal
            return mid
    
    left = 0
    right = len(nums)
    return binaryServerVal(nums,left,right,findVal)
```
## 二分查找非递归
```python
def binarySearch2(nums,findVal):
    left = 0
    right = len(nums)
    while  left < right:
        mid = (right+left)//2
        if nums[mid]>findVal:
            left = mid+1
        elif nums[mid]<findVal:
            right = mid-1
        else:
            return mid
    return -1

```
## 回溯法
```python
def permute(self, nums):
    """
    46.permutations 对没有重复数字的数组 进行全排列
    """
    if len(nums) == 0:
        return []

    res = []

    def _backtrace(nums, pre_list):
        """
        回溯 从待选列表中选取加入
        :param nums: 待选列表
        :param pre_list: 已经加入的
        :return:
        """
        # 出口  已经选取完毕，记录结果
        if len(nums) <= 0:
            res.append(pre_list.copy())  # 这里一定要注意 是把copy的赋给res，不然res会随着pre_list而改变
            return
        else:
            for i in range(len(nums)):
                # 1.做选择
                pre_list.append(nums[i])
                left_nums = nums.copy()
                left_nums.remove(nums[i])  # 没有重复元素，可以用remove从待选列表把该数删除
                # 2.递归
                _backtrace(left_nums, pre_list)
                # 3.撤销选择
                pre_list.pop()  # return之后 pop上个已遍历过的元素

    _backtrace(nums, [])
    return res

```
## 大数相加
```python
def bigNumAdd(num1, num2):
    str_num1 = str(num1)
    str_num2 = str(num2)
    res = []
    add = 0
    for i in range(len(str_num1))[::-1]:
        for j in range(len(str_num2))[::-1]:
            oneplus = int(num1[i])+int(num2[j])+add
            add = 0
            upper = oneplus//10
            if upper>0:
                res.append(oneplus%10)
                add = oneplus//10
            else:
              res.append(oneplus)
    return res[::-1]


