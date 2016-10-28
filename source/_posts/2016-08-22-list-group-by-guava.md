---
layout: post
title: Java List实现group by
description:
tags: java
category: java
---

一般情况下我们可能很熟悉在数据库中使用group by来分组一些数据，但是如果数据来源不是数据库的话可能就需要通过在代码中实现group by了

例子：比如有一组书Book的集合,我们要按照书的类型(type)分组

```java
package org.xuan;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class Book {
    private String name;
    private String type;
    private double price;
}

```

增加几本书到list

```java
List <Book> bookList =Arrays.asList(
         new Book("java programming","java",123.1D),
         new Book("java in concurrency","java",123.2D),
         new Book("c++ primary","c++",123.3D),
         new Book("groovy in action","groovy",123.4D),
         new Book("effective java","java",123.5D),
         new Book("jvm in practice","java",123.6D),
         new Book("scala in action","scala",123.7D)
         );
```


##一、使用传统的java来实现group by

```java
Map<String,List<Book>> bookMapOld = Maps.newLinkedHashMap();
for (Iterator<Book> iterator = bookList.iterator(); iterator.hasNext(); ) {
    Book book =  iterator.next();
    String type = book.getType();
    if(bookMapOld.containsKey(type)){
        bookMapOld.get(type).add(book);
    }else{
        List<Book> bookList2 = Lists.newLinkedList();
        bookList1.add(book);
        bookMapOld.put(type,bookList1);
    }
}
```

##二、使用guava来的multiMap来实现group by

```java
Multimaps.asMap(Multimaps.index(bookList, new Function<Book, String>() {
      public String apply(Book input) {
              return input.getType();
      }
  }));

```
##三、使用java 8来实现group by

```java
Map<String,List<Book>>bookMap =  bookList1.stream().collect(Collectors.groupingBy(b->b.getType(),Collectors.mapping((Book b)->b,Collectors.toList())));

```

##四、使用groovy来实现group by
groovy 使用closure来实现groovy by

```groovy
Map bookMap = bookList1.groupBy{it.getType()}
```
