---
title: 微信读书Obsidian实现二维码扫描登录
date: 2022-05-24 08:06
tags: [obsidian,二维码登录,electron,BrowserWindow]
category: obsidian
---

## 背景

前几天写了个Obsidian微信读书的插件[GitHub - zhaohongxuan/obsidian-weread-plugin](https://github.com/zhaohongxuan/obsidian-weread-plugin)，在B站上发了一个视频[学了3天typescript写了一个微信读书的Obsidian插件_哔哩哔哩](https://www.bilibili.com/video/BV1f34y1h7jk#reply114024637264)，最初版本是需要手动从控制台`复制Cookie`设置到设置界面才能使用的，很多B站网友给我私信说获取Cookie有问题，虽然在readme里已经写的很清楚了，但是对小白来说可能这也是个比较困难的步骤，所以我在想是否可以实现二维码扫码登录呢？

## 思路

因为Obsidian其实也是个浏览器，所以理论上是可以打开浏览器窗口来展示扫码登录界面的。只要load到微信读书的扫码登录界面，然后intercept到请求的header拿到Cookie就可以了，然后后续只要被动刷新Cookie有效期即可。

所以问题就被分成了三部分：
1. 展示二维码扫码框
2. intercept 登录操作获取到Cookie
3. 将Cookie设置到setting 中

<!-- more -->

## 步骤

### 那么如何load微信读书扫码登录页面呢？

用electron的[BrowserWindow](https://www.electronjs.org/docs/latest/api/browser-window)  然后loadURL打开`https://r.qq.com#login`界面即可展示扫码框。

### 如何intercept获取到Cookie呢？

在上篇微信读书Cookie分析 [[2022-05-16-how-to-relong-cookies-in-weread]]的文章里，我已经把微信读书Cookie的机制研究了一遍。
![](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20220516161146.png)
在登录之前，本地已经有Cookie了，只不过关于用户相关的字段都是空的：
![](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20220516161146.png)
![](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20220516161146.png)

在登录完成的时候，`[初始化会话](https://weread.qq.com/web/login/session/init)` 只会获取到4个set-cookie的值，然后调用 https://weread.qq.com/web/user?userVid=xxx 再去查一次用户信息把用户信息放入Cookie中。

所以解法变成了intercept用户信息api拿到用户信息自己组装Cookie，但是在实战过程中发现使用eletron的webRequest获取到网络请求的body非常困难，还需要开启debugger才能使用，所以我放弃了。

换个思路，从request header头上找到Cookie不就行了吗？ 但是在扫码登录的session里面，请求任何页面Cookie都是不完整的，除非等到加载用户信息完成之后Cookie才会被补充完整，这个时候再去请求接口的时候Cookie就是完整的。所以解题思路就来了，我们再扫码完成回调之后 reload下页面不就好了吗？

代码比我想想中的要简单太多了：

```typescript
	const session = this.modal.webContents.session;
		const filter = {
			urls: ['https://weread.qq.com/web/user?userVid=*']
		};
		session.webRequest.onSendHeaders(filter, (details) => {
			const cookies = details.requestHeaders['Cookie'];
			const cookieArr = parseCookies(cookies);
			const wr_name = cookieArr.find((cookie) => cookie.name == 'wr_name').value;
			if (wr_name !== '') {
				settingsStore.actions.setCookies(cookieArr);
				settingTab.display();
				this.modal.close();
			} else {
				this.modal.reload();
			}
		});
```

在intercept [https://weread.qq.com/web/user?userVid=](https://weread.qq.com/web/user?userVid=) 的时候判断下Cookie中`wr_name`字段是不是有值就可以了，没有值说明是`第一次加载`，就原地`reload`一次，第二次request header里Cookie就是完整的了，这个时候就可以关掉登录窗口了，登录完成。 

这个过程中，在登录窗口关闭之前会有一次刷新操作，不过因为时间非常短，所以这个过程对用户是几乎无感的。

## Reference 
1. [BrowserWindow | Electron](https://www.electronjs.org/docs/latest/api/browser-window)
2. [Class: WebRequest | Electron](https://www.electronjs.org/docs/latest/api/web-request)
3. [微信读书Cookie自动延期机制分析 | Hank's Blog](https://zhaohongxuan.github.io/2022/05/16/how-to-relong-cookies-in-weread/)
4. [GitHub - zhaohongxuan/obsidian-weread-plugin](https://github.com/zhaohongxuan/obsidian-weread-plugin)