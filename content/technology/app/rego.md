+++
title = "Rego基础"
date =  2021-05-21T14:34:25+08:00
description= "rego 语言基础"
weight = 9
+++

## rego 基础
`https://www.openpolicyagent.org/docs/latest/policy-reference/`

OPA基于一种数据查询语言Datalog实现了描述语言Rego
|语法|例子|
|-| -|
|上下文	|data|
|输入	|input
|索引取值	|data.bindings[0]
|比较	|“alice” == input.subject.user
|赋值|	user := input.subject.user
|规则|	< Header > { < Body > }
|规则头|	< Name > = < Value > { … } 或者 < Name > { … }
|规则体|	And运算的一个个描述
|多条同名规则|	Or运算的一个规则
|规则默认值	|default allow = false
|函数|	fun(x) { … }
|虚拟文档|	doc[x] { … }

输入会挂在input对象下，用到的上下文（就是规则决策基于的源数据）会挂在data对象

### 赋值和相等

```shell
# assign variable x to value of field foo.bar.baz in input
x := input.foo.bar.baz

# check if variable x has same value as variable y
x == y

# check if variable x is a set containing "foo" and "bar"
x == {"foo", "bar"}

# OR

{"foo", "bar"} == x
```

### 数组
```shell
val := arr[0]
val := arr[count(arr)-1]
```
### 对象
```shell
val := obj["foo"]
```

```shell
# 数组迭代 等价python:   [x for x in arr]
val := arr[_]
# 对象迭代
obj[key]
# 集合迭代
set[val]
# 查找 k 和 i 为变量
foo[k].bar.baz[i] == 7
# 表达式迭代 返回 set结果 ，等价 python:  count( set([ x for x in set: if f(x) ]) )
count({x | set[x]; f(x)}) == 0

any_match {
    set[x]
    f(x)
}
#等价 , 等价python:   any(x for x in set: if f(x))
any_match = true{
    set[x]
    f(x)
}

```



```shell
# 常量定义
a = {1, 2, 3}
b = {4, 5, 6}
c = a | b
```

```shell
# p is true if ...
p = true { ...}
# 等价
p { ... }
```

重复定义
```shell
default allow = false
# 等价 allow = true { ...}
allow {
  3>2
}
allow {
  3<2
}
# 重复定义表示 or计算，有一个为真则allow 为真
```

```shell
# Incremental 递增
a_set[x] { ... }
a_set[y] { ... }
# 重复赋值会增量的加入到变量中，a_set将包含x和y全部值
```

```shell
# else 判断， 等价python:  a=1; 5 if c1 :
default a = 1
a = 5 { ... }
else = 10 { ... }
```

## Functions (Boolean)

```shell
f(x, y) {
    ...
}

# 等价

f(x, y) = true {
    ...
}
```

```shell
# 条件
f(x) = "A" { x >= 90 }
f(x) = "B" { x >= 80; x < 90 }
f(x) = "C" { x >= 70; x < 80 }
```

## Test

```shell
# define a rule that starts with test_
test_NAME { ... }

# override input.foo value using the 'with' keyword
data.foo.bar.deny with input.foo as {"bar": [1,2,3]}}
```


## build in function
```s
==,!=,<,> ...

x - * / %

round(x)  abs(x)  numbers.range(a, b)

count sum product乘积  all  any

array.concat(array, array) 数组连接
array.slice(array, startIndex, stopIndex)  数组片段
```

```s
s1 & s2 集合交集
s1 | s2 集合并集
s1 - s2 集合差集
```
```s
object.get(object, key, default) 获取对象元素
object.remove(object, keys) 删除
object.union(objectA, objectB) 并集，相同元素以objectB 为准
object.filter(object, keys)  key过滤
json.filter(object, paths)  json key过滤， json.filter({"a": {"b": "x", "c": "y"}}, ["a/b"])  匹配a下的b
json.remove(object, paths)  key删除
```

