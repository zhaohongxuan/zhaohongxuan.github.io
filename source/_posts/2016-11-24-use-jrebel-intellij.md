---
layout: post
title: 在intellij idea中使用Jrebel
tags: [jrebel]
date: 2016-11-24
category: java
---

Jrebel是一个优秀的热部署的插件，虽然intellj中也支持热部署修改class文件后自动更新字节码文件，但是，有时候还是会不起作用，Jrebel这款插件可以支持真正的热部署，以前用过破解版的但是很快就提示licence过期非法，在网上也找不到破解的方法=。=，本来想支持正版的，但是高大`$475` 每年的价格不是个人能承受的，这本来就是给企业授权用的，其实jrebel的的个人授权是有免费渠道的。
可以登陆`https://my.jrebel.com/`自己注册，然后获得个人授权。

## 获取个人授权

### 使用twitter或者facebook登陆或自己使用邮箱注册
使用twitter或者facebook登陆得使用vpn，如果自己注册的话点击 [https://my.jrebel.com/register](https://my.jrebel.com/register)进入注册
![注册账号](http://ww2.sinaimg.cn/large/787edccfgw1fa33rdjxluj20zw0mkafi.jpg)

### 获取activation Code然后激活
切换到`Install and Activate` 选项卡
复制出 activation Code

![](http://ww3.sinaimg.cn/large/787edccfgw1fa33xmoy1tj211q0opdkn.jpg)

## 在intellij安装&使用Jrebel
  目前我使用的Intellij版本是 `2016.3`
    >IntelliJ IDEA 2016.3
    Build #IU-163.7743.44, built on November 18, 2016

  Jrebel是最新版的7.0

 点击 `ctrl+alt+s`呼出设置界面，点击plugins->browser repositories 然后搜索jrebel就有新版本的jrebel可以下载，如果速度过慢记得挂代理，或者自己到jetbrains官网下载最新的插件,
 [Jrebel插件地址](https://plugins.jetbrains.com/plugin/4441)
 ![](http://ww2.sinaimg.cn/large/787edccfgw1fa343gy0jnj215m0ngk1k.jpg)

### 配置Jrebel
 安装完jrebel插件后
 在设置界面的jrebel子选项中激活Jrebel
 ![](http://ww3.sinaimg.cn/large/787edccfgw1fa347c4rluj20v30mwdkj.jpg)

### 使用Jrebel启动项目
在使用Jrebel 6.0的时候还需要配置vmoption 升级7.0后可以直接用了不用在配置vmoption了，点击小火箭图标开始运行项目，或者debug图标debug项目
![](http://ww3.sinaimg.cn/large/787edccfgw1fa34iapj8qj217q0adgmf.jpg)
