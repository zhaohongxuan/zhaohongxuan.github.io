---
title: 自动分组chrome标签页
date: 2023-05-05 21:25:18
tags: [效率,chrome扩展]
---

Chrome的标签功能在管理多个标签页时非常好用，但是在标签量更大一些的时候，手动的管理这些标签页就不太方便了，这个时候可以考虑使用chrome扩展来完成这一自动化的操作，特别是对于工作的场景，基本上每天打开的网站都是特定的场景。

Auto-Group Tabs是一个Chrome浏览器插件，用于自动对用户打开的多个标签进行分组，以使它们更容易管理和组织。这个插件还支持配置的导入和导出，可以方便的在多个设备上同步。

## 安装
通过chrome商店：[Auto-Group Tabs - Extensions](https://chrome.google.com/webstore/detail/auto-group-tabs/danncghahncanipdoajmakdbeaophenb) 打开此链接，点击安装即可，如果在商店搜索安装的时候，有多个类似的扩展，注意选择下面这个。

## 配置和使用

<!-- more -->

### 基础配置

对于我工作的电脑，我的标签：

gitlab：
主要是管理一些打开的gitlab repo，MR、pipeline等链接

wiki：
主要是管理confluence上面的文档之类的，包括自己写的文档， Release check list等链接

jira：
主要包含，自己的

dev：
主要是在开发环境相关的一些页面，包括，开发环境的，kibana、argocd、pipeline等链接，管理后台等。

live：
主要包含一些monitoring的相关页面，比如grafana、argocd、kibana等，还有一些业务使用的页面，比如管理后台等

search：
主要是管理自己google search的结果，从search标签里查询出来的结果，如果没有被自动Group到其他的标签就会自动在当前的search标签中。

我的插件配置如下：
![我的插件配置](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/Pasted%20image%2020230209184708.png)

### 使用时添加

配置完成之后，如果以后我们在打开某些网站的时候也可以很方便的添加到我们的规则里，比如在逛京东的时候，可以把京东 `*.jd.co`添加到我们的shopping规则中，然后京东就会自动添加到我们的shopping标签中。

![使用](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/Pasted%20image%2020230209185535.png)






