# App.Bin.note

应用包名：note

显示名称：便签

版本：1.0.6

发布者：左平

占用端口： 10030

前端开发：Vue3 + Element-Plus

后端开发：Go + Gin

数据库： Sqlite

浏览器：推荐最新版谷歌浏览器或把浏览器升级到最新版本运行

## 应用说明

一款简洁好用的便签应用，自适应网页，支持 PC 、平板、移动端放访问。 <br/>
应用支持多账号登录，每个账号都能有自己的数据空间。<br/>
支持多类型的便签，<br/>
&nbsp;1.常规便签：<br/>
    &nbsp;&nbsp;&nbsp;&nbsp;可以输入各样式的文字、表格、图片上传、涂鸦、简单Markdown<br/>
&nbsp;2.绘图便签：<br/>
    &nbsp;&nbsp;&nbsp;&nbsp;一个简单的绘画板<br/>
&nbsp;3.思维导图便签：<br/>
    &nbsp;&nbsp;&nbsp;&nbsp;嵌入那款最火的思维导图开源组件到系统中<br/>
&nbsp;4.拍照类型：<br/>
    &nbsp;&nbsp;&nbsp;&nbsp;开发中，把你最喜欢的那几张照片放到一起，轮播播放、列表、多宫格展示，可以填写保存拍摄时间，拍摄地点和描述<br/>
它可以帮助你记录生活、工作和灵感。<br/>
便签功能持续迭代中，欢迎来飞牛论坛给我建议反馈。<br/>
默认账号：<b>admin</b> 密码：<b>123456</b>

## 应用状态
> 迭代中

> 下一版支持功能：（构想）

> 便签拍照类型、录音类型、附件类型、位置类型、密码本类型

> 拍照、录音类型会上安卓app支持

> 密码类型需要开打密码，内容加密

> 位置类型使用安卓app后台定时实时记录gps位置，并绘制轨迹，这个就当一个儿童手表的位置记录功能吧。

## 本地构建

> 请提前安装好 fnpack

```bash
fnpack build
```

## 飞牛论坛帖子
https://club.fnnas.com/forum.php?mod=viewthread&tid=45704

## 安装
### 1. 命令安装
```bash
sudo rm -f note.fpk && sudo fnpack build && sudo appcenter-cli install-local note.fpk
```
### 2. 应用中心安装
![登录页](docs/1.0.0/app_center_install_fpk.jpg)<br/>

## CGI 打开方式
> /cgi/ThirdParty/note/index.cgi
#### 如果需要单独打开，你的 NAS 访问地址 + CGI 打开方式。需要先登录 NAS<br/>比如：http://192.168.31.111:5666/cgi/ThirdParty/note/index.cgi

## 便签数据备份
> #### 1. 使用飞牛 备份 应用备份，打开备份->备份飞牛->选择目录（应用安装的存储空间->@apphome/note）->下一步->选择备份目的地... 
> #### 2. note 目录下的两个文件夹 data 和 uploads 分别是 SQLite 数据库文件夹 和 上传文件文件夹

![备份便签数据](docs/1.0.2/3.jpg)<br/>
![备份便签数据](docs/1.0.2/4.jpg)<br/>

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

