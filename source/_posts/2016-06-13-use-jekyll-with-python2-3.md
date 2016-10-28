---
layout: post
title: 使用Jekyll共存python2和python3
description: 使用Jekyll共存python2和python3报错
tags: jekyll
category: jekyll
---

jekyll运行环境

    windows 10 pro
    jekyll 3.1.2
    ruby 2.2.1p85
    python 2.7

安装完python3时，配置完python3的环境变量之后，运行jekyll时报`Liquid Exception: Failed to get header`错：


![jekyll报错](https://raw.githubusercontent.com/javaor/javaor.github.io/master/pictures/jekyll/use-jekyll-with-python2-3.png)

解决办法很简单：

将环境变量中的python3替换为python2即可。

将

```
C:\python3.0\
C:\python3.0\Script\
```
换回

```
C:\python2.7\
C:\python2.7\Script\
```




