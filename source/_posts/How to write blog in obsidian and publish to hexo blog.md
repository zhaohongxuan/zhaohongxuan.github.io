---
title: Obsidian和Hexo结合的解决方案
date: 2022-05-03 18:45:29
tags: linux/rsync obsidian
category: obsidian
---

## 背景

Obsidian目前是我的主力笔记软件，Hexo是我的Github Pages引擎。孟子曰：

> 鱼，我所欲也；熊掌，亦我所欲也。二者不可得兼。

虽说二者不可兼得，但是程序员思维总是会指导我：必定有一个方案可以解决这个问题，如果没有那那就创造一个。

在没有Obsidian之前我写Blog的流程是直接在VSCode中打开`blog_source`文件夹，然后编辑md文件，提交到Github然后自动生成Github Pages.

在使用Obsidian之后我会现在Obsidian中建立相关的页面，然后编辑完成之后copy到blog_source文件夹，提交到github，这就导致了一个心智负担：每次都得做重复的工作，copy文件，然后提交代码，间接导致了我不想写Blog（逃。

如何才能在愉快的一边在Obsidian里写笔记一边还能无缝发布Blog呢？

<!-- more -->

我的想法是通过同步Obsidian的Blog目录里的文件`sync`到我们的Github Pages Blog目录，然后在git commit push来间接达到我们的目的。

这里sync操作可以使用`rsync命令`<sup>1</sup>来解决，rsync是一个非常厉害的命令，这里只是用到了最基本的操作，也就是覆盖式同步。

- 优点：只使用git管理 GitHub Pages, 其他的md文件还是通过云盘来同步，虽然拉跨，但是在iPhone和iPad上使用省心不少。

- 缺点：需要在每个电脑上配置一个脚本来进行rsync操作，Mobile端一般也不会写Blog，所以不需要配置这个脚本。
所以这里选择了第二个思路来达到我的目的。

## 同步Obsidian的Blog文件夹到Hexo Blog的_post文件夹
使用rsync命令，一般的linux发行版上都会自带这个命令的，需要注意的是
如果要覆盖是更新，记得要加上`--delete` <sup>2</sup>

```shell
rsync -avu --delete ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/xuan/Blog/ ~/VSCodeProjects/blog_source/source/_posts/
```

## 将变化的post提交到github

这一步需要进入到Github Page的目录，我这里用的是Hexo blog，然后添加所有的md文件，提交到Github
```shell
cd ~/VSCodeProjects/blog_source/source/_posts/
git add *.md 
git commit -m "Commit from Obsidian" 
git push

```

## 编写sh脚本

### 预览Blog

编写一个预览Blog的脚本`sync-commit-obsidian.sh` 
1. 同步blog文件到Blog文件夹
2. hexo server启动本地预览
3. 打开浏览器预览blog

```shell
#!/bin/sh
#!/bin/sh
rsync -avu --delete ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/xuan/Blog/ ~/VSCodeProjects/blog_source/source/_posts/
cd /VSCodeProjects/blog_source
hexo server
open 'http://localhost:4000'

```

这个脚本可以放在一个固定文件夹里，我这里放到`~/Developer/scripts/`里，等下面Obsidian配置shell command的时候会用到。

### 发布Blog

将脚本写入到一个sh文件里，`sync-commit-obsidian-posts.sh` 然后存放在一个目录里，我这里存放在`~/Developer/scripts/`下面
```bash
#!/bin/sh
rsync -avu --delete ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/xuan/Blog/ ~/VSCodeProjects/blog_source/source/_posts/
cd ~/VSCodeProjects/blog_source/source/_posts/
git add .
git commit -m "Commit from Obsidian"
git push
```


## 在Obsidian中执行Shell命令
在Community Plugins中搜索`Shell Command`插件，install 之后记得enable，在Shell Command的设置页面增加`pub`来进行blog publish，这里要记得绑定到你使用的shell上，比如zsh。

我这里会增加两个快捷命令

### 第一个是preview

![](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20220504090032.png)


### 第二个是publish

![publish](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20220503180128.png)

直接使用快捷键`Command+P`唤出`command pelette`输入`preview`即可本地预览，输入`pub`即可发布Blog，当然也可以绑定快捷键直接操作，在github上就能看到Github Page相关的action已经执行了，博客成功发布。

![](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20220503164014.png)


## Reference
1.  [rsync 用法教程](https://www.ruanyifeng.com/blog/2020/08/rsync.html)
2. [How to sync two folders with command line tools?](https://unix.stackexchange.com/questions/203846/how-to-sync-two-folders-with-command-line-tools)
3. https://forum.obsidian.md/t/mobile-setting-up-ios-git-based-syncing-with-mobile-app-using-working-copy/16499