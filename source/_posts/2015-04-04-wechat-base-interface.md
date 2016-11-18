---
layout: post
title:  "【微信接口学习】基础接口"
keywords: "微信,wechat"
date: 2015-04-04 21:12:34
category: 微信开发
tags: wechat
---
##1.获取access_token
access_token是公众号的全局唯一票据，公众号调用各接口时都需使用access_token。

	1. access_token的存储至少要保留512个字符空间。
	2. access_token的有效期目前为2个小时，需定时刷新，重复获取将导致上次获取的access_token失效。
	3. 需要中控服务器定时获取和刷新access_token，而且还需要被动刷新access_token

**接口调用请求说明**

http请求方式: `GET`
	https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=APPID&secret=APPSECRET

正常情况下，微信会返回下述JSON数据包给公众号：

	{"access_token":"ACCESS_TOKEN","expires_in":7200}

##2.获取微信服务器的IP地址

**接口调用请求说明**

http请求方式: `GET`
	https://api.weixin.qq.com/cgi-bin/getcallbackip?access_token=ACCESS_TOKEN

正常情况下，微信会返回下述JSON数据包给公众号：

	{
		"ip_list":["127.0.0.1","127.0.0.1"]
	}

##3.上传和下载多媒体文件

	1. 对多媒体文件的操作是通过media_id来进行的
	2. 每个多媒体文件在发送到服务器3天后自动删除

**上传多媒体文件接口
 调用请求说明**

http请求方式: `POST/FORM`

	http://file.api.weixin.qq.com/cgi-bin/media/upload?access_token=ACCESS_TOKEN&type=TYPE
	调用示例（使用curl命令，用FORM表单方式上传一个多媒体文件）：
	curl -F media=@test.jpg "http://file.api.weixin.qq.com/cgi-bin/media/upload?access_token=ACCESS_TOKEN&type=TYPE"

正确情况下的返回JSON数据包结果如下：
	{"type":"TYPE","media_id":"MEDIA_ID","created_at":123456789}
**下载多媒体文件接口
调用请求说明**

http请求方式: `GET`

	http://file.api.weixin.qq.com/cgi-bin/media/get?access_token=ACCESS_TOKEN&media_id=MEDIA_ID
	请求示例（示例为通过curl命令获取多媒体文件）
	curl -I -G "http://file.api.weixin.qq.com/cgi-bin/media/get?access_token=ACCESS_TOKEN&media_id=MEDIA_ID"
