---
layout: post
title:  "三种遍历Map的方法"
keywords: "遍历Map"
date: 2015-10-17
category: java
tags:
---

昨天在使用`KeySet`的方式遍历一个HashMap时，然后试图`remove`掉其中的一个元素的时候，Java虚拟机抛出了一个`java.util.ConcurrentModificationException`的异常。
搜集了一下java中遍历一个Map的几种方法，主要有以下三种，只有使用使用Iterator遍历的时候才可以移除元素。其他的两种操作都有可能报ConcurrentModificationException的异常。然后顺便整理了一下遍历Map的几种方法。
参考了StackOverFlow上的这个问题,请戳[Iterate through a HashMap](http://stackoverflow.com/questions/1066589/iterate-through-a-hashmap)
## 方法1:使用For-Each循环迭代entrySet
这种方法应该是使用的最多的了，一般需要使用Map的key和value时候使用这个方法

```java

Map<Integer, Integer> map = new HashMap<Integer, Integer>();
for (Map.Entry<Integer, Integer> entry : map.entrySet()) {
    System.out.println("Key = " + entry.getKey() + ", Value = " + entry.getValue());
}
```
<!-- more -->

`For-Each`是在`Java 5` 中被引进的，所以这种方法只能在JDK5之后才能使用，而且使用之前要判断map是否为`null`。
## 方法2:通过迭代keys或者values来遍历Map的keySet和values
Map<Integer, Integer> map = new HashMap<Integer, Integer>();
如果只需要遍历key或者value的时候可以直接遍历`keySet`或者`values`来取代`entrySet`

```java
//仅仅遍历key
for (Integer key : map.keySet()) {
    System.out.println("Key = " + key);
}

//仅仅遍历values
for (Integer value : map.values()) {
    System.out.println("Value = " + value);
}

```
这种方法比使用entrySet的方式要快，而且要更简洁。

####PS.当然也完全可以，遍历完keySet之后只用get()方法查找到对应的value来达到遍历key-value的目的

```java
Map<Integer, Integer> map = new HashMap<Integer, Integer>();
for (Integer key : map.keySet()) {
    Integer value = map.get(key);
    System.out.println("Key = " + key + ", Value = " + value);
}
```
这种方法貌似比第一种要简洁，但是...
注意，**重要的话说三遍**

	这种方法非常耗时间
	这种方法非常耗时间
	这种方法非常耗时间

这种方法相比第一种来说要慢`20%~200%`，所以使用这种方法来遍历key-value的方式应该被`避免`使用。
##  使用Iterator遍历

```java
//使用泛型:
Map<Integer, Integer> map = new HashMap<Integer, Integer>();
Iterator<Map.Entry<Integer, Integer>> it = map.entrySet().iterator();
while (entries.hasNext()) {
    Map.Entry<Integer, Integer> entry = it.next();
    System.out.println("Key = " + entry.getKey() + ", Value = " + entry.getValue());
    it.remove();//避免 ConcurrentModificationException
}
//不使用泛型:
Map map = new HashMap();
Iterator it = map.entrySet().iterator();
while (it.hasNext()) {
    Map.Entry entry = (Map.Entry) it.next();
    Integer key = (Integer)entry.getKey();
    Integer value = (Integer)entry.getValue();
    System.out.println("Key = " + key + ", Value = " + value);
    it.remove();//避免 ConcurrentModificationException
}
```

这种方法看起来很多余，但是它也有自己的优点
1. 这是仅有的一种可以遍历以前Java版本中Map的方法（For-Each）
2. 这是仅有的一种可以在你遍历期间移除元素的方法,
这种方式解决了文章开头的ConcurrentModificationException的错误。
##  结论
1. 如果仅仅需要遍历key或者value可以使用方法2
2. 如果需要在老版本（java5之前的版本）或者要在遍历过程中删除元素时请使用方法3
3. 其他情况下使用方法1
