---
layout: post
title: 学习Java的NIO
date: 2016-02-28
tags: [java, nio]
category: java
---

重要的概念

## 什么是NIO?

NIO是从java 1.4 开始引入的一个新的 `IO API`。

Channel、Buffer、Selector是NIO的核心部分。

IO通过字节流和字符流操作数据，NIO基于通道(Channel)和缓冲区(Buffer)数据 
### Channel&Buffer

#### Channel
数据总是由通道到缓冲区（`Read`），或者由缓冲区到通道（`write`）

其中Channel的几个实现

	FileChannel
	DatagramChannel
	SocketChannel
	ServerSocketChannel
分别对应文件IO/UDP/TCP网络IO.

下面是一个简单的例子实现，从本地文件系统读取数据到Buffer中。
<!-- more -->

```java
 /**
     * Channel的使用
     */
    @Test
    public void fileChannelTest(){
        try {
            RandomAccessFile randomAccessFile = new RandomAccessFile("D:/nio.txt","rw");
            FileChannel fileChannel = randomAccessFile.getChannel();
            ByteBuffer byteBuffer =  ByteBuffer.allocate(100);
            int bytesRead = fileChannel.read(byteBuffer);
            while (bytesRead != -1){
                System.out.println("Read:"+bytesRead);
                byteBuffer.flip();
                while(byteBuffer.hasRemaining()){
                    System.out.print((char)byteBuffer.get());
                }
                byteBuffer.clear();
                bytesRead = fileChannel.read(byteBuffer);
            }
            randomAccessFile.close();
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
```


#### Buffer
Buffer的几个重要实现
	ByteBuffer
	CharBuffer
	DoubleBuffer
	FloatBuffer
	IntBuffer
	LongBuffer
	ShortBuffer

可以通过这些Buffer向Channel数据，或者从Channel读取数据。

使用Buffer来读写数据的步骤

    写入数据到Buffer
    调用flip()方法
    从Buffer中读取数据  
    调用clear()方法或者compact() 方法

clear()方法会清空整个缓冲区，而compact会清空已经读取过的数据。

![buffer属性](http://i12.tietuku.com/bfa5f260b1a477ff.png)

Buffer的三个属性，position,limit,capacity

capacity 是缓冲区的大小
position

写数据时：position表示是当前位置，当前位置写入完毕，position移动到下一个可写的位置， 范围为0~capacity-1.
读数据时：position表示当前位置，当前位置读取完毕，position移动到下一个可读位置。

limit 
limit表示的是最多能够读取的或者写入的数据的大小。
写模式：limit等于capacity
读模式：limit等于读模式的position

分配buffer
使用`allocate()`方法来分配Buffer.例如分配一个100字节长的ByteBuffer缓冲区:
```java
ByteBuffer buf = ByteBuffer.allocate(100);
```

向Buffer中写入数据
1.从channel中读取到Buffer中

    int bytesRead = inChannel.read(buffer);
2.直接向buffer中put
    buffer.put(100);
    
从Buffer中读取数据

1.从Buffer中写数据到Channel
    int bytesRead = inChannel.write(buffer);
2.使用get()方法从Buffer中读取数据
    int bytes = buffer.get();

rewind()方法

rewind()方法将position设置为0

    

#### Selector
![Selector](http://i4.tietuku.com/8793cae275479b76.png)

Selector最重要的特点就是他允许`单线程`处理多个Channel.

1.创建Selector

使用Selector的open()方法创建一个Selector

```java
Selector selector = Selector.open();
```
2.注册Channel

将Channel绑定到一起，使用channel.register()来实现。

```java
channel.configureBlocking(false);
Selector key = channel.register(selector,Selectionkey.OP_READ);

```
configureBlocking是设置Channel为非阻塞模式。FileChannel不能和Selector绑定，因为FileChannel没有阻塞模式。

3.SelectionKey

SelectorKey是一个抽象类 包含了

	interest集合
	ready集合
	Channel
	Selector

1.interest集合
通过Selector监听Channel时对什么事件感兴趣，可以监听4中类型的事件，分别是`OP_CONNECT`,`OP_ACCEPT`,`OP_READ`,`OP_WRITE`。

```java
	int interestSet = selectionKey.interestOps();  
    boolean isInterestedInAccept  = (interestSet & SelectionKey.OP_ACCEPT) == SelectionKey.OP_ACCEPT；  
	boolean isInterestedInConnect = interestSet & SelectionKey.OP_CONNECT;  
	boolean isInterestedInRead    = interestSet & SelectionKey.OP_READ;  
	boolean isInterestedInWrite   = interestSet & SelectionKey.OP_WRITE;
```

通过`&`来和SelectorKey常量确定某个事件是在interest集合中。

2.ready集合
  ready集合是Channel已经准备就绪的集合。

```java
selectionKey.isAcceptable();
selectionKey.isConnectable();
selectionKey.isReadable();
selectionKey.isWritable();
```

3.通过Selector的select()方法选择Channel
使用selector的select()方法来返回已经就绪的通道。
select()方法会一直阻塞到至少有一个通道在事件上注册了。
select()方法返回的int值表示已经有多少个通道已经就绪了 
4.调用过select()方法后，如果返回的int值大于1则表示已经有至少一个通道已经就绪了，这个时候可以调用Selector的selectedKeys()方法来选择已经就绪的Channel.

```java
Set selectKeys = selector.selectedKeys();
```
遍历这个集合来访问就绪的通道。

```java
Set<SelectionKey> selectedKeys = selector.selectedKeys();
Iterator<SelectionKey> keyIterator = selectedKeys.iterator();
while(keyIterator.hasNext()) {

    SelectionKey key = keyIterator.next();
    if(key.isAcceptable()) {
    } else if (key.isConnectable()) {
    } else if (key.isReadable()) {
    } else if (key.isWritable()) {ng
    }
    keyIterator.remove();
}
```