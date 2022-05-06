
---
title: 你会使用 git zsh alias 吗？
date: 2021-01-02 20:45:29
tags: git zsh 
category: linux
---


Git 可以说是每个开发者必备的技能了，使用source tree之类的图形工具的同时，最好能修炼一下git命令行技能，在某种程度上可以让你更加高效的操作，也能在你ssh到远程机器上操作的时候能够临阵不慌，同时在工作中也能体会到git + zsh操作的方便之处。
![doggy](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20210130162903.png)

<!-- more-->
alias是命令行下非常重要的一个功能，能够大大减少我们击键的次数，符合Don’t Repeat Yourself 的哲学。在oh my zsh 内置了很多使用的alias，默认git插件是启用的，所以这些alias也会启用，省去了自己配置的步骤，只需要记忆使用即可。

接下来我会从软件开发的场景来分享一下常用git命令的alias，重点部分用**加粗字体**标注，覆盖的不是很全，但绝对是常用的命令，当然也可以使用grep命令来检索相关alias。

![搜索alias](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20210130162940.png)

# 初始化项目

1. clone远程项目的副本，在你的项目文件夹下执行

```
gcl [repo-url] => git clone [repo-url]
```

2.如果你本地已经有项目了，需要关联到远程repo 可以执行

```
关联到一个远程仓库 
gra => git remote add origin 
设置远程仓库的url，一般用于将ssh模式改为https或者反过来https转换为ssh模式
grset => git remote set-url origin [repo-url]
```

# 分支操作

列出分支：

```
列出本地所有分支，*号代表当前分支
gb  => git branch			
列出远程所有分支
gbr => git branch --remote
列出本地和远程所有分支
gba => git branch -a	
```

创建分支

```
创建新的分支, 分支还停留在当前分支
gb [branch name]  => git branch [branch name]	
删除现有分支
gbd => git branch -d [branch name]	
删除远程分支
gbD => git push origin --delete [branch name]	
```

切换分支

```
创建一个本地分支，并且切换到该分支
gcb => git checkout -b [branch name]
克隆一个远程分支并且切换到这个分支
gcb => git checkout -b [branch name] origin/[branch name]	
切换到一个本地分支
gco => git checkout [branch name]
切换到主分支，一般是master分支
gcm => git checkout $(git_main_branch) 
切换到上一个checkout的分支
gco -  => git checkout -	
```

重新命名分支

```
重新命名本地分支
gb -m  =>  git branch -m [old branch name] [new branch name]	
```

# 缓冲区文件操作（必备）

显示变更的文件，最常用的操作，类似于命令行下的ls

```
展示缓冲区文件的状态
gst => git status 
```

添加文件进缓冲区

```
添加文件进缓冲区
ga  => git add [filename.txt]  
添加所有变化的文件进缓冲
gaa => git add -A	
```

提交变更，我最常用的操作是**gca**

```
提交变更并输入message 
gcmas => git commit -m "[commit message]"	
在编辑器（默认是vim）中展示所有的变更行，在行首输入message保存后将提交所有变更
gca   => git commit -v -a 
添加变更到缓冲区兵提交所有的变更
gcam  => git commit -a -m 
修改最后一次的提交message
gc!   => git commit -v --amend 
```

删除变更文件

```
git rm -r [filename.txt]	" 将文件/文件夹移除缓冲区
```

# 更新工作区&远程仓库（必备）

更新本地工作区，**gl和ggpull**最常用

```
更新本地工作区
gl => git pull	
从远程仓库更新变更
ggpull => git pull origin $(current_branch) 
获取变更，使用rebase操作来处理变更，默认是merge
gup => git pull --rebase 
从upstream更新变更，fork仓库是更新源仓库代码用到
glum => git pull upstream ${git_main_branch} 
```

推送缓冲区变更到远程仓库，其中**ggpush**最常用

```
gp  => git push 
推送一个分支变更到远程仓库
ggpush => git push origin ${git_current_branch} 
推送本地分支到远程仓库，并关联该分支，一般用在初始化仓库
gp -u		=> git push -u origin 
推送远程分支，兵设置upstream
gpsup => git push --set-upstream origin $(git_current_branch) 

```

reset本地工作区至HEAD

```
将当前代码重置为HEAD
grh  =>  git reset HEAD   
grhh => git reset HEAD --hard 
```

# 查看日志

查看日志，我常用的是 **glg和glog**

```
展示commit历史，以及commit的情况
glg - git log --stat --max-count=10 
展示commit 历史，在单行展示message
glo - git log --oneline --decorate --color 
展示commit历史，以terminal图形展示
glog - git log --oneline --decorate --color --graph 
```

![glog](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20210130163023.png)

![glog](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20210130163101.png)

统计代码提交人的commit次数（**常用**）：

```
gcount - git shortlog -sn
```

![统计代码commit次数](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20210130163127.png)

# Merge & Rebase

合并操作

```
将这个分支合并进当前active的分支，比如git merge master 合并master分支到当前分支
gm => git merge [branch name]	
将源分支合并进目标分支
gm => git merge [source branch] [target branch]	
终止当前merge，丢弃所有变更
gma => git merge --abort 
```

变基操作（经常使用，牢记）：

```
[numbers~HEAD]或者[SHA] rebase 代码到某个commit
grbi => git rebase -i  
继续rebase，一般在rebase有冲突的时候，你resolve所有冲突之后，需要进行这一步 
grbc => git rebase --continue 
终止rebase
grba => git rebase --abort 
```

**参考文档：**

https://git-scm.com/book/zh/v2

https://github.com/ohmyzsh/ohmyzsh/wiki/Cheatsheet

