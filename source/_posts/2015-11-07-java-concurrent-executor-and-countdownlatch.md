---
layout: post
title:  "Executor任务执行框架的应用"
keywords: "executor"
date: 2015-11-09
category: java
tags: java
---

最近一段时间没有写东西了，看大名鼎鼎的`Brian Goetz`写的`Java Concurrency in Practice`时候，看到任务执行框架`Executor Framework`
的时候，觉得纸上得来终觉浅，索性写点东西加深一下印象。

在JDK1.5中，Java平台中增加了一个并发包`java.util.concurrent`，这个包中包含了Executor Framework，而且还包含了很多并发包，比如并发
HashMap`ConcurrentHashMap`、阻塞队列`BlockQueue`、栅栏的实现`CyclicBarrier`、信号量`Semaphore`、异步任务`FutureTask`等等。
在处理多线程任务的时候，使用Executor和task要`优于`使用线程,这也不是我说的，是Effect Java的作者 `Joshua Bloach`说的，下面来阐述一下
为什么。

## 并发任务执行
当要执行一个并发任务的时候，通常有两种方式，一种是`串行`的处理方式，一种是`并行`的处理,显然，串行的方式只能一次处理一个任务，当程序在执行
当前的任务的时候，就说明接下来到来的任务请求都要等待当前的任务执行完毕才能获得CPU去执行任务，这种方式虽然不会犯错，但是效率太低。
那么，如果每一个任务到来都分配一个新的任务呢，这种方式貌似很好，`但是`：

如果任务请求量非常大的时候会出现一定的问题，因为它没有限制可以创建的线程的`数量`.

### 线程生命周期的开销很高
  线程的创建和销毁不是没有代价的,根据平台的不同，开销不同，但是不要忘记，线程的创建是需要时间的。
### 活跃的线程会消耗系统资源
  活跃的线程很消耗系统资源，尤其是内存，如果可运行的线程数量多于处理器核心数，那么多余的线程将闲置，但是闲置的线程仍然是消耗系统资源的，尤其
  是内存，给GC回收垃圾带来压力，而且线程间在进行竞争的时候也会消耗大量的资源
### 平台可创建的线程数量是有限的
  也就是说，如果创建的线程超出了平台的限制那么，JVM就可能抛出`OutofMemoryError`的异常

<!-- more -->

## 线程池

和数据库连接池相似，线程池指的是一组`同构`工作线程的资源池，线程池与工作队列 Work Queue密切相关
线程池中的线程的任务很简单：从`工作队列`（Work Queue）中取出一个任务，执行任务，人后返回线程池，等待执行下一个任务

线程池比为每一个任务分配一个线程要有更多优势，通过`重用`现有线程而不是重新创建线程，可以处理多个任务请求的时候，分摊在线程创建和销毁的过程中产生的
巨大开销。
而且，当请求到达的时候，线程池中的线程也已经就绪，不需要在创建线程而延迟响应的时间，提高了响应性。通过调整线程池的大小，可以创建足够多的线程来让CPU
保持忙碌的状态。

创建线程池有很多种方式，

通过调用Executors的工厂方法可以创建线程池，
例如：
`newFixThreadPool` 用来创建一个固定长度的线程池
`newCacheThreadPool` 用来创建一个可缓存的线程池
`newSingleThreadPool` 创建一个单线程的线程池

## Executor框架

任务和线程不同，任务是一组`逻辑工作单元`，而线程是使任务`异步执行`的机制。
在Java类库中，任务执行的主要抽象不是Thread而是Executor

Executor接口定义如下

```java
public interface Executor {

    /**
     * Executes the given command at some time in the future.  The command
     * may execute in a new thread, in a pooled thread, or in the calling
     * thread, at the discretion of the <tt>Executor</tt> implementation.
     *
     * @param command the runnable task
     * @throws RejectedExecutionException if this task cannot be
     * accepted for execution.
     * @throws NullPointerException if command is null
     */
    void execute(Runnable command);
}

```

虽然Executor只是一个简单的接口，但是却为灵活而强大的异步任务执行框架提供了基础。其中Runnable表示可以执行的任务
Executor的实现还提供了对生命周期的支持。

Executor基于 生产者-消费者模式，提交任务到线程池相当于生产者，执行任务相当于消费者。

## 闭锁

闭锁是一种同步工具类，作用是延迟线程的进度直到其到达终止状态。
###举个栗子：
闭锁的作用相当于一扇门，当闭锁到达结束状态之前，这扇门一直是关闭的，并且没有`任何线程`能通过,当闭锁到达技术状态的时候，这扇门会打开而让`所有`
线程通过。
当闭锁到达结束状态的时候，这扇门会`永远`保持`打开`状态。
闭锁的作用是，可以用来确保某些活动直到其他活动`都完成`后才执行。

## 实践

纸上得来终觉浅，写了代码就知道为什么了。

还比如上一次写的爬虫，如果单线程抓取的话，只能首先抓取首页，然后解析其中的图片链接，然后再下载图片，这样效率无疑是很低的，现在
我加上线程池。

### 建立工作队列
一个是抓取页面的阻塞队列`naviQueue`,一个是抓取页面上的图片url的阻塞队列`imgQueue`

```java
    // 定义一个页面导航的队列
	final BlockingQueue<String> naviQueue = new LinkedBlockingQueue<String>(3);
	// 定义一个图片网址的队列
	final BlockingQueue<String> imgQueue = new LinkedBlockingQueue<String>(100);
```

### 创建线程池
线程池的大小是下载图片线程和解析页面线程的数量之和