```s
concat(delimiter, array_or_set)   连接 concat(".",["x","y","z"]) ,相等于python: ".".join(["x","y","z"])
contains(string, search) 包含子串
endswith(string, search)
format_int(number, base)  将 number 转化成对应 base 进制的数，返回字符串 format_int(323, 2) output: "101000011"

indexof(string, search) 查找子串index
lower(string)  小写
replace(string, old, new) 替换
split(string, delimiter) 切分
startswith(string, search)
trim(string, cutset)
trim_left(string, cutset)
trim_prefix(string, prefix)
trim_right(string, cutset)
trim_space(string)
upper(string)
```

```s
regex.match(pattern, value) 正则匹配
regex.is_valid(pattern) 正则检查
regex.split(pattern, string)
regex.globs_match(glob1, glob2)
glob.match(pattern, delimiters, match)  全匹配 delimiters 默认[.]
```

Bitwise 二进制
```s
bits.or(x, y)
bits.and(x, y)
bits.negate(x)
bits.xor(x, y)
...
```

```s
to_number(x)  string 转number to_number("12.2")
units.parse_bytes(x)  字节转化 units.parse_bytes("1KB") ：1000 
```

```s
is_number(x)
is_string(x)
is_array(x)
is_set(x)
is_object(x)
is_null(x)
type_name(x)  变量类型
```


```s
base64.encode(x)
base64.decode(string)
base64url.encode(x)
urlquery.encode(string)
urlquery.encode_object(object)
json.marshal(x)  对象 解码 json
json.unmarshal(string) json 到对象  json.unmarshal("{\"x\":\"a\"}")
yaml.marshal(x)
yaml.unmarshal(string)
```

### Token
jwt 验证
WT是由三段信息构成的，将这三段信息文本用.链接一起就构成了Jwt字符串
jwt 分为三部分： header， palyload ， signature

第三部分：
```
header (base64后的)
payload (base64后的)
secret
```
base64加密

```s
io.jwt.encode_sign_raw() `takes three JSON Objects (strings) as parameters `
io.jwt.encode_sign()  `takes three Rego Objects as parameters and returns their JWS`
```

```shelll
io.jwt.encode_sign({
    "typ": "JWT",
    "alg": "HS256"
}, {
    "iss": "joe",
    "exp": 1300819380,
    "aud": ["bob", "saul"],
    "http://example.com/is_root": true,
    "privateParams": {
        "private_one": "one",
        "private_two": "two"
    }
}, {
    "kty": "oct",
    "k": "AyM1SysPpbyDfgZld3umj1qzKObwVMkoqQ-EstJQLr_T-1qS0gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr1Z9CAow"
})
```

```shell
io.jwt.encode_sign({
    "typ": "JWT",
    "alg": "HS256"},
    {}, {
    "kty": "oct",
    "k": "AyM1SysPpbyDfgZld3umj1qzKObwVMkoqQ-EstJQLr_T-1qS0gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr1Z9CAow"
})
```

token验证
```s
io.jwt.verify_rs256(string, certificate)
io.jwt.verify_hs256(string, secret)
io.jwt.verify_hs384(string, secret)
...
```

示例：
```s
raw_result_hs256 := io.jwt.encode_sign_raw(
    `{"alg":"HS256","typ":"JWT"}`,
    `{}`,
    `{"kty":"oct","k":"Zm9v"}`  	# "Zm9v" is the base64 URL encoded string "foo"
)

# Important!! - Use the un-encoded plain text secret to verify and decode
raw_result_valid_hs256 := io.jwt.verify_hs256(raw_result_hs256, "foo")
raw_result_parts_hs256 := io.jwt.decode_verify(raw_result_hs256, {"secret": "foo"})
```

#### Time
```s
time.now_ns()   timestamp now
time.parse_ns(layout, value) 
time.date(ns)   output is of the form [year, month, day]

```


### Cryptography

加密
```s
crypto.x509.parse_certificates(certs)  certs 为证书内容base64编码后的string，解析结果为json
crypto.x509.parse_certificate_request(csr)   输入为csr证书请求base64后的string，输出为csr请求json
crypto.md5(string)
crypto.sha256(string)
```

### Graphs

walk(x, [path, value])

graph.reachable(graph, initial)


