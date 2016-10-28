---
layout: post
title:  "同一台电脑使用多个Git账号"
keywords: "scala"
description: "同一台电脑使用多个Git账号解决Github提交无Contribution的情况"
category: git
tags: git
---

今天写了文章post到github上发现github并没有记录contribution,使用sourceTree查看提交历史，发现是用公司的git账号提交的，o(╯□╰)o
![git](http://i4.tietuku.com/029904b6b173d5d5.png)

使用下面命令设置本项目中的用户和邮箱

    git config user.name javaor
    git config user.email hxzhenu@gmail.com

