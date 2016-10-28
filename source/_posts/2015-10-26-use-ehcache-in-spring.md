---
layout: post
title:  "在Spring中使用Ehcache"
keywords: "Ehcache"
description: "Spring和Ehcache的整合与使用"
category: spring框架
tags: ehcache spring
---

##一、首先是所需要的包的Maven依赖
1.ehcache的核心包

```xml

	<dependency>
            <groupId>net.sf.ehcache</groupId>
            <artifactId>ehcache</artifactId>
            <version>2.10.0</version>
        </dependency>
```
2.Spring-context-support中包含和缓存、Scheduler有关的类方法等

```xml

        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-context-support</artifactId>
            <version>${spring-framework.version}</version>
        </dependency>
```

##二、编写Ehcache配置文件`ehcache.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ehcache xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:noNamespaceSchemaLocation="http://ehcache.org/ehcache.xsd"
         updateCheck="false">
       <diskStore path="java.io.tmpdir" />
       <defaultCache eternal="false" maxElementsInMemory="1000"
                     overflowToDisk="false" diskPersistent="false" timeToIdleSeconds="0"
                     timeToLiveSeconds="600" memoryStoreEvictionPolicy="LRU" />

       <cache name="serviceCache" eternal="false" maxElementsInMemory="100"
              overflowToDisk="false" diskPersistent="false" timeToIdleSeconds="0"
              timeToLiveSeconds="300" memoryStoreEvictionPolicy="LRU" />
</ehcache>
```

##三、在Spring配置文件中添加ehcache配置信息

```xml
	<!-- 使用ehcache缓存 -->
	<bean id="ehCacheManager" class="org.springframework.cache.ehcache.EhCacheManagerFactoryBean">
		<property name="configLocation" value="classpath:ehcache.xml" />
	</bean>
```
项目启动时候，Spring 容器会加载缓存，还需要一个缓存管理类来进行缓存的管理。

##四、建立缓存管理类EhCacheManager

EhcacheManager中的`CACHE_KEY`是和`ehcache.xml`中的cache name保持一致

```java
import net.sf.ehcache.CacheManager;
import net.sf.ehcache.Ehcache;
import net.sf.ehcache.Element;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.Serializable;

/**
 * Created by LittleXuan on 2015/10/24.
 * 缓存管理类
 */
public class EhCacheManager {
    private static Logger log = LoggerFactory.getLogger(EhCacheManager.class);
    private static final String CACHE_KEY ="serviceCache";
    public static final int CACHE_LIVE_SECONDS = 180;
    private static EhCacheManager instance = new EhCacheManager();
    private static CacheManager cacheManager;
    private static Ehcache fileCache;

    private EhCacheManager() {
        log.info("初始化缓存 ----------------------------------------");
        cacheManager = new CacheManager();
        fileCache = cacheManager.getCache(CACHE_KEY);
        log.info("初始化缓存成功....");
    }

    public static synchronized EhCacheManager getInstance() {
        if (instance == null) {
            instance = new EhCacheManager();
        }
        return instance;
    }

    public static byte[] loadFile(String key) {
        Element e = fileCache.get(key);
        if (e != null) {
            Serializable s = e.getValue();
            if (s != null) {
                return (byte[]) s;
            }
        }
        return null;
    }

    public static void cacheFile(String key, byte[] data) {
        fileCache.put(new Element(key, data));
    }

    /**
     * 将数据存入缓存，缓存无时间限制
     * @param key
     * @param value
     */
    public static <T> void put(String key,T value){
        fileCache.put(new Element(key, value));
    }


    /**
     * 通过key值获取存入缓存中的数据
     * @param key 数据存入缓存时的key
     */
    @SuppressWarnings("unchecked")
    public static <T> T get(String key) {
        Element el = fileCache.get(key);
        if (el == null) {
            if (log.isDebugEnabled())
                log.debug("not found key:"+ key);
            return null;
        }

        T t = (T) el.getObjectValue();
        return t;
    }


    /**
     * 根据key删除缓存
     */
    public static boolean remove(String key) {
        log.info("remove key:"+key);
        return fileCache.remove(key);
    }

    /**
     * 关闭cacheManager 对象
     */
    public static void shutdown() {
        cacheManager.shutdown();
    }

}

```

##五、创建Service类

```java
@Service("userService")
public class UserServiceImpl extends BaseServiceImpl<User,userMapper> implements IUserService {
    private final static String GET_USER_KEY ="GET_USER_KEY_";
    @Resource
    private  UsertMapper userMapper;
    @Override
    public List<User> selectUserById(String userId) {
       
        //从缓存中查找
        User user = EhCacheManager.get(GET_USER_KEY+userId);
        if(user == null){
	    User queryUser = new User();
	    queryUser.setUserId(userId);
            log.info("第一次加载，缓存为空从数据库中查找...");
            user = userMapper.selectOne(queryUser);
            //将从数据库中查询到的结果放入缓存
            EhCacheManager.put(GET_USER_KEY+userId,user);
        }
        return user;
    }
}
```

##六、创建测试类

```java
@RunWith(SpringJUnit4ClassRunner.class)     //表示继承了SpringJUnit4ClassRunner类
@ContextConfiguration(locations = {"classpath:spring-mybatis.xml"})
public class UserTest {
    private static Logger logger = LoggerFactory.getLogger(UserTest.class);

    @Resource
    private IUserService userService = null;
    @Test
    public void test1() {
        User userResult = this.userService.selectUserById("0001");
    }
}


@Controller
@RequestMapping("/user")
public class CacheTest {
    private static Logger logger = LoggerFactory.getLogger(CacheTest.class);

    @Resource
    private IConstantService constantService;

    @RequestMapping("/userInfo")
    public void testConstant() {
         User userResult = this.userService.selectUserById("0001");
	 System.out.println("username:"+userResult.getUsername());
    }
}

```
##七、运行结果


第一次请求

	初始化缓存 ----------------------------------------
	初始化缓存成功....
	username:赵宏轩

接下来请求

	username:赵宏轩
