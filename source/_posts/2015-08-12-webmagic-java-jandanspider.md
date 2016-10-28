---
layout: post
title:  "根据WebMagic写的一个爬取煎蛋网的小爬虫"
keywords: "webmagic"
description: "使用路径表达式选择xml或者html文档中的节点元素"
category: java
tags: java
---
之前研究jsoup，想用jsoup写一个小爬虫，爬煎蛋网的`无聊图`，我也是够无聊的 =.=,挖了个坑过了半个月还没填上，昨天上知乎的时候，
发现有更加好用的爬虫框架WebMagic（知乎，果然让人发现更大的世界），先用WebMagic实现一下我的小爬虫，好啦，填坑开始...

这里用到`webmagic`，就把webmagic介绍，使用方法都放出来，没用过的先熟悉一下。

这里是[WebMagic中文使用文档](https://github.com/code4craft/webmagic/tree/master/zh_docs)，一点即达 @.@

介绍文档已经很详细了，下面开始，生产爬虫
##一、分析煎蛋网无聊图html源码
下面是煎蛋网`无聊图`页面的html源码片段

```html
       <div id="content">
            <h1 class="title">无聊图</h1>
            <!-- begin comments -->
            <div id="comments">

                <div style="clear:both;"></div>

                <h3 class="title" id="comments">TOTAL COMMENTS: 177,359<span
                        class="plusone"><a href="#respond" title="来一发">+1</a></span></h3>

                <span class="break"></span>
                <div class="comments">
                    <div class="cp-pagenavi"><span class="current-comment-page">[7095]</span> <a href="http://jandan.net/pic/page-7094#comments">7094</a> <a href="http://jandan.net/pic/page-7093#comments">7093</a>  <a class="previous-comment-page" href="http://jandan.net/pic/page-7094#comments" title="Older Comments">&raquo;</a></div>
                </div>

                <ol class="commentlist" style="list-style-type: none;">
                    <li id="comment-2894921">
                        <div>
                            <div class="row">
                                <div class="author"><strong
                                        title="防伪码：8d6a6ef3b33b2280a7c0803dc5cb97977799cbd2">不发表评论</strong>                            <br>
                                  
                                </div>
                                <div class="text"><span class="righttext"><a href="http://jandan.net/pic/page-7095#comment-2894921">177358</a></span><p><img src="http://ww3.sinaimg.cn/mw600/a801236bjw1euyksy43o7j20f20qo40d.jpg" /></p>
                                   
                                </div>
                            </div>
                            <span class="break"></span></div>

                    </li>
		                           
            <li id="comment-2894895">
                <div>
                    <div class="row">
                        <div class="author"><strong
                                title="防伪码：10d69593001a14fc2189787eb1a0315113ff1714">delectate</strong>                            <br>
                            <small><a href="#footer" title="@回复"
                                      onclick="document.getElementById('comment').value += &#39;@&lt;a href=&quot;http://jandan.net/pic/page-7095#comment-2894895&quot;&gt;delectate&lt;/a&gt;: &#39;">@37 mins ago</a></span></small>
                        </div>
                        <div class="text"><span class="righttext"><a href="http://jandan.net/pic/page-7095#comment-2894895">177352</a></span><p>老规矩，坟请猛x，谢谢。<br />
<img src="http://ww2.sinaimg.cn/thumbnail/0066UPGbjw1euyrnitpbzg30b404gx6p.gif" org_src="http://ww2.sinaimg.cn/mw1024/0066UPGbjw1euyrnitpbzg30b404gx6p.gif" onload="add_img_loading_mask(this, load_sina_gif);"/></p>

</div>
                    </div>
                    <span class="break"></span></div>

            </li>
	    </ol>
	              <div class="comments">

                    <div class="cp-pagenavi"><span class="current-comment-page">[7095]</span> <a href="http://jandan.net/pic/page-7094#comments">7094</a> <a href="http://jandan.net/pic/page-7093#comments">7093</a>  <a class="previous-comment-page" href="http://jandan.net/pic/page-7094#comments" title="Older Comments">&raquo;</a></div>

                    <h3>
                        <p id="respond">发表评论</p>
                    </h3>
                </div>

            </div>
        </div>
        <!-- END wrapper --></body>
</html>

```

先理一下思路
####1.爬取无聊图首页图片
想要爬的图片路径在
div[id=content]->div[id='comments']->ol[class=commentlist]->li[id='xxxx']->div->div[class='row']->...->img[src]
img的`src链接`就是静态图片的`url`，如果是动态图`gif`的话，那么`org_src`才是图片的真正`url`，`src`只是对应缩略图的`url`
让爬虫选中列表项列表li，然后遍历每个li,然后取每个li的`图片url`和`title`,
####2.保存图片到本地
用httpclient根据`图片url`下载该图片保存在本地就行了
####3.爬取下一页图片
找到本页的下一页标签，从上面的源码片段可以看到是`class="previous-comment-page"`的a标签
当爬虫爬完首页时，接下来爬`上一页`，煎蛋网是倒序的...

##二、开始编写爬虫
###首先，新建一个解析图片的Processor类
新建一个`PicProcessor`类，继承自`PageProcessor`，并重写`process`方法

####第一步，先处理首页图片

```java
 //处理图片类
    private void processPicture(Page page) {
    //得到所有Gif的li标签

        List<String> gifLists = page.getHtml().xpath("//ol[@class='commentlist']/li[@id]").all();
        for (String gif:gifLists){
            //得到标题
            String title=xpath("//div[@class='author']/strong").selectElement(gif).attr("title");
            logger.info("title:"+title);
            //得到上传者
            String author=xpath("//div[@class='author']/strong").selectElement(gif).text();
            //将标题中的防伪码转换为：上传者名称
            title=title.replace("防伪码",author);
            //图片url
            //如果有org_src属性，则是gif图片
            String url=xpath("//div[@class='text']/p/img").selectElement(gif).attr("src");
            String gifUrl=xpath("//div[@class='text']/p/img").selectElement(gif).attr("org_src");
            if(StringUtils.isNotEmpty(gifUrl)){
                logger.info("Gif图片...替换新链接...");
                url=gifUrl;//如果是gif则用大图链接替换缩略图链接
            }
            logger.info("图片url:" + url);
            //保存图片到本地
            String filePath=downloadDir+ File.separator+author;
            String picType=url.substring(url.length()-3);
            try {
                FileUtil.downloadFile(url,filePath,title, picType);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
```
保存图片的工具类代码：

```java
package com.zeusjava.jandan.util;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.log4j.Logger;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;

/**
 * Created by LittleXuan on 2015/8/11.
 * 文件操作工具类
 */
public class FileUtil {
    private static Logger logger = Logger.getLogger(FileUtil.class);
    /**
     * 下载文件
     *
     * @param url
     *            文件http地址
     * @param filePath
     *            目标文件路径
     * @param fileName
     *            目标文件
     * @param picType
     *            文件类型
     * @throws java.io.IOException
     */
    public static synchronized void downloadFile(String url,String filePath, String fileName,String picType)
            throws Exception {
        logger.info("----------------------下载文件开始---------------------");
        CloseableHttpClient httpclient = HttpClients.createDefault();
        if (url == null || "".equals(url)) {
            return;
        }
        //目标目录
        File desPathFile = new File(filePath);
        if (!desPathFile.exists()) {
            desPathFile.mkdirs();
        }
        //得到文件绝对路径
        String fullPath =filePath +File.separator+fileName+"."+picType;
        logger.info("文件路径："+filePath);
        logger.info("文件名："+fileName);
        logger.info("源文件url："+url);
        //从元网址下载图片
        HttpGet httpget = new HttpGet(url);
        HttpResponse response = httpclient.execute(httpget);
        HttpEntity entity = response.getEntity();
        InputStream in = entity.getContent();
        //设置下载地址
        File file = new File(fullPath);

        try {
            FileOutputStream fout = new FileOutputStream(file);
            int l = -1;
            byte[] tmp = new byte[1024];
            while ((l = in.read(tmp)) != -1) {
                fout.write(tmp,0,l);
            }
            fout.flush();
            fout.close();
        } finally {

            in.close();
        }
        logger.info("----------------------下载文件结束---------------------");
    }
}

```

####第二步，爬取下一页

```java
 @Override
    public void process(Page page) {
        System.out.println("================================");
        //定义抽取信息，并保存信息
        processPicture(page);
        //得到下一页链接
        String comments=page.getHtml().xpath("//a[@class='previous-comment-page']").toString();
        logger.info("comments:"+comments);
        String link = xpath("a/@href").select(comments);
        logger.info("link:" + link);
        Request request = new Request(link);
        page.addTargetRequest(request);
        System.out.println("================================");

    }
```


####第三步，网站信息配置

```java
//得到网站配置
    private Site site = Site.me().setDomain("jandan.net").addHeader("Accept",
            "application/x-ms-application, image/jpeg, application/xaml+xml, image/gif, image/pjpeg, application/x-ms-xbap, */*")
            .addHeader("Referer", "http://jandan.net/pic").setSleepTime(10000).setUserAgent("zhaohongxuan")
            .addStartUrl("http://jandan.net/pic");
```
这里注意的是，要设置`UserAgent`，之前没加代理，刚开始启动程序可以爬，后来，煎蛋网就给屏蔽了，HttpClient返回`HTTP/1.1 302 Moved Temporarily`，煎蛋网把请求给重定向了
设置`SleepTime`可以设置每次爬取之间的时间间隔，我写的是`10000ms`，即程序爬完一页之后休息`10s`继续爬下一页。

####第三步，编写程序入口

```java
public class JanDanSpiderTest {
    private static Logger logger = Logger.getLogger(JanDanSpiderTest.class);

    public static void main(String[] args) {
        PropertyConfigurator.configure(ClassLoader.getSystemResourceAsStream("log4j.properties"));
        Spider.create(new PicProcessor()).scheduler(new PriorityScheduler()).run();
    }
}

```
由于`WebMagic`采用的是链式编程，可以很方便的进行配置，上面我默认用的是`PriorityScheduler`，当然也可以使用多线程，使用`thread()`括号里写上Thread的数量就行了


```java
	Spider.create(new PicProcessor()).scheduler(new PriorityScheduler()).thread(10).run();
```
本程序源代码请戳[JanDanSpider](https://github.com/javaor/JanDanSpider/)...
