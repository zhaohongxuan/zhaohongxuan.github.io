---
layout: post
title:  "Maven整合Spring MVC搭建笔记"
keywords: "Spring MVC"
date: 2015-09-12
category: spring框架
tags: springmvc
---

Maven是一个有效的项目管理构建工具，可以帮我们管理项目的生命周期，和项目中依赖的jar包，下面使用Maven来整合Spring来实现一个简单的登录功能。


## 在intellij中新建一个maven webapp项目，叫做HelloSpring

![新建项目](http://i13.tietuku.com/6687d9877206acd6.png)
## 在pom.xml中添加Spring包的依赖

```xml
<properties>
        <org.springframework.version>3.2.2.RELEASE</org.springframework.version>
    </properties>
    <dependencies>
        <!-- Spring-->
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-core</artifactId>
            <version>${org.springframework.version}</version>
        </dependency>

        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-aop</artifactId>
            <version>${org.springframework.version}</version>
        </dependency>

             <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-beans</artifactId>
            <version>${org.springframework.version}</version>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-context</artifactId>
            <version>${org.springframework.version}</version>
        </dependency>
      <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-context-support</artifactId>
            <version>${org.springframework.version}</version>
        </dependency>
      <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-expression</artifactId>
            <version>${org.springframework.version}</version>
        </dependency>

        <!--Spring mvc -->
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-webmvc</artifactId>
            <version>${org.springframework.version}</version>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-web</artifactId>
            <version>${org.springframework.version}</version>
        </dependency>

        <dependency>
            <groupId>commons-logging</groupId>
            <artifactId>commons-logging</artifactId>
            <version>1.2</version>
        </dependency>

        <!--data source -->
        <dependency>
            <groupId>commons-dbcp</groupId>
            <artifactId>commons-dbcp</artifactId>
            <version>1.4</version>
        </dependency>

        <dependency>
            <groupId>cglib</groupId>
            <artifactId>cglib</artifactId>
            <version>2.2.2</version>
        </dependency>

    </dependencies>
```
<!-- more -->

## Maven中Spring jar包的依赖关系
在intellij idea中打开`pom.xml`文件，右键`Diagrams`选择`Show Dependencies`就会出现Maven项目中包的依赖关系

![依赖关系](http://i13.tietuku.com/8612e375a4ff1145.png)
## web.xml配置
web.xml需要配置`DispatcherServlet`和`listener`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://java.sun.com/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://java.sun.com/xml/ns/javaee
        http://java.sun.com/xml/ns/javaee/web-app_3_0.xsd"
         version="3.0">

    <display-name>Hello Spring</display-name>
    <context-param>
        <param-name>contextConfigLocation</param-name>
        <param-value>classpath:applicationContext.xml</param-value>
    </context-param>

     <listener>
         <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
     </listener>
    <servlet>
        <servlet-name>Spring</servlet-name>
        <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
        <init-param>
            <param-name>contextConfigLocation</param-name>
            <param-value>/WEB-INF/spring-servlet.xml</param-value>
        </init-param>
        <load-on-startup>1</load-on-startup>
    </servlet>
    <servlet-mapping>
        <servlet-name>Spring</servlet-name>
        <url-pattern>/</url-pattern>
    </servlet-mapping>
    <filter>
        <filter-name>encodingFilter</filter-name>
        <filter-class>
            org.springframework.web.filter.CharacterEncodingFilter
        </filter-class>
        <init-param>
            <param-name>encoding</param-name>
            <param-value>UTF-8</param-value>
        </init-param>
    </filter>

    <filter-mapping>
        <filter-name>encodingFilter</filter-name>
        <url-pattern>/*</url-pattern>
    </filter-mapping>

</web-app>
```

## spring-servlet.xml的配置

在这里将Spring MVC配置文件单独从`applicationContext.xml`中抽取出来，在`spring-servlet.xml`中配置视图解析器、拦截器、自动扫描等信息

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xmlns:mvc="http://www.springframework.org/schema/mvc"
       xsi:schemaLocation="
        http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context.xsd
        http://www.springframework.org/schema/mvc http://www.springframework.org/schema/mvc/spring-mvc.xsd
">
    <!--扫描自动依赖注入的包名 -->
    <context:component-scan base-package="com.zeusjava.controller"/>
    <!-- 默认的注解映射的支持 -->
    <mvc:annotation-driven/>
    <!--视图解释器 -->
    <bean class="org.springframework.web.servlet.view.InternalResourceViewResolver" >
        <property name="prefix" value="/WEB-INF/jsp/"/>
        <property name="suffix" value=".jsp"/>
    </bean>

</beans>
```

需要注意的是`schemaLocation` 的设置一定要正确，一个schema对应一个xsd文件，如果缺少的话，就会报
通配符的匹配很全面, 但无法找到元素 'context:component-scan' 的声明的错误~教训啊
## applicationContext.xml配置
由于我们把Spring MVC的配置文件spring-servlet.xml提取出来了，如果需要配置事务、数据源等可以在applicationContent中配置，这个简单的demo还不需要，
所以先空着。

## Controller代码实现
![代码结构](http://i13.tietuku.com/0210b66098996017.png)

```java
package com.zeusjava.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Created by LittleXuan on 2015/9/12.
 */
@Controller
@RequestMapping("account")
public class AccountController {

    @RequestMapping(value="/login", method= RequestMethod.GET)
    public String login(HttpServletRequest request ,HttpServletResponse response) {

        return "account/login";
    }
    @RequestMapping(value="/login", method= RequestMethod.POST)
    public ModelAndView loginResponse(@RequestParam("username") String username,@RequestParam("password") String password,HttpServletRequest request) {
        ModelAndView m =new ModelAndView();
        if(username.equals("zhaohongxuan")&&password.equals("123")){
            m.setViewName("index");
            return m;
        }
        m.setViewName("error");
        return m;
    }
}


```


## jsp代码

```jsp
<%--
  Created by IntelliJ IDEA.
  User: LittleXuan
  Date: 2015/9/12
  Time: 14:55
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>登录</title>
</head>
<body>
    <form action="/account/login" method="post">
      用户名：<input type="text" name="username" ><br/>
      密码：<input type="password" name="password"><br/>
      <input type="submit" value="登录">

    </form>
</body>
</html>

```
## 启动项目测试
![项目测试](http://i13.tietuku.com/583d1b027adf3749.png)

![运行效果](http://i13.tietuku.com/4777d2f30809bfb3.png)

