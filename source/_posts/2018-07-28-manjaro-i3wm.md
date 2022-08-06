---
layout: post
title: 使用Manjaro Linux + i3wm心得
tags: linux/manjaro
date: 2018-07-28
category: linux
---


> 所有的熟悉都是从陌生开始的。

![](https://upload-images.jianshu.io/upload_images/170138-7fa4639e3b56da27.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

在使用3个月`manjaro linux +i3wm`之后我打算写一篇文章来记录一下心得,首先说一下，这篇文章并不是教程，只是分享一下使用心得。在这几个月使用期间，从刚开始的懵，到最后熟练使用效率大大提升，以至于使用gnome 或者windows桌面的时候各种不适应
接下来会分成两部分来写，第一部分是`manjaro linux`，第二部分是`i3wm`。
## 一、基于arch的manjaro linux
在使用Manjaro之前使用了大约1个月时间的Deepin Linux，界面确实很华丽漂亮，但是在Deepin的下面很多界面会有卡顿的感觉，比如启动器界面，以及多任务切换的时候，还有一个重要原因：我的蓝牙耳机 Fiil Diva 连上之后断断续续，基本不能用，而在Manjaro下面可以完美使用。
 <!-- more --> 
### 1.1 常用软件

#### 1.1.1 开发工具
- java开发环境 使用yarout 终于可以拜托了debian系列繁琐的配置了，只需要无脑 `yaourt`
- intellij idea java开发必备
- switchhosts 切换各个开发环境的hosts
- vscode  
- postman
- sublime 基本上就使用vscode了，然而在编辑一些文本的时候vscode还是会卡顿，这个时候就要祭出sublime text了
- xfce-terminal 我选择使用`xfce-terminal` 而不是`uvxrt`的原因是因为简单，而且字体展示更加优美，还可以方便的设置背景透明

#### 1.1.2 日常使用
- scrot 截屏软件
- virtualbox 虚拟机，不管怎么样，在linux里面，虚拟机还是需要的，因为一些办公软件必须在windows下面才能使用。
-
### 1.2 命令行工具

#### 1.2.1 命令行文件管理：ranger
![image.png](https://upload-images.jianshu.io/upload_images/170138-6d4299cc09c0aba8.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#### 1设置代理
作为一个程序员，命令行上面有些资源难免要出墙，如果不用代理网速有些资源可能是龟速，比如`yaourt`某些软件的时候。如果你使用ss作为代理，可以使用alias给命令行设置代理。使用setproxy给命令行设置全局代理，使用完成之后在使用`unsetproxy`来取消代理。
可以把下面三句话放到你的 `.zshrc`里面，这样随时随地就都能使用了。
```shell
alias setproxy="export ALL_PROXY=socks5://127.0.0.1:1080"
alias unsetproxy="unset ALL_PROXY"
alias ip="curl -i http://ip.cn"
```

## 二、 i3wm

在使用i3wm之前，我知道的linux桌面有 `gnome`,`cinnamon`,`kde`,`xfce`等，对了还有国产的`dde`，这些桌面都有一个特点，就是和windows类似的，浮动窗口管理器，一个窗口可以浮在另外一个窗口上面，所以要在多个窗口间切换，则需要使用 `alt+tab`来回切换
如果窗口少还好，如果窗口多的话，来回切换会非常繁琐，直到遇到了 平铺式窗口管理器i3wm。
i3wm的所有窗口都平铺在桌面上，可以按照你的需求平铺或堆叠。初学起来可能配置麻烦，但是一点点熟悉下来会发现熟悉了根本离不开了，就如开头说的那样，所有的熟悉都是从陌生开始的。
放一张截图：
![2018-08-02-145643_3640x1920_scrot.png](https://upload-images.jianshu.io/upload_images/170138-6c0349ecc8ea9419.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

关于i3wm的配置，就不写太多了，就推荐一个视频教程就够了
教程地址：[i3wm configuration](https://www.youtube.com/watch?v=j1I63wGcvU4&list=PL5ze0DjYv5DbCv9vNEzFmP6sU7ZmkGzcf
)
附上我的配置文件地址：https://github.com/zhaohongxuan/dot_files/tree/master/i3