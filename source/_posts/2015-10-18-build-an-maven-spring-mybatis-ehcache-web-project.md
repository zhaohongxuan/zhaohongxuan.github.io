---
layout: post
title:  "使用Maven搭建Spring+SpringMVC+Mybatis+ehcache项目"
keywords: "搭建框架"
date: 2015-10-18
category: web开发
tags: [spring ,maven ,mybatis, ehcache]
---



搭建Spring不用说肯定是必须的，前端使用SpringMVC 而不使用Struts2是因为SpringMVC的效率要比struts2要高很多，虽然struts2有丰富的标签可以使用，
使用Mybatis是因为以后项目要做报表模块，Mybatis使用SQL Mapping的方式很容易操作数据库。

这里我们使用intellij idea来做我们的开发工具，废话不多说，开干。
框架的版本是

Spring 3.2.8.RELEASE
Spring MVC 3.2.8.RELEASE
mybatis 3.2.8


##  创建Maven Web项目
（略）
本项目中用的maven是 3.3.3版本的，要求jdk版本是1.7之后的

##  在pom.xml中加入项目依赖的jar包

项目包依赖关系如下：
![依赖关系](../../../spring-mvc-mybatis-diagram.png)

pom文件如下：

```xml
   <dependencies>
   
       <!-- Spring MVC -->
       <dependency>
           <groupId>org.springframework</groupId>
           <artifactId>spring-webmvc</artifactId>
           <version>${spring-framework.version}</version>
       </dependency>
   
       <!-- Spring jdbc -->
       <dependency>
           <groupId>org.springframework</groupId>
           <artifactId>spring-jdbc</artifactId>
           <version>${spring-framework.version}</version>
       </dependency>
   
       <dependency>
           <groupId>org.springframework</groupId>
           <artifactId>spring-test</artifactId>
           <version>${spring-framework.version}</version>
           <scope>test</scope>
       </dependency>
   
       <dependency>
           <groupId>org.springframework</groupId>
           <artifactId>spring-web</artifactId>
           <version>${spring-framework.version}</version>
       </dependency>
   
   
       <!-- Logging with SLF4J & Log4j -->
       <dependency>
           <groupId>org.slf4j</groupId>
           <artifactId>slf4j-log4j12</artifactId>
           <version>1.7.12</version>
       </dependency>
   
       <!-- mybatis & mysql -->
       <dependency>
           <groupId>org.mybatis</groupId>
           <artifactId>mybatis-spring</artifactId>
           <version>1.2.2</version>
       </dependency>
   
       <dependency>
           <groupId>org.mybatis</groupId>
           <artifactId>mybatis</artifactId>
           <version>3.2.8</version>
       </dependency>
   
       <dependency>
           <groupId>org.mybatis</groupId>
           <artifactId>mybatis-ehcache</artifactId>
           <version>1.0.0</version>
       </dependency>
   
       <dependency>
           <groupId>org.ehcache</groupId>
           <artifactId>ehcache</artifactId>
           <version>3.0.0.m3</version>
       </dependency>
   
       <dependency>
           <groupId>mysql</groupId>
           <artifactId>mysql-connector-java</artifactId>
           <version>5.1.34</version>
       </dependency>
   
       <dependency>
           <groupId>commons-dbcp</groupId>
           <artifactId>commons-dbcp</artifactId>
           <version>1.4</version>
       </dependency>
       <!--Test-->
       <dependency>
           <groupId>junit</groupId>
           <artifactId>junit</artifactId>
           <version>${junit.version}</version>
           <scope>test</scope>
       </dependency>
  
   </dependencies>

```
<!-- more -->


## 添加日志的支持
日志我们使用slf4j，并用log4j来实现
SLF4J不同于其他日志类库，与其它有很大的不同。SLF4J(Simple logging Facade for Java)不是一个真正的日志实现，而是一个抽象层（ abstraction layer），它允许你在后台使用任意一个日志类库。
SLF4J还有很多优点，具体可以参考 http://javarevisited.blogspot.com/2013/08/why-use-sl4j-over-log4j-for-logging-in.html
日志的实现类还是用熟悉的log4j，先要在项目的pom.xml文件中加入日志的支持

