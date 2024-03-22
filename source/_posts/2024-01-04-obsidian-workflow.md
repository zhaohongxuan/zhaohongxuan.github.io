---
title: 我的Obsidian笔记工作流
date: 2024-01-04 18:34:38
tags:
  - obsidian
  - 卡片笔记
  - 效率工具
category: 效率工具 
cover: https://raw.githubusercontent.com/zhaohongxuan/picgo/master/20240104183635.png 
---

个人认为笔记的本质是： **让思考继续发生**。记笔记不是目的，是为了更好的服务于思考，但是大脑不善于存储和检索，因此才要记笔记，本质是上是给大脑减压，记笔记的各种方法也都是为了让大脑更好的思考。大脑本能是躲避思考的，所以要尽可能简化记笔记的流程，形成习惯。


由于我对卡片笔记的理解还不够深刻，也还在探索中，因此这篇文章旨在分享我的一些心得和体会，每个人的习惯不一样，因此笔记方法因人而已，别人的方法不一定是适合自己的，每个人都要探索形成自己的笔记方法。

## 我的笔记原则

<!-- more-->

- 没有最好的笔记软件，没有工具可以解决所有问题。
- 没有最好的笔记方法，不迷信任何人的方法，探索自己记录笔记的方法。
- 方法是可以被改进的，工具是可以被改进的。
- 记录笔记时多记录元数据，多建立链接和标签，尽量和其他笔记发生链接，尽量不建立Orphan笔记。
- 笔记要定期回顾，把过期的draft笔记清理掉。



## 为什么是Obsidian？

- Obsidian很简单，开箱即用，虽然没有开源，但是个人用户免费。
- Obsidian基于纯文本的markdown文件，不怕跑路，就算跑路了，markdown转移到其他软件中成本也小。
- Obsidian不是基于网络的，离线同步的模式可以更好的适应不同的环境。
- Obsidian够开放，插件市场很丰富，还可以自己编写插件，定制属于自己的功能。
- Obsidian在支持双链的同时还保持了和传统笔记一样的文件夹层级，对于普通用户更加友好，大纲型笔记（如RoamResearch和logseq为代表）可能不太适合我（并不是说大纲型笔记不好）。

当然，这只是当下的选择而已，以后可能还会随着时间变化，不必执着于工具，掌握了方法，使用`Apple Notes`一样可以把笔记整理的很好，笔记工具有很多，选择一个自己趁手的工具就好了，在不断的写作中不断迭代自己的方法即可。


## Obsidian 工作流

目前我的卡片笔记工作流，是基于Obsidian的`Daily Notes`，也称为Journal构建的。对我来说，记log最大的优点在于记录的时候不用思考这个笔记应该放在哪里，不要小瞧这个小问题，这一步很消耗脑力，大脑为了躲避思考，可能就会排斥做笔记，做笔记的难度就提升了。

Journal型笔记最大的优点就在于记录的时候压力很小，如果大脑中有一个idea，直接capture住这个idea加入到log中就行了，在这个过程中尽可能多的为这个idea添加元数据，比如标签或者双链，这就需要自己在建立笔记的时候尽量多使用标签或者双链，这样，我们在以后提取的时候就能够尽可能多的提取到有用的信息，让自己大脑可以方便的Switch Context，有了这些特征信息，大脑就能更快、更准确的把这些信息提取出来，让思考继续发生。有了这些idea，一些伟大的产品就可以诞生，可能是一个side project，甚至是一个company。

