+++
title = "排序"
date =  2022-11-03T18:04:04+08:00
description= "description"
weight = 5
+++

- [冒泡](#冒泡)
- [选择排序](#选择排序)
- [插入排序](#插入排序)
- [希尔排序](#希尔排序)
- [归并](#归并)
- [快排](#快排)
- [堆排序](#堆排序)

## 冒泡
```python
def bubbleSort(nums):
  for i in range(len(nums)-1):
    for j in range(len(nums)-i-1):
        if nums[j]>nums[j+1]:
            nums[j],nums[j+1] = nums[j+1],nums[j]
  return nums
```

## 选择排序
```python
def selectionSort(nums):
  for i in range(len(nums)-1):
    minIndex = i
    for j in range(i+1,len(nums)):
        if nums[j]<minIndex:
            minIndex = j
    nums[i],nums[minIndex] = nums[minIndex],nums[i]
  return nums
```
## 插入排序
```python
def insertionSort(nums):
  for i in range(len(nums)-1):
    curNum,preIndex = nums[i+1],i
    while preIndex>=0 and curNum < nums[preIndex]:
      nums[preIndex+1] = nums[preIndex]
      preIndex-=1
    nums[preIndex+1] = curNum
  return nums
```
## 希尔排序
```python
def shellSort(nums):
    n = len(nums)
    gap = n//2
    while gap > 0:
        for i in range(gap,n): 
            curNum,preIndex = nums[i],i
            while  preIndex >= gap and  curNum < nums[preIndex-gap]: 
                nums[preIndex] = nums[preIndex-gap] 
                preIndex -= gap 
            nums[preIndex] = curNum 
        gap = gap//2
```
## 归并
```python
def mergeSort(nums):
  def merge(left,right):
    result = []
    i=j=0
    while i< len(left) and j < (right):
        if left[i]<=right[j]:
            result.append[left[i]]
            i+=1
        else:
            result.append[right[j]]
            j+=1
    result = result + left[i:] + right[j:]
    return result
  if len(nums)<=1:
    return nums
  mid = len(nums)//2
  left = mergeSort(nums[:mid])
  right = mergeSort(nums[mid:])
  return merge(left,right)
```
## 快排
```python
def quickSort(nums):
    if len(nums)<=1:
        return nums
    pivot = nums[0]
    left = [nums[i] for i in range(len(nums)) if nums[i]<=pivot]
    right = [nums[i] for i in range(len(nums)) if nums[i]>pivot]
    return quickSort(left)+[pivot]+quickSort(right)
```
## 堆排序
```python
def heapSort(nums):
  def adjustHeap(nums,i,size):
    lchild = 2*i+1
    rchild = 2*i+2
    lagest = i
    if lchild<size and nums[lchild]>nums[lagest]:
        lagest = lchild
    if rchild < size and nums[rchild]> nums[lagest]:
        lagest = rchild
    if lagest!=i:
        nums[lagest],nums[i] =  nums[i],nums[lagest]
    adjustHeap(nums,lagest,size)

  def buildHeap(nums,size):
    for i in range(len(nums)//2)[::-1]: ## 从最后节点开始建堆
        adjustHeap(nums,i,size)
  size = len(nums)
  buildHeap(nums,size)
  for i in range(len(nums))[::-1]:
    nums[0],nums[i] =  nums[i],nums[0]  ## 将最后的元素调整到第一个值
    adjustHeap(nums,0,size) ## 从0个元素开始调整堆
  return nums
```