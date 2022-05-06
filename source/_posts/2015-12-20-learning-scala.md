---
layout: post
title:  "函数式编程语言Scala的学习（Hello Scala）"
keywords: "scala"
date: 2015-12-20
category: scala
tags: scala
---

Scala吸收了收并继承了多种语言中的优秀特性，另一方面也没有抛弃Java这个强大的平台，它可以运行在 Java 虚拟机之上，能够轻松地与Java互联互通。与Java不同的是，
Scala既支持面向对象的特性，又支持函数式编程，被称为是Java的替代语言，是更好的Java，下面开始学习这一强大的语言。

## Scala和Java比较
在Scala中
1. 所有类型都是对象
2. 函数是对象
3. 支持Domain specific language (DSL)领域特定语言 
4. 特质(Trait)
5. 闭包(Closure)，嵌套函数
6. Erlang支持的并发设计
7. 类型推导

## 基础语法
### 表达式

	scala> 1 + 1
	res0: Int = 2

`res0`是解释器自动创建的变量名称，指代表达式计算的结果，是Int类型的，值为2。在scala几乎一切都是表达式。
### 变量和值

可以将表达式赋给一个或者不变量（val）--值或者变量（var）

	scala> val two = 1 + 1
	two: Int = 2

如果需要以后修改这个名称和结果的绑定，需要使用var（变量），大部分的情况下用val的情况居多。

	scala> var name = "zhaohongxuan"
	name: java.lang.String = zhaohongxuan

	scala> name = "zhaoxiaoxuan"
	name: java.lang.String = zhaoxiaoxuan
<!-- more -->

### 函数
使用`def`关键字来创建函数

	scala> def addOne(m: Int): Int = m + 1
	addOne: (m: Int)Int

调用函数：

	scala> val three = addOne(2)
	three: Int = 3

在scala中，需要为函数参数制定类型的签名。但是，如果函数不带参数，括号可以省略。

	scala> def three() = 1 + 2
	three: ()Int

	scala> three()
	res2: Int = 3

	scala> three
	res3: Int = 3
#### 匿名函数
创建匿名函数

	scala> (x: Int) => x + 1
	res2: (Int) => Int = <function1>

这个函数的作用是给名为x的变量加1.

	scala> res2(1)
	res3: Int = 2

也可以传递匿名函数

	
	scala> val addOne = (x: Int) => x + 1
	addOne: (Int) => Int = <function1>

	scala> addOne(1)
	res4: Int = 2

如果函数中表达式很多，可以用花括号{}来格式化代码、

	scala> { i: Int =>
		println("hello world")
		i * 2
	}
	res0: (Int) => Int = <function1>

#### 部分应用（Partial application）

可以使用下划线`_`部分应用一个函数，结果是得到另一个函数。

定义一个add函数

	scala> def add(m: Int, n: Int) = m + n
	add: (m: Int,n: Int)Int

将add函数部分应用得到一个新的匿名函数

	scala> val add2 = add(2, _:Int)
	add2: (Int) => Int = <function1>

	scala> add2(3)
	res50: Int = 5

#### 可变长度参数

这是一种特殊的语法，可以向方法传入任意多个同类型的参数。比如给传入的参数的首字母进行大写的操作。

	def capitalizeAll(args: String*) = {
	  args.map { arg =>
	    arg.capitalize
	  }
	}

	scala> capitalizeAll("zhaoxiaoxuan", "douxiaonna")
	res2: Seq[String] = ArrayBuffer(Zhaoxiaoxuan, Douxiaonna)


## 类、继承与特质

### 类

	scala> class Calculator {
	     |   val brand: String = "HP"
	     |   def add(m: Int, n: Int): Int = m + n
	     | }
	defined class Calculator

	scala> val calc = new Calculator
	calc: Calculator = Calculator@e75a11

	scala> calc.add(1, 2)
	res1: Int = 3

	scala> calc.brand
	res2: String = "HP"

这个计算器类展示了在类中使用`def`定义方法，和使用val定义字段。其中`方法`就是可以可以访问类状态的`函数`。
### 构造函数

构造函数不是特殊的方法，他们是除了类的方法定义之外的代码。

	class Calculator(brand: String) {
	  //构造函数
	  val color: String = if (brand == "TI") {
	    "blue"
	  } else if (brand == "HP") {
	    "black"
	  } else {
	    "white"
	  }
	  // An instance method.
	  def add(m: Int, n: Int): Int = m + n
	}

使用构造函数来构造一个实例：

	scala> val calc = new Calculator("HP")
	calc: Calculator = Calculator@1e64cc4d

	scala> calc.color
	res0: String = black

在上面的例子中，颜色的值就是绑定在一个if/else表达式上的。Scala是高度面向表达式的：大多数东西都是表达式而非指令。

### 继承

```scala

	class Point(xc: Int, yc: Int) {
	  val x: Int = xc
	  val y: Int = yc
	  def move(dx: Int, dy: Int): Point =
	    new Point(x + dx, y + dy)
	}
	class ColorPoint(u: Int, v: Int, c: String) extends Point(u, v) {
	  val color: String = c
	  def compareWith(pt: ColorPoint): Boolean =
	    (pt.x == x) && (pt.y == y) && (pt.color == color)
	  override def move(dx: Int, dy: Int): ColorPoint =
	    new ColorPoint(x + dy, y + dy, color)
	}
```

`ColorPoint`继承了`Point`中所有的成员，包括`x,y`包括`move`方法。

子类`ColorPoint`增加了一个新的方法`compareWith`。
Scala允许对成员定义进行覆盖（Override），在这个例子中，我们在子类中用move方法`覆盖`了的父类的`move`方法,当然在子类中可以使用`super`关键字来调用父类的`move`方法。
### 抽象类

定义一个抽象类，它定义了一些方法但没有实现它们。取而代之是由扩展抽象类的子类定义这些方法。抽象类不能创建实例。


	scala> abstract class Shape {
	     |   def getArea():Int    // subclass should define this
	     | }
	defined class Shape

	scala> class Circle(r: Int) extends Shape {
	     |   def getArea():Int = { r * r * 3 }
	     | }
	defined class Circle

	scala> val s = new Shape
	<console>:8: error: class Shape is abstract; cannot be instantiated
	       val s = new Shape
		       ^
	scala> val c = new Circle(2)
	c: Circle = Circle@65c0035b
### 特质

特质是一些字段和行为的集合，可以扩展或者混入（Mixin）你的类中。

	trait Car {
	  val brand: String
	}

	trait Shiny {
	  val shineRefraction: Int
	}
	class BMW extends Car {
	  val brand = "BMW"
	}

通过`with`关键字，一个类可以扩展多个特质：

	class BMW extends Car with Shiny {
	  val brand = "BMW"
	  val shineRefraction = 12
	}

