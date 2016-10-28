---
layout: post
title:  "使用Jersey创建RESTful服务"
keywords: "Jersey"
description: "使用Maven和Jersey创建简单的RESTFul服务实现CRUD"
category: java
tags: java RESTFul
---

##一、REST基础概念
首先REST是`Representational State Transfer`的缩写，如果一个架构符合REST原则，它就是RESTful架构。
在REST中的一切都被认为是一种资源。所谓"资源"，就是网络上的一个实体，或者说是网络上的一个具体信息。它可以是一段文本、一张图片、一首歌曲、一种服务，总之就是一个具体的实在。你可以用一个URI（统一资源定位符）指向它，每种资源对应一个特定的URI。要获取这个资源，访问它的URI就可以，因此URI就成了每一个资源的地址或独一无二的识别符。
所谓"上网"，就是与互联网上一系列的"资源"互动，调用它的URI。

我们把"资源"具体呈现出来的形式，叫做它的`表现层（Representation）`。
比如，文本可以用txt格式表现，也可以用HTML格式、XML格式、JSON格式表现，甚至可以采用二进制格式；图片可以用JPG格式表现，也可以用PNG格式表现。
URI只代表资源的实体，不代表它的`形式`。URI只代表资源的`位置`。它的具体表现形式，应该在HTTP请求的头信息中用`Accept`和`Content-Type`字段指定，这两个字段才是对"表现层"的描述。
客户端和服务器的一个互动过程。在这个过程中，势必涉及到数据和状态的变化。
互联网通信协议HTTP协议，是一个`无状态协议`。这意味着，所有的状态都保存在`服务器端`。因此，如果客户端想要操作服务器，必须通过某种手段，让服务器端发生`状态转化`（State Transfer）。而这种转化是建立在表现层之上的，所以就是`表现层状态转化`。
客户端用到的手段，只能是HTTP协议。具体来说，就是HTTP协议里面，四个表示操作方式的动词：GET、POST、PUT、DELETE。它们分别对应四种基本操作：GET用来获取资源，POST用来新建资源（也可以用于更新资源），PUT用来更新资源，DELETE用来删除资源。

