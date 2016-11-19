---
layout: post
title:  "JDK动态代理和cglib动态代理"
keywords: "动态代理"
date: 2015-10-13
category: java
tags: cglib
---

一晃眼，国庆节已经过去了，时间到了10月中旬了，总是感觉时间不够用，想多看点书，多写点代码，在点滴中积淀属于自己的知识系统。

闲言少叙，先来说一下什么是代理模式，我们去一个新的地方总是要先找地方住，但是我们人生地不熟的掌握的资源不多，这时候一般会找中介，中介对房源很熟悉，很快就能为你找到合适的房子，这时候，`中介`就是一个`代理`,你就相当于是一个`委托`方。

下面是设计模式中的代理：

## 代理模式
代理模式是常用的java设计模式，他的特征是`代理类`与`委托类`有同样的接口，代理类主要负责为委托类预处理消息、过滤消息、把消息`转发`给委托类，以及事后处理消息等。代理类与委托类之间通常会存在关联关系，一个代理类的对象与一个委托类的对象关联，代理类的对象本身并不真正实现服务，而是通过调用`委托类`的对象的相关方法，来提供特定的服务。 

按照代理的创建时期，代理类可以分为两种：
### 静态代理
	由程序员创建或特定工具自动生成源代码，再对其编译。在程序运行前，代理类的.class文件就已经存在了。 

### 动态代理
	在程序运行时，运用反射机制动态创建而成。 动态代理类的字节码在程序运行时由Java反射机制动态生成，无需程序员手工编写它的源代码。动态代理类不仅简化了编程工作，而且提高了软件系统的可扩展性，因为Java 反射机制可以生成任意类型的动态代理类。java.lang.reflect 包中的Proxy类和InvocationHandler 接口提供了生成动态代理类的能力。 

动态代理有很多种，先看第一种，JDK动态代理
<!-- more -->

## JDK动态代理
先来看下JDK源码中InvocationHandler中invoke()方法

```java
public Object invoke(Object proxy, Method method, Object[] args)
    throws Throwable;
```

JDK源码中Proxy类的代码：

```java
public static Object newProxyInstance(ClassLoader loader,
                                      Class<?>[] interfaces,
                                      InvocationHandler h)
    throws IllegalArgumentException
{
    if (h == null) {
        throw new NullPointerException();
    }

    /*     
     * Look up or generate the designated proxy class.
     */
    Class<?> cl = getProxyClass(loader, interfaces);

    /*
     * Invoke its constructor with the designated invocation handler.
     */
    try {
        Constructor cons = cl.getConstructor(constructorParams);
        return cons.newInstance(new Object[] { h });
    } catch (NoSuchMethodException e) {
        throw new InternalError(e.toString());
    } catch (IllegalAccessException e) {
        throw new InternalError(e.toString());
    } catch (InstantiationException e) {
        throw new InternalError(e.toString());
    } catch (InvocationTargetException e) {
        throw new InternalError(e.toString());
    }
}
```

#### 参数说明：

	ClassLoader loader：类加载器 
	Class<?>[] interfaces：得到全部的接口 
	InvocationHandler h：得到InvocationHandler接口的子类实例 

#### PS:类加载器

在Proxy类中的newProxyInstance（）方法中需要一个ClassLoader类的实例，ClassLoader实际上对应的是类加载器，
在Java中主要有一下三种类加载器:

	Booststrap ClassLoader：此加载器采用C++编写，一般开发中是看不到的； 
	Extendsion ClassLoader：用来进行扩展类的加载，一般对应的是jre\lib\ext目录中的类; 
	AppClassLoader：(默认)加载classpath指定的类，是最常使用的是一种加载器。

##  JDK动态代理实现步骤
### 实现InvocationHandler接口
### 获得代理对象

```java
public Object getInstance(Object target){
    return Proxy.newProxyInstance(target.getClass().getClassLoader(), target.getClass().getInterfaces(), this);
}
```


### 回调函数

```java
@Override
public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
    Object result = null;
    System.out.println("jdk 动态代理 begin...");
    result = method.invoke(target,args);
    System.out.println("jdk 动态代理 end...");
    return result;
}
```

JDK动态代理缺点：

	只能对实现了接口的类进行，没有实现接口的类不能使用JDK动态代理。

## cglib动态代理

JDK的动态代理机制只能代理实现了接口的类，而不能实现接口的类就不能实现JDK的动态代理，cglib是针对类来实现代理的，他的原理是对指定的`目标类`生成一个`子类`，并覆盖其中方法实现增强，但因为采用的是继承，所以不能对`final修饰`的类进行代理。
cglib实现动态代理的方法和JDK动态代理类似
### 实现MethodInterceptor接口
### 获得代理对象

```java
public Object getInstance(Object target){
    this.target = target;
    Enhancer enhancer = new Enhancer();
    enhancer.setSuperclass(this.target.getClass());
    //设置回调方法
    enhancer.setCallback(this);
    //创建代理对象
    return enhancer.create();
}
```

### 设置回调方法

```java
@Override
public Object intercept(Object o, Method method, Object[] objects, MethodProxy methodProxy) throws Throwable {
    System.out.println("UserFacadeProxy.intercept begin");
    methodProxy.invokeSuper(o,objects);
    System.out.println("UserFacadeProxy.intercept end");
   return null;
}
```

## Spring AOP原理

java动态代理是利用反射机制生成一个实现代理接口的匿名类，在调用具体方法前调用InvokeHandler来处理。而cglib动态代理是利用asm开源包，对代理对象类的class文件加载进来，通过修改其字节码生成子类来处理。
SpringAOP动态代理策略是：

	1、如果目标对象实现了接口，默认情况下会采用JDK的动态代理实现AOP 
	2、如果目标对象实现了接口，可以强制使用CGLIB实现AOP 
	3、如果目标对象没有实现了接口，必须采用CGLIB库，spring会自动在JDK动态代理和CGLIB之间转换




