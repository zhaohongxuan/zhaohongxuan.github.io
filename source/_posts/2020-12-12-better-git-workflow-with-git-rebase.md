---
title: 一个基于Git Rebase的高效Workflow
date: 2020-12-06 15:28:29
tags: tools/git
category: tools

---

**你是否还在经历合并代码的痛苦？**你是否经历过刚合并完代码，又提示合并反复多次？

这个时候你可能需要使用git rebase了，我会通过这篇文章来告诉你一个基于rebase的高效git workflow，学习成本很低，但是学会了受益无穷。

如果不想看文章正文可以直接滑到末尾，我总结了整篇文章的重点，直接用就可以了。

# 为什么要用Git rebase

很多公司在使用git的时候没有一套规范，自己想怎么提交就怎么提，rebase和merge乱用，最后导致git log非常的混乱，commit全是各种小补丁，看起来就像狗皮膏药一样。比如下面的gitlog，能够看到代码分支纵横交错，看起来非常的费力：
<!-- more -->
![](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20210130160447.png)



而一个整洁的git log应该是下面这样的，master是一条直线，历史的提交非常整洁。

![使用rebase来协作](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20210130161152.png)




# 背景介绍

正常的软件开发流程是：

首先你接到一个开发需求，比如说是，你就首先建立一个分支

假如你在自己的dev branch中提交了5次commit，很多都是调试性的gitlog，比如增加配置、添加log，或者直接就是一个update，这些commit你都已经push到repo了，因为代码push到Dev环境才能让测试介入测试。

当测试到一半的时候，突然有一个同事的feature上线了，这个时候你就需要重新更新master的代码。

如果使用不当，那么在你rebase/merge master分支的时候简直就是一个灾难现场，假如你有5次提交，你需要不停的处理**5次**基本上相同的git 代码冲突，处理到你怀疑人生。

# 使用Git rebase来优化整个workflow

**3.1 Squash自己branch的commit**

在和master代码进行交互之前，首先在自己的branch上使用 rebase squash自己的commit。

```bash
git rebase -i [SHA] 
或者
git rebase -i HEAD~[NUMBER OF COMMIT]
```

这两者是等价的，如果使用zsh的话可以使用，grbi来代替git rebase -i这个命令.

```bash
git rebase -i HEAD~5 等价于 grbi HEAD~5
```

假如我要squash下面的5个commit到9a86d1c（当然需要根据你的代码情况来判断，我这里只是举一个例子）的提交上面。

![git log](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20210130160851.png)

那么我们, git rebase -i HEAD~5就会出现下面的rebase 交互界面, 仔细观察会发现这个顺序其实是和gitlog**相反的**，最上面的是最早的commit，最下面的最近的commit。

![git rebase](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20210130161014.png)



我们把除了第一个的commit前面pick改成s就好了，这里的s代表squash。保存之后会弹出编辑commit message的页面，在这里面更改你的commit message，结束之后保存，

![squash commit message](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20210130161338.png)

![rebase successful](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20210130161403.png)


我这里是成功了，假如有冲突的话，需要手工进行冲突解决。由于是自己的分支上进行的rebase，所以一般不会起冲突，所以用起来很方便。

rebase squash完成之后，如果你之前已经push过origin的话，那么需要你执行

```bash
git push origin branchName --force
```

如果你安装了zsh，可以用ggpush -f 来强制更新你的代码到origin，当然，你也可以rebase了master之后再进行这一步。

**3.2 从自己的branch rebase master代码**

squash了自己的branch之后就可以rebase master代码了，方法也非常简单：

```bash
git checkout master
git pull  
或者 
git fetch origin master:master
```

这个时候一般来说不会有太多的冲突，大部分时候就是release的版本号会冲突，这个时候只需要简单处理就好了。

rebase master完成之后就可以把自己的代码push 到origin了，方法同3.1。

# 总结一下

**整个git workflow是这样的：**

一、从master最新代码 checkout 新的分支进行开发

git checkout -b feature/branch_name

二、中间随意进行代码提交即可，不要想着会污染git log，待所有的单元测试都完成之后，就可以使用rebase squash来合并commit，这个数量可从git log中算出来。

git rebase -i [SHA] 或 git rebase -i HEAD~[合并commit的数量]，

三、如果你之前push过 origin，可能需要force push（自己的分支不用担心），

git push origin branchName --force或者ggpush -f（zsh）

四、更新master代码

```
git checkout master && git pull  
或者 
git fetch origin master:master
```

五、在你的feature branch rebase master代码，然后处理冲突（**这时只需要处理一次冲突，因为之前做过squash**）

git rebase master

六、重新force push代码到remote，如果你有CI的话，那么这里就结束了，因为CI会帮你从feature到master的步骤

七、如果你没有CI的话，那么需要你把feature branch **merge（从feature到master用merge）**到master，然后git push origin master，整个workflow就结束了。

这样一套 git workflow下来，你的代码提交日志将会非常整洁，看起来一点也不凌乱，如果你学会了，记得要向同事推荐，这将大大降低协作的成本。当然也要注意由于使用了 git force push，所以使用起来要**小心一点**，不过只要不用在自己的分支以外就没有问题。