##二、Jersey RESTful 
Jersey RESTful 框架是开源的RESTful框架, 实现了`JAX-RS` 规范。它扩展了JAX-RS 参考实现， 提供了更多的特性和工具， 可以进一步地简化 RESTful service 和 client 开发。
尽管相对年轻，它已经是一个产品级的`RESTful service`和`client`框架。
有关Jersey文档请点击[Jersey文档](https://github.com/jersey/jersey)
下面介绍使用Maven与Jersey编写一个简单的RestFul服务的栗子。
##三、在intellij中创建RestFul栗子
###1.加入Maven包依赖

```xml
   <dependency>
      <groupId>com.sun.jersey</groupId>
      <artifactId>jersey-core</artifactId>
      <version>1.3</version>
    </dependency>
    <dependency>
      <groupId>com.sun.jersey</groupId>
      <artifactId>jersey-server</artifactId>
      <version>1.3</version>
    </dependency>
    <dependency>
      <groupId>com.sun.jersey</groupId>
      <artifactId>jersey-client</artifactId>
      <version>1.3</version>
    </dependency>
    <dependency>
      <groupId>log4j</groupId>
      <artifactId>log4j</artifactId>
      <version>1.2.14</version>
    </dependency>
    <dependency>
      <groupId>javax.ws.rs</groupId>
      <artifactId>jsr311-api</artifactId>
      <version>1.1.1</version>
    </dependency>
    <dependency>
      <groupId>asm</groupId>
      <artifactId>asm</artifactId>
      <version>3.2</version>
    </dependency>
```

###2.在Web.xml文件中定义Servlet调度程序
定义一个初始化参数，指示包含资源的Java包，我把Resource都放在了`com.zeusjava.resource`里了,所有的资源通过`http://localhost:8081/jersey/api/`来访问

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://java.sun.com/xml/ns/javaee" xmlns:web="http://java.sun.com/xml/ns/javaee/web-app_2_5.xsd" xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_2_5.xsd" id="WebApp_ID" version="2.5">
<display-name>JerseyRestFul</display-name>
<servlet>
    <servlet-name>JerseyRestFul</servlet-name>
    <servlet-class>com.sun.jersey.spi.container.servlet.ServletContainer</servlet-class>
    <init-param>
        <param-name>com.sun.jersey.config.property.packages</param-name>
        <param-value>com.zeusjava.resource</param-value>
    </init-param>
    <load-on-startup>1</load-on-startup>
</servlet>
<servlet-mapping>
    <servlet-name>JerseyRestFul</servlet-name>
    <url-pattern>/api/*</url-pattern>
</servlet-mapping>
    <welcome-file-list>
        <welcome-file>index.jsp</welcome-file>
    </welcome-file-list>
</web-app>

```
###3.创建资源文件
资源是Rest中最重要的部分，可以通过Http的方法 GET、POST、PUT 和DELETE等对资源进行增删改查，下面创建的`UserResource`中实现了对User的增删改查，用户存储在`UserCache`的一个Map中，在`JAX-RX`中，资源通过`POJO`实现，使用`@Path` 注释组成其标识符。资源可以有子资源。在这种情况下，父资源是资源集合，子资源是成员资源。

####1.增加一个User

注解`@Path("/users")`将`UserResource`暴露为一个Rest服务，注解`@POST`将HTTP方法映射到资源的 让POST方法变成创建方法。

1. @Consumes：声明该方法使用 HTML FORM即表单输入。
2. @FormParam：注入该方法的 HTML 属性确定的表单输入。
3. @Response.created(uri).build()： 构建新的 URI 用于新创建的User（/users/{id}）并设置响应代码（201/created）。您可以使用 http://localhost:8081/jersey/api/users/<id> 访问新用户。
4. @Produces：限定响应内容的`MIME`类型。MIME类型有很多种，XML和JSON是常用的两种
5. @Context： 使用该注释注入上下文对象，比如 Request、Response、UriInfo、ServletContext 等。

```java
@Path("/users")
public class UserResource {
    @Context
    UriInfo uriInfo;
  /**
     * 增加用户
     * @param userId
     * @param userName
     * @param userAge
     * @param servletResponse
     * @throws IOException
     */
    @POST
    @Consumes(MediaType.APPLICATION_FORM_URLENCODED)
    public void newUser(
            @FormParam("userId") String userId,
            @FormParam("userName") String userName,
            @FormParam("userAge") int userAge,
            @Context HttpServletResponse servletResponse
    ) throws IOException {
        User user = new User(userId,userName,userAge);
        UserCache.getUserCache().put(userId,user);
        URI uri = uriInfo.getAbsolutePathBuilder().path(userId).build();
        Response.created(uri).build();
    }
}
```
####2.删除用户
 @DELETE将Http Delete请求绑定到删除用户（资源）操作上
 @PathParam该注释将参数注入方法参数的路径

```java
 @DELETE
    @Path("/{id}")
    public void deleteContact(@PathParam("id") String id) {
        User user = UserCache.getUserCache().remove(id);
        if(user==null)
            throw new NotFoundException("No such User.");
    }
```

####3.更新用户

根据用户的Id来更新一个用户（资源）。
Consume XML：putContact() 方法接受 APPLICATION/XML 请求类型，而这种输入 XML 将使用 JAXB 绑定到 User 对象。
PUT 请求的响应没有任何内容，但是有不同的状态码。如果Cache中存在联系人，我将更新该User并返回 204/no content。如果没有User，我将创建一个并返回 201/created。

```java
    /**
     * 更新用户
     * @param jaxbContact
     * @return
     */
    @PUT
    @Path("/{id}")
    @Consumes(MediaType.APPLICATION_XML)
    public Response putUser(JAXBElement<User> jaxbContact,@PathParam("id") String id) {
        User user = jaxbContact.getValue();
        Response res;
        if(UserCache.getUserCache().containsKey(id)) {
            res = Response.noContent().build();
        } else {
            res = Response.created(uriInfo.getAbsolutePath()).build();
        }
        UserCache.getUserCache().put(user.getUserId(), user);
        return res;
    }
```

####4.查找用户
根据传入的id查找用户，如果没有用户则抛出异常。
返回类型为`MediaType.APPLICATION_XML`需要在JavaBean中设置`@XmlRootElement`注解。


```java
   @GET
    @Path("/{id}")
    @Produces(MediaType.APPLICATION_XML)
    public User getUser(@PathParam("id") String id) {

        User user = UserCache.getUserCache().get(id);
        if(user==null){
            throw new NotFoundException("No such User.");
        }
        return user;
    }
```

####4.User实体类

```java
package com.zeusjava.entity;

import javax.xml.bind.annotation.XmlRootElement;

/**
 * Created By IntelliJ IDEA.
 * User: LittleXuan
 * Date: 2015/11/18.
 * Time: 17:05
 * Desc: User实体类
 */
