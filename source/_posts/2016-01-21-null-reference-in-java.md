---
layout: post
title:  "Java中的null引用"
keywords: "java"
date: 2016-01-21
category: java
tags: java
---

空指针也许是java中最常见的异常，到处都埋藏着NullpointerException，最近就遇到一个NullPointException，如下：

```java
  int lastMonthTotalScore = integralOperationReadMapper.getSumByIntegralIdAndDate(integralId, lastMonthDate);
```

一个很常见的情况，mybatis查询的一个列的和，此时Debug时 integralId、lastMonthDate 都不为空，自动注入的 `integralOperationReadMapper`也不为空
但是Console却实实在在的打出了这一行有一个NullPointerException，此时没有注意到Wrapper类自动转换`基本数据类型`的情形。

`getSumByIntegralIdAndDate` 方法返回的是`NULL`，自动拆箱的时候的要将一个NULL转换为基本数据类型就出错了...o(╯□╰)o

现在总结几个NULL的经验。

1.不用null来返回方法的返回值
  不要用null来舒适化变量，方法不要返回null、这样会造成null的传播，在每一个调用的地方都需要检查null
  例如：

  ```java
  public String doSomething(int id){
    String name = findName(id);
    ...
    return name;
  }
  ```

  这样如果findName如果返回为null，那么null就由findname游走到了doSomething。比如在findname中，如果没有找到对应的Id的姓名，就应该表明是`没找到`，而不是`出错了`。
  善于运用Java的异常。

  ```java
  public String findName() throws NotFoundException {
   if (...) {
      return ...;
    } else {
     throw new NotFoundException();
     }
   }
  ```
<!-- more -->



2.不把null放进容器内
  容器（collection），是指一些对象以某种方式集合在一起，所以null不应该被放进Array，List，Set等结构，不应该出现在Map的key或者value里面。把null放进容器里面，是一些莫名其妙错误的来源。因为对象在容器里的位置一般是动态决定的，所以一旦null从某个入口跑进去了，你就很难再搞明白它去了哪里，你就得被迫在所有从这个容器里取值的位置检查null。你也很难知道到底是谁把它放进去的，代码多了就导致调试极其困难。
解决方案是：如果你真要表示“没有”，那你就干脆不要把它放进去（Array，List，Set没有元素，Map根本没那个entry），或者你可以指定一个特殊的，真正合法的对象，用来表示“没有”。
需要指出的是，类对象并不属于容器。所以null在必要的时候，可以作为对象成员的值，表示它不存在。

3.尽早对方法进行参数检查null
 应该尽早的对null进行检查，不试图对null进行容错，采用强硬的手段,如果为空则抛出异常，可以使用java.util包里Objects.requireNonNull()方法来给方法的作者回应，告诉方法作者不应该把null传进来。
 Objects.requireNonNull()方法如下：

 ```java
 public static <T> T requireNonNull(T obj) {
   if (obj == null) {
     throw new NullPointerException();
   } else {
     return obj;
   }
 }
 ```

4.使用Java8的Optional或者guava的Optional

Optional类型的设计原理，就是把`检查`和`访问`这两个操作合二为一，成为一个`原子操作`。
