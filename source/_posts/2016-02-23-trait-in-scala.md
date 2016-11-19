---
layout: post
title: Scala中的特质
date: 2016-02-23
tags: scala
category: scala
---

特质的构造顺序

    1. 超类的构造器
    2. 特质由左至右构造
    3. 每个特质中，父特质先被构造
    4. 多个特质公用一个父特质，而那个特质已经被构造，则不会被再次构造
    5. 所有特质构造完毕，子类被构造


eg： 其中 `FileLogger`和`ShortLogger`都继承`Logger`特质

```scala
calss SavingsAccount extends Account with FileLogger with ShortLogger
```

构造顺序

    1.Account（超类）
    2.Logger（第一个特质的父特质）
    3.FileLogger（第一个特质）
    4.ShortLogger（第一个特质）
    5.SavingAccount（类）
    
<!-- more -->

JVM中的特质

由于scala在jvm中运行，所以scala需要将特质翻译为JVM的类与接口

只有抽象方法的特质被简单的翻译成一个Java接口

```scala
trait Logger{
   def log(msg: String)
}
```
被翻译为

```java
public interface Logger{
    void log(String )
}
```

如果特质中有具体的方法，Scala会创建出一个伴生类，伴生类用`静态方法`存放特质的方法。

```scala
trait ConsoleLogger extends Logger {
    def log(msg: String){
        println(msg)
    }
}
```

被翻译成

```java
public interface ConsoleLogger extends Logger{
    void log(Stirng msg)
}

```
以及一个和ConsoleLogger接口对应的伴生类

```java
public class ConsoleLogger$class{
    public static void log(ConsoleLogger self, String msg){
        println(msg)
    }
}
```