```java
final int DOWNLOAD_THREAD = 30;
final int PAGE_THREAD = 2;
final ExecutorService exec = Executors.newFixedThreadPool((DOWNLOAD_THREAD + PAGE_THREAD));
```

### 定义闭锁
定义一个开始倒数锁和一个结束倒数锁

```java
	// 定义一个开始的倒数锁
	final CountDownLatch begin = new CountDownLatch(1);
	// 定义一个结束的倒数锁
	final CountDownLatch end = new CountDownLatch((DOWNLOAD_THREAD + PAGE_THREAD));
```

其中，开始倒数锁的作用是，等待`主线程`加载首页信息，加载完成后才能继续抓取`下一页`的URL，所以开始倒数锁的初始大小为1，等初始化线程一旦执行完毕之后，
立刻释放所有的线程，开始执行并行任务。

结束倒数锁的作用是，主线程能够等待所有的工作线程依次执行完成，而不是顺序的等待每个线程执行完毕。

### 初始化线程

```java
	public ThreadPoolMananger() {
		int i = 1;
		for (; i <= PAGE_THREAD; i++) {
			exec.submit(new PageThread(i, begin, end));
		}
		for (; i <= (DOWNLOAD_THREAD + PAGE_THREAD); i++) {
			exec.submit(new ImageThread(i, "D:\\pictures", begin, end));
		}
		HtmlParser parser = new HtmlParser();
		SimpleHttpClient client = new SimpleHttpClient();
		parser.setHtml(client.get("http://jandan.net/pic"));
		System.out.println("====开始抓取首页");
		try {
			naviQueue.put(parser.getPageNavi());
			parser.handleImgs(imgQueue);
		} catch (InterruptedException e) {
		}
		client.close();
		System.out.println("首页结束，开始执行多线程抓取");
		begin.countDown();
	}
```

构造器中初始化了页面抓取线程和一些下载图片的线程到线程池中，然后开始执行首页的抓取，等待首页抓取完毕之后，begin.coutDown(),这时候`开始门`
的大小为0，这时候会释放所有的工作线程，开始执行多线程的抓取工作。

### 页面处理线程

页面抓取线程在初始化主线程执行完毕之后开始执行，从页面URL队列`naviQueue`中取出队列头部的url，使用Jsoup进行解析，得到本页面所有的`图片url`并添加到待处理
的图片URL队列`imgQueue`中然后得到`下一页`的链接URL，加入`naviQueue`中，如果在解析的过程中发现，Jsoup解析的下一页为空，那么就说明已经解析完成了。

```java
class PageThread implements Runnable {
		private final CountDownLatch startSignal;
		private final CountDownLatch stopSignal;
		private int index;
		public PageThread(int index, CountDownLatch start, CountDownLatch end) {
			this.startSignal = start;
			this.stopSignal = end;
			this.index = index;
		}
		@Override
		public void run() {
			try {
				startSignal.await();
			} catch (Exception e) {
			}
			String html = "";
			String url = "";
			int left = 0;
			HtmlParser parser = new HtmlParser();
			SimpleHttpClient client = new SimpleHttpClient();
			while (true) {
				try {
					url = naviQueue.take();
					left = naviQueue.size();
					if ("".equals(url)) {
						// 把结束的标志放回去，其他的线程也要调用
						naviQueue.put("");
						break;
					}
				} catch (Exception e) {
					System.err.println("[" + index + "]:" + e.getMessage());
				}
				System.out.println("[" + index + "][页面left:" + left
						+ "]线程抓取html-->" + url);
				try {
					html = client.get(url);
				} catch (Exception e1) {
				}
				parser.setHtml(html);
				String next = parser.getPageNavi();
				try {
					if (next == null) {
						naviQueue.put("");
						parser.handleImgs(imgQueue); // 在图片队列的最后也放上一个""作为结束的标志
						imgQueue.put("");
					} else {
						naviQueue.put(next);
						parser.handleImgs(imgQueue);
					}
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
			}
			client.close();
			stopSignal.countDown();
		}
	}
```

### 图片下载线程

图片线程的主要任务就是下载所有的图片并保存到本地。

```java
	class ImageThread implements Runnable {
		private final CountDownLatch startSignal;
		private final CountDownLatch stopSignal;
		private int threadIdx;
		private String dest;
		public ImageThread(int index, String dest, CountDownLatch start,
				CountDownLatch end) {
			this.threadIdx = index;
			this.dest = dest;
			this.startSignal = start;
			this.stopSignal = end;
		}
		@Override
		public void run() {
			try {
				// 等待初始的线程结束
				startSignal.await();
			} catch (Exception e) {
			}
			System.out.println("[" + threadIdx + "]线程开始");
			SimpleHttpClient client = new SimpleHttpClient();
			String picurl = "";
			int left = 0;
			// 这个线程不断的从图片队列里面取出图片的地址
			while (true) {
				// 取出一个图片地址
				try {
					picurl = imgQueue.take();
					left = imgQueue.size();
				} catch (InterruptedException e1) {
					System.err
							.println("[" + threadIdx + "]:" + e1.getMessage());
				}
				if ("".equals(picurl)) {
					try {
						// 结束标志，丢回去，其他的线程要根据这个判断结束
						imgQueue.put("");
					} catch (Exception e) {
						e.printStackTrace();
					}
					// 如果说，取到图片地址为空而且页面的已经解析完毕，这个就应该要结束了。
					break;
				}
				try {
					System.out.println("[" + threadIdx + "][图片left:" + left
							+ "]线程开始抓取image-->" + picurl);
					client.downloadFile(picurl, dest);
				} catch (Exception e) {
					System.err.println("[" + threadIdx + "]:" + e.getMessage());
				}
			}
			client.close();
			stopSignal.countDown();
		}
	}
```

