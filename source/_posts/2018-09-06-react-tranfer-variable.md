---
title: React 组件参数传递
date: 2018-09-06 00:12:36
tags: javacript/react
category: 技术随笔
---

![image.png](https://upload-images.jianshu.io/upload_images/170138-94373511a5284ef8.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 一、父组件向子组件传值
父组件向子组件传值直接使用`props`进行传值，比如下面`Root`想要传值给`Left`,父组件`Root`里面直接引用子组件`Left`，并且通过组件的属性`name`传递给子组件，子组件在自己的内部，直接使用`this.props.name`来获取传递过来的值。

<!--more -->
```js
class Left extends React.Component {
  construct(props){
    super(props);
  }
  
  render() {
    return <h1>Hello, {this.props.name}</h1>;
  }
}
class Root extends React.Component{
   construct(props){
    super(props);
   }

   greeting(msg){
      this.setState({
      msg
    });
  }
  
  render(){
    return (
    <div>
      <Left msg="I came From Left " />
    </div>
     )
    
  }
}

ReactDOM.render(
  <Root />,
  document.getElementById('root')
);
```
代码演示地址：https://codepen.io/javaor/pen/dqzRvQ
### 二、子组件向父组件传值
子组件向父组件与父组件给子组件传值类似，假如组件`Right`要传值给`Root`,
`Root`将传递一个函数`greeting`给子组件`Right`，子组件`Right`调用该函数，将想要传递的信息，作为参数，传递到父组件的作用域中。
函数将保障子组件`Right`在调用 greeting函数时，其内部 this 仍指向父组件。


```js

class Right extends React.Component {

componentDidMount() {   
    this.props.greeting('Hello From Right')
  }
  render() {
    return <h1>I'm right</h1>;
  }
}

class Root extends React.Component{

  state = {
    msg: ''
  };

   greeting(msg){
      this.setState({
      msg
    });
  }
  
  render(){
    return (
    <div>
      <p>Msg From Right: {this.state.msg}</p>
      <Right greeting={msg => this.greeting(msg)} />
    </div>
     )
  }
}

ReactDOM.render(
  <Root />,
  document.getElementById('root')
);
```
代码演示地址：https://codepen.io/javaor/pen/WgEOdG?editors=1011
###三、兄弟节点之间的传值
假设`Right`想要向`Left`传递参数，因为他们之间没有之间关联的节点，只有一个公共的父组件`Root`，所以只能通过`Right`先向`Root`传值，然后在通过props从`Root`向`Left`传值。基本第二个基本上一致，代码如下：

```js

class Left extends React.Component {

  render() {
    return <h1>Hello, {this.props.msg}</h1>;
  }
}

class Right extends React.Component {

componentDidMount() {   
    this.props.greeting('Hello From Right')
  }
  render() {
    return <h1>I'm right</h1>;
  }
}

class Root extends React.Component{

  state = {
    msg: ''
  };

   greeting(msg){
      this.setState({
      msg
    });
  }
  
  render(){
    return (
    <div>
      <Right greeting={msg => this.greeting(msg)} />
      <Left msg={this.state.msg}  />
    </div>
     )
  }
}

ReactDOM.render(
  <Root />,
  document.getElementById('root')
);
```




