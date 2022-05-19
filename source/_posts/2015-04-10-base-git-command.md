---
layout: post
title:  "Git常见命令!"
date: 2015-04-10
category: 版本控制
tags: #tools/git
---
## Git基本操作命令
### 创建Git版本仓库
在本地的任何一个空目录，通过`git init`把目录变成一个Git仓库

	git init

### 添加文件到Git仓库

	git add <file_name>

### 提交文件到Git仓库

	git commit -m "<commit_message>"

### 显示提交日志

	git log [--pretty=oneline] 

可以加上`--pretty=oneline`参数来减少输出的信息,	`git log --graph`命令可以看到分支合并图。
### 回退上一个版本

	git reset --hard HEAD
	
上一个版本就是`HEAD^`，上上一个版本就是`HEAD^^`，如果版本号较多，可以写成`HEAD~100`。
### 查看命令日志

	git reflog

### 查看Git仓库状态

	git status

### 添加文件到暂存区

	git add

### 将暂存区文件提交到当前分支

	git commit

### 撤销修改

	git checkout --<file_name>

### 删除文件

	git rm <file_name>
<!-- more -->
## 远程仓库
### 添加远程库
在本地的仓库下面运行

	$ git remote add origin git@github.com:zhaohongxuan/zhaohongxuan.github.io.git

将本地库内容推送到远程库上

	git push [-u] origin master

其中`-u`参数会把本地的master分支和远程的master分支关联起来。
### 从远程仓库克隆

	$ git clone git@github.com:zhaohongxuan/zhaohongxuan.github.io.git

地址可使用SSH协议的git地址，也可以使用Https协议的地址
## 分支管理
### 查看当前分支

	git branch

### 显示本地、服务器所有分支

	git branch -a

### 显示本地分支和服务器分支的映射关系

	git branch -vv

### 切换分支

	git checkout <branch_name>

### 创建新分支

	git checkout -b  <branch_name>

### 提交本地分支代码到远端服务器

	git push origin <remote_branch_name>

如果远端服务器没有该分支，将会自动创建
### 更新远端分支代码到本地当前分支

	git pull origin master

### 合并分支到当前分支

	git merge <branch_name>

### 合并远程master分支到当前分支

	git merge origin/master

### 删除本地分支

	git checkout <another_branch>
	git branch -d <branch_name>

### 删除远程分支

	git push origin --delete <branch_name>

## 标签管理
### 创建标签
首先切换到要创建标签的分支

	git tag <tag_name>

标签打在最新提交的commit上
### 查看标签

	git tag

### 查看标签详情

	git show tag <tag_name>

### 删除标签

	git tag -d <tag_name>

### 将标签推送至远程

	git push origin <tag_name> 

使用`git push origin --tags` 推送所有标签到远程
### 删除远程标签
删除远程标签需要先删除本地的标签，然后输入下面命令

	git push origin :refs/tags/<tagname>
 
