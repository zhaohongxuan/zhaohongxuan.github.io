---
title: 使用Yt-dlp高效下载Youtube的视频
date: 2022-03-14 23:45:29
tags: 命令行
category: 工具
---

![](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20220314235517.png)


## 代理

如果没有全局梯子的话，在命令行里就需要使用代理来下载。使用`--proxy`来指定代理，支持`HTTP/HTTPS/SOCKS` 等协议。

<!--more-->

## 下载

默认下载的视频格式是webm格式，如果需要转换可以使用`--merge-output-format mp4` 来转换，mp4可以指定为其他格式，比如mkv等，下载的文件名格式是 `%(title)s [%(id)s].%(ext)s` ，通过`--output`可以指定输出的文件名格式。

文件名的Template语法参考：https://github.com/yt-dlp/yt-dlp/blob/master/README.md#output-template 

### 下载1080P视频+音频并合并

```

yt-dlp -f 'bv[height=1080][ext=mp4]+ba[ext=m4a]' https://www.youtube.com/watch?v=WHSoSAqOyPY 

```


### 下载4K视频+音频合并

```bash
yt-dlp -f 'bv[height=2160][ext=mp4]+ba[ext=m4a]' --embed-metadata    https://www.youtube.com/watch?v=WHSoSAqOyPY 
```


### 下载列表

默认输入视频URL带上list的话会自动下载list的

设置`--playlist-start 1` 来指定开 始的index，设置 `--playlist-end` 指定结束的index，`--playlist-items 1,2,5-8` 指定某一些item进行下载

```

yt-dlp -f 'bv+ba' --embed-metadata --merge-output-format mp4 --playlist-items 1,2,6-10 -o '%(playlist_index)s-%(playlist)s-%(title)s.mp4' https://www.youtube.com/watch\?v\=rY-7DtUFiEI\&list\=PLJVKAfvqjvcofezOxMQaSHnO6HV84isXO

```



## 字幕操作


```bash

--write-subs 把字幕写到磁盘上
--sub-langs zh-Hans,en  多个语言使用逗号隔开，all下载全部语言
--write-auto-subs 把自动生成的字幕写到磁盘上
--embed-subs 把字幕嵌入视频文件中

```

通过`--write-subs` 把字幕写到磁盘上，`--sub-langs zh-Hans,en`  多个语言使用逗号隔开，all下载全部语言，`--write-auto-subs` 把自动生成的字幕写到磁盘上，`--embed-subs` 把字幕嵌入视频文件中
下载视频带中英文字幕文件：

```shell

yt-dlp https://www.youtube.com/watch?v=XiGk6PXt38w&t=18s --sub-langs zh-Hans,en --write-subs --write-auto-subs --embed-thumbnail --write-thumbnail --write-link

```

## 综合操作

下载最佳分辨率视频+音频+下载中英文字幕文件+转换为mp4+视频链接+缩略图

```bash
yt-dlp \
--format 'bv+ba' \ 
--write-auto-subs \
--sub-langs zh-Hans,en \
--write-link \
--write-thumbnail \
--embed-metadata \
--merge-output-format mp4 \
--output '%(playlist_index)s-%(playlist)s-%(title)s.mp4' \
https://www.youtube.com/watch\?v\=rY-7DtUFiEI\&list\=PLJVKAfvqjvcofezOxMQaSHnO6HV84isXO
```

## References
1.  https://github.com/yt-dlp/yt-dlp
