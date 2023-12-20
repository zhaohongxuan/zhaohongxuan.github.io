---
title: 使用Templater在Obsidian中实现每日诗词
date: 2023-12-20 11:06:45
tags: 
 - obsidian
 - 古诗词
category: 效率工具
---

一直使用Templater的Quote功能，使用方法也很简单，直接使用`<% tp.web.daily_quote() %>` ，但是默认调用的接口是：https://api.quotable.io, 返回的英文的名言，如果想要中文的名言或者每日诗词等就没法做到。 好在Templater的作者还留了一个口子：用户脚本，用户可以自己按照[CommomJS](https://flaviocopes.com/commonjs/)的规范来编写自己的脚本，文档参考这里：[Templater User function](https://silentvoid13.github.io/Templater/user-functions/script-user-functions.html)，这里需要注意的是：**不支持第三方node module！！**

<!-- more -->

### 创建脚本

因此我们只需要调用一个今日诗词的接口就行了，这里选择了[今日诗词](https://v1.jinrishici.com/)的接口，接下来就是请求数据然后解析数据了。
然后由于obsidian的限制，我们不能直接引用第三方的node module，比如`node-fetch`，好在Templater暴露了obsidian自身的接口，接口都在`tp.obsidian`中，因此，我们可以利用Obsidian自身的`request`方法来调用古诗词的api返回我们自己想要的内容，下面是示例代码：

```js
async function daily_poem(tp) {
      const response = await tp.obsidian.request('https://v1.jinrishici.com/all/');
      const { content,origin,author } =  JSON.parse(response) ;
      return `>[!quote] \n ${content}  <cite style="text-align: right; display: block;" > —  ${author}·《${origin}》</cite>`
}
  
module.exports = daily_poem;
```

### 使用脚本

#### 保存脚本

复制上面的脚本代码保存为一个js文件，这里命名为`daily_poem.js`，并将脚本存放在Vault中的一个文件夹中，笔者设置的是：`Assets/Script`，你可以根据自己的实际需求设定，这个文件夹在下面使用的使用要用。
![](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/202312201206853.png)

#### 设定脚本所在的文件夹
![](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/202312201205855.png)

#### 在Daily Notes模板中使用

在自己的Daily Notes的模板中直接使用 `<% tp.user.daily_poem(tp) %>`即可使用，这里必须要传tp进去，因为tp是Templater的全局变量，如果不手动传入，就不能调用obsidian的request方法。
下面是我在Daily Notes中使用的效果：
![](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/202312201214674.png)

当然，除了调用现成的API处理json数据之外，如果访问的页面是原始HTML，还可以处理DOM元素，使用选择器来获取我们想要的数据，可玩性更高了。

## References
1. [使用脚本自定义用户函数](https://silentvoid13.github.io/Templater/user-functions/script-user-functions.html)
2.  [Obsidian内置函数](https://silentvoid13.github.io/Templater/internal-functions/internal-modules/obsidian-module.html)

