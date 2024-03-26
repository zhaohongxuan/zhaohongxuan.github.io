---
title: 将Apple Watch跑步数据同步到Garmin
date: 2023-07-08 07:50
tags: 跑步
category: 工具效率
---

起因是这样的，上马有个积分的功能，他可以影响正常的抽签（虽然是黑盒，但是有人反馈关系很大）的权重，而积分只能通过，签到，线下比赛，以及跑步获取，前两种好理解，第三种，跑步记录换取积分，需要上马官方合作伙伴数字心动APP来提供数据，然而，数字心动APP只能通过Garmin设备通过，并不支持Apple Watch直接上传（如果支持了，那么也没有这个项目了），于是我想是否能够曲线救国，将记录上传到Garmin，然后再通过Garmin同步到数字心动，这样就可以正常获取积分了。

<!-- more-->

![Twitter](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/202311152208371.png)

首先我需要做的是验证可行性，于是我研究了一下Garmin开发者平台[^1]，发现Fit文件中包含了设备信息的，Garmin设备应该都是上传的Fit文件，所以，理论上可以通过将GPX转换为Fit文件，同时将设备信息写入Fit文件就可以伪装成Garmin设备上传的记录。


然后我花了一下午做了一个简单的POC，把我导出的GPX文件转换为Fit（当然也可以直接用Fit文件，Apple Watch导出的也是Fit文件）文件，然后通过Garmin Fit的SDK工具将文件decode成csv，然后把设备信息加上重新打包成fit上传Garmin Connect，跑步记录中就有设备信息了，经测试，这个伪造的运动记录可以正常从Garmin同步到数字心动了，于是上马APP上也就有了跑步的里程信息。
![Twitter](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/202311152210877.png)

于是接下来就是将这个过程自动化了，刚好发现一直在用的跑步主页项目[Running page](https://github.com/yihong0618/running_page)中的Strava脚本有backup到Garmin的功能，因此我就想，能否通过这个修改脚本加入默认的Garmin设备，这样就可以将健身记录通过Garmin间接的同步到其他APP中，不仅仅是数字心动,实现的效果如下图：
[Strava_to_garmin](https://user-images.githubusercontent.com/8613196/250013264-ba668c5f-2dab-4405-b2d6-f0e49b4c99d4.png)

于是就开干了，改动不是很大，主要就是将原来的Fit文件decode，然后加入Fake的Garmin信息，然后重新打包成新的Fit文件， 最终的PR在这里：https://github.com/yihong0618/running_page/pull/435

![](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/202311152217854.png)


[^1]:https://developer.garmin.com/fit/file-types