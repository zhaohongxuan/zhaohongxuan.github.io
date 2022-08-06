---
title: 理解Jvm Class文件结构
date: 2022-07-31 09:19
tags: [jvm]
category: 深入理解JVM
---
# 理解Jvm Class 文件结构


Class 文件结构如下：

```
ClassFile {
	u4 magic; //Class 文件的标志
	u2 minor_version;//Class 的小版本号
	u2 major_version;//Class 的大版本号
	u2 constant_pool_count;//常量池的数量
	cp_info constant_pool[constant_pool_count-1];//常量池
	u2 access_flags;//Class 的访问标记
	u2 this_class;//当前类
	u2 super_class;//父类
	u2 interfaces_count;//接口
	u2 interfaces[interfaces_count];//一个类可以实现多个接口
	u2 fields_count;//Class 文件的字段属性
	field_info fields[fields_count];//一个类可以有多个字段
	u2 methods_count;//Class 文件的方法数量
	method_info methods[methods_count];//一个类可以有个多个方法
	u2 attributes_count;//此类的属性表中的属性数
	attribute_info attributes[attributes_count];//属性表集合
}
```

下面的这个图更加直观：

![](https://raw.githubusercontent.com/zhaohongxuan/picgo/master/20220806135458.png)


使用`010 Editor` 打开 `Hello.class` 可以更加直观的查看

![](https://raw.githubusercontent.com/zhaohongxuan/picgo/master/20220806134852.png)

<!-- more -->

首先创建一个简单的Hello Word程序：

```java

public static void main(String[] args){
	System.out.println("Hello World");
}

```

然后使用 `javap -v Hello.class` 来将字节码文件生成反汇编文件如下：

```java
Classfile /Users/xuan/IdeaProjects/learn-spring/target/classes/Hello.class
  Last modified 2022年7月31日; size 548 bytes
  SHA-256 checksum eaba6958496d3a0d5605df6adb13ad3af4d3c5939bf1244f38b255637eec3c89
  Compiled from "Hello.java"
public class Hello
  minor version: 0
  major version: 52
  flags: (0x0021) ACC_PUBLIC, ACC_SUPER
  this_class: #5                          // Hello
  super_class: #6                         // java/lang/Object
  interfaces: 0, fields: 0, methods: 2, attributes: 1
Constant pool:
   #1 = Methodref          #6.#21         // java/lang/Object."<init>":()V
   #2 = Fieldref           #22.#23        // java/lang/System.out:Ljava/io/PrintStream;
   #3 = String             #24            // Hello World
   #4 = Methodref          #25.#26        // java/io/PrintStream.println:(Ljava/lang/String;)V
   #5 = Class              #27            // Hello
   #6 = Class              #28            // java/lang/Object
   #7 = Utf8               <init>
   #8 = Utf8               ()V
   #9 = Utf8               Code
  #10 = Utf8               LineNumberTable
  #11 = Utf8               LocalVariableTable
  #12 = Utf8               this
  #13 = Utf8               LHello;
  #14 = Utf8               main
  #15 = Utf8               ([Ljava/lang/String;)V
  #16 = Utf8               args
  #17 = Utf8               [Ljava/lang/String;
  #18 = Utf8               MethodParameters
  #19 = Utf8               SourceFile
  #20 = Utf8               Hello.java
  #21 = NameAndType        #7:#8          // "<init>":()V
  #22 = Class              #29            // java/lang/System
  #23 = NameAndType        #30:#31        // out:Ljava/io/PrintStream;
  #24 = Utf8               Hello World
  #25 = Class              #32            // java/io/PrintStream
  #26 = NameAndType        #33:#34        // println:(Ljava/lang/String;)V
  #27 = Utf8               Hello
  #28 = Utf8               java/lang/Object
  #29 = Utf8               java/lang/System
  #30 = Utf8               out
  #31 = Utf8               Ljava/io/PrintStream;
  #32 = Utf8               java/io/PrintStream
  #33 = Utf8               println
  #34 = Utf8               (Ljava/lang/String;)V
{
  public Hello();
    descriptor: ()V
    flags: (0x0001) ACC_PUBLIC
    Code:
      stack=1, locals=1, args_size=1
         0: aload_0
         1: invokespecial #1                  // Method java/lang/Object."<init>":()V
         4: return
      LineNumberTable:
        line 1: 0
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0       5     0  this   LHello;

  public static void main(java.lang.String[]);
    descriptor: ([Ljava/lang/String;)V
    flags: (0x0009) ACC_PUBLIC, ACC_STATIC
    Code:
      stack=2, locals=1, args_size=1
         0: getstatic     #2                  // Field java/lang/System.out:Ljava/io/PrintStream;
         3: ldc           #3                  // String Hello World
         5: invokevirtual #4                  // Method java/io/PrintStream.println:(Ljava/lang/String;)V
         8: return
      LineNumberTable:
        line 3: 0
        line 4: 8
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0       9     0  args   [Ljava/lang/String;
    MethodParameters:
      Name                           Flags
      args
}
SourceFile: "Hello.java"

```

## Reference 
1. [The Java® Virtual Machine Specification](https://docs.oracle.com/javase/specs/jvms/se8/html/index.html)