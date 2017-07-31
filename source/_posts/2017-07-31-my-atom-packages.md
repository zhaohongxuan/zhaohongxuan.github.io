
---
layout: post
title: Atom优秀package列表（持续更新）
tags: [总结]
date: 2017-07-31
category: 工具效率
---

Atom,VSCode 都属于Electronic 构建的跨平台编辑器,Atom 属于Github，VSCode属于Microsoft，两个的开源软件在社区里都挺活跃，Sublime也挺好用的，特别是速度，完爆Atom，VSCode 速度要比Atom快不少，那为啥要用Atom呢
因为Sublime在Windows上字体渲染惨不忍睹，特别是在25寸2k显示器上，字体大就发虚，所以在我的mac上sublime还是挺好用的，但是在windows上如果不是编辑大的文件（Atom打开大的文本兼职坑爹），在不讲速度的前提下，我也不用sublime，都用Atom，毕竟颜值即正义。

下面是我自己平时用的好用的Package列表：


## 工具
## file-icons
让你的侧边栏和Tab更加美观，为每种文件类型都绘制了精美的图标，甩默认的好几条街。

![file-icons](http://upload-images.jianshu.io/upload_images/170138-af44e038752f1e14.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## Sublime Style Column Selection
Atom默认没有Block选择的功能，但是别怕，已经有包实现了这个功能，Sublime Style Column Selection 这个包可以让你像EditPlus一样编辑`块文本`，在windows下面按住`alt`然后鼠标选择就可以选择区块文件了

![Sublime Style Column Selection](http://upload-images.jianshu.io/upload_images/170138-a19affacc6e0c145.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## minimap
预览所有的代码

![image.png](http://upload-images.jianshu.io/upload_images/170138-91f3e24d8111a900.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## pretty-json
正如其名，美化json，比如你从服务器日志上copy下来的json报文，可以用它一键美化，也可以反向将Json压缩成一行。

![image.png](http://upload-images.jianshu.io/upload_images/170138-73374a243ad02b09.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## highlight-selected
双击的时候高亮你选择的单词，如果此单词在该文件中已经有了 也都会被高亮显示

![image.png](http://upload-images.jianshu.io/upload_images/170138-e75dfaa117082b20.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 语言

## script
在Atom内运行代码，必备Package

## Python Autocomplete

![image.png](http://upload-images.jianshu.io/upload_images/170138-ec183bdc8802bed8.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

python自动提示，写python必备。

### linter-pycodestyle

记得先pip 安装pycodestyle插件然后再安装atom package 要不然一点击保存就会报错。
安装的时候Atom会提示你其他的必须包，一起安装了就好。
```
pip install pycodestyle
```
### Python Tools

快捷键`ctrl+alt+u`显示当前变量被调用的地方
快捷键`ctrl+alt+g`显示定义的地方
