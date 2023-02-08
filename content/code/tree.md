+++
title = "树"
date =  2022-11-03T18:08:31+08:00
description= "description"
weight = 5
+++

- [通用结构](#通用结构)
- [1. 前序遍历](#1-前序遍历)
- [2. 迭代前序](#2-迭代前序)
- [3. 中序遍历](#3-中序遍历)
- [4. 后序遍历](#4-后序遍历)
- [5. 层次遍历](#5-层次遍历)
- [6. 二叉树直径](#6-二叉树直径)
- [7. 最大深度](#7-最大深度)
- [8. 最小深度](#8-最小深度)
- [9. 翻转二叉树](#9-翻转二叉树)
- [10. 合并二叉树](#10-合并二叉树)
- [11. 二叉树的锯齿形层序遍历](#11-二叉树的锯齿形层序遍历)
- [12. 最近公共祖先](#12-最近公共祖先)
- [13. 最近公共祖先 dps](#13-最近公共祖先-dps)
- [14. 序列化](#14-序列化)
- [15. 反序列化](#15-反序列化)
- [16. 是否对称](#16-是否对称)
- [17. 树高](#17-树高)
- [18. 平衡二叉树](#18-平衡二叉树)
- [19. 二叉搜索树 第k大节点](#19-二叉搜索树-第k大节点)
- [20. 第k小的元素](#20-第k小的元素)
- [21. 距离target节点距离为k的所有节点](#21-距离target节点距离为k的所有节点)
- [22. 从前序与中序遍历序列构造二叉树](#22-从前序与中序遍历序列构造二叉树)
- [23. 从中序与后序遍历序列构造二叉树](#23-从中序与后序遍历序列构造二叉树)
- [24. 将有序数组转换为二叉搜索树](#24-将有序数组转换为二叉搜索树)
- [25. 所有路径](#25-所有路径)

## 通用结构
```
from ast import List
from xmlrpc.client import Boolean


class TreeNode: 
    def __init__(self, x): 
        self.val = x
        self.left = None 
        self.right = None
```

## 1. 前序遍历
```python
def preorder(root,res=[]): 
    if not root: 
        return
    res.append(root.val) 
    preorder(root.left, res) 
    preorder(root.right, res) 
    return res
```
## 2. 迭代前序
```python
def preorder(root): 
    res= []
    if not root:
      return [] 
    stack=[root]
    while stack: 
        node=stack.pop() 
        res.append(node.val) 
        if node.right: stack.append(node.right) 
        if node.left: stack.append(node.left) 
    return res
```
## 3. 中序遍历
```python
def inorder(root,res=[]): 
    if not root: 
      return
    inorder(root.left,res) 
    res.append(root.val) 
    inorder(root.right,res) 
    return res
```
## 4. 后序遍历
```python
def preorder(root,res=[]): 
    if not root: 
        return
    preorder(root.left, res) 
    preorder(root.right, res)
    res.append(root.val) 
    return res
```

## 5. 层次遍历
```python
def levelOrder(self, root: TreeNode) -> List[List[int]]:
    ## 先处理特殊情况
    if not root:
        return []

    ## 返回结果
    res = []

    from collections import deque
    ## 定义队列
    queue = deque()
    ## 将根节点入队
    queue.append(root)
    ## 队列不为空，表达式二叉树还有节点，循环遍历
    while queue:
        ## 先标记每层的节点数
        size = len(queue)
        ## 定义变量，记录每层节点值
        level = []
        ## 这里开始遍历当前层的节点
        for _ in range(size):
            ## 出队
            node = queue.popleft()
            ## 先将当前节点的值存储
            level.append(node.val)
            ## 节点的左右节点非空时，入队
            if node.left:
                queue.append(node.left)
            if node.right:
                queue.append(node.right)
        ## 添加每层的节点值列表
        res.append(level)
    return res
```
## 6. 二叉树直径
```python
def diameterOfBinaryTree(self, root: TreeNode) -> int:
    self.ans = 1
    def depth(node):
        ## 访问到空节点了，返回0
        if not node:
            return 0
        ## 左儿子为根的子树的深度
        L = depth(node.left)
        ## 右儿子为根的子树的深度
        R = depth(node.right)
        ## 计算d_node即L+R+1 并更新ans
        self.ans = max(self.ans, L + R + 1)
        ## 返回该节点为根的子树的深度
        return max(L, R) + 1

    depth(root)
    return self.ans - 1
```
## 7. 最大深度
```python
def maxDepth(self, root):
    if root is None: 
        return 0 
    left_height = self.maxDepth(root.left) 
    right_height = self.maxDepth(root.right) 
    return max(left_height, right_height) + 1
```
## 8. 最小深度
```python
def minDepth(self, root: TreeNode) -> int:
    if not root:
        return 0
    
    if not root.left and not root.right:
        return 1
    
    min_depth = 10**9
    if root.left:
        min_depth = min(self.minDepth(root.left), min_depth)
    if root.right:
        min_depth = min(self.minDepth(root.right), min_depth)
    
    return min_depth + 1
```
## 9. 翻转二叉树
```python
def invertTrees(self, root: TreeNode) -> TreeNode:
    if not root:
        return root
    left = self.invertTrees(root.left)
    right = self.invertTrees(root.right)
    root.left,root.right = right,left
    return root
```
## 10. 合并二叉树
```python
def mergeTrees(self, t1: TreeNode, t2: TreeNode) -> TreeNode:
    if  not t1:
        return t2
    if not t2:
        return t1
    merge = TreeNode(t1.val+t2.val)
    merge.left = self.mergeTrees(t1.left,t2.left)
    merge.right = self.mergeTrees(t1.right,t2.right)
    return merge
```
## 11. 二叉树的锯齿形层序遍历
```python
def zigzagLevelOrder(self, root: Optional[TreeNode]) -> List[List[int]]:
    res = []
    if not root:
        return res
    from collections import deque
    stack = deque()
    stack.append(root)
    level_num = 0
    while stack:
        level_num+=1
        size = len(stack)
        level = []
        for _ in range(size):
            node = stack.pop()
            res.append(node.val)
            if node.left:
                stack.append(node.left)
            if node.right:
                stack.append(node.right)
        if level_num %2 == 1:
            level = level[::-1]
        res.append(level)
    return res
```
## 12. 最近公共祖先
```python
def lowestCommonAncestor(self, root: TreeNode, p: TreeNode, q: TreeNode) -> TreeNode:
    if not root or root == p or root == q:
        return root
    left = self.lowestCommonAncestor(root.left,p,q)
    right = self.lowestCommonAncestor(root.right,p,q)
    if not left:
        return right
    if not right:
        return left
    return root
```
## 13. 最近公共祖先 dps
```python
def lowestCommonAncestordps(self, root: TreeNode, p: TreeNode, q: TreeNode) -> TreeNode:
    parent = dict()
    visit = dict()
    def dps(root: TreeNode):
        if not root:
            return
        if root.left:
            parent[root.left] = root
            dps(root.left)
        if root.right:
            parent[root.right] = root
            dps(root.right)
    dps(root)
    while p:
        visit[p] = True
        p = parent[p]
    while q:
        if visit[q]:
            return q
        q = parent[q]
    return None
```
## 14. 序列化
```python
def serialize(self,root: TreeNode)->str:
    sb = ""
    def dfs(root):
        if not root:
            sb+="null"
        sb+=f'{root.val},'
        dfs(root.left)
        dfs(root.right)
    dfs(root)
    return sb
```
## 15. 反序列化
```python
def deserialize(self, data: str)-> TreeNode:
    sp = data.split(",")
    def build()->TreeNode:
        if sp[0]=='null':
            sp = sp[1:]
            return None
        val = int(sp[0])
        sp=sp[1:]
        node=TreeNode(val,build(),build())
    return build()
```
## 16. 是否对称
```python
def isSymmetric(self, root: TreeNode) -> Boolean:
    def check(p,q)->Boolean:
        if p==None and q ==None:
            return True
        if p==None or q == None:
            return False
        return p.val==q.val and check(p.left,q.right) and check(p.right,q.left)
    return check(root,root)
```
## 17. 树高
```python
def height(self, root: TreeNode)-> int:
    if not root:
        return 0
    return max(self.height(root.left),self.height(root.right))+1
```
## 18. 平衡二叉树
```python
def isBalanced(self, root: TreeNode)-> Boolean:
    if not root:
        return True
    return abs(self.height(root.left),self.height(root.right))<=1 and self.isBalanced(root.left) and self.isBalanced(self.right)
```
## 19. 二叉搜索树 第k大节点
```python
def kthLargest(self, root: TreeNode, k: int)->int:
    def dfs(root):
        if not root: return
        dfs(root.right)
        if k == 0: return
        k -= 1
        if k == 0:
            res = root.val
        dfs(root.left)
    res = 0
    dfs(root)
    return res
```
## 20. 第k小的元素
```python
def kthSmallest(self, root: TreeNode, k: int) -> int:
    stack = []
    while root or stack:
        while root:
            stack.append(root)
            root = root.left
        root = stack.pop()
        k -= 1
        if k == 0:
            return root.val
        root = root.right
```
## 21. 距离target节点距离为k的所有节点
```python
def distanceK(self, root:TreeNode,target: TreeNode, k:int) -> List[int]:
    parents = dict()
    def dfs(root):
        if not root:
            return
        if root.left:
            parents[root.left] = root
            dfs(root.left)
        if root.right:
            parents[root.right] = root
            dfs(root.right)
    dfs(root)
    res = []
    def findk(root:TreeNode, frm: TreeNode, deep:int):
        if not root:
            return
        if deep == k:
            res.append(root.val)
        if root.left!= frm:
            findk(root.left,root,deep+1)
        if root.right!=frm:
            findk(root.right,root,deep+1)
        if parents[root]!=frm:
            findk(parents[root],root,deep+1)
    findk(root,None,0)
    return res
```
## 22. 从前序与中序遍历序列构造二叉树
```python
def buildTree(self, preorder: List[int], inorder: List[int]) -> TreeNode:
    def myBuildTree(preorder_left: int, preorder_right: int, inorder_left: int, inorder_right: int):
        if preorder_left > preorder_right:
            return None
        
        ## 前序遍历中的第一个节点就是根节点
        preorder_root = preorder_left
        ## 在中序遍历中定位根节点
        inorder_root = index[preorder[preorder_root]]
        
        ## 先把根节点建立出来
        root = TreeNode(preorder[preorder_root])
        ## 得到左子树中的节点数目
        size_left_subtree = inorder_root - inorder_left
        ## 递归地构造左子树，并连接到根节点
        ## 先序遍历中「从 左边界+1 开始的 size_left_subtree」个元素就对应了中序遍历中「从 左边界 开始到 根节点定位-1」的元素
        root.left = myBuildTree(preorder_left + 1, preorder_left + size_left_subtree, inorder_left, inorder_root - 1)
        ## 递归地构造右子树，并连接到根节点
        ## 先序遍历中「从 左边界+1+左子树节点数目 开始到 右边界」的元素就对应了中序遍历中「从 根节点定位+1 到 右边界」的元素
        root.right = myBuildTree(preorder_left + size_left_subtree + 1, preorder_right, inorder_root + 1, inorder_right)
        return root
    
    n = len(preorder)
    ## 构造哈希映射，帮助我们快速定位根节点
    index = {element: i for i, element in enumerate(inorder)}
    return myBuildTree(0, n - 1, 0, n - 1)
```
## 23. 从中序与后序遍历序列构造二叉树
```python
def buildTree(self, inorder: List[int], postorder: List[int]) -> TreeNode:
    def helper(in_left, in_right):
        ## 如果这里没有节点构造二叉树了，就结束
        if in_left > in_right:
            return None
        
        ## 选择 post_idx 位置的元素作为当前子树根节点
        val = postorder.pop()
        root = TreeNode(val)

        ## 根据 root 所在位置分成左右两棵子树
        index = idx_map[val]

        ## 构造右子树
        root.right = helper(index + 1, in_right)
        ## 构造左子树
        root.left = helper(in_left, index - 1)
        return root
    
    ## 建立（元素，下标）键值对的哈希表
    idx_map = {val:idx for idx, val in enumerate(inorder)} 
    return helper(0, len(inorder) - 1)
```
## 24. 将有序数组转换为二叉搜索树
```python
def sortedArrayToBST(self, nums: List[int]) -> TreeNode:
    def helper(left, right):
        if left > right:
            return None

        ## 总是选择中间位置左边的数字作为根节点
        mid = (left + right) // 2

        root = TreeNode(nums[mid])
        root.left = helper(left, mid - 1)
        root.right = helper(mid + 1, right)
        return root

    return helper(0, len(nums) - 1)
```
## 25. 所有路径
```python
def binaryTreePaths(self, root):
    """
    :type root: TreeNode
    :rtype: List[str]
    """
    def construct_paths(root, path):
        if root:
            path += str(root.val)
            if not root.left and not root.right:  ## 当前节点是叶子节点
                paths.append(path)  ## 把路径加入到答案中
            else:
                path += '->'  ## 当前节点不是叶子节点，继续递归遍历
                construct_paths(root.left, path)
                construct_paths(root.right, path)

    paths = []
    construct_paths(root, '')
    return paths
```