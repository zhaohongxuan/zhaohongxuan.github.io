---
layout: post
title: Java集合中的Fail-fast和Fail-Safe机制
date: 2016-03-23
tags: java/collection
category: java
---

### 1.何为Fail-fast和Fail-Safe机制？

java.util包里的Iterator 抛出` ConcurrentModificationException`异常， 在集合迭代的时候被集合的`add`方法或者 `remove`方法调用。fail-fast 指java的集合的一种错误机制，当多个线程对集合修改操作的时候就可能抛出`ConcurrentModificationException`异常。

`java.util.concurrent`包里的Iterator 通过迭代一个集合的`snapshot` 允许并发修改集合，但是在迭代器创建之后可能不反映Collection更新。fail-safe机制意味着多个线程在操作同一个集合的时候，不会出现`ConcurrentModificationException`异常,
但是需要复制集合获得集合的快照，所以性能上开销会比非同步的集合开销要大。

多线程环境下用`java.util.concurrent`包里的集合替代 `java.util`包里的集合，比如 CopyOnWriteList=>ArrayList,ConcurrentHashMap=>HashMap etc.

### 2.JDK中的源码分析

下面代码是JDK1.7源码中ArrayList中的ListIterator，当Iterator创建时，当前的计数器`modCount` 赋值给Iterator对象,注意到`modCount`是一个 `transient`类型的成员变量，transient说明了计数器将不被序列化。
    
    protected transient int modCount = 0;

modCount用来记录List修改的次数的计数器，每修改一次(添加/删除等操作)，将modCount+1，例如 add()方法：

```java
 public void add(int index, E element) {
        rangeCheckForAdd(index);
        checkForComodification();
        l.add(index+offset, element);
        this.modCount = l.modCount;
        size++;
    }
```

<!-- more -->

当Iterator执行相应操作的时候，会先检验两个计数器的值是否相等，如果不相等就抛出`ConcurrentModificationException` 异常。

```java
 /**
     * An optimized version of AbstractList.Itr
     */
    private class Itr implements Iterator<E> {
        int cursor;       // index of next element to return
        int lastRet = -1; // index of last element returned; -1 if no such
        int expectedModCount = modCount;

        public boolean hasNext() {
            return cursor != size;
        }

        @SuppressWarnings("unchecked")
        public E next() {
            checkForComodification();
            int i = cursor;
            if (i >= size)
                throw new NoSuchElementException();
            Object[] elementData = ArrayList.this.elementData;
            if (i >= elementData.length)
                throw new ConcurrentModificationException();
            cursor = i + 1;
            return (E) elementData[lastRet = i];
        }

        public void remove() {
            if (lastRet < 0)
                throw new IllegalStateException();
            checkForComodification();

            try {
                ArrayList.this.remove(lastRet);
                cursor = lastRet;
                lastRet = -1;
                expectedModCount = modCount;
            } catch (IndexOutOfBoundsException ex) {
                throw new ConcurrentModificationException();
            }
        }

        final void checkForComodification() {
            if (modCount != expectedModCount)
                throw new ConcurrentModificationException();
        }
    }
```


CopyOnWriteArrayList的Iterator，可以看到COWIterator在构造函数初始化的时候把集合中的元素保存了一份快照，所有的操作都在快照上面进行的。CopyOnWriteArrayList的Iterator实现类中，checkForComodification()方法，也没有抛出ConcurrentModificationException异常！ 


```java
    private static class COWIterator<E> implements ListIterator<E> {
        /** Snapshot of the array */
        private final Object[] snapshot;
        /** Index of element to be returned by subsequent call to next.  */
        private int cursor;

        private COWIterator(Object[] elements, int initialCursor) {
            cursor = initialCursor;
            snapshot = elements;
        }

        public boolean hasNext() {
            return cursor < snapshot.length;
        }

        public boolean hasPrevious() {
            return cursor > 0;
        }

        @SuppressWarnings("unchecked")
        public E next() {
            if (! hasNext())
                throw new NoSuchElementException();
            return (E) snapshot[cursor++];
        }

        @SuppressWarnings("unchecked")
        public E previous() {
            if (! hasPrevious())
                throw new NoSuchElementException();
            return (E) snapshot[--cursor];
        }

        public int nextIndex() {
            return cursor;
        }

        public int previousIndex() {
            return cursor-1;
        }

        /**
         * Not supported. Always throws UnsupportedOperationException.
         * @throws UnsupportedOperationException always; <tt>remove</tt>
         *         is not supported by this iterator.
         */
        public void remove() {
            throw new UnsupportedOperationException();
        }

        /**
         * Not supported. Always throws UnsupportedOperationException.
         * @throws UnsupportedOperationException always; <tt>set</tt>
         *         is not supported by this iterator.
         */
        public void set(E e) {
            throw new UnsupportedOperationException();
        }

        /**
         * Not supported. Always throws UnsupportedOperationException.
         * @throws UnsupportedOperationException always; <tt>add</tt>
         *         is not supported by this iterator.
         */
        public void add(E e) {
            throw new UnsupportedOperationException();
        }
    }
```