```xml
        <!-- Logging with SLF4J & Log4j -->
        <dependency>
            <groupId>org.slf4j</groupId>
            <artifactId>slf4j-log4j12</artifactId>
            <version>1.7.12</version>
        </dependency>
```

配置很简单,log4j的详细配置可以参考log4j官网

log4j.properties

```html
log4j.rootLogger=INFO,Console,File
log4j.appender.Console=org.apache.log4j.ConsoleAppender
log4j.appender.Console.Threshold = DEBUG
log4j.appender.Console.layout=org.apache.log4j.PatternLayout
log4j.appender.Console.layout.ConversionPattern=%d %p [%c]  - %m%n


log4j.appender.A2=org.apache.log4j.DailyRollingFileAppender
log4j.appender.A2.File=${catalina.home}/logs/
log4j.appender.A2.Append=false
log4j.appender.A2.DatePattern='-'yyyy-MM-dd'.log'
log4j.appender.A2.layout=org.apache.log4j.PatternLayout
log4j.appender.A2.layout.ConversionPattern=%d %p [%c] - %m%n
```

## 整合Spring+Mybatis
把Spring和Mybatis的jar包都引入之后就可以整合这两个框架了
先看下项目的相关配置文件
其中gererator.properties和generatorConfig.xml是用来根据数据库自动生成mapper接口，实体，以及映射文件的
mybatis-config是mybatis的一些映射的相关配置，比如mapper，cache等
spring-mybatis是自动扫描，自动装配mapper以及datasource，sqlSessionFactory等配置

这些会在接下来详细说明

