---
layout: post
title:  "Xpath语法学习"
keywords: "xml xpath"
date: 2015-08-11
category: 技术随笔
tags: xml
---
最近写爬虫时，需要解析`html`，有好多种选择xml文档节点的方法，先熟悉一下使用`xpath`来选取节点、解析节点

下面是学习需要的`XML文档`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<bookstore>
<book>
  <title lang="eng">Harry Potter</title>
  <price>29.99</price>
</book>
<book>
  <title lang="eng">Learning XML</title>
  <price>39.95</price>
</book>
</bookstore>
```

### 选取节点
`XPath`使用路径表达式在`XML`文档中选取节点。节点是通过沿着路径或者`step`来选取的。

最有用的路径表达式如下：

`nodename`	选取此节点的所有子节点。
`/`		从根节点选取。
`//`		从匹配选择的当前节点选择文档中的节点，而不考虑它们的位置。
`.`		选取当前节点。
`..`		选取当前节点的父节点。
`@`		选取属性。
####实例
	bookstore	选取 bookstore 元素的所有子节点。
	/bookstore	选取根元素 bookstore。

**注意**：假如路径起始于正斜杠( / )，则此路径始终代表到某元素的`绝对路径`！

	bookstore/book	选取属于 bookstore 的子元素的所有 book 元素。
	//book	选取所有 book 子元素，而不管它们在文档中的位置。
	bookstore//book	选择属于 bookstore 元素的后代的所有 book 元素，而不管它们位于 bookstore 之下的什么位置。
	//@lang	选取名为 lang 的所有属性。
<!-- more -->
### 谓语（Predicates）
谓语用来查找某个特定的节点或者包含某个指定的值的节点。
谓语被嵌在`方括号中`。
#### 实例
	/bookstore/book[1]	选取属于 bookstore 子元素的`第一个` book 元素。
	/bookstore/book[last()]	选取属于 bookstore 子元素的`最后一个` book 元素。
	/bookstore/book[last()-1]	选取属于 bookstore 子元素的`倒数第二个` book 元素。
	/bookstore/book[position()<3]	选取`最前面的两个`属于 bookstore 元素的子元素的 book 元素。
	//title[@lang]	选取`所有`拥有名为`lang的属性`的 title 元素。
	//title[@lang='eng']	选取`所有` title 元素，且这些元素拥有值为 eng 的 lang 属性。
	/bookstore/book[price>35.00]	选取 bookstore 元素的所有 book 元素，且其中的 price 元素的值须`大于` 35.00。
	/bookstore/book[price>35.00]/title	选取 bookstore 元素中的 book 元素的所有 title 元素，且其中的 price 元素的值须大于 35.00。
### 选取未知节点
XPath 通配符可用来选取未知的 XML 元素。
`*`	匹配任何元素节点。
`@*`	匹配任何属性节点。
`node()`	匹配任何类型的节点。
#### 实例

	/bookstore/*	选取 bookstore 元素的所有`子元素`。
	//*	选取文档中的`所有元素`。
	//title[@*]	选取所有带有属性的`title`元素。

### 选取若干路径
通过在路径表达式中使用`|运算符，您可以选取若干个路径。
#### 实例

	//book/title | //book/price	选取 book 元素的所有 title 和 price 元素。
	//title | //price	选取文档中的所有 title 和 price 元素。
	/bookstore/book/title | //price	选取属于 bookstore 元素的 book 元素的所有 title 元素，以及文档中所有的 price 元素。
