# App.Bin.note

应用包名：note

显示名称：便签

版本：1.0.0

发布者：左平

占用端口： 10030

前端开发：Vue3 + Element-Plus

后端开发：Go + Gin

数据库： Sqlite

## 应用说明

一款简洁高效的便签应用，支持富文本编辑与手写涂鸦，记录更自由。多用户独立数据，安全私密，让每个人都能拥有属于自己的笔记空间。这是一款简洁而强大的便签应用，帮助你轻松记录生活、工作与灵感，默认账号：admin 密码：123456。

## 应用状态
> 上架中

> 下一版支持功能：（构想）

> 便签思维导图类型、绘图模式类型、拍照类型、录音类型、附件类型、位置类型、密码本类型

> 拍照、录音类型会上安卓app支持

> 密码类型需要开打密码，内容加密

> 位置类型使用安卓app后台定时实时记录gps位置，并绘制轨迹，这个就当一个儿童手表的位置记录功能吧。

## 本地构建

> 请提前安装好 fnpack

```bash
fnpack build
```

## 命令安装
```bash
sudo rm -f note.fpk
sudo fnpack build
sudo appcenter-cli uninstall note
sudo appcenter-cli install-fpk note.fpk
sudo appcenter-cli start note
```

## CGI 打开方式
### cgi地址
> /cgi/ThirdParty/note/index.cgi
### cgi 代码 cgi.go
> go build -o index.cgi cgi.go
``` go
package main

import (
	"bytes"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strings"
)

const backendURL = "http://127.0.0.1:10030" // 后端接口地址

func main() {
	cwd, err := os.Getwd()
	if err != nil {
		outputError(500, err)
		return
	}

	path := os.Getenv("REQUEST_URI")
	if path == "" {
		path = "/index.html"
	}

	// 去掉 index.cgi 前缀
	if strings.Contains(path, "index.cgi/") {
		path = "/" + strings.SplitN(path, "index.cgi/", 2)[1]
	}

	// 接口请求判断
	if strings.HasPrefix(path, "/admin/") || strings.HasPrefix(path, "/app/") {
		proxyToBackend(path)
		return
	}

	// 直接访问 index.cgi 返回首页
	if strings.HasSuffix(path, "index.cgi") || path == "/" {
		path = "/index.html"
	}

	var filePath string
	if strings.HasPrefix(path, "/uploads/") {
		// /uploads/ 文件实际存放在 ../../home/uploads/
		filePath = filepath.Join(cwd, "../../../@apphome/note/", path)
	} else {
		// 默认静态文件在 CGI 当前目录
		filePath = filepath.Join(cwd, path)
	}

	// 判断文件是否存在
	_, err = os.Stat(filePath)
	if err != nil {
		// ❗文件不存在 → Vue 刷新、路由跳转 fallback
		// 如 /login /user/list /xxx/yyy 都会回退到 index.html
		filePath = filepath.Join(cwd, "index.html")
	}

	// 打开文件
	file, err := os.Open(filePath)
	if err != nil {
		outputError(404, err)
		return
	}
	defer file.Close()

	// 设置 Content-Type
	contentType := "text/plain"
	switch strings.ToLower(filepath.Ext(filePath)) {
	case ".html":
		contentType = "text/html"
	case ".css":
		contentType = "text/css"
	case ".js":
		contentType = "application/javascript"
	case ".json":
		contentType = "application/json"
	case ".png":
		contentType = "image/png"
	case ".jpg", ".jpeg":
		contentType = "image/jpeg"
	case ".gif":
		contentType = "image/gif"
	case ".svg":
		contentType = "image/svg+xml"
	}

	// 输出 HTTP 头
	fmt.Println("Status: 200 OK")
	fmt.Printf("Content-Type: %s\r\n\r\n", contentType)

	// 输出文件内容
	io.Copy(os.Stdout, file)
}

// 代理接口到后端
func proxyToBackend(path string) {
	method := os.Getenv("REQUEST_METHOD")
	if method == "" {
		method = "GET"
	}

	// 读取请求 Body
	var body []byte
	if method != "GET" && method != "HEAD" {
		body, _ = io.ReadAll(os.Stdin)
	}

	// 构建后端 URL
	targetURL := backendURL + path

	req, err := http.NewRequest(method, targetURL, bytes.NewReader(body))
	if err != nil {
		outputError(500, err)
		return
	}

	// 复制 HTTP headers
	for _, env := range os.Environ() {
		if !strings.HasPrefix(env, "HTTP_") {
			continue
		}
		parts := strings.SplitN(env, "=", 2)
		key := strings.ReplaceAll(parts[0][5:], "_", "-")
		req.Header.Set(key, parts[1])
	}

	// 注入真实 IP
	remoteAddr := os.Getenv("REMOTE_ADDR")
	if remoteAddr != "" {
		req.Header.Set("X-Real-IP", remoteAddr)
		req.Header.Set("X-Forwarded-For", remoteAddr)
	}

	// 发起请求
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		outputError(502, err)
		return
	}
	defer resp.Body.Close()

	// 输出 HTTP 头
	fmt.Printf("Status: %d OK\r\n", resp.StatusCode)
	for k, vs := range resp.Header {
		fmt.Printf("%s: %s\n", k, strings.Join(vs, ","))
	}
	fmt.Println()

	// 输出响应体
	io.Copy(os.Stdout, resp.Body)
}

// 错误输出
func outputError(code int, err error) {
	fmt.Printf("Status: %d Error\r\n", code)
	fmt.Println("Content-Type: text/plain\r\n")
	fmt.Println("CGI Error:")
	fmt.Println(err)
}

```

