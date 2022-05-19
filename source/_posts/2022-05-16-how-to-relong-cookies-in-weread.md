---
title: 微信读书Cookie自动延期机制分析
date: 2022-05-16 12:57:00
tags: 
	- obsidian
	- 微信读书
	- cookie
category: 前端技术
---

>HTTP Cookie（也叫 Web Cookie 或浏览器 Cookie）是服务器发送到用户浏览器并保存在本地的一小块数据，它会在浏览器下次向同一服务器再发起请求时被携带并发送到服务器上。通常，它用于告知服务端两个请求是否来自同一浏览器，如保持用户的登录状态。Cookie 使基于[无状态](https://developer.mozilla.org/en-US/docs/Web/HTTP/Overview#http_is_stateless_but_not_sessionless)的HTTP协议记录稳定的状态信息成为了可能。

## 分析Cookie


### 登录之前
在进入到weread.qq.com的时候，就已经存在Cookie信息了，只不过一部分的Cookie信息是空的，
下面是扫码登录之前的Cookie信息：

![](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20220516161146.png)

<!-- more -->

### 扫码登录

微信读书网页版获取Cookie的流程
1. 获取用户uid ，https://weread.qq.com/web/login/getuid，前端js生成一个uid，这个机制不清楚。
2. 获取登录用户扫码信息，https://weread.qq.com/web/login/getinfo，这个请求会一直pending，直到你扫码，然后获取到用户信息。
3. 网页登录，https://weread.qq.com/web/login/weblogin，使用第二步的获取到网页信息之后会立即进行登录。
4. session初始化，https://weread.qq.com/web/login/session/init，根据登录的信息初始化session，然就返回4个httpOnly的cookie信息，httpOnly的cookie信息不能通过`document.cookie` 这个也解释了之前在console中获取的cookie无法正常使用的问题。可以看到`wr_skey`的有效期只有5400秒，过了这个有效期，调用API接口会响应401，所以关键信息也就是如何更新这个`wr_skey`是关键。
5. 获取用户信息， https://weread.qq.com/web/user?userVid=xxx 这里会根据uid查询用户的基本信息，然后放入Cookie中。
![](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20220516160707.png)

## 延长Cookie

在cookie过期的时候刷新一下网页发现服务器都会自动返回`set-cookie`字段来更新`wr_skey`字段以及有效期。
![](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20220516174817.png)

## 解决方案

### 根据时间刷新
1. 在middle server中增加代理`/refresh`，重定向`https://weread.qq.com`用来刷新Cookie
2. 设置完Cookie的时候，保存Cookie的存储时间
3. 点击同步按钮的时候校验Cookie的存储时间，超过1个小时，则调用refresh刷新Cookie，超过一个小时会请求一次首页，获取set-cookie中新的cookie字段。

```typescript
 const app = express();
 this.app.use(
	'/refresh',
	createProxyMiddleware({
		target: 'https://weread.qq.com',
		changeOrigin: true,
		pathRewrite: {
			'^/refresh': '/'
		},
		onProxyReq: function (proxyReq, req, res) {
			const cookie = getEncodeCookieString();
			proxyReq.setHeader('Cookie', cookie);
		},
		onProxyRes: function (proxyRes, req, res: ServerResponse) {
			proxyRes.headers['Access-Control-Allow-Origin'] = '*';
			proxyRes.headers['Access-Control-Allow-Methods'] = '*';
			const respCookie: string[] = proxyRes.headers['set-cookie'];
			if (respCookie) {
				updateCookies(respCookie);
			}
		}
	})
);

```

使用axios来访问`/refresh` endpoint,这里使用`head`方法就够了，只需要获取head里的set cookie字段而已，不需要使用`get`方法获取整个html文档，使用get会降低请求速度。
```typescript
	async refreshCookie() {
		try {
			await axios.head(this.baseUrl + '/refresh');
		} catch (e) {
			console.error(e);
			new Notice('刷新Cookie失败');
		}
	}
```

### 根据401报错重试

如果在使用Obsidian的过程中，又在其他浏览器里刷新了微信读书的页面，会导致Obsidian的Cookie提前失效，这个时候Obsidian中在进行同步会发生401报错。

这里我在middle server中代理返回401的时候刷新cookie，同时在获取getNotebook的时候设置401重试，这样就算在别的浏览器里登录，Obsidian也会自动进行Cookie刷新，不让用户察觉到Cookie的存在。

```typescript
const app = express();
this.app.use(
		'/',
		createProxyMiddleware({
			target: 'https://i.weread.qq.com',
			changeOrigin: true,
			onProxyReq: function (proxyReq, req, res) {
				try {
					const cookie = getEncodeCookieString();
					proxyReq.setHeader('Cookie', cookie);
				} catch (error) {
					new Notice('cookie 设置失败，检查Cookie格式');
				}
			},
			onProxyRes: function (proxyRes, req, res: ServerResponse) {
				if (proxyRes.statusCode == 401) {
					refreshCookie(true);
				} else if (proxyRes.statusCode != 200) {
					new Notice('获取微信读书服务器数据异常！');
				}
				proxyRes.headers['Access-Control-Allow-Origin'] = '*';
				proxyRes.headers['Access-Control-Allow-Methods'] = '*';
			}
		})
	);
```

## Reference 
1. [HTTP cookies](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Cooki)