## CGI转发代码
### index.cgi 构建：go build -trimpath -o index.cgi cgi.go
```go
package main

import (
	"bytes"
	"fmt"
	"io"
	"mime"
	"net/http"
	"os"
	"path/filepath"
	"strings"
)

const backendURL = "http://127.0.0.1:10030" // 后端接口地址
const debugMode = false                     // true = 开启调试

func main() {
	cwd, _ := os.Getwd()
	path := os.Getenv("REQUEST_URI")

	// Debug 调试模式
	if debugMode {
		debugOutput("路径调试", map[string]string{
			"REQUEST_URI": path,
		})
		return
	}

	// 1. 规范化路径
	path = normalizePath(path)

	// 2. API 请求优先
	if isAPIRequest(path) {
		proxyToBackend(path)
		return
	}

	// 3. 静态文件服务
	if serveStaticFile(cwd, path) {
		return
	}

	// 4. fallback index.html
	serveIndexHTML(cwd)
}

/* ================================
 * 路径处理
 * ================================
 */
// 规范化路径
func normalizePath(path string) string {
	if path == "" {
		return "/index.html"
	}

	// 提取 index.cgi 后面的路径
	if strings.Contains(path, "index.cgi/") {
		return "/" + strings.SplitN(path, "index.cgi/", 2)[1]
	}

	// 访问 index.cgi 本体 → 返回首页
	if strings.HasSuffix(path, "index.cgi") {
		return "/index.html"
	}

	return path
}

/* ================================
 * 静态文件服务
 * ================================
 */
func serveStaticFile(cwd, path string) bool {
	var filePath string

	// uploads 特殊存储
	if strings.HasPrefix(path, "/uploads/") {
		filePath = filepath.Join(cwd, "../../../@apphome/note/", path)
	} else {
		filePath = filepath.Join(cwd, path)
	}

	if _, err := os.Stat(filePath); err != nil {
		return false
	}

	file, err := os.Open(filePath)
	if err != nil {
		outputError(404, err)
		return true
	}
	defer file.Close()

	contentType := getContentType(filePath)
	fmt.Println("Status: 200 OK")
	fmt.Printf("Content-Type: %s\r\n\r\n", contentType)
	io.Copy(os.Stdout, file)
	return true
}

// fallback index.html
func serveIndexHTML(cwd string) {
	filePath := filepath.Join(cwd, "index.html")
	file, err := os.Open(filePath)
	if err != nil {
		outputError(404, err)
		return
	}
	defer file.Close()

	fmt.Println("Status: 200 OK")
	fmt.Println("Content-Type: text/html\r\n")
	io.Copy(os.Stdout, file)
}

/* ================================
 * 判断是否是 API 请求
 * ================================
 */
func isAPIRequest(path string) bool {
	return strings.HasPrefix(path, "/admin/") ||
		strings.HasPrefix(path, "/app/")
}

/* ================================
 * Content-Type 管理
 * ================================
 */
// getContentType 自动识别文件类型
func getContentType(filePath string) string {
	ext := strings.ToLower(filepath.Ext(filePath))
	if ext == "" {
		return "application/octet-stream"
	}

	// 尝试通过系统 MIME 表识别
	mimeType := mime.TypeByExtension(ext)
	if mimeType != "" {
		return mimeType
	}

	// 默认二进制流
	return "application/octet-stream"
}

/* ================================
 * 后端代理
 * ================================
 */
func proxyToBackend(path string) {
	method := os.Getenv("REQUEST_METHOD")
	if method == "" {
		method = "GET"
	}

	var body []byte
	if method != "GET" && method != "HEAD" {
		body, _ = io.ReadAll(os.Stdin)
	}

	targetURL := backendURL + path
	req, err := http.NewRequest(method, targetURL, bytes.NewReader(body))
	if err != nil {
		outputError(500, err)
		return
	}

	copyHeaders(req)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		outputError(502, err)
		return
	}
	defer resp.Body.Close()

	fmt.Printf("Status: %d OK\r\n", resp.StatusCode)
	for k, vs := range resp.Header {
		fmt.Printf("%s: %s\n", k, strings.Join(vs, ","))
	}
	fmt.Println()

	io.Copy(os.Stdout, resp.Body)
}

// 复制 CGI 的请求头
func copyHeaders(req *http.Request) {
	for _, env := range os.Environ() {
		if strings.HasPrefix(env, "HTTP_") {
			parts := strings.SplitN(env, "=", 2)
			key := strings.ReplaceAll(parts[0][5:], "_", "-")
			req.Header.Set(key, parts[1])
		}
	}

	if ip := os.Getenv("X-Real-IP"); ip != "" {
		req.Header.Set("X-Real-IP", ip)
		req.Header.Set("X-Forwarded-For", ip)
	}
}

/* ================================
 * 工具方法
 * ================================
 */
// 错误输出
func outputError(code int, err error) {
	fmt.Printf("Status: %d Error\r\n", code)
	fmt.Println("Content-Type: text/plain\r\n")
	fmt.Println("CGI Error:")
	fmt.Println(err)
}

// Debug 输出
func debugOutput(title string, items map[string]string) {
	fmt.Println("Status: 200 OK")
	fmt.Println("Content-Type: text/plain; charset=utf-8\r\n")

	fmt.Println("====== DEBUG MODE ======")
	fmt.Println("INFO:", title)
	fmt.Println("-------------------------")

	for k, v := range items {
		fmt.Printf("%s: %s\n", k, v)
	}

	if os.Getenv("REQUEST_METHOD") != "GET" {
		body, _ := io.ReadAll(os.Stdin)
		fmt.Println("\n====== BODY ======")
		fmt.Println(string(body))
	}

	fmt.Println("\n====== ENV ======")
	for _, env := range os.Environ() {
		fmt.Println(env)
	}

	fmt.Println("\n====== END ======")
}

```
