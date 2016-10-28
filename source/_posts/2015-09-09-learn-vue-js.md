---
layout: post
title:  "vue.js学习笔记（一）"
keywords: "vue.jss"
description: "MVVM框架vue.js学习笔记，vue.js简介"
category: javascript
tags: js
---

##简介

Vue.js 是一个用于创建 web 交互界面的库。

从技术角度讲，`Vue.js`专注于`MVVM`模型的`ViewModel`层。它通过双向数据绑定把`View`层和 Model 层连接了起来。实际的`DOM`封装和输出格式都被抽象为了`Directives`和`Filters`。

从哲学角度讲，Vue 希望通过一个尽量简单的 API 来提供响应式的数据绑定和可组合、复用的视图组件。它不是一个大而全的框架——它只是一个简单灵活的视图层。您可以独立使用它快速开发原型、也可以混合别的库做更多的事情。它同时和诸如 Firebase 这一类的 BaaS 服务有着天然的契合度。

Vue.js 的 API 设计深受`AngularJS、KnockoutJS、Ractive.js` 和 `Rivets.js` 的影响。尽管有不少相似之处，但我们相信 Vue.js 能够在简约和功能之间的微妙平衡中体现出其独有的价值。

###ViewModel

ViewModel在vue.js中同步Model和View的对象，在vue.js中，每个vue.js实例都是一个ViewModel它们是通过构造函数 `Vue`或者其子类被创建出来的

```javascript
var vm =new Vue({});
```

###视图(View)

View是被Vue实例管理的DOM节点

```javascript
vm.$el
```
Vue.js 使用基于 DOM 的模板。每个 Vue 实例都关联着一个相应的 DOM 元素。当一个 Vue 实例被创建时，它会递归遍历根元素的所有子结点，同时完成必要的数据绑定。当这个视图被编译之后，它就会自动响应数据的变化。

当数据发生变化时，视图将会自动触发更新。这些更新的粒度精确到一个文字节点。同时为了更好的性能，这些更新是批量异步执行的。


###模型(Model)

```javascript
vm.$data
```
Vue.js中的模型就是普通的javascript对象。一旦某对象被作为 Vue 实例中的数据，它就成为一个 “响应式” 的对象了。你可以操作它们的属性，同时正在观察它的 Vue 实例也会收到提示。

###指令(Directives)

Vue.js的指令是带有特殊前缀`v-`的HTML特性，可以让Vue.js对DOM做各种处理。
####1.简单示例

```html
<div v-text ='name'> </div>
```
这里的前缀是默认的 `v-`。指令的`ID` 是 `text`，表达式是 `name`。这个指令告诉 Vue.js， 当 Vue 实例的 `name` 属性改变时，更新该 `div` 元素的 `textContent`。
Directives 可以封装任何 DOM 操作。比如`v-attr` 会操作一个元素的特性；`v-repeat` 会基于数组来复制一个元素；`v-on` 会绑定事件等
####2.内联表达式

```html
<div v-text="'hello ' + user.firstName + ' ' + user.lastName"></div>
```

这里我们使用了一个计算表达式 (computed expression)，而不仅仅是简单的属性名。Vue.js 会自动跟踪表达式中依赖的属性并在这些依赖发生变化的时候触发指令更新。
同时，因为有异步批处理更新机制，哪怕多个依赖同时变化，表达式也只会触发一次。
需要注意的是Vue.js 把内联表达式限制为一条语句。如果需要绑定更复杂的操作，可以使用`计算属性`。
####3.参数

```html
<div v-on="click : clickHandler"></div>
```
有些指令需要在路径或表达式前加一个参数。在这个例子中`click`参数代表了我们希望`v-on` 指令监听到点击事件之后调用该 `ViewModel` 实例的 `clickHandler` 方法。

####4.多重指令从句

你可以在同一个特性里多次绑定同一个指令。这些绑定用逗号分隔，它们在底层被分解为多个指令实例进行绑定。

<div v-on="
  click   : onClick,
  keyup   : onKeyup,
  keydown : onKeydown
">
</div>
####5.字面量指令

有些指令不会创建数据绑定——它们的值只是一个字符串字面量。比如 v-ref 指令：

```html
<my-component v-ref="some-string-id"></my-component>
```

这里的 `some-string-id` 并不是一个响应式的表达式 — `Vue.js`不会尝试去观测组件中的对应数据。

在有些情况下，你也可以使用 `Mustache` 风格绑定来使得字面量指令 `反应化`：

```html
<div v-show="showMsg" v-transition="{{dynamicTransitionId}}"></div>
```
但是，请注意只有`v-transition` 指令具有此特性。`Mustache`表达式在其他字面量指令中，例如 `v-ref` 和 `v-el`，只会被计算一次。它们在编译完成后将不会再响应数据的变化。

###Mustache 风格绑定

你也可以使用 mustache 风格的绑定，不管在文本中还是在属性中。它们在底层会被转换成 v-text 和 v-attr 的指令。比如：

```html
<div id="person-{{id}}">Hello {{name}}!</div>
```

###过滤器(filter)

####1.示例
过滤器是用于在更新视图之前处理原始值的函数,它们通过一个“管道”在指令或绑定中进行处理：

```html
<div>{{message | capitalize}}</div>

```
这样在 div 的文本内容被更新之前，message 的值会先传给 capitalizie 函数处理。
####2.参数
一些过滤器是可以接受参数的。参数用空格分隔开：

```html
<span>{{order | pluralize 'st' 'nd' 'rd' 'th'}}</span>
<input v-on="keyup: submitForm | key 'enter'">
```
