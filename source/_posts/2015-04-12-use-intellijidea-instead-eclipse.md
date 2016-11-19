---
layout: post
title:  "使用intellij IDEA"
keywords: "intellij"
date: 2015-04-12
category: java
tags: [java,intellij]
---
#  intellij初体验
据说是最好用的Java IDE，没有之一，吓得我赶紧下载来用用，果然第一次用好魔性，Darcula主题简直炫酷吊炸天，Github功能也集成了，
可以直接分享项目到Github好方便有木有，工具可以直接连接SSH，对于经常需要连接SSH的人来说，简直幸福死，有了Terminal，妈妈再也
不用担心我来回换窗口了，就像JetBrains公司的宣传语是这么说的：Develop with pleasure！让我们带着快乐编程吧~
## 初体验之操作Java EE项目
### 导入J2EE项目
导入之前eclipse项目，点击`File->Import Module`选中之前的的J2EE项目，选择`Import from extern model`的`eclipse`然后点击`next`
最后点击`finish`完成导入项目。
### 设置项目的库文件，
想要项目运行，就需要添加项目需要的jar包啦，点击`File->Project Structure`进入项目结构界面，点击`Module`进入模块设置，点击绿色的`+`号，
加入spring，web等模块
![加入模块](http://i2.tietuku.com/5d2dd21a7a197043s.png)
<!-- more -->
### 输出的war包
设置项目打的war包的
点击`artifacts`点击绿色的`+`,选择`Web Application:Achieve`也就是war包，点击`output directory`选择输出的路径
![生成war包](http://i2.tietuku.com/0b9e41ca80ca029as.png)

## 初体验之集成工具的使用
### Jboss的使用
1. 点击`Run ->edit configration`进入服务器设置
2. 点击绿色的`+`选择`Jboss server`,选择`local `进入Jboss设置
![Jboss设置](http://i2.tietuku.com/f1cf95cf1ccb78e1s.png)
3. 点击`Application server`后面的`configure`选择Jboss的主目录，Intellij idea会自动搜索jboss下的jar包
![生成war包](http://i2.tietuku.com/cdd125a88d8f0430s.png)
设置完主目录以后点击`User alternative JRE`选择JRE目录
![生成war包](http://i2.tietuku.com/aeecfd9418e1b94as.png)
4. 点击`server instance`选择`default`作为当前的服务器实例
5. 点击`deployment`选项卡，选择刚才所打的war包
6. 点击完成，Jboss服务器就搭建好了。
![Jboss启动](http://i2.tietuku.com/e4b9eead835dc1ads.png)
7. 点击工具栏的`Run->Run weixin` weixin是你设置的Jbosss服务器名，然后Jboss就启动起来了 =。=
###SSH工具的使用
点击菜单栏`Tools->start SSH session-Edit credentials`编辑你的服务器的IP端口等就可以登录服务器了。

# 2.intellij idea快捷键使用

点击菜单栏`Help->default keyMap reference`会自动打开一个PDF，里面是当前快捷键的设置，如果英文好一点的话，看起来应该毫不费力
![快捷键的使用](http://i2.tietuku.com/e403cd26fa8f754cs.png)
实用快捷键:

    Ctrl+/      行注释（// ）
    Ctrl+Shift+/块注释（*...*/ ）
    Ctrl+D      复制行
    Ctrl+X      删除行
    alt+enter   快速修复
    alt+/       代码提示
    ctr+G       定位某一行
    Shift+F6    重构-重命名
    Ctrl+R      替换文本
    Ctrl+F      查找文本
    Ctrl+E      最近打开的文件
    Ctrl+J      自动代码
    Ctr+alt+O   组织导入
    Ctr+alt+L   格式化代码
    Ctr+shift+U 大小写转化
    Alt+回车    导入包,自动修正
    Ctrl+N      查找类
    Ctrl+Shift+N 查找文件
    Ctrl+Alt+L   格式化代码
    Ctrl+Alt+O  优化导入的类和包
    Alt+Insert  生成代码(如get,set方法,构造函数等)
    Ctrl+E      最近更改的代码
    Ctrl+R      替换文本
    Ctrl+F      查找文本
    Ctrl+Space  基本自动补全代码
    Ctrl+Shift+Space    智能自动补全代码
    Ctrl+Alt+Space      类名或接口名提示
    Ctrl+P              方法参数提示
    Ctrl+Shift+Alt+N    查找类中的方法或变量
    Alt+Shift+C         对比最近修改的代码

    Ctrl+X      删除行
    Ctrl+D      复制行
    Ctrl+J      自动代码
    Ctrl+H      显示类结构图
    Ctrl+Q      显示注释文档
    Alt+F1      查找代码所在位置
    Alt+1       快速打开或隐藏工程面板
    Ctrl+Alt+ left/right 返回至上次浏览的位置
    Alt+ left/right     切换代码视图
    Alt+ Up/Down        在方法间快速移动定位
    Ctrl+Shift+Up/Down  代码向上/下移动。
    F2 或Shift+F2       高亮错误或警告快速定位
    Ctrl+Shift+F7       高亮显示所有该文本，按Esc高亮消失。
    Ctrl+W              选中代码
    Alt+F3              逐个往下查找相同文本，并高亮显示。
    Ctrl+Up/Down        光标跳转到第一行或最后一行下
    Ctrl+B              快速打开光标处的类或方法
