---
layout: post
title: Java中final关键字总结
tags: [java]
date: 2017-04-17
category: java
---

final在java中的用法有很多，可以修饰field，可以修饰Method，可以修饰Class，而且final在多线程环境中保证了对象状态的不变性，下面就系统的总结一下Java中final关键字的用法

### 修饰Variable/field

1. 修饰primitive变量，变量一旦赋值就不再可变。
2. final修饰`基本数据类型变量`和`String类型`时，类似于C++的const
3. 3种变量会被隐式的定义为final：
   3.1. 接口中的field是final的
   3.2. Java7中出现的try with resource语句中的变量是隐式的final类型,如下面的代码，inputStream虽然未被声明为final，但是如果试图在try块里面重新对inputStream赋值的话，就会产生编译异常，不能给final变量赋值
    ```java
      try (FileInputStream inputStream = new FileInputStream("text.txt")){
      inputStream = new FileInputStream("");
      } catch (Exception e) {
         e.printStackTrace();
      }
    ```

4. 修饰引用实例类型变量，变量被赋值后，变量指向的引用的值可以变，但是不能重新指向新的引用，即final只关心引用本身，而不关心final引用的内容。
    ```java
    public static void main(String[] args) {
       final User user = new User("xuan1",23);
       System.out.println(user.getAge()); //输出23
       user.setAge(24);
       System.out.println(user.getAge()); //输出24
       user = new User("xuan2",25); //编译错误，提示不能赋值给final变量
       System.out.println(user.getAge());
    }
    ```
5. 修饰实例成员变量时，必须在定义的时候初始化：直接赋值，构造器初始化，或代码块中初始化，或的意思是这三种方式只能选择一种，否则编译报错。
6. 修饰静态成员变量时，必须在变量定义的时候初始化：直接赋值，静态代码块中赋值
    Tips: 有一种特殊情况：`System.in,System.out,System.err` 是静态域但是没有在定义的时候或者静态代码块中初始化，而是使用了set方法来设置值。
7. JDK8以前内部类访问外部类的变量时要求变量为Final类型,JDK8之后，只要求外部类为事实不可变变量，不一定要加上final
<!-- more -->

  关于事实不可变final的定义：
  > variable or parameter whose value is never changed after it is initialized is effectively final
  也就是说变量被初始化之后没有改变过即使没有final，jvm也会把这个变量解释为final类型来对待。

  下面是官方文档的一个例子：
  在内部类PhoneNumber中的构造器中使用外部的numberLength的时候，JDK8之前必须显示定义为final类型，否则编译器将会给出警告，而在JDK8之后并不需要显式声明为final，但是，如果变量在初始化之后被再次赋值的话，就会出现异常了，因为打破了事实不可变的条件，所以在构造器中再次给numberLength赋值为7的时候，JDK8的编译器也给出了错误提示。
  同理，在printOriginalNumbers方法中方为外部类的变量`phoneNumber1`，`phoneNumber2`的时候JDK8以前的编译器给出错误提示。

    ```java
    package io.github.javaor;
    /**
     * Created by zhaohongxuan
     */
    public class LocalClassExample {
    	static String regularExpression = "[^0-9]";

    	public static void validatePhoneNumber(String phoneNumber1, String phoneNumber2) {
    		int numberLength = 10;
    		// Valid in JDK 8 and later:
    		// int numberLength = 10;
    		class PhoneNumber {
    			String formattedPhoneNumber = null;
    			PhoneNumber(String phoneNumber) {
    //				 numberLength = 7;
    				String currentNumber = phoneNumber.replaceAll(regularExpression, "");
    				if (currentNumber.length() == numberLength)
    					formattedPhoneNumber = currentNumber;
    				else
    					formattedPhoneNumber = null;
    			}

    			public String getNumber() {
    				return formattedPhoneNumber;
    			}
    			// Valid in JDK 8 and later:
    			public void printOriginalNumbers() {
    				System.out.println("Original numbers are "+phoneNumber1+" and "+phoneNumber2);
    			}
    		}

    		PhoneNumber myNumber1 = new PhoneNumber(phoneNumber1);
    		PhoneNumber myNumber2 = new PhoneNumber(phoneNumber2);

    		// Valid in JDK 8 and later:
    //        myNumber1.printOriginalNumbers();

    		if (myNumber1.getNumber() == null)
    			System.out.println("First number is invalid");
    		else
    			System.out.println("First number is " + myNumber1.getNumber());
    		if (myNumber2.getNumber() == null)
    			System.out.println("Second number is invalid");
    		else
    			System.out.println("Second number is " + myNumber2.getNumber());

    	}

    	public static void main(String... args) {
    		validatePhoneNumber("123-456-7890", "456-7890");
    	}
    }
    ```





### 修饰Method

Java语言规范中的描述如下：

>A method can be declared final to prevent subclasses from overriding or hiding it.
It is a compile-time error to attempt to override or hide a final method.
A private method and all methods declared immediately within a final class (§8.1.1.2) behave as if they are final, since it is impossible to override them.
At run time, a machine-code generator or optimizer can "inline" the body of a final method, replacing an invocation of the method with the code in its body. The inlining process must preserve the semantics of the method invocation. In particular, if the target of an instance method invocation is null, then a NullPointerException must be thrown even if the method is inlined. A Java compiler must ensure that the exception will be thrown at the correct point, so that the actual arguments to the method will be seen to have been evaluated in the correct order prior to the method invocation.

 1. final修饰方法可以阻止子类覆盖，如果试图覆盖则编译报错
 2. `private` 方法和`final` 类的方法表现的为final方法的属性，因为无法覆盖他们。  
 3. 运行时，JVM会`内联final方法`，用final方法的代码替换方法的调用，下图是一个简单示例:

```java
final class Point {
       int x, y;
       void move(int dx, int dy) { x += dx; y += dy; }
}
class Test {
    public static void main(String[] args) {
        Point[] p = new Point[100];
        for (int i = 0; i < p.length; i++) {
            p[i] = new Point();
            p[i].move(i, p.length-1-i);
        }
    }
}
```
main方法里的for循环中的Point类中的`move方法`将会被内联为下面的代码：

```java
 for (int i = 0; i < p.length; i++) {
    p[i] = new Point();
    Point pi = p[i];
    int j = p.length-1-i;
    pi.x += i;
    pi.y += j;
}

```
| Header One     | Header Two     |
| :------------- | :------------- |
| Item One       | Item Two       |

>参考资料：http://docs.oracle.com/javase/specs/jls/se8/html/jls-8.html#jls-8.4.3.3

###  修饰Class
        1. final修饰Class可以防止类被继承
        2. final和abstract不能同时修饰类，因为2者是互斥的。
###  final的语义
        1. Java编译器允许final域缓存在寄存器中而不用重新加载它，如果是非fina域的话，将会被重新加载
        2. final可以确保初始化过程中的安全性，不可变对象时线程安全的，在多个线程中共享这些对象无需同步。
        3. 多线程中，一个对象的final域在一个线程的构造器结束的时候，在另外的线程中可见。java中有很多安全的特点都是依据String类是被设计为final来保证的
### Java内存模型中的final TODO




参考资料：http://docs.oracle.com/javase/specs/jls/se8/html/jls-17.html#jls-17.5