@XmlRootElement
public class User {
    private String userId;
    private String userName;
    private int userAge;

    public User(){

    }

    public User(String userId, String userName, int userAge) {
        this.userId = userId;
        this.userName = userName;
        this.userAge = userAge;
    }
   //getter&setter
 
}
```
####5.User缓存类

```java
package com.zeusjava.cache;
import com.zeusjava.entity.User;
import java.util.HashMap;
import java.util.Map;

/**
 * Created By IntelliJ IDEA.
 * User: LittleXuan
 * Date: 2015/11/19.
 * Time: 9:17
 * Desc: UserCache 存储用户
 */
public class UserCache {
    private static Map<String,User> userCache;
    private static UserCache instance = null;

    private UserCache() {
        userCache = new HashMap<String,User>();
        initOneUser();
    }

    public static Map<String,User> getUserCache() {
        if(instance==null) {
            instance = new UserCache();
        }
        return userCache;
    }

    private static void initOneUser() {
        User user = new User("001","zhaohongxuan",24);
        userCache.put(user.getUserId(),user);
    }
}

```
###4.创建Client测试

测试代码如下：

```java
package com.zeusjava.client;
import javax.ws.rs.core.MediaType;
import javax.xml.bind.JAXBElement;
import com.sun.jersey.api.client.Client;
import com.sun.jersey.api.client.ClientResponse;
import com.sun.jersey.api.client.GenericType;
import com.sun.jersey.api.client.WebResource;
import com.sun.jersey.api.representation.Form;
import com.zeusjava.entity.User;
import org.junit.Test;

public class UserClient {
	private WebResource r = null;
	@Test
	public void insertUser(){
		r = Client.create().resource("http://localhost:8081/jersey/api/users");
		Form form = new Form();
		form.add("userId", "002");
		form.add("userName", "ZhaoHongXuan");
		form.add("userAge", 23);
		ClientResponse response = r.type(MediaType.APPLICATION_FORM_URLENCODED)
				.post(ClientResponse.class, form);
		System.out.println(response.getStatus());
	}
	@Test
	public void findUser(){
		r = Client.create().resource("http://localhost:8081/jersey/api/users/002");
		String jsonRes = r.accept(MediaType.APPLICATION_XML).get(String.class);
		System.out.println(jsonRes);
	}

	@Test
	public void updateUser(){
		r = Client.create().resource("http://localhost:8081/jersey/api/users");
		User user = new User("002","ZhaoXiaoXuan",24);
		ClientResponse response = r.path(user.getUserId()).accept(MediaType.APPLICATION_XML)
				.put(ClientResponse.class, user);
		System.out.println(response.getStatus());
	}
	@Test
	public void deleteUser(){
		r = Client.create().resource("http://localhost:8081/jersey/api/users");

		GenericType<JAXBElement<User>> generic = new GenericType<JAXBElement<User>>() {};
		JAXBElement<User> jaxbContact = r
				.path("002")
				.type(MediaType.APPLICATION_XML)
				.get(generic);
		User user = jaxbContact.getValue();
		System.out.println(user.getUserId() + ": " + user.getUserName());
		ClientResponse response = r.path("002").delete(ClientResponse.class);
		System.out.println(response.getStatus());
	}


}

```
###5.测试程序
服务器使用tomcat启动（本步略）
####1.首先运行`insertUser`Test方法添加一个用户
    返回响应码`201`表示创建成功。
####2.运行`findUser`查询id为`002`的用户

	<?xml version="1.0" encoding="UTF-8" standalone="yes"?><user><userAge>23</userAge><userId>002</userId><userName>ZhaoHongXuan</userName></user>

服务器响应的是我们刚才添加的用户
###3.运行`updateUser`更新用户名为`ZhaoXiaoXuan`,年龄为`24`
    返回响应码为`204`表示更新成功
    再次查询id为002的用户

	<?xml version="1.0" encoding="UTF-8" standalone="yes"?><user><userAge>24</userAge><userId>002</userId><userName>ZhaoXiaoXuan</userName></user>
    
    用户名称和年龄已经更改为`ZhaoxiaoXuan`和`24`


###4.运行`deleteUser`删除用户

结果如下：

	002: ZhaoXiaoXuan
	204

表示删除成功
再次运行查询，则服务器报`404`错误，说明该用户已经被删除。

	GET http://localhost:8081/jersey/api/users/002 returned a response status of 404


**完整**的使用Jersey创建服务的代码地址为：[JerseyRestFul](https://github.com/javaor/JerseyRestFul)



