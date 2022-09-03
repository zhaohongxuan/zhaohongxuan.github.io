---
title: Spring 事件驱动的原理
date: 2022-09-03 17:46
tags: [java,spring]
category: 源码解析
---


## Spring事件驱动

Spring 事件驱动的代码都位于spring-context 模块的event包中，主要包括：事件(Event)发布者() Publisher) ,订阅者(Listener)组成。

### 事件
ApplicationEvent 
java的所有事件对象一般都是java.util.EventObject的子类，Spring的整个继承体系如下:

![ApplicationEvent](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20220218175226.png)

<!-- more -->

### Publisher 发布者
#### ApplicationEventPublisher

AbstractApplicationContext实现了ApplicationEventPublisher接口 publishEvent


#### ApplicationEventMulticaster
ApplicationEventPublisher实际上正是将请求委托给ApplicationEventMulticaster来实现的。其继承体系:
![](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20220218181201.png)

### Listeners 监听者

所有的监听器是jdk EventListener的子类，这是一个mark接口。继承体系:

![](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20220218175429.png)

可以看出SmartApplicationListener和GenericApplicationListener是高度相似的，都提供了事件类型检测和顺序机制，而后者是从Spring4.2加入的，Spring官方文档推荐使用后者代替前者。

#### 初始化
前面说过AppjlicationEventPublisher是通过委托给ApplicationEventMulticaster实现的，所以refresh方法中完成的是对ApplicationEventMulticaster的初始化:

```java
// Initialize event multicaster for this context.
initApplicationEventMulticaster();
```

initApplicationEventMulticaster则首先在BeanFactory中寻找ApplicationEventMulticaster的bean，如果找到，那么调用getBean方法将其初始化，如果找不到那么使用SimpleApplicationEventMulticaster。

### ApplicationEventPublisher 接口

AbstractApplicationContext.publishEvent核心代码:

```java
protected void publishEvent(Object event, ResolvableType eventType) {
    getApplicationEventMulticaster().multicastEvent(applicationEvent, eventType);
}
```

SimpleApplicationEventMulticaster.multicastEvent:
```java
@Override
public void multicastEvent(final ApplicationEvent event, ResolvableType eventType) {
    ResolvableType type = (eventType != null ? eventType : resolveDefaultEventType(event));
    for (final ApplicationListener<?> listener : getApplicationListeners(event, type)) {
        Executor executor = getTaskExecutor();
        if (executor != null) {
            executor.execute(new Runnable() {
                @Override
                public void run() {
                    invokeListener(listener, event);
                }
            });
        } else {
            invokeListener(listener, event);
        }
    }
}

```

#### 监听器获取

获取当然还是通过beanFactory的getBean来完成的，值得注意的是Spring在此处使用了缓存(ConcurrentHashMap)来加速查找的过程。

#### 同步/异步

可以看出，如果executor不为空，那么监听器的执行实际上是异步的。那么如何配置同步/异步呢?

#### 全局
```xml
<task:executor id="multicasterExecutor" pool-size="3"/>
<bean class="org.springframework.context.event.SimpleApplicationEventMulticaster">
    <property name="taskExecutor" ref="multicasterExecutor"></property>
</bean>
```
task schema是Spring从3.0开始加入的，使我们可以不再依赖于Quartz实现定时任务，源码在org.springframework.core.task包下，使用需要引入schema：
```xml
xmlns:task="http://www.springframework.org/schema/task"
xsi:schemaLocation="http://www.springframework.org/schema/task http://www.springframework.org/schema/task/spring-task-4.0.xsd"

```

开启注解支持:
```xml
<!-- 开启@AspectJ AOP代理 -->  
<aop:aspectj-autoproxy proxy-target-class="true"/>  
<!-- 任务调度器 -->  
<task:scheduler id="scheduler" pool-size="10"/>  
<!-- 任务执行器 -->  
<task:executor id="executor" pool-size="10"/>  
<!--开启注解调度支持 @Async @Scheduled-->  
<task:annotation-driven executor="executor" scheduler="scheduler" proxy-target-class="true"/>  

```
在代码中使用示例:

```java
@Component  
public class EmailRegisterListener implements ApplicationListener<RegisterEvent> {  
    @Async  
    @Override  
    public void onApplicationEvent(final RegisterEvent event) {  
        System.out.println("注册成功，发送确认邮件给：" + ((User)event.getSource()).getUsername());  
    }  
}  

```


## References
1. https://www.iteye.com/blog/jinnianshilongnian-1902886
2. https://github.com/seaswalker/spring-analysis/blob/master/note/Spring.md#applicationeventmulticaster