![配置文件](http://i13.tietuku.com/477850fbcc2c12fa.png)


### JDBC配置文件

```html
jdbc.driverClassName=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://localhost:3306/test
jdbc.username=root
jdbc.password=root
```


### 创建spring-mybatis.xml
创建spring-mybatis.xml来配置mybatis的一些信息，主要是数据源、事务、自动扫描、自动注入等功能

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
	   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	   xmlns:p="http://www.springframework.org/schema/p"
	   xmlns:tx="http://www.springframework.org/schema/tx"
	   xmlns:context="http://www.springframework.org/schema/context"
	   xmlns:aop="http://www.springframework.org/schema/aop"
	   xsi:schemaLocation="http://www.springframework.org/schema/beans
    http://www.springframework.org/schema/beans/spring-beans-3.0.xsd
    http://www.springframework.org/schema/aop http://www.springframework.org/schema/aop/spring-aop-3.0.xsd
    http://www.springframework.org/schema/tx
    http://www.springframework.org/schema/tx/spring-tx-3.0.xsd
    http://www.springframework.org/schema/context
    http://www.springframework.org/schema/context/spring-context-3.0.xsd">
	<!-- enable component scanning -->
	<context:component-scan base-package="com.zeusjava" />

	<!-- enable autowire -->
	<context:annotation-config />

	<!-- enable transaction demarcation with annotations -->
	<tx:annotation-driven />

	<!-- 读取mysql jdbc的配置-->
	<bean id="propertyConfigurer"
		  class="org.springframework.beans.factory.config.PropertyPlaceholderConfigurer">
		<property name="location" value="classpath:jdbc.properties" />
	</bean>
	<!-- 配置数据源，从上面配置文件读取-->
	<!-- 数据源 -->
	<bean id="dataSource" class="org.apache.commons.dbcp.BasicDataSource">
		<property name="driverClassName" value="${jdbc.driverClassName}" />
		<property name="url" value="${jdbc.url}" />
		<property name="username" value="${jdbc.username}" />
		<property name="password" value="${jdbc.password}" />
		<property name="initialSize" value="${jdbc.initialSize}" />
		<property name="maxActive" value="${jdbc.maxActive}" />
		<property name="maxIdle" value="${jdbc.maxIdle}" />
		<property name="defaultAutoCommit" value="${jdbc.defaultAutoCommit}" />
		<property name="removeAbandoned" value="true" />
		<property name="removeAbandonedTimeout" value="${jdbc.removeAbandonedTimeout}" />
		<property name="logAbandoned" value="${jdbc.logAbandoned}" />
		<!--主动检测连接池是否有效-->
		<property name="testWhileIdle"  value="${jdbc.testWhileIdle}" />
		<property name="validationQuery" value="${jdbc.validationQuery}" />
		<property name="timeBetweenEvictionRunsMillis"  value="${jdbc.timeBetweenEvictionRunsMillis}" />
		<property name="numTestsPerEvictionRun" value="${jdbc.numTestsPerEvictionRun}" />
	</bean>

	<bean id="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean">
		<property name="dataSource" ref="dataSource"/>
		<!-- 配置扫描Domain的包路径 -->
		<property name="typeAliasesPackage" value="com.zeusjava.kernel.entity"/>
		<!-- 配置mybatis配置文件的位置 -->
		<property name="configLocation" value="classpath:mybatis-config.xml"/>
		<!-- 配置扫描Mapper XML的位置 -->
		<property name="mapperLocations" value="classpath*:com/zeusjava/kernel/mapper/*.xml"/>
	</bean>

	<!-- 配置扫描Mapper接口的包路径 -->
	<bean class="org.mybatis.spring.mapper.MapperScannerConfigurer">
		<property name="basePackage" value="com.zeusjava.kernel.dao"/>
	</bean>
</beans>
```

### 创建数据库表

```sql

  CREATE TABLE `user` (  
  `id` int(11) NOT NULL AUTO_INCREMENT,  
  `user_name` varchar(40) NOT NULL,  
  `password` varchar(255) NOT NULL,  
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;  
  
  
insert  into `user`(`id`,`user_name`,`password`) values (1,'赵宏轩','123456');  
```

### 创建User的Mapping映射文件,User实体和Mapper接口

#### 在pom.xml中添加mybatis-generator-maven-plugin插件

```xml
  <build>
    <finalName>HelloSSM</finalName>
    <plugins>
      <plugin>
        <groupId>org.mybatis.generator</groupId>
        <artifactId>mybatis-generator-maven-plugin</artifactId>
        <version>1.3.2</version>
        <configuration>
          <verbose>true</verbose>
          <overwrite>true</overwrite>
        </configuration>
      </plugin>
    </plugins>
  </build>
``
`

#### 在maven项目下的src/main/resources 目录下建立名为 generatorConfig.xml的配置文件以及和generator有关的属性文件，作为mybatis-generator-maven-plugin 插件的执行目标

![目录结构](http://i13.tietuku.com/274205a36b4c55d5.png)
 generatorConfig.xml

 ```xml
 <?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE generatorConfiguration
        PUBLIC "-//mybatis.org//DTD MyBatis Generator Configuration 1.0//EN"
        "http://mybatis.org/dtd/mybatis-generator-config_1_0.dtd">
<generatorConfiguration>
    <!--导入属性配置 -->
    <properties resource="generator.properties"></properties>
    <!--指定特定数据库的jdbc驱动jar包的位置 -->
    <classPathEntry location="${jdbc.driverLocation}"/>
    <context id="default" targetRuntime="MyBatis3">
        <!-- optional，旨在创建class时，对注释进行控制 -->
        <commentGenerator>
            <property name="suppressDate" value="true" />
        </commentGenerator>
        <!--jdbc的数据库连接 -->
        <jdbcConnection driverClass="${jdbc.driverClassName}" connectionURL="${jdbc.url}" userId="${jdbc.username}" password="${jdbc.password}">
        </jdbcConnection>
        <javaTypeResolver >
            <property name="forceBigDecimals" value="false" />
        </javaTypeResolver>
        <javaModelGenerator targetPackage="com.zeusjava.kernel.entity" targetProject="src/main/java">
            <!-- 是否对model添加 构造函数 -->
            <property name="constructorBased" value="true"/>
            <!-- 是否允许子包，即targetPackage.schemaName.tableName -->
            <property name="enableSubPackages" value="false"/>
            <!-- 建立的Model对象是否 不可改变  即生成的Model对象不会有 setter方法，只有构造方法 -->
            <property name="immutable" value="true"/>
            <property name="trimStrings" value="true"/>
        </javaModelGenerator>

        <!--Mapper映射文件生成所在的目录 为每一个数据库的表生成对应的SqlMap文件 -->
        <sqlMapGenerator targetPackage="com.zeusjava.kernel.mapper" targetProject="src/main/java">
            <property name="enableSubPackages" value="false"/>
        </sqlMapGenerator>

        <javaClientGenerator targetPackage="com.zeusjava.kernel.dao" targetProject="src/main/java" type="MIXEDMAPPER">
            <property name="enableSubPackages" value=""/>
            <property name="exampleMethodVisibility" value=""/>
            <property name="methodNameCalculator" value=""/>
            <property name="rootInterface" value=""/>
        </javaClientGenerator>

        <table tableName="user"
               domainObjectName="User"
               enableCountByExample="false"
               enableUpdateByExample="false"
               enableDeleteByExample="false"
               enableSelectByExample="false"
               selectByExampleQueryId="false">

        </table>
    </context>
</generatorConfiguration>
 ```

 还有与之相关联的generator.properties文件

 ```html
jdbc.driverLocation=D:\\idea\\maven\\mysql\\mysql-connector-java\\5.1.29\\mysql-connector-java-5.1.29.jar
jdbc.driverClassName=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://localhost:3306/test
jdbc.username=root
jdbc.password=root

 ```

#### 在Intellij IDEA添加一个“Run运行”选项，使用maven运行mybatis-generator-maven-plugin插件
1).点击Run,选择Edit Configurations
![运行插件](http://i13.tietuku.com/9a550cf8567c13e0.png)
2).点击左上角的`+`，选择`maven`
![运行插件](http://i13.tietuku.com/659c0c57ae9c14a8.png)
3).输入name,选择Working directory,Command line 填上`mybatis-generator:generate -e`
![运行插件](http://i13.tietuku.com/1debbb8cf435b32b.png)

#### 点击运行查看结果
运行插件控制台如果打印build Success 就说明成功了
![运行插件](http://i13.tietuku.com/3b215a8a2b76c929.png)
会在指定目录产生三个文件，分别是`实体`，`Mapper接口`，`Mapping配置文件`
![运行插件](http://i13.tietuku.com/aa715f1fc59c8fbf.png)

### 创建mybatis-config.xml配置文件

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE configuration
        PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
       <settings>
              <setting name="cacheEnabled" value="false"/>
              <setting name="lazyLoadingEnabled" value="true"/>
              <setting name="aggressiveLazyLoading" value="false"/>
              <setting name="localCacheScope" value="STATEMENT"/>
              <setting name="multipleResultSetsEnabled" value="true"/>
              <setting name="useColumnLabel" value="true"/>
              <setting name="defaultStatementTimeout" value="25000"/>
              <setting name="mapUnderscoreToCamelCase" value="true"/>
              <!-- 是否使用插入数据后自增主键的值，需要配合keyProperty使用 -->
              <setting name="useGeneratedKeys" value="true"/>
       </settings>

       <typeAliases>
              <typeAlias alias="User" type="com.zeusjava.kernel.entity.User" />
       </typeAliases>

       <mappers>
              <!--<mapper resource="com/zeusjava/kernel/mapper/UserMapper.xml"/>-->
              <!--<mapper class="com.zeusjava.kernel.dao.UserMapper"/>-->
              <!--<mapper url="file:///D:/idea/HelloSSM/src/main/java/com/zeusjava/kernel/mapper/UserMapper.xml"/>-->
              <package name="com.zeusjava.kernel.dao"/>
              <!--<mapper class="com.zeusjava.kernel.dao.UserMapper"/>-->

       </mappers>
</configuration>
```
其中最后的mapper有四种配置方式，但是，在我的电脑上只有使用url的方式才行，不知道是怎么回事，待查询。

### 建立Service接口和实现类

IUserService.java代码如下

```java
package com.zeusjava.kernel.service;

import com.zeusjava.kernel.entity.User;

/**
 * Created by LittleXuan on 2015/10/17.
 */
public interface IUserService {
    public User getUserById(int userId);
}

```

UserServiceImpl.java的代码如下

```java

package com.zeusjava.kernel.service.impl;

import com.zeusjava.kernel.dao.UserMapper;
import com.zeusjava.kernel.entity.User;
import com.zeusjava.kernel.service.IUserService;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;

/**
 * Created by LittleXuan on 2015/10/17.
 */
@Service("userService")
public class IUserServiceImpl implements IUserService {
    @Resource
    private UserMapper userMapper;

    @Override
    public User getUserById(int userId) {
        return this.userMapper.selectUserByUserId(userId);
    }
}

```

### 建立测试类

```java
import com.zeusjava.kernel.entity.User;
import com.zeusjava.kernel.service.IUserService;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import javax.annotation.Resource;

/**
 * Created by LittleXuan on 2015/10/17.
 */
@RunWith(SpringJUnit4ClassRunner.class)     //表示继承了SpringJUnit4ClassRunner类
@ContextConfiguration(locations = {"classpath:conf/spring/beans-mybatis.xml"})
public class SSMTest {
    private static Logger logger = LoggerFactory.getLogger(SSMTest.class);

    @Resource
    private IUserService userService = null;


    @Test
    public void test1() {
        User user = userService.getUserById(1);
        logger.info("姓名："+user.getUserName());
    }
}

```

运行单元测试，结果如下，说明spring和mybatis的整合已经完成。
![运行结果](http://i11.tietuku.com/7bd3219c19d37e95.png)

## 和SpringMVC整合
和Spring MVC的整合就简单的多了，只需要添加一个Spring MVC配置文件，和配置一下Web.xml就行了，我在前面的博客写过一篇文章，请戳 [Maven整合Spring MVC搭建笔记-ZeusJava Blog](http://zeusjava.com/2015/09/12/maven-springmvc-demo)
###1.配置Spring MVC 配置文件zeusjava-servlet.xml
![spring mvc ](http://i11.tietuku.com/81c60aab101c6fef.png)
在配置文件里主要配置 `自动扫描控制器`，`视图解析器`，`注解`


```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:p="http://www.springframework.org/schema/p"
	xmlns:context="http://www.springframework.org/schema/context"
	xsi:schemaLocation="
	       http://www.springframework.org/schema/beans 
           http://www.springframework.org/schema/beans/spring-beans-3.0.xsd
           http://www.springframework.org/schema/context
           http://www.springframework.org/schema/context/spring-context-3.0.xsd
  ">
    <!-- 激活利用注解进行装配 -->
	<context:annotation-config />
           
	<!-- ① ：对 web 包中的所有类进行扫描，以完成 Bean 创建和自动依赖注入的功能 -->
    <context:component-scan base-package="com.zeusjava.web.controller"/>

    <!-- ② ：启动 Spring MVC 的注解功能，完成请求和注解 POJO 的映射 --> 
    <bean class="org.springframework.web.servlet.mvc.annotation.AnnotationMethodHandlerAdapter"/>
    
    <!--  ③ ：对模型视图名称的解析，即在模型视图名称添加前后缀 -->
    <bean class="org.springframework.web.servlet.view.InternalResourceViewResolver"  p:prefix="/WEB-INF/jsp/" p:suffix=".jsp"/>
	
</beans>

```

### 配置web.xml
在web.xml里配置Spring MVC的DispatcherServlet和mybatis的配置文件

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		 xmlns="http://java.sun.com/xml/ns/javaee"
		 xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_3_0.xsd"
		 version="3.0">
	<display-name>HelloSSM</display-name>
	<!-- Spring和mybatis的配置文件 -->
	<context-param>
		<param-name>contextConfigLocation</param-name>
		<param-value>classpath:spring-mybatis.xml</param-value>
	</context-param>
	<!-- Spring监听器 -->
	<listener>
		<listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
	</listener>


	<!-- Spring MVC servlet -->
	<servlet>
		<servlet-name>SpringMVC</servlet-name>
		<servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
		<init-param>
			<param-name>contextConfigLocation</param-name>
			<param-value>classpath:spring-mvc.xml</param-value>
		</init-param>
		<load-on-startup>1</load-on-startup>
		<async-supported>true</async-supported>
	</servlet>
	<servlet-mapping>
		<servlet-name>SpringMVC</servlet-name>
		<url-pattern>/</url-pattern>
	</servlet-mapping>
	<welcome-file-list>
		<welcome-file>/index.jsp</welcome-file>
	</welcome-file-list>

</web-app>  
```
### 在WEB_INF/jsp建立一个简单的测试页面user.jsp

```html
<%@ page language="java" pageEncoding="UTF-8"%>
<html>
<body>
<h1>用户ID为${user.id}的用户详情</h1>
ID：${user.id}
姓名:${user.userName}
</body>
</html>


```

### 建立User控制器

通过url传入一个id，解析这个id然后查询数据库，得到User对象放入jsp页面显示。

```java
package com.zeusjava.web.controller;

/**
 * Created by LittleXuan on 2015/10/18.
 */
import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import com.zeusjava.kernel.entity.User;
import com.zeusjava.kernel.service.IUserService;
import org.apache.commons.lang.StringUtils;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

@Controller
@RequestMapping("/user")
public class UserController {
    @Resource
    private IUserService userService;

    @RequestMapping(value="/userInfo/{id}", method= RequestMethod.GET)
    public String toIndex(HttpServletRequest request, Model model,@PathVariable("id") String id) {
        if(StringUtils.isEmpty(id)){
            throw new IllegalArgumentException("id不能为空");
        }
        int userId = Integer.parseInt(id);
        User user = this.userService.getUserById(userId);
        model.addAttribute("user", user);
        return "user";
    }
}
```

### 添加tomcat服务器并部署war包
####  `File-Project Structure`点击`Artifacts`一栏
点击`+`，选择`Web-Application-Exploded`然后选择from maven选中本项目
Web Application Exploded是没有压缩的war包，相当于文件夹
Web Application Achieved是雅俗后的war包
![tomcat](http://i13.tietuku.com/39c29f83a1e66eda.png)

#### intellij会自动帮我们生成一个war包
![tomcat](http://i13.tietuku.com/12b7bc65c9467469.png)

#### 点击`Run-Run Configurations`
点击`+`选择`tomcat server->local`
![tomcat](http://i13.tietuku.com/703c0105327e168d.png)
![tomcat](http://i13.tietuku.com/9277871664046bc8.png)
#### 点击`Configure`
![tomcat](http://i13.tietuku.com/41644246a4f5a562.png)

### 点击`Deployment选项卡`，点击`+`号，选择一个artifact，就是第二部的war包
![tomcat](http://i13.tietuku.com/6eaacb039997ba33.png)


### OK启动服务器
在任务栏输入`http://localhost:8081/HelloSSM/user/userInfo/1`,回车，结果如下：
一个简单的SSM项目环境就搭建好了。
![tomcat运行结果](http://i11.tietuku.com/51e0b1e59d159108.png)


## 和ehcache的整合
Ehcache是Hibernate的默认的cache，但是mybatis中需要自己集成，在Mybatis中使用会大大增加性能，下面开始整合mybatis和Ehcache

### 使用首先要把需要的jar包依赖加入pom中

```xml
 <dependency>
            <groupId>org.mybatis</groupId>
            <artifactId>mybatis-ehcache</artifactId>
            <version>1.0.0</version>
 </dependency>
 <dependency>
            <groupId>org.ehcache</groupId>
            <artifactId>ehcache</artifactId>
            <version>3.0.0.m3</version>
 </dependency>

```

### 在Resource中添加一个ehcache.xml的配置文件

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ehcache xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:noNamespaceSchemaLocation="http://ehcache.org/ehcache.xsd"
         updateCheck="false">
       <diskStore path="java.io.tmpdir" />
       <defaultCache eternal="false" maxElementsInMemory="1000"
                     overflowToDisk="false" diskPersistent="false" timeToIdleSeconds="0"
                     timeToLiveSeconds="600" memoryStoreEvictionPolicy="LRU" />
       <cache name="testCache" eternal="false" maxElementsInMemory="100"
              overflowToDisk="false" diskPersistent="false" timeToIdleSeconds="0"
              timeToLiveSeconds="300" memoryStoreEvictionPolicy="LRU" />
</ehcache>

```
说明：

    name：Cache的唯一标识  
    maxElementsInMemory：内存中最大缓存对象数  
    maxElementsOnDisk：磁盘中最大缓存对象数，若是0表示无穷大  
    eternal：Element是否永久有效，一但设置了，timeout将不起作用  
    overflowToDisk：配置此属性，当内存中Element数量达到maxElementsInMemory时，Ehcache将会Element写到磁盘中  
    timeToIdleSeconds：设置Element在失效前的允许闲置时间。仅当element不是永久有效时使用，可选属性，默认值是0，也就是可闲置时间无穷大  
    timeToLiveSeconds：设置Element在失效前允许存活时间。最大时间介于创建时间和失效时间之间。仅当element不是永久有效时使用，默认是0.，也就是element存活时间无穷大   
    diskPersistent：是否缓存虚拟机重启期数据  
    diskExpiryThreadIntervalSeconds：磁盘失效线程运行时间间隔，默认是120秒  
    diskSpoolBufferSizeMB：这个参数设置DiskStore（磁盘缓存）的缓存区大小。默认是30MB。每个Cache都应该有自己的一个缓冲区  
    memoryStoreEvictionPolicy：当达到maxElementsInMemory限制时，Ehcache将会根据指定的策略去清理内存。默认策略是LRU（最近最少使用）。你可以设置为FIFO（先进先出）或是LFU（较少使用）   


### 在spring-mybatis.xml中加入chache配置

```xml
	<!-- 使用ehcache缓存 -->
	<bean id="ehCacheManager" class="org.springframework.cache.ehcache.EhCacheManagerFactoryBean">
		<property name="configLocation" value="classpath:ehcache.xml" />
	</bean>
```

### 在mapper.xml中配置cache

```xml
<cache type="org.mybatis.caches.ehcache.LoggingEhcache" >  
    <property name="timeToIdleSeconds" value="3600"/>
    <property name="timeToLiveSeconds" value="3600"/>
    <property name="maxEntriesLocalHeap" value="1000"/>  
    <property name="maxEntriesLocalDisk" value="10000000"/>  
    <property name="memoryStoreEvictionPolicy" value="LRU"/>  
</cache>
```

type是使用的cache类型，`LoggingEhcache`会记录下日志，如果不需要日志的话可以使用`EhcacheCache`
这样配置之后，所以的操作都会执行缓存，如果有的操作不需要的话，可以在sql配置里将useCache设置为`false`


```java
    @Select({
        "select",
        "id, user_name, password",
        "from user",
        "where id = #{id,jdbcType=INTEGER}"
    })
    @Options(useCache = false,timeout = 10000,flushCache = false)
    @ResultMap("BaseResultMap")
    User selectByPrimaryKey(Integer id);
```
### 测试性能
测试代码

```java
 @Test
    public void test1() {
        long beginTime=System.nanoTime();
        User user = userService.getUserById(1);
        long endTime=System.nanoTime();
        System.out.println("查询时间 :" + (endTime-beginTime)+"ns");
        logger.info("姓名："+user.getUserName());
    }
```

第一次把useCache设置为`false`

![cache-false](http://i11.tietuku.com/5dc1b224af33d185.png)

第二次把useCache设置为`true`
![cache-true](http://i11.tietuku.com/350a9762f1eb6292.png)

两次执行的时间差了大约**0.4**秒


整个项目已经放到github上了，有需要的可以前往[HelloSSM](https://github.com/zhaohongxuan/HelloSSM)查看， 不懂的地方欢迎探讨...
