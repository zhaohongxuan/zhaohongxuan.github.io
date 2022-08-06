---
layout: post
title: Java中的互斥锁和读写锁
tags: java/thread
date: 2016-11-26
category: java
---

在JDK5之前，访问共享对象的时候使用的机制只有`synchronized`和`volatile` ，JDK5的并发包里提供了一种新的更加高级的机制：互斥锁ReentrantLock，显式锁是为了弥补内置锁的方法而开发的，两者是互补的关系，显式锁并不能代替内置锁。
ReentrantLock实现了一种标准的互斥锁，亦即每次最多有一个线程能够持有ReentrantLock

## Lock接口&ReentrantLock简介
concurrent包中的Lock类定义了一组抽象的加锁操作，如下代码所示，与synchronized不同的是，Lock提供了一种`无条件`、`可轮询`、`定时`、`可中断`的锁获取操作，所有的加锁和解锁操作都是显示的
ReentrantLock实现了Lock接口，提供了与synchronized相同的互斥性以及内存可见性。与synchronized一样，ReentrantLock提供了可重入（即可以被单个线程多次获取）的加锁语义。

```java
public interface Lock {
    void lock();
    void lockInterruptibly() throws InterruptedException;
    boolean tryLock();
    boolean tryLock(long time, TimeUnit unit) throws InterruptedException;
    void unlock();
    Condition newCondition();
}

```
ReentrantLock的使用方法：

```java
Lock lock = new ReentrantLock();
...
lock.lock();
try{

} finally{
  lock.unlock();
}
```
在使用显示锁的时候一定要在finally块中释放锁，否则如果代码中一旦出现异常，那么可能这个锁永远都无法释放就会造成某个对象的状态不一致，如果是账户余额或者别的重要的信息可能就会出现很严重的事故。
<!-- more -->
## 与内置锁的区别

### 可轮询及定时的锁
在内置锁中，一旦出现死锁，唯一的办法就是重启服务，ReentrantLock使用tryLock()方法来实现可轮询的或者定时的锁，如果一次不能获得全部的锁，那么通过可定时或者轮询的锁可以重新获得控制权，它会释放已经获得的锁然后重新获取所有的锁，如果在指定的时间内没有获取到所有的锁，那么就返回失败。
如下例子，通过tryLock()来避免锁顺序死锁

```java
public boolean transferMoney(Account fromAcc,Account toAcc,Amount amount,long timeout,TimeUnit timeUnit){

  long fixeDelay = getFixDelayNanos(timeout,timeUnit); //固定的时间
  long ranMod = getRandomDelayNanos(timeout,timeUnit); //随机的时间
  long stopTime = System.nanoTime() + timeUnit.toNanos(timeout);
  while(true){
    if(fromAcc.lock.tryLock()){
      try{
        if(toAcc.lock.tryLock()){
          try{
            if(fromAcc.getBalance().compareTo(amount)<0){
              throw new InsufficientFundsException();
            }else{
              fromAcc.debit(amount);
              to.credit(amount);
              return true;
            }
          }finally{
            toAcc.lock.unlock();
          }

        }
      }finally{
        fromAcc.lock.unklock();
      }
    }

    if(System.nanoTime()<stopTime)
      return false;
    NANOSECONDS.sleep(fixeDelay+rnd.nextLong()%ranMod)  
  }
}
```
另一种方式是使用定时锁，如果在指定的时间内无法获取到锁的话那么将操作失败

### 可中断的锁获取操作
使用Lock接口中的lockInterruptibly方法能够在获得锁的同时保持对中断的响应。


```java
public boolean sendSharedLine(String message) throw InterruptedException{
  lock.lockInterruptibly();
  try{
    return cancellableSendOnSharedLine(message);
  }finally{
    lock.unlock();
  }
}

private boolean cancellableSendOnSharedLine(String message) throw InterruptedException{
  ...
}
```

