---
title: Scala中 implicit 用法
categories: [源码解析]
tags: [scala,spark]
date: 2024-05-31 07:17:54
---

## Background
最近一段时间接手了几个Spark相关的大数据项目，主要使用Scala来编写代码，做了几个需求，感觉Scala这门语言还挺有意思，Scala以前也学习过，但是是很早了，很多语法点都忘了，在工作中经常编写的代码是Spark Job，使用stream的方式来编写代码，感觉非常的舒服。Spark中经常使用的一个操作是使用`$`来选择Column，比如下面使用`$`选择`dt`这一列，

<!-- more-->


```scala
val omnitracking_ios = spark.read.parquet(file_path).filter($"dt" >= one_month_ago_fmt)
```
起初我并没有在意，起初我还以为`$`的用法是字符串插值，但是后来发现不是的，这一下子激发了我的好奇心，于是花时间研究了一下，Spark 中的`$`是 `import spark.implicits._` 导入的：

SQLImplicits中的 StringToColumn类
```scala
implicit class StringToColumn(val sc: StringContext) {  
  def $(args: Any*): ColumnName = {  
    new ColumnName(sc.s(args: _*))  
}}
```

分析一下源码，虽然源码只有三行，但是知识点还是比较密集的：

首先，第一行，StringToColumn是一个隐式类，定义了一个隐式类`StringToColumn`，它接受一个`StringContext`类型的参数`sc`。`StringContext`是Scala中的一个类，用于处理字符串插值(interpolator)（例如，`s"hello $name"`）。

第二行在隐式类中定义了一个`$`方法， `$(args: Any*): ColumnName`，该方法返回一个`ColumnName`对象。

第三行：`new ColumnName(sc.s(args: _*))`：使用生成的字符串创建一个新的`ColumnName`对象。关键点在`sc.s(args: _*)`方法 ，使用`StringContext`类中的`s`方法将`args`参数插入到`StringContext`中的字符串模板中。`args: _*`表示将参数序列展开成单独的参数。

我们知道Scala中的字符串插值使用方法是：

```scala

val path = s"${base_path}/dt=${last_date_fmt}"
```

这里，我们就可以以字符串插值的方式来使用`$`了

比如从Dataframe中选择一个Column
```scala
val columnName = $"columnName"
```

这里隐式类的作用是在特定的作用域中自动将某种类型转换为隐式类的实例，从而可以调用隐式类中的方法。在这个例子中，当你在字符串上下文中使用`$`插值时，Scala会自动将`StringContext`转换为`StringToColumn`，从而可以调用`$`方法。

通过隐式类和字符串插值机制，Spark SQL允许用户方便地将字符串转换为`ColumnName`对象，从而进一步转换为`Column`对象。这使得代码在处理列名时更加直观和简洁。具体代码如下

## Scala中 implicit 用法

Scala中的`implicit`关键字用于定义隐式转换和隐式参数，可以简化代码和提高可读性。
### 隐式转换

隐式转换用于在需要某种类型但实际提供的类型不匹配时，自动将一种类型转换为另一种类型。可以通过定义隐式函数或隐式类来实现。
#### 隐式函数示例：

自动调用 intToString，将 Int 转换为 String

```scala
implicit def intToString(x: Int): String = x.toString

val s: String = 42  
```

在这个例子中，`intToString`函数将`Int`类型转换为`String`类型。因为`implicit`关键字的存在，当需要`String`类型但提供的是`Int`类型时，编译器会自动应用这个隐式函数。

#### 隐式类示例：

```scala
implicit class RichInt(val x: Int) {
  def square: Int = x * x
}

val num = 4
println(num.square)  // 输出 16
```

在这个例子中，`RichInt`是一个隐式类，它为`Int`类型增加了`square`方法。这样，我们可以直接调用`num.square`，即使`Int`类型本身没有`square`方法。

### 隐式参数

隐式参数是一种可以自动传递给函数或方法的参数。如果一个方法的最后一个参数列表被标记为`implicit`，那么在调用这个方法时，如果没有提供这些参数，Scala编译器会在作用域内寻找合适的隐式值来填充。

#### 示例：

```scala
case class User(name: String)

def greet(implicit user: User): String = s"Hello, ${user.name}!"

implicit val defaultUser: User = User("John Doe")

println(greet)  // 输出 "Hello, John Doe!"
```

在这个例子中，`greet`方法需要一个`User`类型的隐式参数。因为在作用域内定义了一个隐式值`defaultUser`，所以调用`greet`时不需要显式地传递参数。

### 使用场景

1. **增强现有类型**：通过隐式类，可以为现有类型添加新的方法，而不需要修改类型本身。
2. **类型转换**：隐式函数可以在需要某种类型但提供的类型不匹配时，自动进行类型转换。
3. **依赖注入**：隐式参数可以用于依赖注入，使得代码更加简洁和易于测试。
4. **类型类模式**：在Scala中，类型类通过隐式参数和隐式转换实现，提供了一种灵活的多态性。

## Reference
- [Implicits](https://wwwscala-lang.org/files/archive/spec/2.11/07-implicits.html)
- [syntax - Understanding implicit in Scala - Stack Overflow](https://stackoverflow.com/questions/10375633/understanding-implicit-in-scala)

