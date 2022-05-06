---
title: 10款插件让你的Obsidian更加好用
date: 2022-05-05 13:35:58
tags: obsidian 写作工具
category: obsidian
---
Obsidian 是一款非常优秀的`双链笔记`软件，用它可以很方便的来管理自己的笔记，打造自己的数字花园（Digital Garden），虽然和Roam等纯粹的Outliner型笔记不太一样，它基于纯文本md文件，且支持文件夹，给了一些用户选择的自由，最重要的是启动速度很快（特别是和Notion相比，虽然是基于Electron的，不知道用了什么黑魔法）

同时Obsidian也是一款非常好用的写作软件，支持`Live Preview`的模式，类似于Typora的效果，个人感觉体验很好。

Obsidian是以Plugin化的形式设计的，很多核心的功能也都是以Plugin的形式出现的，这给了用户自由定制的空间，当然这也提高了上手的难度，无形中劝退了不少人，但是Plugin的形式会让这个软件生命力得到释放，社区的优秀的插件数量很多，用户可以根据自己的喜好自己定制自己的Obsidian，我想这也是Obsidian最吸引人的地方之一。

下面就介绍10款我平时用的最多的第三方插件，可以让你的Obsidian更加易用。

## 外观插件

<!-- more -->

### Hider
Obsidian官方主题是在是有点丑，我这边使用排名第一个主题 `Minimal Theme` 简约大气，使用Hider搭配这个主题可以隐藏掉界面上不想看到的元素，比如`vault name`， `title bar`等，搭配`Minimal Theme`简直完美

![Minimal Theme](https://github.com/kepano/obsidian-minimal/raw/master/assets/minimal-variants.png)

### Obsidian File Explorer Count
顾名思义，就是在Obsidian的文件管理器上显示笔记的数量，很直观建议安装。
![](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20220505130444.png)


## 绘图插件

### ExcaliDraw

免费的手绘白板软件，一些简单的绘图可以用它来画，很有质感，搭配Obsidian很有质感，间接省了一个ipad和还有一支笔。
![](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20220505125742.png)

### Diagram
Diagram是在Obsidian上的drawio<sup>1</sup> ，drawio是我最喜欢的开源流程图工具，使用jira的人肯定对这个工具不陌生， 图片是svg格式的，在Obsidian里可以直接使用`![[]]` 引用在正文中显示。
![](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20220505125950.png)

### Plantuml
Plantuml<sup>2</sup> 是开源的文本绘图工具，可以直接使用代码块来进行绘图，搭配上面的drawio来说基本上已经满足所有的绘图需求。


## 效率提升插件

### QuickAdd

这个插件，可以让我们预定义一些快捷的指令来记录一些具体格式的内容，也可以用它可以capture内容到指定文件，这个功能应该是借鉴于 Emacs 的 `org-mode`。
可以用它来记录闪念笔记，也可以指定模板来快速生成Blog，可以用它来帮你配置更多高级的功能。

可以点击[How to use QuickAdd for Obsidian - with examples](https://www.youtube.com/watch?v=gYK3VDQsZJo&ab_channel=ChristianB.B.Houmann)进一步学习使用。


### Tasks

可以使用query来查询散落在各个页面中的task也就是todo，这样就可以无拘束的在各个页面写下自己要做的事情，心智负担为0

比如可以展示出来我的write的tasks

![](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/iShot_2022-05-05_12.49.35.gif)


### Image auto upload Plugin

这个插件配合Picgo<sup>3</sup> 很方便的在Obsidian里插入图片，自动上传到图床，让markdown配图变成一件
简单的事情，尤其是对写Blog而言。

## 笔记插件
### Random Note 
这个经常用到，在复习笔记的时候很有用，点击之后会随机打开一篇笔记，类似维基百科的随机条目，对于庞大的笔记系统来说可以说是必备的插件。![](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20220505100237.png)


### Hypothsis 

主要用来管理网页上的标柱信息，能够很方便的将网页上的高亮文本同步到Obsidian中，还可以自己写备注信息，添加标签等，可以很有效的捕捉上网的时候的灵感。




## Reference
1. https://github.com/jgraph/drawio
2. https://github.com/plantuml/plantuml
3. https://github.com/Molunerfinn/PicGo
4. https://github.com/chhoumann/quickadd
5. https://sspai.com/post/69375
6. https://catcoding.me/p/obsidian-for-programmer/