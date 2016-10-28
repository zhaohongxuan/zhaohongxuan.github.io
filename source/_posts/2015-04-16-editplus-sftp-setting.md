---
layout: post
title:  "使用Editplus配置sftp连接服务器"
keywords: "editplus sftp"
description: "使用Editplus配置sftp连接到远程服务器查看服务器日志文件，上传本地文件等"
category: 杂文其他
tags: editplus
---
##使用Editplus配置sftp连接服务器
之前一直使用SSH，但是发现每次都得输入登陆密码，然后再打开 `file transfer` 工具，一层一层的打开日志的文件目录，然后把日志文件下载到本地的目录再打开
是不是感觉很繁琐，有了Editplus，麻麻再也不用担心我查看日志了，闲言碎语不要讲，下面是配置sftp的步骤
##配置步骤

1.打开Editplus，选择`文件->FTP->设置FTP服务器`：
![Editplus设置ftp](http://i2.tietuku.com/3d687e1df53c5e50s.png)


2.点击`添加`
![Editplus设置ftp](http://i2.tietuku.com/4bbd3b6f8fbfda83s.png)


3.如果是SFTP或用了其它端口，点击`高级选项`，进行相应设置，我这里使用的是`22`端口，所以要进行设置
![Editplus设置ftp](http://i2.tietuku.com/d324b2efd44d8965s.png)

4.当然也可以添加多个FTP服务器地址
![Editplus设置ftp](http://i2.tietuku.com/0f98e3e56ab2e731s.png)


5.将多个ftp服务器放在一个组中
![Editplus设置ftp](http://i2.tietuku.com/ccfa2bb269f81c79s.png)

这样一个FTP服务器组就配置成功了，可以小试牛刀了。

##使用方法
依次点击菜单栏`文件->FTP->打开远程文件`，选择刚才创建的`天安微信测试`帐号，点击`显示`上面的列表里就会显示出当前日志目录的所有文件。
![Editplus设置ftp](http://i2.tietuku.com/614da49a060da11bs.png)


