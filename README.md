## 应用说明
> App.Bin.note <br/>
> 名称：便签 <br/>
> 版本：1.2.1 <br/>
> 一款功能丰富的便签应用。自适应网页，支持导入导出，历史记录，从 NAS 添加文件，外部 HTTPS 10029 端口访问，多用户登录，数据备份恢复，文件管理，内容分享，回收站，通知提醒。<br/>
支持多类型便签，<br/>
&nbsp;1.常规便签：<br/>
    &nbsp;&nbsp;&nbsp;&nbsp;可记录文字、图片内容<br/>
&nbsp;2.绘图便签：<br/>
    &nbsp;&nbsp;&nbsp;&nbsp;自由的绘画板<br/>
&nbsp;3.思维导图便签：<br/>
    &nbsp;&nbsp;&nbsp;&nbsp;设计你的思维导图<br/>
&nbsp;4.拍照类型：<br/>
    &nbsp;&nbsp;&nbsp;&nbsp;存你的图片<br/>
&nbsp;5.录音类型：<br/>
&nbsp;&nbsp;&nbsp;&nbsp;存你的录音<br/>
&nbsp;6.附件类型便签：<br/>
&nbsp;&nbsp;&nbsp;&nbsp;存你的附件文件<br/>
&nbsp;7.密码本类型：<br/>
&nbsp;&nbsp;&nbsp;&nbsp;存你的密码，使用 AES-256-GCM 算法加密全部密码本内容<br/>
&nbsp;7.任务待办类型：<br/>
&nbsp;&nbsp;&nbsp;&nbsp;记录你的计划、任务、待办<br/>
默认账号：<b>admin</b> 密码：<b>123456</b>

## 更多详情查看飞牛论坛交流帖
> https://club.fnnas.com/forum.php?mod=viewthread&tid=45704

## Docker版本
> https://hub.docker.com/r/zuoping1/note<br/>
> docker pull zuoping1/note:latest<br/>

## 在你的 Linux 服务器中部署
下载仓库 https://github.com/FNOSP/App.Bin.note 目录中 app/server/note 中的二进制文件，上传到你的服务器，服务器开放 10029 端口或宝塔反代到 https://127.0.0.1:10029 访问。<br/>
运行 x86/amd64 的 note：<br/>
> chmod 755 note <br/>
> chown www:www note <br/>
> ./note

## 免责声明
> 本应用为免费非商业工具，仅供个人学习与测试使用。开发者不对服务的稳定性、数据安全性作任何保证，使用风险由您自行承担。严禁用于违法违规用途。
> 数据存储说明：所有数据均仅存储于您指定的NAS设备中，开发者不存储、不转发、不备份任何用户数据。
> 使用即视为同意以上声明。
