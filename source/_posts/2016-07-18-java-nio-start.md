---
layout: post
title: Java NIO创建步骤
date: 2016-07-18
tags: NIO
category: java
---


NIO创建过程
一、打开ServerSocketChannel,用于监听客户端的连接

```java
ServerSocketChannel acceptSvr = ServerSocketChannel.open();
```
二、绑定监听端口，设置连接为非阻塞模式

```java
acceptSvr.socket().bind(new InetSocketAddress(InetAddress.getByName("IP"),port));
accptSvr.configureBlocking(false);
```
三、创建Reactor线程，创建多路复用器并启动线程

```java
Selector selector = Selector.open();
new Thread(new ReactorTask()).start();
```
<!-- more -->

四、将ServerSocketChannel 注册到Reactor线程的多路多路复用器Selector上，监听ACCEPT事件

```java
SelectionKey key = acceptorSvr.register(selector,SelectionKey.OP_ACCEPT,ioHandler);
```

五、多路复用器在线程run方法中无限循环体内轮询准备就绪的Key

```java
int num = seletor.select();
Set selectedKeys = selector.selectedKeys();
while(it.hasNext()){
    SelectionKey key = (SelectionKey)it.next();
    //处理IO事件
}
```

六、多路复用器监听到新的客户端接入，处理新的接入请求，完成TCP三次握手，简历物理链路

```java
SocketChannel channel = svrChannel.accpet();
```

七、设置客户端链路为非阻塞模式

```java
channel.configureBlocking(flase);
channel.socket().setReuseAddress(true);
```
八、将新接入的客户端连接注册到Reactor线程的多路复用器上，监听读操作，用来读取客户端发送的网络消息

```java
SelectionKey key = soccketChannel.register(selector,SelectionKey.OP_READ,ioHandler);

```
九、异步读取客户端请求消息到缓冲区

```java
int readNumber = channel.read(reaceivedBuffer);
```
十、对ByteBuffer进行编解码，如果有半包消息指针reset，继续读取后续保温，将解码成功的消息封装成task，投递到业务线程池中，进行业务逻辑编排。

```java
Object message = null;
while(buffer.hasRemain()){
    byteBuffer.mark();
    Object message = decode(byteBuffer);
    if(message == null){
        byteBuffer.reset();
        break;
    }
    messageList.add(message);
    if(!byteBuffer.hasRemain()){
        byteBuffer,clear();
    }else{
        byteBuffer.compact();
    }
    if(messageList != null & !messageList.isEmpty){
        for(Object messageE:messageList){
            handlerTask(messageE);
        }
    }

}
```

十一、将POJO对象encode 成ByteBuffer ,调用SocketChannel的异步write接口，将消息异步发送给客户端。

```java
socketChannel.write(buffer);
```