```s
package graph_reachable_example

org_chart_data = {
  "ceo": {},
  "human_resources": {"owner": "ceo", "access": ["salaries", "complaints"]},
  "staffing": {"owner": "human_resources", "access": ["interviews"]},
  "internships": {"owner": "staffing", "access": ["blog"]}
}

# 所有 entity包含的 子类
org_chart_graph[entity_name] = edges {
  org_chart_data[entity_name]
  edges := {neighbor | org_chart_data[neighbor].owner == entity_name}
}

# graph.reachable 按照key查找遍历
org_chart_permissions[entity_name] = access {
  org_chart_data[entity_name]
  reachable := graph.reachable(org_chart_graph, {entity_name})
  access := {item | reachable[k]; item := org_chart_data[k].access[_]}
}
```

output:
```s
> org_chart_graph
{
  "ceo": [
    "human_resources"
  ],
  "human_resources": [
    "staffing"
  ],
  "internships": [],
  "staffing": [
    "internships"
  ]
}
```

### HTTP

http.send(request)

example:
```s
http.send({"method": "get", "url": "https://www.baidu.com", "tls_use_system_certs": true })
```


### NET
```s
net.cidr_contains(cidr, cidr_or_ip)  ip包含 net.cidr_contains("127.0.0.1/24","127.0.0.64/26")
net.cidr_intersects(cidr1, cidr2)  ip重叠
net.cidr_expand(cidr)  展开ip段
net.cidr_merge(cidrs_or_ips)  合并ip段
...
```

### Rego

rego.parse_module(filename, string)

运行时：

opa.runtime()

trace(string)

### 保留字

```s
as
default
else
false
import
package
not
null
true
with
```

### 语法

```s
module          = package { import } policy
package         = "package" ref
import          = "import" package [ "as" var ]
policy          = { rule }
rule            = [ "default" ] rule-head { rule-body }
rule-head       = var [ "(" rule-args ")" ] [ "[" term "]" ] [ ( ":=" | "=" ) term ]
rule-args       = term { "," term }
rule-body       = [ "else" [ "=" term ] ] "{" query "}"
query           = literal { ( ";" | ( [CR] LF ) ) literal }
literal         = ( some-decl | expr | "not" expr ) { with-modifier }
with-modifier   = "with" term "as" term
some-decl       = "some" var { "," var }
expr            = term | expr-call | expr-infix
expr-call       = var [ "." var ] "(" [ term { "," term } ] ")"
expr-infix      = [ term "=" ] term infix-operator term
term            = ref | var | scalar | array | object | set | array-compr | object-compr | set-compr
array-compr     = "[" term "|" rule-body "]"
set-compr       = "{" term "|" rule-body "}"
object-compr    = "{" object-item "|" rule-body "}"
infix-operator  = bool-operator | arith-operator | bin-operator
bool-operator   = "==" | "!=" | "<" | ">" | ">=" | "<="
arith-operator  = "+" | "-" | "*" | "/"
bin-operator    = "&" | "|"
ref             = ( var | array | object | set | array-compr | object-compr | set-compr | expr-call ) { ref-arg }
ref-arg         = ref-arg-dot | ref-arg-brack
ref-arg-brack   = "[" ( scalar | var | array | object | set | "_" ) "]"
ref-arg-dot     = "." var
var             = ( ALPHA | "_" ) { ALPHA | DIGIT | "_" }
scalar          = string | NUMBER | TRUE | FALSE | NULL
string          = STRING | raw-string
raw-string      = "`" { CHAR-"`" } "`"
array           = "[" term { "," term } "]"
object          = "{" object-item { "," object-item } "}"
object-item     = ( scalar | ref | var ) ":" term
set             = empty-set | non-empty-set
non-empty-set   = "{" term { "," term } "}"
empty-set       = "set(" ")"
```
The grammar defined above makes use of the following syntax. See the Wikipedia page on EBNF for more details:

```s
[]     optional (zero or one instances)
{}     repetition (zero or more instances)
|      alternation (one of the instances)
()     grouping (order of expansion)
STRING JSON string
NUMBER JSON number
TRUE   JSON true
FALSE  JSON false
NULL   JSON null
CHAR   Unicode character
ALPHA  ASCII characters A-Z and a-z
DIGIT  ASCII characters 0-9
CR     Carriage Return
LF     Line Feed
```