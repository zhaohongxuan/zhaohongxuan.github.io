---
title: 使用Middle Server解决浏览器CORS跨域问题
date: 2022-05-12 11:46:00
tags: 
	- obsidian
	- cors
	- http
	- midderServer
category: obsidian
---

## 问题产生

最近学了Typescript写了一个Obsidian微信读书的插件[Obsidian Weread Plugin](https://github.com/zhaohongxuan/obsidian-weread-plugin)，在写插件的过程中需要跨域请求`r.qq.com`来获取微信读书的书摘和想法。

使用axios在vscode中运行api测试的时候是好的，在obsidian中产生了`CORS`的问题，这是因为Obsidian本质上是一个Electron的app，本质上也是一个浏览器，所以才会出现跨域问题。

关于CORS的文章已经很多了，推荐参考Mozila [CORS](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/CORS)，作为一个后端开发，CORS 并不陌生，，对于Spring全家桶用户来说，就是几行`@CrossOrigin`的配置问题，但是这一篇文章提供的是`前端视角`来解决CORS的思路，也就是说对服务端不可控时如何处理？

## 解决思路

我们都知道CORS本身只是对浏览器才会限制，所以可以跳出来使用代理服务器来解决问题，这里刚开始，我建立了一个Springboot的Web项目专门转发来自Obsidian的请求，将请求转发到r.qq.com，这样能够正常工作，但是也印出来了另外一个问题：

每次使用Weread插件的时候，我都需要把SpringBoot项目启动起来，显然不够`优雅`。特别是后面插件上架了Obsidian的社区市场之后肯定更不行，你不可能要求用户自己再额外下载一个服务器来运行。

那么是否可以找到一个可以在前端使用的middle server呢？ 答案是可以！那就是[http-proxy-middleware](https://github.com/chimurai/http-proxy-middleware)

<!-- more -->

## 解决方法

### Http Proxy Middleware

它是基于node开发的简单的中间层代理，搭配express使用非常简单，完全服务我的需求：
在Obsidian中启动Weread Plugin同步任务的时候，首先启动server，绑定一个端口

当用户在obsidian里点击同步的时候，实际上在所有的网络请求之前我会启动一个middle server，然后绑定到一个端口，这里写的是`12011`，然后实现onProxyRes方法，将服务器返回的`Access-Control-Allow-Origin`设置为`*`，然后插件认为没有跨域，所以能够正常和微信阅读服务器进行通讯。

这里由于微信读书API只能通过`cookie`的方式来进行认证，所以将setting中的cookie设置到proxyReq上面，这样就模拟了网页端的请求。

```typescript
async startMiddleServer(app: any): Promise<Server> {
		const cookie = this.settings.cookie;
		if (cookie === undefined || cookie == '') {
			new Notice('cookie未设置，请填写Cookie');
		}
		const escapeCookie = this.escapeCookie(cookie);
		app.use(
			'/',
			createProxyMiddleware({
				target: 'https://i.weread.qq.com',
				changeOrigin: true,
				onProxyReq: function (proxyReq, req, res) {
					try {
						proxyReq.setHeader('Cookie', escapeCookie);
					} catch (error) {
						new Notice('cookie 设置失败，检查Cookie格式');
					}
				},
				onProxyRes: function (proxyRes, req, res: ServerResponse) {
					if (res.statusCode != 200) {
						new Notice('获取微信读书服务器数据异常！');
					}
					proxyRes.headers['Access-Control-Allow-Origin'] = '*';
				}
			})
		);
		const server = app.listen(12011);
		return server;
	}

```

在进行API调用的时候绑定到上面的代理端口`12011`上。

```typescript
readonly baseUrl: string = 'http://localhost:12011';

async getWereadNotebooks() {
		try {
			let noteBooks = [];
			const resp = await axios.get(this.baseUrl + '/user/notebooks', {});
			noteBooks = resp.data.books;
			return noteBooks;
		} catch (e) {
			new Notice(
				'Failed to fetch weread notebooks . Please check your Cookie and try again.'
			);
		}
	
```

在同步任务结束的时候，调用`server`的`close`方法，关闭掉代理服务器，这样就完成了一次同步。

```typescript
	async startSync(app: any) {
		new Notice('start to sync weread notes!');
		this.startMiddleServer(app).then((server) => {
			console.log('Start syncing Weread note...');
			this.syncNotebooks.startSync().then((res) => {
				server.close(() => {
					console.log('HTTP server closed ', res, server);
				});
				new Notice('weread notes sync complete!');
			});
		});
	}
```

这样代理服务器仅仅会在程序运行的时候启动，不会一直在后台耗着占用我们的CPU资源，算是一种比较完美的解决方案。

## References
1.  https://developer.mozilla.org/zh-CN/docs/Web/HTTP/CORS
2.  https://github.com/chimurai/http-proxy-middleware 