+++
title = "数组"
date =  2022-11-03T18:13:07+08:00
description= "description"
weight = 5
+++

- [1. 两数和](#1-两数和)
- [2. 三数和](#2-三数和)
- [3. 四数和](#3-四数和)
- [4.  最大子数列和 最大子数组和](#4--最大子数列和-最大子数组和)
- [5. 搜索旋转数组](#5-搜索旋转数组)
- [6. 数组中的众数](#6-数组中的众数)
- [7. 两个正序数组中的中位数](#7-两个正序数组中的中位数)
- [8.  两个数组的最长重复子数组（动态规划)](#8--两个数组的最长重复子数组动态规划)
- [9. 两个数组的最长子数组（滑动窗口）](#9-两个数组的最长子数组滑动窗口)
- [10. 合并两个有序数组 归并和](#10-合并两个有序数组-归并和)
- [11. 接雨水](#11-接雨水)
- [12.买卖股票最佳时机](#12买卖股票最佳时机)
- [13. 合并区间](#13-合并区间)
- [14. 下一个排列](#14-下一个排列)
- [15. 最小路径和 动态规划 或者广搜](#15-最小路径和-动态规划-或者广搜)
- [16. 在排序数组中查找元素的第一个和最后一个位置  二分查找](#16-在排序数组中查找元素的第一个和最后一个位置--二分查找)
- [17. 寻找旋转排序数组中的最小值 二分查找](#17-寻找旋转排序数组中的最小值-二分查找)
- [18. 寻找峰值 查找最大值](#18-寻找峰值-查找最大值)
- [19. 矩阵置零 标记0的位置，然后置零行列](#19-矩阵置零-标记0的位置然后置零行列)
- [20. 第三大的数 有序集合](#20-第三大的数-有序集合)
- [21. 跳跃游戏](#21-跳跃游戏)
- [22. 删除重复元素](#22-删除重复元素)
- [23. 查找超过百分比的数](#23-查找超过百分比的数)
- [24. 交换得到最大](#24-交换得到最大)
- [25. 最长连续序列](#25-最长连续序列)
- [26. 除自身以外数组的乘积](#26-除自身以外数组的乘积)
- [27. 子集 所有排列可能](#27-子集-所有排列可能)
- [28. 盛最多水的容器](#28-盛最多水的容器)
- [29. 数组全排列](#29-数组全排列)
- [30. 插入区间](#30-插入区间)
- [31. 乘积最大子数组](#31-乘积最大子数组)
- [32. 长度最小的子数组 滑动窗口](#32-长度最小的子数组-滑动窗口)
- [33. 和为K的子数组 前缀法](#33-和为k的子数组-前缀法)
- [34.和为K的子数组 暴力法](#34和为k的子数组-暴力法)
- [35. 组合总和  回溯法遍历 组合等于](#35-组合总和--回溯法遍历-组合等于)
- [36. 乘积小于 K 的子数组](#36-乘积小于-k-的子数组)
- [37. 数组中第k大的元素](#37-数组中第k大的元素)

```
from ast import List
```

## 1. 两数和
```python
def twoSum(self, nums: List[int], target: int) -> List[int]:
    tg = dict()
    for key, value in enumerate(nums):
        if target - value in tg:
            return [tg[target-nums], key]
        tg[value] = key
    return []
```
## 2. 三数和
```python
def threeSum(self, nums: List[int]) -> List[List[int]]:
    n = len(nums)
    nums.sort()
    ans = list()
    for first in range(n):
        if first > 0 and nums[first] == nums[first-1]:
            continue
        third = n - 1
        target = -nums[first]
        for second in range(first+1, n):
            if second > first+1 and nums[second] == nums[second-1]:
                continue
        while third > second and nums[second] + nums[third] > target:
            third -= 1
        if second == third:
            break
        if nums[second] + nums[third] == target:
            ans.append([nums[first], nums[second], nums[third]])
    return ans
```
## 3. 四数和
```python
def fourSum(self, nums: List[int], target: int) -> List[List[int]]:
    quadruplets = list()
    if not nums or len(nums) < 4:
        return quadruplets
    
    nums.sort()
    length = len(nums)
    for i in range(length - 3):
        if i > 0 and nums[i] == nums[i - 1]:
            continue
        if nums[i] + nums[i + 1] + nums[i + 2] + nums[i + 3] > target:
            break
        if nums[i] + nums[length - 3] + nums[length - 2] + nums[length - 1] < target:
            continue
        for j in range(i + 1, length - 2):
            if j > i + 1 and nums[j] == nums[j - 1]:
                continue
            if nums[i] + nums[j] + nums[j + 1] + nums[j + 2] > target:
                break
            if nums[i] + nums[j] + nums[length - 2] + nums[length - 1] < target:
                continue
            left, right = j + 1, length - 1
            while left < right:
                total = nums[i] + nums[j] + nums[left] + nums[right]
                if total == target:
                    quadruplets.append([nums[i], nums[j], nums[left], nums[right]])
                    while left < right and nums[left] == nums[left + 1]:
                        left += 1
                    left += 1
                    while left < right and nums[right] == nums[right - 1]:
                        right -= 1
                    right -= 1
                elif total < target:
                    left += 1
                else:
                    right -= 1
    
    return quadruplets
```
## 4.  最大子数列和 最大子数组和
```python
def maxSubArray(self, nums: List[int]) -> int:
    size=len(nums)
    if size==0:
        return 0
    dp = [0 for _ in range(size)]
    dp[0] = nums[0]
    for i in range(i,size):
        if dp[i-1]>=0:
            dp[i] = dp[i-1]+nums[i]
        else:
            dp[i] = nums[i]
    return max(dp)
```
## 5. 搜索旋转数组
```python
def search(self, nums: List[int], target: int) -> int:
    if not nums:
        return -1
    l,r = 0, len(nums)-1
    while l<r:
        mid = (l+r)//2
        if nums[mid] == target:
            return mid
        if nums[0]<=nums[mid]:
            if nums[0]<= target<=nums[mid]:
                r = mid-1
            else:
                l = mid +1
        else:
            if nums[mid]<=target<=nums[-1]:
                l = mid + 1
            else:
                r = mid - 1
    return -1
```
## 6. 数组中的众数
```python
def majorityElement(self, nums: List[int]) -> int:
    dt = dict()
    pix = len(nums)/2
    for i in range(len(nums)):
        if nums[i] not in dt.keys():
            dt[nums[i]] = 1
        else:
            dt[nums[i]]+=1
            if dt[nums[i]]>=pix:
                return nums[i]
    return -1
```
##  7. 两个正序数组中的中位数
```python
def findMedianSortedArrays(self, nums1: List[int], nums2: List[int]) -> float:
    def merge(n1,n2):
        res=[]
        i=j=0
        while i<len(n1) and j<len(n2):
            if n1[i]>n2[j]:
                res.append(n2[j])
                j+=1
            else:
                res.append(n1[i])
                i+=1
        return res+n1[i:]+n2[j:]
    len_nums1 = len(nums1)
    len_nums2 = len(nums2)
    left=right = (len_nums2+len_nums1) // 2
    lf = (len_nums2+len_nums1) % 2
    if lf>0:
        left+=1
        right+=1
    else:
        right+=1
    res=merge(nums1,nums2)
    return (res[left-1]+res[right-1])/2.0
```
##  8.  两个数组的最长重复子数组（动态规划)
```python
def findLength(self, A: List[int], B: List[int]) -> int:
    n,m = len(A),len(B)
    dp = [[0]*m+1 for _ in range(n+1)]
    ans = 0
    for i in range(n-1,-1,-1):
        for j in range(m-1,-1,-1):
            dp[i][j] = dp[i+1][j+1]+1 if A[i] == B[j] else  0
            ans = max(ans, dp[i][j])
    return ans
```
##  9. 两个数组的最长子数组（滑动窗口）
```python
def findLength2(self, A: List[int], B: List[int]) -> int:
    def maxLength(addA: int,addB:int, length: int) -> int:
        ret=k=0
        for i in range(length):
            if A[addA+i] == B[addB+i]:
                k+=1
            else:
                k = 0
        return ret
    n,m= len(A),len(B)
    ret = 0
    for i in range(n):
        length = min(n-i,m)
        ret = maxLength(i,0,length)
    for j in range(m):
        length = min(n,m-i)
        ret = maxLength(0,j.length)
    return ret
```
##  10. 合并两个有序数组 归并和
```python
def merge(self, nums1: List[int], m: int, nums2: List[int], n: int) -> None:
    """
    Do not return anything, modify nums1 in-place instead.
    """
    res = []
    i = j =0
    while i < m and j < n:
        if nums1[i]<=nums2[j]:
            res.append(nums1[i])
            i+=1
        else:
            res.append(nums2[j])
            j+=1
    return res + nums1[i:] + nums2[j:]
```
##  11. 接雨水
```python
def trap(self, height: List[int]) -> int:
    ans = 0
    left, right = 0, len(height) - 1
    leftMax = rightMax = 0

    while left < right:
        leftMax = max(leftMax, height[left])
        rightMax = max(rightMax, height[right])
        if height[left] < height[right]:
            ans += leftMax - height[left]
            left += 1
        else:
            ans += rightMax - height[right]
            right -= 1
    
    return ans
```
##  12.买卖股票最佳时机
```python
def maxProfit(self, prices: List[int]) -> int:
    inf = int(1e9)
    minprice = inf
    maxprofit = 0
    for price in prices:
        maxprofit = max(price - minprice, maxprofit)
        minprice = min(price, minprice)
    return maxprofit
```
##  13. 合并区间
```python
def merge(self, intervals: List[List[int]]) -> List[List[int]]:
    intervals.sort(key=lambda x: x[0])

    merged = []
    for interval in intervals:
        ##  如果列表为空，或者当前区间与上一区间不重合，直接添加
        if not merged or merged[-1][1] < interval[0]:
            merged.append(interval)
        else:
            ##  否则的话，我们就可以与上一区间进行合并
            merged[-1][1] = max(merged[-1][1], interval[1])

    return merged
```
##  14. 下一个排列
```python
def nextPermutation(self, nums: List[int]) -> None:
    i = len(nums) - 2
    while i >= 0 and nums[i] >= nums[i + 1]:
        i -= 1
    if i >= 0:
        j = len(nums) - 1
        while j >= 0 and nums[i] >= nums[j]:
            j -= 1
        nums[i], nums[j] = nums[j], nums[i]
    
    left, right = i + 1, len(nums) - 1
    while left < right:
        nums[left], nums[right] = nums[right], nums[left]
        left += 1
        right -= 1
```
##  15. 最小路径和 动态规划 或者广搜
```python
def minPathSum(self, grid: List[List[int]]) -> int:
    for i in range(len(grid)):
        for j in range(len(grid[0])):
            if i == j == 0: continue
            elif i == 0:  grid[i][j] = grid[i][j - 1] + grid[i][j]
            elif j == 0:  grid[i][j] = grid[i - 1][j] + grid[i][j]
            else: grid[i][j] = min(grid[i - 1][j], grid[i][j - 1]) + grid[i][j]
    return grid[-1][-1]
```
##  16. 在排序数组中查找元素的第一个和最后一个位置  二分查找
```python
def searchRange(self, nums: List[int], target: int) -> List[int]:
    left = nums.index(target)
    if left == len(nums) or nums[left]!=target:
        return [-1,-1]
    right = nums.index(target+1,left)-1
    return [left,right]
```
##  17. 寻找旋转排序数组中的最小值 二分查找
```python
def findMin(self, nums: List[int]) -> int:    
    low, high = 0, len(nums) - 1
    while low < high:
        pivot = low + (high - low) // 2
        if nums[pivot] < nums[high]: ##  有序的后段
            high = pivot  ##  截掉后段 保留最后一个元素
        else:
            low = pivot + 1
    return nums[low]
```
##  18. 寻找峰值 查找最大值
```python
def findPeakElement(self, nums: List[int]) -> int:
    idx = 0
    for i in range(1, len(nums)):
        if nums[i] > nums[idx]:
            idx = i
    return idx
```
##  19. 矩阵置零 标记0的位置，然后置零行列
```python
def setZeroes(self, matrix: List[List[int]]) -> None:
    m, n = len(matrix), len(matrix[0])
    row, col = [False] * m, [False] * n

    for i in range(m):
        for j in range(n):
            if matrix[i][j] == 0:
                row[i] = col[j] = True
    
    for i in range(m):
        for j in range(n):
            if row[i] or col[j]:
                matrix[i][j] = 0
```
##  20. 第三大的数 有序集合
```python
def thirdMax(self, nums: List[int]) -> int:
    from sortedcontainers import SortedList
    s = SortedList()
    for num in nums:
        if num not in s:
            s.add(num)
            if len(s) > 3:
                s.pop(0)
    return s[0] if len(s) == 3 else s[-1]
```
##  21. 跳跃游戏
```python
def jump(self, nums: List[int]) -> int:
    n = len(nums)
    maxPos, end, step = 0, 0, 0
    for i in range(n - 1):
        if maxPos >= i:
            maxPos = max(maxPos, i + nums[i])
            if i == end:
                end = maxPos
                step += 1
    return step
```
##  22. 删除重复元素
```python
def removeDuplicates(self, nums: List[int]) -> int:
    if not nums:
        return 0
    
    n = len(nums)
    fast = slow = 1
    while fast < n:
        if nums[fast] != nums[fast - 1]:
            nums[slow] = nums[fast]
            slow += 1
        fast += 1
    
    return slow
```
##  23. 查找超过百分比的数
```python
def findSpecialInteger(self, arr: List[int]) -> int:
    n = len(arr)
    cur, cnt = arr[0], 0
    for i in range(n):
        if arr[i] == cur:
            cnt += 1
            if cnt * 4 > n:
                return cur
        else:
            cur, cnt = arr[i], 1
    return -1
```
##  24. 交换得到最大
```python
def maximumSwap(self, num: int) -> int:
    ans = num
    s = list(str(num))
    for i in range(len(s)):
        for j in range(i):
            s[i], s[j] = s[j], s[i]
            ans = max(ans, int(''.join(s)))
            s[i], s[j] = s[j], s[i]
    return ans
```
##  25. 最长连续序列
```python
def longestConsecutive(self, nums: List[int]) -> int:
    longest_streak = 0
    num_set = set(nums)

    for num in num_set:
        if num - 1 not in num_set:
            current_num = num
            current_streak = 1

            while current_num + 1 in num_set:
                current_num += 1
                current_streak += 1

            longest_streak = max(longest_streak, current_streak)

    return longest_streak
```
##  26. 除自身以外数组的乘积
```python
def productExceptSelf(self, nums: List[int]) -> List[int]:
    length = len(nums)
    answer = [0]*length
    
    ##  answer[i] 表示索引 i 左侧所有元素的乘积
    ##  因为索引为 '0' 的元素左侧没有元素， 所以 answer[0] = 1
    answer[0] = 1
    for i in range(1, length):
        answer[i] = nums[i - 1] * answer[i - 1]
    
    ##  R 为右侧所有元素的乘积
    ##  刚开始右边没有元素，所以 R = 1
    R = 1;
    for i in reversed(range(length)):
        ##  对于索引 i，左边的乘积为 answer[i]，右边的乘积为 R
        answer[i] = answer[i] * R
        ##  R 需要包含右边所有的乘积，所以计算下一个结果时需要将当前值乘到 R 上
        R *= nums[i]
    
    return answer
```
##  27. 子集 所有排列可能
```python
def subsets(self, nums: List[int]) -> List[List[int]]:
    n = len(nums)
    ans = []
    for mask in range(1<<n):
        st = []
        for i,v in enumerate(nums):
            if mask>>i&1>0:
                st.append(v)
        ans.append(st)
    return ans
```
##  28. 盛最多水的容器
```python
def maxArea(self, height: List[int]) -> int:
    i, j, res = 0, len(height) - 1, 0
    while i < j:
        if height[i] < height[j]:
            res = max(res, height[i] * (j - i))
            i += 1
        else:
            res = max(res, height[j] * (j - i))
            j -= 1
    return res
```
##  29. 数组全排列
```python
def permute(self, nums):
    """
    :type nums: List[int]
    :rtype: List[List[int]]
    """
    def backtrack(first = 0):
        ##  所有数都填完了
        if first == n:  
            res.append(nums[:])
        for i in range(first, n):
            ##  动态维护数组
            nums[first], nums[i] = nums[i], nums[first]
            ##  继续递归填下一个数
            backtrack(first + 1)
            ##  撤销操作
            nums[first], nums[i] = nums[i], nums[first]
    
    n = len(nums)
    res = []
    backtrack()
    return res
```
##  30. 插入区间
```python
def insert(self, intervals: List[List[int]], newInterval: List[int]) -> List[List[int]]:
    left, right = newInterval
    placed = False
    ans = list()
    for li, ri in intervals:
        if li > right:
            ##  在插入区间的右侧且无交集
            if not placed:
                ans.append([left, right])
                placed = True
            ans.append([li, ri])
        elif ri < left:
            ##  在插入区间的左侧且无交集
            ans.append([li, ri])
        else:
            ##  与插入区间有交集，计算它们的并集
            left = min(left, li)
            right = max(right, ri)
    
    if not placed:
        ans.append([left, right])
    return ans
```
##  31. 乘积最大子数组
```python
def maxProduct(self, nums: List[int]) -> int:
    if not nums: return 
    res = nums[0]
    pre_max = nums[0]
    pre_min = nums[0]
    for num in nums[1:]:
        cur_max = max(pre_max * num, pre_min * num, num)
        cur_min = min(pre_max * num, pre_min * num, num)
        res = max(res, cur_max)
        pre_max = cur_max
        pre_min = cur_min
    return res
```
##  32. 长度最小的子数组 滑动窗口
```python
def minSubArrayLen(self, s: int, nums: List[int]) -> int:
    if not nums:
        return 0
    
    n = len(nums)
    ans = n + 1
    start, end = 0, 0
    total = 0
    while end < n:
        total += nums[end]
        while total >= s:
            ans = min(ans, end - start + 1)
            total -= nums[start]
            start += 1
        end += 1
    
    return 0 if ans == n + 1 else ans
```
##  33. 和为K的子数组 前缀法
```python
def subarraySum(self, nums: List[int], k: int) -> int:
    ##  要求的连续子数组
    count = 0
    n = len(nums)
    preSums = collections.defaultdict(int)
    preSums[0] = 1

    presum = 0
    for i in range(n):
        presum += nums[i]
        
        ##  if preSums[presum - k] != 0:
        count += preSums[presum - k]   ##  利用defaultdict的特性，当presum-k不存在时，返回的是0。这样避免了判断

        preSums[presum] += 1  ##  给前缀和为presum的个数加1
        
    return count
```
##  34.和为K的子数组 暴力法
```python
def subarraySum2(self, nums: List[int], k: int) -> int:
    ##  要求的连续子数组
    count = 0
    n = len(nums)

    for i in range(n):
        for j in range(i, n):
            if sum(nums[i:j+1]) == k:
                count += 1
    
    return count
```
##  35. 组合总和  回溯法遍历 组合等于
```python
def combinationSum2(self, candidates: List[int], target: int) -> List[List[int]]:
    def dfs(pos: int, rest: int):
        nonlocal sequence
        if rest == 0:
            ans.append(sequence[:])
            return
        if pos == len(freq) or rest < freq[pos][0]:
            return
        
        dfs(pos + 1, rest)

        most = min(rest // freq[pos][0], freq[pos][1])
        for i in range(1, most + 1):
            sequence.append(freq[pos][0])
            dfs(pos + 1, rest - i * freq[pos][0])
        sequence = sequence[:-most]
    
    freq = sorted(collections.Counter(candidates).items())
    ans = list()
    sequence = list()
    dfs(0, target)
    return ans
```

## 36. 乘积小于 K 的子数组
```python
def numSubarrayProductLessThanK(self, nums: List[int], k: int) -> int:
    ans, prod, i = 0, 1, 0
    for j, num in enumerate(nums):
        prod *= num
        while i <= j and prod >= k:
            prod //= nums[i]
            i += 1
        ans += j - i + 1
    return ans
```

## 37. 数组中第k大的元素

使用大根堆排序

```python
def elementFindK(nums,k):
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
  x = 0
  for i in range(len(nums))[::-1]:
    nums[0],nums[i] =  nums[i],nums[0]  ## 将最后的元素调整到第一个值
    adjustHeap(nums,0,size) ## 从0个元素开始调整堆
    x+=1
    if x == k:
        return num[i]
  return 0
```