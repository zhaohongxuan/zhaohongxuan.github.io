---
layout: post
title:  "Redis 整合Spring"
keywords: "redis"
date: 2015-09-11
category: spring框架
tags: redis
---

Redis是一种性能非常高效的Key-Value数据库，在企业项目开发中应用广泛，因为一直用Spring，所以决定使用Spring支持的`spring-data-redis`,java中Redis有多种客户端，Spring推荐的是
`Jedis`，这篇文章就是基于Jedis的。

## SDR(Spring Data Redis)简介
**SDR(Spring Data Redis)**支持低层次的通过连接器`connector`连接到`Redis`，支持高层次的友好的模板类`RedisTemplate`,RedisTemplate是建立在低级别的connection基础之上。`RedisConnection`接收或返回字节数组
需要自身处理连接，比如关闭连接，而RedisTemplate负责处理串行化和反串行化，并且管理对连接进行管理。
`RedisTemplate`提供操作视图，比如(Bound)ValueOperations,(Bound)ListOperations,(Bound)SetOperations,(Bound)ZSetOperations,(Bound)HashOperations。RedisTemplate是线程安全的，能够用于多个实例中。
`RedisTemplate`默认选择`java-based`串行化,也可以切换为其它的串行化方式，或者设置`enabledDefaultSerializer`为`false`或者设置串行化器为null，则`RedisTemplate`用`raw byte arrays`表示数据。
SDR连接到`redis`通过`RedisConnectionFactory`来获得有效的`RedisConnection`。`RedisConnection`负责建立和处理和redis后端通信。`RedisConnection`提供`getNativeconnection`返回用来通信的底层`connection`。


## Maven的pom.xml文件配置
在`dependencies`中添加两个依赖，分别是`spring-data-redis`和`jedis`

```xml
 <dependency>
	        <groupId>org.springframework.data</groupId>
	        <artifactId>spring-data-redis</artifactId>
	        <version>1.4.2.RELEASE</version>
	    </dependency>
		<dependency>
		    <groupId>redis.clients</groupId>
		    <artifactId>jedis</artifactId>
		    <version>2.6.2</version>
		    <type>jar</type>
		    <scope>compile</scope>
		</dependency>

```
<!-- more -->

## Properties文件中配置Redis的基本参数

```java
# Redis config
redis.host=localhost
redis.port=6379
redis.password=
redis.maxIdle=300
redis.maxActive=600
redis.maxWait=1000
redis.testOnBorrow=true
```

## 配置`applicationContext.xml`
在`applicationContext.xml`S中配置`jedisConnFactory`和`jedisTemplate`，加载Properties的各个属性

```xml
<?xml version="1.0" encoding="UTF-8"?>

<beans xmlns="http://www.springframework.org/schema/beans"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:context="http://www.springframework.org/schema/context"
	xmlns:p="http://www.springframework.org/schema/p"
	xmlns:tx="http://www.springframework.org/schema/tx"
	xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
		http://www.springframework.org/schema/tx http://www.springframework.org/schema/tx/spring-tx-3.2.xsd
		http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context.xsd">
    
	<context:component-scan base-package="com.zeusjava.osf.model" />
	<context:component-scan base-package="com.zeusjava.osf.dao.impl" />
	<context:component-scan base-package="com.zeusjava.osf.service" />
	<context:component-scan base-package="com.zeusjava.osf.util" />
	<context:property-placeholder location="classpath:spring/property.properties"/>
	
	<bean id="jedisConnFactory" 
	    class="org.springframework.data.redis.connection.jedis.JedisConnectionFactory" 
	    p:usePool="true"
	    p:hostName="${redis.host}"
	    p:port="${redis.port}"
	    p:password="${redis.password}"/>
	
	<!-- redis template definition -->
	<bean id="redisTemplate" 
	    class="org.springframework.data.redis.core.RedisTemplate"
	    p:connectionFactory-ref="jedisConnFactory">

		<property name="keySerializer">
           <bean class="org.springframework.data.redis.serializer.StringRedisSerializer" />
        </property>  
        <property name="hashKeySerializer">  
           <bean class="org.springframework.data.redis.serializer.StringRedisSerializer" />
        </property>
	</bean>	
	 
	<bean id="transactionManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager" 
		p:dataSource-ref="dataSource"/>    
	<tx:annotation-driven transaction-manager="transactionManager" />
	
	
</beans>

```
## 在java类中使用Redis进行增删改查
下面是一个简单的查询的例子

```java
@Repository("userDao")
public class UserDAOImpl implements UserDAO{

	@Autowired
	@Qualifier("redisTemplate")
	private RedisTemplate<String, String> redisTemplate; 
	
	@Resource(name="redisTemplate")
	private HashOperations<String, String, Object> mapOps;
	
	
	public User getUserByID(int id) {
		String key = "user:"+id;
		Object obj = mapOps.get("user",key);
		User user = (User) obj;
		return user;
	}
}
```