### 非块结构的加锁
synchronized锁的获取和释放的操作都是基于代码块的，虽然这样能够简化代码的编写，降低编码错误的可能性，但是有的时候可能需要更加灵活的加锁规则。
降低锁的力度可以提高代码的`伸缩性`, 在某些情况下，可以将锁分解成对`一组独立对象`上的锁的的分解，这种技术被称为`锁分段`，在ConcurrentHashMap中使用了一个包含`16`个锁的数组，每个锁保护所有散列桶的`1/16`，  一种第N个散列桶由第`N mod 16`个锁来保护。如果散列函数合理分布，这样锁的请求就减少到了原来的1/16。正是由于锁分段技术，ConcurrentHashMap能够支持多大16个并发的写入器，当然如果并发量足够大的话可以将默认的锁分段数量超过默认的16个。
下面的代码块就是ConcurrentHashMap的`锁分段`的代码，其中能看到Segment是继承与ReentrantLock的，本质上是一把互斥锁。

```java
static class Segment<K,V> extends ReentrantLock implements Serializable {
    private static final long serialVersionUID = 2249069246763182397L;
    final float loadFactor;
    Segment(float lf) { this.loadFactor = lf; }
}
```
## 公平锁与非公平锁

ReentrantLock的构造函数如下，提供了两种公平性的锁，一种是公平锁，一种是非公平的锁（默认）

```java
public ReentrantLock() {
    sync = new NonfairSync();
}

public ReentrantLock(boolean fair) {
    sync = fair ? new FairSync() : new NonfairSync();
}
```

在公平锁上，线程按照`发出请求`的顺序来获得锁，而当线程请求非公平锁时，如果刚好该锁的状态变为可用的话那么久允许这个线程先于队列其他线程获得锁。

公平锁与非公平锁
```java
/**
    * Sync object for fair locks
    */
   static final class FairSync extends Sync {
       private static final long serialVersionUID = -3000897897090466540L;

       final void lock() {
           acquire(1);
       }

       /**
        * Fair version of tryAcquire.  Don't grant access unless
        * recursive call or no waiters or is first.
        */
       protected final boolean tryAcquire(int acquires) {
           final Thread current = Thread.currentThread();
           int c = getState();
           if (c == 0) {
               if (!hasQueuedPredecessors() &&
                   compareAndSetState(0, acquires)) {
                   setExclusiveOwnerThread(current);
                   return true;
               }
           }
           else if (current == getExclusiveOwnerThread()) {
               int nextc = c + acquires;
               if (nextc < 0)
                   throw new Error("Maximum lock count exceeded");
               setState(nextc);
               return true;
           }
           return false;
       }
   }

   /**
 * Sync object for non-fair locks
 */
static final class NonfairSync extends Sync {
    private static final long serialVersionUID = 7316153563782823691L;

    /**
     * Performs lock.  Try immediate barge, backing up to normal
     * acquire on failure.
     */
    final void lock() {
        if (compareAndSetState(0, 1))
            setExclusiveOwnerThread(Thread.currentThread());
        else
            acquire(1);
    }

    protected final boolean tryAcquire(int acquires) {
        return nonfairTryAcquire(acquires);
    }
}

```

由代码可以看到公平锁和非公平都是继承于Sync的而Sync是继承与抽象的AQS（AbstractQueuedSynchronizer）的，AQS是java中锁的抽象类，包含了锁的许多公共方法，是互斥锁(例如，ReentrantLock)和共享锁(例如，Semaphore)的公共父类。
可以看到公平锁和非公平锁的不同点在于`tryAcquire()`方法即获取锁的方式不同。

在大多数情况下，非公平锁的性能要高于公平锁的性能。主要原因是在恢复一个被挂起的线程与线程真正运行之间有很大的延迟。假如现在线程A持有一个锁，线程B请求这个锁，由于A持有这个锁，所以B挂起，当A释放锁的时候B被唤醒，再次尝试获取这个锁，如果在同时有C也请求这个锁，那么有很大可能C会在B`完全唤醒前`获取这个锁使用以及使用这个锁，当B获得锁的时候，C已经使用完毕并释放锁了，所以吞吐量会有所提高。但是当请求锁的平均时间较长的时候应该使用`公平锁`。

## 读写锁 ReadWriteLock TODO