## [更新日志]<br/>
## 2025-11-28
### 1.0.1<br/>
1.修复刷新页面菜单选中错误问题<br/>
2.修复刷新页面乱跳转问题<br/>
3.优化移动端菜单显示效果，移动端左侧菜单自动收缩展开<br/>
4.去除了每一页的重复标题显示
5.编辑器支持了简单的 Markdown 输入和粘贴自动解析<br/>
6.增加了分页支持，超出 20 条记录自动展示分页栏
7.内容详情优化了删除、保存、预览/编辑按钮的展示效果
8.编辑器输入框支持了自适应高度，加入了渐变以示区别
9.支持了空标题和空内容保存，编辑内容取消最大内容限制
10.其他优化

---
## 2025-11-19
### 初版更新 1.0.0<br/>
- ### 登录页
1. 多账户登录功能，每个账号数据独立。<br/>
- ### 首页
1. 无内容时首页新增便签。<br/>
2. 展示便签列表内容，每个内容块展示标题和简介。<br/>
3. 便签列表内容点击宽屏右侧展示便签内容，移动端跳转新页面展示单独的详情页。<br/>
4. 详情内容顶上支持编辑和删除，移动端支持关闭返回便签列表页。
- ### 添加页
1. 支持添加标题、标签、描述自动截取、详情内容。<br/>
2. 详情内容编辑器支持简单的文字排版、表格、图片上传和涂鸦等功能。<br/>
3. 保存后跳转到便签列表页。<br/>
- ### 设置页
1. 支持修改默认 admin 密码，和添加其他账号，管理员账号可以修规其他账号的密码。
2. 可以添加账号和退出登录功能。
---

- ### 功能图片
![登录页](docs/1.0.0/0.png)<br/>

![登录页](docs/1.0.0/1.png)<br/>

![首页](docs/1.0.0/2.png)<br/>

![首页详情](docs/1.0.0/3.png)<br/>

![移动端打开的详情页](docs/1.0.0/4.png)<br/>

![首页详情页](docs/1.0.0/5.png)<br/>

![首页详情](docs/1.0.0/6.png)<br/>

![首页编辑模式绘画](docs/1.0.0/7.png)<br/>

![添加便签页](docs/1.0.0/8.png)<br/>

![首页展示绘画图](docs/1.0.0/9.png)<br/>

![设置页](docs/1.0.0/10.png)<br/>
