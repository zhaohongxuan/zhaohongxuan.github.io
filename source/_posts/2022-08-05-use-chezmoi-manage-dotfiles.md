---
title: 使用chezmoi管理dotfiles
date: 2022-08-05 13:35
tags: [dotfiles,chezmoi]
category: 工具效率
---

## 为什么要管理dotfiles？

dotfile是对自己的软件配置文件的总称，如果有多台开发设备的话，我们需要在不同的电脑上保持同样的配置，我们对工具的使用不是一成不变的，而是随着时间不断演进的，日常使用的过程中，会不断修改dotfile让工具越来越顺手，这时同步dotfile就变得非常重要了，你的工具的行为在多个平台上应该是一致的，就像VSCode自带的setting 同步功能一样。

## dotfiles管理的痛点

- dotfile总是分布在不同的位置，想把他们汇总在同一个位置非常不方便，使用软连接之后，用github管理又非常不便。
- 配置文件的修改不能及时同步到github
- 多个设备可能跨平台，配置文件可能是不一样的
- 相同的平台，不同的设备也有差异化的配置，比如工作电脑和自己私人电脑，有一些配置肯定是不一样的
- 密码管理器，选择自己合适的密码管理软件（）

## 什么是chezmoi？

[chezmoi](https://www.chezmoi.io/)是一款使用go语言编写的跨平台的的dot配置管理器，它是一个法语单词，意思是家，读作 /ʃeɪ mwa/ (shay-moi)

chezmoi的工作原理很简单：
![](https://raw.githubusercontent.com/zhaohongxuan/picgo/master/20220806123526.png)

它使用一个working copy来管理dotfiles，`chezmoi`负责对`working copy`和`home directory` 进行同步，然后使用`git`来管理 `working copy`和`remote repo`的差异。

<!-- more -->

## chezmoi基本使用

安装非常简单，我使用mac 直接 `brew install chezmoi` 就行了，如果你使用其他的平台，可以参考：[Install - chezmoi](https://www.chezmoi.io/install/)

### 初始化


如果是初次使用的话，先使用`chezmoi init`会在`~/.local/share/chezmoi`创建一个git仓库，这个是local的repo，我们还需要一个remote的repo，我们可以在github上创建一个名字为：`dotfiles`的Repo来存储自己的dotfiles，dotfiles名字是chezmoi的使用惯例，使用起来更方便，参考`### 在其他设备上使用dotfiles` 这一章节。

### 添加dotfile

添加dotfile到chezomi管理 ，例如 `chezmoi add ~/.zshrc`  就会把我们的.zshrc文件copy到`~/.local/share/chezmoi` 中去，并且改名字为：`dot_zshrc` ，它是和`.zshrc` 一一对应的，是.zshrc的一份working copy。

### 编辑dotfile
一旦添加到chezomoi，编辑`.zshrc`的时候我们就需要使用 `chezmoi edit ~/.zshrc`来编辑zshrc文件，这个命令会自动帮我们mapping到 `dot_zshrc`文件进行修改，当然你也可以直接到`~/.local/share/chezmoi`  直接编辑`dot_zshrc`文件，效果是一样的。
编辑完成之后，可以使用 `chezmoi diff` 来查看修改的部分。比如我使用 `chezmoi edit ~/.zshrc`在文件最后加上`alias cm='chezmoi'` ，然后使用 `chezmoi diff`  命令，可以看到:
![](https://raw.githubusercontent.com/zhaohongxuan/picgo/master/20220806122654.png)
然后我们执行`chezmoi -v apply` 来使dotfile生效，如果你不想每次都`chezmoi apply` 
可以在`~/.config/chezmoi/chezmoi.toml`加上下面的配置文件：
```toml
[git]
    autoCommit = true
    autoPush = true

```

### 同步dotfile到github
我们所做的编辑都只是在本地的working copy，想要在其他的设备上使用，首先要同步到github上，chezomi 把这个权利交给了git，我们可以首先 `chezmoi cd`  进入到 working copy的文件夹，然后就和普通的git操作一致了：

1. `git status` 来看working copy 工作区的文件状态
2. `git add` 来把修改过后的dotfile添加到git缓冲区
3. `git commit & push` 提交dotfile 和push dotfile到github 

当然你也可以直接使用`chezmoi git `来进行git的相关操作而不用进入文件夹。

## 在其他设备上使用dotfiles

我们维护了dotfiles repo之后，以后我们到其他的设备上初始化的时候直接 `chezmoi init --apply username`即可，chezmoi会自动到github名字为`username`的repo下寻找`dotfiles`的repo来进行初始化，叫这个名字是为了使用方便，也可以使用其他名字，在其他设备上初始化的时候，需要指定github repo的全地址：`chezmoi init https://github.com/username/dotfiles.git`


## 管理可执行Script
除了dotfiles 我们一般在开发的过程中会有一些script需要，在各个设备上运行，这个时候就可以设置script，chezmoi的script是在source 文件夹（`~/.local/share/chezmoi`）以 `run_` 开头的文件，chezmoi会以按照字母顺序执行，其中，`run_once_`开头的会执行一次，
`run_onchange_`会在每次文件内容有变化的时候执行。
具体参考：[Use scripts to perform actions - chezmoi](https://www.chezmoi.io/user-guide/use-scripts-to-perform-actions/)

## 结语

这篇文章只是简单的介绍基本使用，除此之外，还支持 template操作，它可以帮你管理设备之间的差异，还支持多种密码管理器，支持外部文件（比如`.oh-my-zsh` 以及插件等），可以参考：[Command overview - chezmoi](https://www.chezmoi.io/user-guide/command-overview/)  获取更多信息。

最后放上我的dotfile仓库：[Hank's dotfiles](https://github.com/zhaohongxuan/dotfiles)

## Reference 
1.  [chezmoi - chezmoi](https://www.chezmoi.io/#considering-using-chezmoi)
2. [[使用chezmoi管理dotfiles]]