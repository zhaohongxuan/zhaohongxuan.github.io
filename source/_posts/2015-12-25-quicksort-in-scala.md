---
layout: post
title:  "使用Scala实现快速排序"
keywords: "scala"
date: 2015-12-25
category: scala
tags: scala
---

首先是一个用Scala写的简单的快速排序的栗子（非函数式）：

```scala
 def sort(xs: Array[Int]) {
    def swap(i: Int, j: Int) {
      val t = xs(i); xs(i) = xs(j); xs(j) = t
    }
    def sort1(l: Int, r: Int) {
      val pivot = xs((l + r) / 2)
      var i = l; var j = r
      while (i <= j) {
        while (xs(i) < pivot) i += 1
        while (xs(j) > pivot) j -= 1
        if (i <= j) {
          swap(i, j)
          i += 1
          j -= 1
        }
      }
      if (l < j) sort1(l, j)
      if (j < r) sort1(i, r)
    }
    sort1(0, xs.length - 1)
  }
```
<!-- more -->

和Java写的快速排序类似，使用操作符和控制语句来实现，只不过语法和Java有所不同。但是Scala的不同点就在于它的`函数式编程`，
函数式编程可以写出完全不同的程序，更加简单，更加优雅。
这次还是快速排序，这一次用函数式的风格来写：

```scala
  def quicksort(xs: Array[Int]): Array[Int] = {
    if (xs.length <= 1) xs
    else {
      val pivot = xs(xs.length / 2)
      Array.concat(
        quicksort(xs filter (pivot >)),
        xs filter (pivot ==),
        quicksort(xs filter (pivot <)))
    }
  }
```

函数式编程用一种简洁的方式抓住了快速排序的本质

1. 如果数组array是空的或者只有一个元素那么肯定是已经排好序的所以直接返回
2. 如果数组array不是空的,选择数组中间的元素当做pivot。
3. 将数组划分为三个子数组,分别包含笔pivot大、小、相等的元素。
4. 对于大于和小于pivot的子元素的数组递归调用sort函数。
5. 讲三个子数组组合在一起就是排序结果。


