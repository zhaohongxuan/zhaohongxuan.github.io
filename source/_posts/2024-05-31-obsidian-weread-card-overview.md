---
title: 使用Obsidian Dataview搭建微信读书阅读主页
categories: [效率工具]
tags: [微信读书,obsidian]
date: 2024-05-31 17:13:14
---

之前在Weread的Wiki中介绍过使用Dataview和Minimal主题管理微信读书的方法：[使用Dataview进行书籍管理](https://github.com/zhaohongxuan/obsidian-weread-plugin/wiki/%E4%BD%BF%E7%94%A8Dataview%E8%BF%9B%E8%A1%8C%E4%B9%A6%E7%B1%8D%E7%AE%A1%E7%90%86) ，随着Weread插件的不断迭代，现在增加了不少元数据，比如，开始阅读日期:readingDate，完成阅读日期：finishedDate ，阅读进度：progress等，且不需要手动添加readYear属性了，有了这些新的数据就可以更好的汇总读书数据了。

使用效果如图：
![Weread Card](https://raw.githubusercontent.com/zhaohongxuan/picgo/master/202405311721932.png)

<!-- more -->
## 准备

- 下载 [Obsidian - Sharpen your thinking](https://obsidian.md/)，并安装好软件
- 安装Obsidian Weread 插件，本人开发的一款Obsidian插件，用于同步所有的微信读书数据，有了数据才能做汇总页，可以在Obsidian官方市场下载或者Github Release页面下载手动安装：[GitHub - zhaohongxuan/obsidian-weread-plugin](https://github.com/zhaohongxuan/obsidian-weread-plugin)
- 安装Obsidian Dataview插件，官方市场下载
- Minimal主题或者自定义Card View 的css， 如果使用Minimal主题的话就不需要自定义css了，
## 步骤

### 同步微信读书数据

通过本人开发的 Obsidian Weread 插件，将自己微信读书的数据同步到Obsidian中，有了数据才能做汇总页，更多使用说明，可以参考微信读书Obsidian插件主页：[GitHub - zhaohongxuan/obsidian-weread-plugin: Obsidian Weread Plugin is a plugin to sync Weread(微信读书) hightlights and annotations into your Obsidian Vault.](https://github.com/zhaohongxuan/obsidian-weread-plugin)

这里需要记录下自己的微信读书笔记的文件夹，比如我自己的是`Reading/Weread`

### 主题准备

#### 选项一：
安装minimal 主题，直接在官方主题市场搜索下载
#### 选项二：
由于Card View的效果提取自minimal主题，因此，如果不适用minimal主题的话就需要手动安装Card View的css样式表。下载[Cards.css](https://raw.githubusercontent.com/zhaohongxuan/picgo/master/Cards.css) 放置到自定义css文件夹中、然后启用该css。

具体操作如下：
![](https://raw.githubusercontent.com/zhaohongxuan/picgo/master/202405311705960.png)

### 创建Card页面

创建一个空白页面，以源码的方式编辑文档，在文件的顶部，粘贴以下代码：

```yaml
---
cssclasses:
  - cards
  - cards-cols-5
  - iframe-wide
  - cards-cover
  - cards-align-bottom
---
```

这段代码是和css搭配的，顶部有这些属性的文档才会应用Card View 样式，不会影响到其他的文档。
### 使用Dataview筛选数据

使用Dataview可以很方便的筛选、汇总数据，这里主要使用微信读书笔记的`元数据`进行筛选和汇总，这些字段默认都会在文档顶部的frontmatter中存在。

我这里主要使用的属性如下：
- cover 书籍的封面
- file.link 表示的是双链地址
- readingTime 阅读时长
- readingStatus 阅读状态，总共有四个状态，空、在读、读过、读完。
- author 作者
- readingDate 开始阅读的时间
- finishedDate 开始阅读的时间
- lastReadDate 最近一次阅读时间

我的微信读书汇总页面，总共分成三个部分，2024在读清单、2024完成清单、历史完成清单，把当前年份领出来就是为了方便自己查看当年的数据。
### 2024年在读清单

这里包括了，我2024年阅读的书籍，过滤条件为：
- 微信读书文件夹，我这里是 `Reading/weread`
- cover不为空的
- readingStatus 是`在读`的
- lastReadDate.year 是 `2024`年的
最后一个条件表示的是，如果一本书在今年以前没读完，今年又重新读了，会被归结到今年在读清单里。

```js
table without id ("![](" + cover + ")") as cover ,file.link as Title, readingTime, readingStatus, author as Author, dateformat(readingDate,"yyyy-MM-dd") 
from "Reading/weread"  where cover != null and readingStatus = "在读" and lastReadDate.year = 2024
```

### 2024年已读清单

这个脚本抓取的是2024年已经阅读完成的书籍，上在读不一样的地方：
- readingStatus 是`读完`的，这个依赖于你自己在微信读书上面的标记，一般来说，我们每读一本书都会标记成读完。
- finishedDate.year = 2024

```js
table without id ("![](" + cover + ")") as cover,  file.link as Title, author as Author, "笔记：" + noteCount as NoteCount, dateformat(finishedDate,"yyyy-MM-dd") , readingTime
from "Reading/weread"  where cover != null and readingStatus = "读完"  and finishedDate.year = 2024 
SORT finishedDate DESC
```

### 历史已读

就是上面的脚本，把上面的=换成<，就是历史所有的已读书籍。

```js
table without id ("![](" + cover + ")") as Cover ,file.link as Title, author as Author, "笔记：" + noteCount as NoteCount, dateformat(finishedDate,"yyyy-MM-dd") as FinishedDate 
from "Reading/weread"  where cover != null and readingStatus = "读完"  and finishedDate.year < 2024
sort finishedDate DESC
```

## 总结

Obsdian的玩法很多，你可以根据自己的实际需求来进行更改，添加自己需要展示的字段，删除不需要展示的字段，而且不使用自定义css和minimal主题也可以完成，比如使用Project插件和Component插件，可以参考：[Obsidian使用Components快速搭建可视化图书库\_哔哩哔哩\_bilibili](https://www.bilibili.com/video/BV1AF4m1T79g/?spm_id_from=333.337.search-card.all.click&vd_source=6c9d35b151f6826cf41b939376b81ead)和 [和 Projects 插件结合的场景 · zhaohongxuan/obsidian-weread-plugin · Discussion #130 · GitHub](https://github.com/zhaohongxuan/obsidian-weread-plugin/discussions/130)

## References
- [Obsidian - Sharpen your thinking](https://obsidian.md/)
- [GitHub - zhaohongxuan/obsidian-weread-plugin: Obsidian Weread Plugin is a plugin to sync Weread(微信读书) hightlights and annotations into your Obsidian Vault.](https://github.com/zhaohongxuan/obsidian-weread-plugin)
- [Snippet so you can use Dataview Cards from Minimal theme in any theme - Share & showcase - Obsidian Forum](https://forum.obsidian.md/t/snippet-so-you-can-use-dataview-cards-from-minimal-theme-in-any-theme/56866/12)

