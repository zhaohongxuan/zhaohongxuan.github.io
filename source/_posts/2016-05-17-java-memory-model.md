---
layout: post
title: Java内存模型【译】
date: 2016-05-17
tags: java/thread
category: java
---

本文翻译自 [Java Memory Model](http://tutorials.jenkov.com/java-concurrency/java-memory-model.html)旨在加深自己对Java Memory Model (JMM)的理解。

>The Java memory model specifies how the Java virtual machine works with the computer's memory (RAM). 
The Java virtual machine is a model of a whole computer so this model naturally includes a memory model - AKA the Java memory model.
It is very important to understand the Java memory model if you want to design correctly behaving concurrent programs.
The Java memory model specifies how and when different threads can see values written to shared variables by other threads, and how to synchronize access to shared variables when necessary.
The original Java memory model was insufficient, so the Java memory model was revised in Java 1.5. This version of the Java memory model is still in use in Java 8.

Java内存模型详述了java虚拟机如何与物理机的RAM的一起工作的，
java虚拟机是整个计算机的模型，所以这个模型自然包括内存模型，这个模型卡就是Java内存模型。
如果你想正确的设计并发程序，知道Java内存模型是非常重要的
java内存模型详解了多个不同的线程是何时而又如何写入一个共享的变量的，还有如何同步的访问一个共享变量。
原来的Java内存模型是不足的，所以Java内存模型在java 5中重新修订了，这个版本的java内存模型一直在Java8中还在使用。

## 内部的java内存模型

>The Java memory model used internally in the JVM divides memory between thread stacks and the heap. This diagram illustrates the Java memory model from a logic perspective:

<!-- more -->


Java内存模型将JVM的内存按照线程栈和堆进行分割，下面的图表从逻辑的视图展示了Java内存模型：
![enter description here][http://tutorials.jenkov.com/images/java-concurrency/java-memory-model-1.png]  

>Each thread running in the Java virtual machine has its own thread stack.
The thread stack contains information about what methods the thread has called to reach the current point of execution. I will refer to this as the "call stack". As the thread executes its code, the call stack changes.
The thread stack also contains all local variables for each method being executed (all methods on the call stack). A thread can only access it's own thread stack.
Local variables created by a thread are invisible to all other threads than the thread who created it. Even if two threads are executing the exact same code, 
the two threads will still create the local variables of that code in each their own thread stack. Thus, each thread has its own version of each local variable.
All local variables of primitive types ( boolean, byte, short, char, int, long, float, double) are fully stored on the thread stack and are thus not visible to other threads. 
One thread may pass a copy of a pritimive variable to another thread, but it cannot share the primitive local variable itself.
The heap contains all objects created in your Java application, regardless of what thread created the object. This includes the object versions of the primitive types (e.g. Byte, Integer, Long etc.).
It does not matter if an object was created and assigned to a local variable, or created as a member variable of another object, the object is still stored on the heap.

每一个运行在JVM上的线程都有自己的线程栈，
线程栈中包含了线程当前执行点的方法的详细信息，我想这个称之为`调用栈`,当线程执行了代码，调用栈就发生了变化。
线程栈中也包含了所有的正在执行方法（所有在在调用栈中的方法）的局部变量，一个线程只能访问`自己的线程栈`。
被线程创建的本地变量对于其他的线程来说是`不可见`的,即使两个线程执行同样的代码，这两个线程仍然会在自己的线程栈上创本地变量。
所有的原始类型（ boolean, byte, short, char, int, long, float, double）的本地变量全部存储在自己的线程栈中对其他线程不可见，一个线程可以传递一个原始类型的变量给其他线程，但是不能和其他线程共享原始类型的变量。
堆中包含了你的java程序中的所有的对象，不管是由哪个线程创建的对象，其中包含了原始类型对应的Wrapper类（Byte, Integer, Long etc），
不管一个对象是被分配给一个局部变量还是成员变量，这个对象都仍旧保存在`堆`上。

>Here is a diagram illustrating the call stack and local variables stored on the thread stacks, and objects stored on the heap:

下面是一个图表说明了在线程栈中保存的调用栈，局部变量和在堆中保存的所有对象。
![enter description here]http://tutorials.jenkov.com/images/java-concurrency/java-memory-model-2.png]

>A local variable may be of a primitive type, in which case it is totally kept on the thread stack.
A local variable may also be a reference to an object. In that case the reference (the local variable) is stored on the thread stack, but the object itself if stored on the heap.
An object may contain methods and these methods may contain local variables. These local variables are also stored on the thread stack, even if the object the method belongs to is stored on the heap.
An object's member variables are stored on the heap along with the object itself. That is true both when the member variable is of a primitive type, and if it is a reference to an object.
Static class variables are also stored on the heap along with the class definition.
Objects on the heap can be accessed by all threads that have a reference to the object. When a thread has access to an object, it can also get access to that object's member variables. 
If two threads call a method on the same object at the same time, they will both have access to the object's member variables, but each thread will have its own copy of the local variables.

一个局部变量可能是原始类型的，这种情况下，它将完全保存在线程栈上
一个局部变量也可能引用一个对象，这个中情况下引用（该局部变量）将会被存储在`线程栈`中，而`被引用的对象`将会被存储在`堆`上。
一个对象可能包含多个方法，而这些方法也可能包含局部变量，这些局部变量也将会保存在`线程栈`上，即使该方法所属的对象是存在`堆`上的。
一个对象的成员变量和对象本身一起被存放在`堆`上，`不管`成员变量是`基本数据类型`的还是`引用数据类型`的。
静态成员变量将会和类定义一起被保存在`堆`上。
在堆上保存的对象可以被所有和这个对象有引用关系的线程访问，当一个线程有权访问一个对象，那么这个线程也能够访问这个对象的成员变量。
当两个线程`同时`调用同一个对象的某个方法，他们将`同时拥有`该对对象的`成员变量`的访问权，但是每个线程将会有一份`局部变量`的`副本`。

>Here is a diagram illustrating the points above:

下图说明上述观点：
![enter description here][http://tutorials.jenkov.com/images/java-concurrency/java-memory-model-3.png]


>Two threads have a set of local variables. One of the local variables (Local Variable 2) point to a shared object on the heap (Object 3).
The two threads each have a different reference to the same object. 
Their references are local variables and are thus stored in each 
thread's thread stack (on each). The two different references point to the same object on the heap, though.
Notice how the shared object (Object 3) has a reference to Object 2 and Object 4 as member variables (illustrated by the arrows from Object 3 to Object 2 and Object 4). 
Via these member variable references in Object 3 the two threads can access Object 2 and Object 4.
The diagram also shows a local variable which point to two different objects on the heap. In this case the references point to two different objects (Object 1 and Object 5), not the same object. 
In theory both threads could access both Object 1 and Object 5, 但是上图中的两个线程都只有两个对象中的一个的引用。
if both threads had references to both objects. But in the diagram above each thread only has a reference to one of the two objects.

两个线程都各自一个局部变量的集合，其中的一个局部变量（Local Variable 2）只想了堆上的一个共享对象（Object 3），
两个线程对同一个对象有不同的引用。
他们的引用都是局部变量并且都被存在自己的`线程栈`上，尽管两个引用只想堆上的同一个对象。
注意到共享对象（`Object 3`）对 `Object 2` 和 `Object 4` 有作为成员变量的引用关系（Object 3指向Object 2和Object 4的箭头）。
通过在Object 3 中引用成员变量，这两个线程可以访问`Object 2`和`Object 4`

上图也展示了一个指向堆上不同对象的局部变量，这种情况下引用指向了对上的不同对象（Object 1 和Object 5）而不是同一个对象，
理论上讲，如果两个各对象都有两个对象的引用的话是可以访问Object 1和Object 5

>So, what kind of Java code could lead to the above memory graph? Well, code as simple as the code below:

所以，什么样的Java 代码可以解释上面的内存图，代码简单如下：

```java
public class MyRunnable implements Runnable() {

    public void run() {
        methodOne();
    }

    public void methodOne() {
        int localVariable1 = 45;

        MySharedObject localVariable2 =
            MySharedObject.sharedInstance;

        //... do more with local variables.

        methodTwo();
    }

    public void methodTwo() {
        Integer localVariable1 = new Integer(99);

        //... do more with local variable.
    }
}
```

```java
public class MySharedObject {

    //static variable pointing to instance of MySharedObject

    public static final MySharedObject sharedInstance =
        new MySharedObject();


    //member variables pointing to two objects on the heap

    public Integer object2 = new Integer(22);
    public Integer object4 = new Integer(44);

    public long member1 = 12345;
    public long member1 = 67890;
}
```

>If two threads were executing the run() method then the diagram shown earlier would be the outcome. The run() method calls methodOne() and methodOne() calls methodTwo().
methodOne() declares a primitive local variable (localVariable1 of type int) and an local variable which is an object reference (localVariable2).
Each thread executing methodOne() will create its own copy of localVariable1 and localVariable2 on their respective thread stacks. 
The localVariable1 variables will be completely separated from each other, only living on each thread's thread stack. 
One thread cannot see what changes another thread makes to its copy of localVariable1.

如果两个方法同时执行 `run()`方法，run()方法调用`methodOne()`然后 `methodOne()`调用 `methodTwo()`
`methodOne()` 声明了一个基本数据类型的局部变量（int类型 localVariable1）和一个引用数据类型的局部变量（localVariable2）
每一个线程在执行`methodOne()`时将会创建 `localVariable1` 和`localVariable2`的副本在各自的线程栈。
局部变量 `localVariable1` 将会和其他的变量分割开来，仅仅存活在自己线程的线程栈中。
线程不能够看到其他线程对`localVariable1`变量副本做出的改变。


>Each thread executing methodOne() will also create their own copy of localVariable2.
However, the two different copies of localVariable2 both end up pointing to the same object on the heap. 
The code sets localVariable2 to point to an object referenced by a static variable. 
There is only one copy of a static variable and this copy is stored on the heap. 
Thus, both of the two copies of localVariable2 end up pointing to the same instance of MySharedObject which the static variable points to.
The MySharedObject instance is also stored on the heap. It corresponds to Object 3 in the diagram above.
Notice how the MySharedObject class contains two member variables too. The member variables themselves are stored on the heap along with the object. 
The two member variables point to two other Integer objects. These Integer objects correspond to Object 2 and Object 4 in the diagram above.
Notice also how methodTwo() creates a local variable named localVariable1. This local variable is an object reference to an Integer object. 
The localVariable1 reference will be stored in one copy per thread executing methodTwo(). 
The method sets the localVariable1 reference to point to a new Integer instance. 
The two Integer objects instantiated will be stored on the heap, but since the method creates a new Integer object every time the method is executed, two threads executing this method will create separate Integer instances. 
The Integer objects created inside methodTwo() correspond to Object 1 and Object 5 in the diagram above.
Notice also the two member variables in the class MySharedObject of type long which is a primitive type. 
Since these variables are member variables, they are still stored on the heap along with the object. Only local variables are stored on the thread stack.


每个线程执行`methodOne()`时也将会创建它们各自的localVariable2拷贝。
然而，两个`localVariable2`的不同拷贝都指向堆上的同一个对象。
 代码中通过一个静态变量设置`localVariable2`指向一个对象引用。
 仅存在一个静态变量的一份拷贝，这份拷贝存放在堆上。
 因此，`localVariable2`的两份拷贝都指向由`MySharedObject`指向的静态变量的同一个实例。
 `MySharedObject`实例也存放在堆上。它对应于上图中的`Object3`。
注意，`MySharedObject`类也包含两个成员变量，这些成员变量随着这个对象存放在堆上。
这两个成员变量指向另外两个`Integer`对象。这些Integer对象对应于上图中的`Object2`和`Object4`.
注意，`methodTwo()`创建一个名为localVariable的本地变量。这个成员变量是一个指向一个Integer对象的对象引用。
这个方法设置localVariable1引用指向一个新的Integer实例。
在执行`methodTwo`方法时，`localVariable1`引用将会在每个线程中存放一份拷贝。
这两个Integer对象实例化将会被存储堆上，但是每次执行这个方法时，这个方法都会创建一个新的Integer对象，两个线程执行这个方法将会创建两个不同的Integer实例。
`methodTwo()`方法创建的Integer对象对应于上图中的`Object1`和`Object5`。
注意，MySharedObject类中的两个`long`类型的成员变量是`原始类型`的。
因为，这些变量是成员变量，所以它们任然随着该对象存放在堆上，仅有本地变量存放在线程栈上。


## 硬件的内存架构（TODO）
