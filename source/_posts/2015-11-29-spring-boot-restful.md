---
layout: post
title:  "使用Spring boot 创建RestFul服务"
keywords: "spring"
date: 2015-11-29
category: spring框架
tags: [spring, RESTFul]
---

## 准备工作

1.JDK8
2.Maven 3.0+

## 程序要实现的简单功能
当用户访问

    http://localhost:8080/greeting

返回一个默认的Json字符串

    {"id":1,"content":"Hello, World!"}

当用户访问

    http://localhost:8080/greeting?name=User


返回 name后面的参数在后台组成的字符串

    {"id":1,"content":"Hello, User!"}


## 创建Maven项目

创建一个普通的maven项目，添加maven依赖如下：
<!-- more -->

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.zeusjava</groupId>
    <artifactId>SpringMVCRESTFul</artifactId>
    <version>1.0-SNAPSHOT</version>

    <properties>
        <java.version>1.8</java.version>
    </properties>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>1.3.0.RELEASE</version>
    </parent>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>

    <repositories>
        <repository>
            <id>spring-releases</id>
            <url>https://repo.spring.io/libs-release</url>
        </repository>
    </repositories>
    <pluginRepositories>
        <pluginRepository>
            <id>spring-releases</id>
            <url>https://repo.spring.io/libs-release</url>
        </pluginRepository>
    </pluginRepositories>

</project>
```

各个包之间的依赖关系如下图：

![包依赖关系](http://i5.tietuku.com/a954ae925778b0cb.png)
##创建一个resource representation 类
To model the greeting representation, you create a resource representation class.
Provide a plain old java object with fields, constructors, and accessors for the id and content data:

创建一个User类，有id和name两个属性

```java
package com.zeusjava;

public class User {

    private final long id;
    private final String name;

    public User(long id, String name) {
        this.id = id;
        this.name = name;
    }

    public long getId() {
        return id;
    }

    public String getName() {
        return name;
    }
}

```

当用户访问URL的时候，程序后台会自动获得URL上附带的名为`name`的参数。

## 创建一个resource controller

在Spring4中新增了一个@RestController注解，相当于Spring3中的@Controller和@ResponseBody两个注解一起的效果
创建一个UserController来处理Request如下：

```java
package com.zeusjava;

import java.util.concurrent.atomic.AtomicLong;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class UserController {

    private static final String template = "Hello, %s!";
    private final AtomicLong counter = new AtomicLong();

    @RequestMapping("/greeting")
    public User greeting(@RequestParam(value="name", defaultValue="World") String name) {
        return new User(counter.incrementAndGet(),
                            String.format(template, name));
    }



}

```

## 执行程序

main方法使用Spring Boot 的`SpringApplication.run()`来加载程序。

```java
package com.zeusjava;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class Application {

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}

```

## 测试程序

在Application的main方法中运行application，在地址栏输入

    http://localhost:8080/greeting

结果为：
![默认](http://i5.tietuku.com/f7230af6479c1cc9.png)

再输入一次

    http://localhost:8080/greeting?name=Zhaohongxuan

结果为：

![非默认](http://i5.tietuku.com/53e94df57cb9f031.png)

不用配置繁琐的xml，一个简单的Restful风格的程序就创建好了。


