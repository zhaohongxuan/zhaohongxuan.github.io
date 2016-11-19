---
layout: post
title: 使用Btrace来跟踪调试代码
tags: [java,jvm]
date: 2016-09-10
category: java
---

有的时候在写程序的时候可能有些地方的日志没有照顾到，产生了bug，如果到了线上环境，有时候不得不停掉服务重新来加入日志来查看产生bug的地方，这个时候Btrace就派的上用场了，在VisualVM中可以很方便的调试目标程序，而对原有项目没有影响，当然也可以不用VisualVM而使用命令行来实现这个功能。
Btrace是一个开源项目，项目托管在github上


使用VisualVM的Btrace插件最为方便，下面就写个小例子来熟悉一下


### 准备工作
1.在[visualvm官网](https://visualvm.java.net/download.html )下载visualVM可视化工具
2.依次点击visualVM菜单栏的`Tool->plugins`打开插件窗口，选择  `Btrace workBench` 然后一路 next安装


### 目标程序
  准备了一个简单的小程序：从键盘接收两个数字然后计算两个数字之和，主要目的是方便下一步用Btrace来调试打印出方法的参数的值，以及堆栈信息

  ```java
package org.xuan.trace;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

/**
 * Created by Xuan on 2016/9/10.
 */
public class BTraceTest {
    public int add(int a ,int b){
        return a+b;
    }
    public static void main(String[] args) throws IOException {
        BTraceTest traceTest= new BTraceTest();
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        for (int i = 0; i < 10; i++) {
            reader.readLine();
            int a  = (int)Math.round(Math.random()*1000);
            int b  = (int)Math.round(Math.random()*1000);
            System.out.println(traceTest.add(a,b));

        }
    }
}

```
<!-- more -->
### 跟踪程序
运行第二步中的小程序，在VisualVM中选中这个虚拟机进程，然后右键`Trace application`进入到Btrace选项卡
在文本框中输入调试的代码：

```java
/* BTrace Script Template */
import com.sun.btrace.annotations.*;
import static com.sun.btrace.BTraceUtils.*;

@BTrace
public class TracingScript {
	  @OnMethod(clazz="org.xuan.trace.BTraceTest",method="add",location=@Location(Kind.RETURN))
    public static void func(@Self org.xuan.trace.BTraceTest instance,int a,int b,@Return int result){
        println("打印堆栈:");
        jstack();
        println(strcat("方法参数A：",str(a)));
        println(strcat("方法参数B：",str(b)));   
        println(strcat("方法返回C：",str(result)));
    }
}
```

点击`run`按钮，如果调试代码没错的话,控制台会输出编译通过的信息

```shell
* Starting BTrace task
** Compiling the BTrace script ...
*** Compiled
** Instrumenting 1 classes ...
*** Done
** BTrace up&running
```

然后在程序的控制台输入一个字符，程序会给出两个参数以及方法的返回值

```shell
打印堆栈:
org.xuan.trace.BTraceTest.add(BTraceTest.java:12)
org.xuan.trace.BTraceTest.main(Unknown Source)
方法参数A：628
方法参数B：461
方法参数C：1089
```
