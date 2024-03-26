---
title: RIME 输入法使用体验
date: 2024-03-20 17:46:30
tags: [双拼输入法, Rime, 鼠须管]
category: 工具效率
---

磨刀不误砍柴工，输入法是平时**使用频率极高**的工具类软件，因此值得花时间去让这个工具变得更加趁手，在 2022 年我学会了双拼输入法（如果你还在使用全拼，我强烈建议学一下双拼，可以参考我之前写的这篇博客：[也许你该试试双拼输入法 | Hank's Blog](https://zhaohongxuan.github.io/2023/06/30/how-i-learn-shuang-pin/)

<!-- more -->

我一直用的是 macOS 系统自带的双拼输入法，今年年初看到很多 X 友都强烈推荐 RIME输入法，我决定使用这个开源的输入法，使用至今已经3个多月了，这篇文章就来总结一下我的使用体验。
这篇文章只是我的体验，不会详细介绍 RIME 输入法的详细功能，更详细的配置可以查官方文档，希望能对你使用输入法产生一些启发。
![image.png](https://raw.githubusercontent.com/zhaohongxuan/picgo/master/WX20240320-185930@2x.png)

## 为什么是RIME？

- RIME是一个高度定制的输入法，意味着它非常的自由。
- 它是基于 yaml 配置的，没有GUI，因此需要你有一些程序基础和耐心才能配置。
- 强大的拓展系统，可以使用 lua 实现自定义功能。
- 体积小巧，无须联网，没有隐私问题。

基于上面这些对于一个程序员来说完全不是问题，而且是优势，因此我选择使用它来作为我的输入法再好不过了。
当然，如果你对输入法没有感受到痛点，我建议还是使用成品输入法，现在关闭这篇文章还来得及，至少现在来说，支持双拼的**微信输入法**已经足够好用了（除去隐私问题）。

## 基础配置

在Mac平台的一个比较受欢迎的实现是 Squirrel 输入法，中文又称鼠须管，别担心配置文件是在各个平台通用的，因此只需要维护一个自己的一套输入法配置就好了，所有平台都可以共享。

强烈建议不要从头开始写一份配置，目前网络上友有很多鼠须管配置文件，我使用的是[mint-rime](https://github.com/Mintimate/oh-my-rime)，也成为oh-my-rime，你也可以基于其他的配置文件来二次配置。

薄荷拼音的基本配置可以参考这里：[oh-my-rime Input Method | Mint Pinyin](https://www.mintimate.cc/)，讲的可以说是非常细致了。

### 安装配置

#### 下载安装 

直接下载配置文件zip包，解压之后放置在 `~/Library/Rime` 中，然后在菜单栏点击菜单栏【ㄓ】-【重新部署】即可完成基础配。如果是使用全拼输入法的话这里就可以正常使用了。

这种方式适合大部分用户，方便快捷，后续可以使用云盘来同步配置文件。

####  软链接安装

如果是Git用户，可以fork一份配置，然后git clone到本地的项目文件夹 ，进入仓库目录，将本地目录创建软链接到到 Rime 的配置目录：

```
ln -s "$(pwd)" ~/Library/Rime
```

⚠️ 使用这种方式的时候要注意，如果是public repo 的话`custom_phrase.txt` 中不要放置敏感的信息。

## 进阶配置

安装完成之后一般就能使用了，但是如果要实现一些自定义的功能，需要修改配置，修改配置的方法有两种：
- 直接修改原始配置：
- Patch 配置，
我建议使用第二种方式，Patch 在不影响原始配置文件的情况下来实现自定义的功能，支持覆盖配置和新增配置，后续在更新作者配置的时候更加方便，如果使用Github的话，只需要写一个Github action就可以定时同步配置了

下面来介绍一下我Patch的一些配置，你可以做一些参考。

### Patch 自己的输入方案 

默认情况下，RIME使用的一般都是拼音输入法，我们可以根据自己的需求修改自己的方案，在 `default.yaml` 可以配置自己需要的输入方案
我自己是双拼用户，所以，在schema list中只保留了小鹤双拼

我这里根据自己的需要，只保留了`小鹤双拼`的方案，设置方法很简单，新增一个 `default.custom.yaml` 中把其他的schema都删除掉，只保留double_pinyin_flypy，然后设置候选字一页为 9 个：

```yaml
patch:
  schema_list:
    - schema: double_pinyin_flypy    # 小鹤双拼
  menu:
    page_size: 9
```

你可以根据自己的需求保留相应的方案，使用的时候使用 `ctrl + ~` 切换方案。
### Patch 自定义皮肤

首先要理解如何自定义皮肤，下面是鼠须管输入法皮肤每个配置项，你可以自己根据自己的喜好来定制自己的专属皮肤。
![image.png](https://raw.githubusercontent.com/zhaohongxuan/picgo/master/20240122182514.png)
也可以使用 Squirrel 皮肤设计软件[GitHub - LEOYoon-Tsaw/Squirrel-Designer: Squirrel Theme Simulator](https://github.com/LEOYoon-Tsaw/Squirrel-Designer)来设计皮肤，目前我使用的皮肤就是这个皮肤设计软件自带的 flat 主题，我感觉非常漂亮。
![image.png](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20240317165220.png)
　

新增一个 `squirrel.custom.yaml` 配置文件用来覆盖默认的主题配置，分别patch 掉 style和preset_color_schemes字段。

```yaml
patch:
  style:
    # 选择皮肤，亮色与暗色主题
    color_scheme: flat_light
    color_scheme_dark: purity_of_form_custom
  preset_color_schemes:
    flat_light:
        name: "'flat_light'"
        font_face: "Helvetica"
        font_point: 15.0
        candidate_list_layout: linear
        text_orientation: horizontal
        inline_preedit: false
        translucency: true
        mutual_exclusive: true
        corner_radius: 15.0
        hilited_corner_radius: 13.0
        border_height: -5.0
        border_width: -5.0
        line_spacing: 4.0
        spacing: 10.0
        alpha: 60.0
        shadow_size: 1.0
        color_space: display_p3
        back_color: 0x1AFFFFFF
        candidate_text_color: 0xB3000000
        comment_text_color: 0x80333333
        label_color: 0xBB333333
        hilited_candidate_back_color: 0x7DC6C6C6
        hilited_candidate_text_color: 0x000000
        hilited_comment_text_color: 0xBF333333
        hilited_candidate_label_color: 0x000000
        preedit_back_color: 0x1A000000
        text_color: 0xBF323232
        hilited_text_color: 0xBF1A1A1A
```


然后重新部署就可以生效了。

### Patch 双拼 preedit_format

默认情况下，输入双拼音节，comment框中会自动转换为全拼，但是按回车之后上屏的依然还是双拼，我感觉还是不习惯，可以把这个配置改掉，我在Github上找到了解决的方案：[双拼模式下怎么能不让输入框的拼音自动展开成全拼？ · Issue #261 · rime/squirrel · GitHub](https://github.com/rime/squirrel/issues/261)

在 `double_pinyin_flypy.schema.yaml` 文件里，找到 translator配置项，把 preedit_format 设置为 `[]`，这样双拼就不会自动展开成全拼了。 

最终结果如下：
![image.png](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20240317180116.png)

### macOS更新托盘图标

[Release Squirrel System Tray Icon for MacOS Ventura/Sonoma  · lewangdev/rime-ice · GitHub](https://github.com/lewangdev/rime-ice/releases/tag/0.0.1-squirrel-system-tray-icon)
默认的托盘图标很窄，可以参考这个连接：修改为系统输入法一样的宽图标，强迫症狂喜。

![image.png](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20240317180314.png)
## 配置同步

如果在一个设备上修改了配置，如何在其他的设备上还能够正常同步？
### 同步至 iCloud

1、配置文件里打开 `installation.yaml`，将 `id` 改为自己设备的名称，比如家里的Macbook Pro之类的。  
2、复制下面路径代码粘贴进去，将 `admin` 替换为 Mac 管理员名称（代码里 `RimeSync` 是同步后文件夹名称，支持自定义）。

```
sync_dir: "/Users/admin/Library/Mobile Documents/com~apple~CloudDocs/RimeSync"
```
![image.png](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20240317171250.png)

更多同步的选项可以看文档：[多设备同步 | oh-my-rime输入法](https://www.mintimate.cc/zh/guide/deviceSync.html)

### Git 同步

上面的「软链接安装」章节已经提到了，如果使用Git管理的话，最好通过软链接的方式安装，就和正常管理一个项目一样简单。

## 手机端

iPhone上面可以使用【仓输入法】[GitHub - imfuxiao/Hamster: librime for iOS App](https://github.com/imfuxiao/Hamster)，配置文件和电脑端的位置文件一样，只需要把配置文件复制一份到iCloud的仓输入法文件夹就可以了，然后部署就可以了。

## 参考资料
- [GitHub - Mintimate/oh-my-rime: The Simple Config Template Of Rime By Mintimate. QQ Chat-Group: 703260572](https://github.com/Mintimate/oh-my-rime)
- [Rime 配置：雾凇拼音 - Dvel's Blog](https://dvel.me/posts/rime-ice/)
- [GitHub - ssnhd/rime: Rime Squirrel 鼠须管配置文件（朙月拼音、小鹤双拼、自然码双拼）](https://github.com/ssnhd/rime?tab=readme-ov-file)
- [GitHub - iDvel/rime-ice: Rime 配置：雾凇拼音 | 长期维护的简体词库](https://github.com/iDvel/rime-ice)
- [GitHub - imfuxiao/Hamster: librime for iOS App](https://github.com/imfuxiao/Hamster)
