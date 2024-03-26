---
layout: post
title:  "vue.js学习笔记（二）"
keywords: "vue.jss"
date: 2015-09-22
category: 技术随笔
tags: Coding/javascript/Vue
---

继续上一篇文章，中间耽误了一个多星期，去面试和复习以前的代码，继续愉快的的vue.js学习之旅 :)...

## 列表渲染

vue.js的`v-repeat`指令用来根据相对应的ViewModel的对象数组来渲染列表。

### 简单示例
html代码：


```html
<ul id="demo">
  <li v-repeat="items" class="item-{{$index}}">
    {{$index}} : {{parentMsg}} {{childMsg}}
  </li>
</ul>
```

js代码：

```javascript
var demo = new Vue({
  el: '#demo',
  data: {
    parentMsg: '你好',
    items: [
      { childMsg: '赵' },
      { childMsg: '宏轩' }
    ]
  }
})
```

这些子实例继承父实例的数据作用域，因此在重复的模板元素中你既可以访问子实例的属性，也可以访问父实例的属性。还可以通过`$index`属性来获取当前实例对应的数组索引。

<!-- more -->

### 块级重复
`<template>`标签用来重复循环一个包含多个节点的块

```html
<ul>
  <template v-repeat="list">
    <li>{{msg}}</li>
    <li class="divider"></li>
  </template>
</ul>
```

### 简单值数组

简单值 (primitive value) 是字符串、数字、boolean 等并非对象的值。
对于包含简单值的数组，可用`$value`直接访问值:

```html
<ul id="tags">
  <li v-repeat="tags">
    {{$value}}
  </li>
</ul>
```

```javascript
new Vue({
el:'tags',
data:{
   tags:['java','sql','c++']
}
})
```


### 使用别名

如果想要访问实例对象的属性，可以通过`in`关键字来获得`repeat`对象的单个对象，有点类似于java中的`for-each`

```html
<ul id="users">
  <li v-repeat="user in users">
    {{user.name}} - {{user.email}}
  </li>
</ul>
```

```javascript
new Vue({
  el: '#users',
  data: {
    users: [
      { name: '赵小轩', email: 'hongxuanzhao@gmail.com' },
      { name: '窦小娜', email: 'xiaonadou@gmail.com' }
    ]
  }
})
```

### 遍历对象
使用使用`v-repeat`遍历一个对象的所有属性，每个重复的实例会有一个特殊的属性`$key`。
对于简单值，你也可以象访问数组中的简单值那样使用`$value`属性。

```html
<ul id="repeat-object">
  <li v-repeat="primitiveValues">{{$key}} : {{$value}}</li>
  <li>===</li>
  <li v-repeat="objectValues">{{$key}} : {{msg}}</li>
</ul>
```

```javascript
new Vue({
  el: '#repeat-object',
  data: {
    primitiveValues: {
      FirstName: 'John',
      LastName: 'Doe',
      Age: 30
    },
    objectValues: {
      one: {
        msg: 'Hello'
      },
      two: {
        msg: 'Bye'
      }
    }
  }
})
```

### 迭代值域
`v-repeat`可以接收一个整数，然后重复显示模版多次

```html
<div id="range">
    <div v-repeat="val">Hi! {{$index}}</div>
</div>
```

```javascript
new Vue({
  el: '#range',
  data: {
    val: 3
  }
});
```

### 数组过滤器

Vue有两个内置的过滤器来过滤或者排序数据，分别是：`filterBy`和`orderBy`。

#### filterBy
语法：

    filterBy searchKey [in dataKey...]

返回原数组过滤后的结果。`searchKey` 参数是当前`ViewModel` 的一个属性名，这个属性的值会被用作查找的目标。
`in`关键字指定具体要在哪个属性中进行查找。
用法：
##### 1.不使用`in`关键字

```html
<input v-model="searchText">
<ul>
  <li v-repeat="users | filterBy searchText">{{name}}</li>
</ul>
```

这个过滤器会遍历整个users数组每个元素的**每个**属性值来匹配`searchText`的内容
比如如果一个元素为`{name:'赵宏轩',tel:'021-111111'}`,`searchText`的值为`021`,那么这条数据就是合法的数据，不会被过滤器过滤掉。
##### 2.使用`in`关键字

```html
<input v-model="searchText">
<ul>
  <li v-repeat="user in users | filterBy searchText in 'name'">{{name}}</li>
</ul>
```

和上一个例子数据一样，但是如果`searchText`的值还是`021`的话，那么这条数据就会被过滤掉。因为过滤的内容限定在 `name`属性中，如果
`searchText`的值为`赵`的话，这个元素就不会被过滤掉。

####   OrderBy

    语法： orderBy sortKey [reverseKey].

`orderBy`用于返回原数组排序后的结果。
`sortKey`参数是当前`ViewModel`的一个属性名。这个属性的值表示用来排序的键名.
`reverseKey`参数也是当前`ViewModel`的一个属性名，如果这个属性值为真则数组会被倒序排列。
可以使用引号来表示字面量的排序键名。使用 -1 来表示字面量的 reverse 参数。

    语法： orderBy sortKey [reverseKey].

用法：

```html
<ul>
  <li v-repeat="user in users | orderBy field reverse">{{name}}</li>
</ul>
```

```javascript
new Vue({
  /* ... */
  data: {
    field: 'name',
    reverse: false
  }
})
```