下面是我在Obsidian中记录笔记的workflow：
![](https://raw.githubusercontent.com/zhaohongxuan/picgo/master/20240104183635.png)
### 捕获 Capture

捕获（Capture）是记录脑瓜子里一闪而过的一些想法，这里就分成了两类：
- 一类是自己想到的，比如散步的时候，一闪而过的灵感。
- 一类是在阅读，这里的阅读很宽泛，包括读书、rss工具、公众号、社交媒体或者看视频和听博客时候自己想到的一些想法。
这里Journal其实充当了灵感笔记（Fleeting Note ）的作用。

#### 捕获想法（灵感）

Capture灵感和想法需要即时性，因为灵感不常有，是个非常稀缺的东西，一般出现在reflection中，比如正念的过程，或者刚睡醒的早上，或者运动的过程中。大部分时候就是一瞬间的事情，理论上可以用任何工具，手机上自带的Notes 或者Todolist都是可以的，这一步主要是帮助自己快速捕捉到大脑的想法，因为这些灵感稍纵即逝。

在移动端，我自己使用Obsidian的Quickadd插件，下拉就可以在Journal记录想法，手机上不适合大段的编辑文字，但是非常适合捕捉灵感。比如在地铁上，或者走路的时候，突然迸发的灵感，就可以用手机随时记录。

在电脑端，我会直接在Obsidian的Journal中直接记录。平时我的电脑的一个屏幕里是专门放置的Obsidian，
如果是简单的想法，我会直接在log中记录想法，然后打上标签，如果未来以后有什么计划，比如要写一个帖子或者blog等，会建立一个**双向链接**的Placeholder，然后打上标签，比如 `#tasks/write`等，这些标签会在一个主页里通过dataview和[Tasks](https://github.com/obsidian-tasks-group/obsidian-tasks)插件进行搜索展示：


```
not done
sort by due desc
description includes tasks/write
```

如果是要发一个X帖子这样的简单的Task，我就直接在Journal中新建一个bullet list 记录，然后随手打一个标签，然后使用Dataview汇总：

```
list L.text
from "Journal"
flatten file.lists as L
where contains(L.tags, "#backlog") and contains(L.tags, "#twitter")
```

#### 捕获阅读信息

更多时候，我们是在阅读的时候产生的灵感，我们被我们的好奇心和兴趣所牵引，去阅读、观看、收听一些我们感兴趣的内容，我常用的工具如下：
- 阅读工具：
	- 微信读书，我使用自己写的Obsidian Weread Plugin同步读书笔记到Obsidian中。
	- NetNewsWire：Apple平台最佳的开源rss阅读器，订阅的优秀的blog和newsletter来收集信息。
	- Safari阅读列表：一些gitbook会收藏进safari的阅读列表中，在碎片时间进行阅读。
- 社交媒体：
	- X（Twitter）：关注海内外一些优秀的开发者分享的一些有趣的内容。
	- Telegram：关注了一些开发者的频道，会分享一些业界比较关注的资讯。
	- IT之家：已经使用十年了，基本上每天都会刷一会儿
- 媒体工具：
	- Bilibili：看一些自己感兴趣的视频，
	- 小宇宙：在跑步或者地铁上的时候会听一些自己订阅的播客。

如果是读到的感兴趣的内容，就需要建立一个简单的卡片笔记，把援引的链接记录下来，然后把文章的内容和自己的想法下来，在这一步就是类似于制作卡片的过程，不需要过多的引用原文，要尽可能多的思考，然后用自己的话写出来，然后尽可能多的添加元数据信息，比如各种标签，以及关联上各种已经存在的链接，让这个卡片渐渐丰满起来，这个卡片是为了以后整理加工使用的，

这一步千万不要着急，一天能有个三四个卡片就够了，每个卡片代表了自己思考的过程。
### 整理和提取

整理是把这些零散的信息，重新加工成自己需要的笔记，在**捕获**这一步，我们已经尽可能多的把信息保存下来了。
比如，各种个样的标签，我这里使用Obsidian的dataview插件和tasks插件，把需要进一步整理的任务列出来，仅此，检索这些需要进一步处理的任务变得简单。

此外，由于我们此前已经在文献笔记卡片上记录了足够多的信息，因此，就算过了几天，大脑也能快速切换到当前的上下文，快速进入记笔记的状态，不用担心提笔忘字。比如，我们要根据卡片内容，写一个twitter帖子，或者写一篇blog，我们可以根据现在卡片上的内容以及关联的各种信息和其他卡片，进一步整理加工，形成一个永久笔记（Permanent Notes）。

这一步可能比较耗时，比如一篇blog写上大半天都是有可能的。

### 输出和回顾

> 你对某件事情越感兴趣，就会阅读得越多，思考得越多，进而收集的笔记越多，最终越有可能从中提出问题和想法。它可能正是你一开始就感兴趣的东西，但更有可能是你的兴趣已经发生了变化，这就是洞见的作用。 --《卡片笔记写作法》

最终，我们写出了一个有价值的内容，可以存放到一个单独的文件夹保存，等待以后检索和提取，也可以分享到社交平台上接受检验，我们的目的不在于分享本身，而是公开学习的过程可以促使我们更好的思考和学习，而笔记只是学习的成果。当然笔记并不是要在文件夹中吃灰的，而是需要经常回顾的，在回顾的过程中，可能会产生新的灵感，每一次回顾，我们都可以获取新的收获。我一般使用Random的插件来随机访问自己写的笔记，然后反思之后产生新的想法。

## 总结

简述一下我一天的记录流程：
- 每天早上起床洗漱完成之后，打开Journal，看下Dashboard，回顾一下先前的任务和没有做完的事情，然和写下这一天的主要目标🎯，比如完成某个任务，学习一个主题等。
- 看一会儿RSS和X，如果看到感兴趣的主题，会capture成为一个卡片，然后链接到Journal中，然后给卡片打上各种标签，如果当时有时间就思考，然后构建一个卡片，如果没有时间，那就打上标记TBD，等待后续进一步处理，Dashboard中会记录各种TBD的卡片的记录。
- 地铁上使用微信读书标记以及写想法，然后使用插件同步笔记到Obsidian中。
- 工作中遇到的一些问题，或者想法也会及时capture到journal中。
- 有自己的时间的时候开始整理自己的卡片，根据卡片整理成永久笔记。分享自己的研究学习成果到互联网。
- 删除没有用的draft note

这个流程的核心是有一个地方可以存放自己的闪念笔记（Fleeting Notes，存放自己的灵感和草稿），然后将它们源源不断地转换为永久笔记，永久笔记就是自己学习的成果，可以将它们分享到网络上，或者存放在自己单独的文件夹中。在持续不断的[[公开学习]]中，我们不断将学到的东西转换为其他人能够看的懂的内容，这种[[费曼学习法]]可以极大的提高自己的学习效率，在一个小小的领域里面不断研究，进步是非常迅速的。

每个人都有自己的记录笔记的方式方法，每个人记录笔记的方法不一定适合他人，最多只能给启发。
## References
-  《卡片笔记写作法：如何实现从阅读到写作》
- [我的 Obsidian 使用经验  程序员的喵](https://catcoding.me/p/obsidian-for-programmer/)