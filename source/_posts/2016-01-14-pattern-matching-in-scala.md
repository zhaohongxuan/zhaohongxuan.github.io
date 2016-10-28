---
layout: post
title:  "Scala中的模式匹配"
keywords: "scala"
description: "Scala最重要的模式匹配的学习"
category: scala
tags: scala
---

##模式匹配

scala有一套内建的模式匹配机制，这种机制允许在任何类型的数据上与第一个匹配策略匹配。模式匹配可以应用在很多场合，switch语句，类型检查以及提取对象中的
的复杂表达式。

下面是一个小例子，说明如何与一个整型值匹配：

```scala
object MatchTest1 extends App {
  def matchTest(x: Int): String = x match {
    case 1 => "one"
    case 2 => "two"
    case _ => "many"
  }
  println(matchTest(3))
}
```
这段带有`case`的代码块定义了一个从证书向字符串映射的函数
关键字`match`提供了一个便捷的方法来把一个函数`apply`给一个对象，比如上面的模式匹配函数`matchTest`。
下面是第二个例子匹配不同类型

```scala
object MatchTest2 extends App {
  def matchTest(x: Any): Any = x match {
    case 1 => "one"
    case "two" => 2
    case y: Int => "scala.Int"
  }
  println(matchTest("two"))
}
```

第一个case匹配如果 x是integer类型的且值为1的情况
第二个case匹配如果 x是string类型的且值为two的情况
Scala的模式匹配语句在通过y样例类来匹配代数类型是最有用的。
Scala也允许定义独立自主的对类的匹配，在提取对象使用了预定义的`unapply`方法。