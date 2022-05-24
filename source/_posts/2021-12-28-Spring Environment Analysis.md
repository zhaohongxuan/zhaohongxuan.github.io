---
title: Spring Environment源码分析
date: 2021-12-28 17:08:10
tag: java/spring
category: 源码分析
---


## Spring Environment 体系


![Spring-environment.excalidraw](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20220506183240.png)



## Environment 

> Interface representing the environment in which the current application is running. Models two key aspects of the application environment: profiles and properties. Methods related to property access are exposed via the PropertyResolver superinterface.

Environment 继承自**PropertyResolver** 定义了应用运行环境的两大关键要素： profiles 和properties，其中properties接口通过父类的**PropertyResolver** 暴露接口.

<!-- more -->

ApplicationContext负责将Environment给后面创建Bean来使用


```java
public void setEnvironment(ConfigurableEnvironment environment) {  
   super.setEnvironment(environment);  
   this.reader.setEnvironment(environment);  
   this.scanner.setEnvironment(environment);  
}
```
在对Bean进行操作的过程中，如果需要进行一些解析，会调用Environment对象进行操作。 

SpringBoot 中会在run方法中创建默认的  ConfigurableEnvironment, 在prepareContext中设置到Context中

```java
public ConfigurableApplicationContext run(String... args) {  
	...
      ApplicationArguments applicationArguments = new DefaultApplicationArguments(args);  
      ConfigurableEnvironment environment = prepareEnvironment(listeners, bootstrapContext, applicationArguments);  
      context = createApplicationContext();  
      context.setApplicationStartup(this.applicationStartup);  
      prepareContext(bootstrapContext, context, environment, listeners, applicationArguments, printedBanner);  
      refreshContext(context);  
      afterRefresh(context, applicationArguments);  
    ...
   }  
   catch (Throwable ex) {  
      handleRunFailure(context, ex, listeners);  
      throw new IllegalStateException(ex);  
   }  

   return context;  
}  

```
根据类型创建environment
```java
private ConfigurableEnvironment getOrCreateEnvironment() {  
   if (this.environment != null) {  
      return this.environment;  
   }  
   switch (this.webApplicationType) {  
   case SERVLET:  
      return new ApplicationServletEnvironment();  
   case REACTIVE:  
      return new ApplicationReactiveWebEnvironment();  
   default:  
      return new ApplicationEnvironment();  
   }  
}
```



### ConfigurableEnvironment
先来看ConfigurableEnvironment源码中的注释：
>Configuration interface to be implemented by most if not all Environment types. Provides facilities for setting active and default profiles and manipulating underlying property sources. Allows clients to set and validate required properties, customize the conversion service and more through the ConfigurablePropertyResolver superinterface.
Manipulating property sources

ConfigurableEnvironment提供两大功能，设置profile和操作委托对象[[Spring PropertySource]] 来实现对Property的操作

[![pages-build-deployment](https://github.com/zhaohongxuan/zhaohongxuan.github.io/actions/workflows/pages/pages-build-deployment/badge.svg)](https://github.com/zhaohongxuan/zhaohongxuan.github.io/actions/workflows/pages/pages-build-deployment)


### AbstractEnvironment
AbstractEnvironment 实现了大部分**ConfigurableEnvironment**的功能，包含了一下委托对象

```java
private final Set<String> activeProfiles = new LinkedHashSet<>();  
  
private final Set<String> defaultProfiles = new LinkedHashSet<>(getReservedDefaultProfiles());  
  
private final MutablePropertySources propertySources = new MutablePropertySources()
```

子类通过**customizePropertySources** 的hook来操作propertySources

```java
public String getProperty(String key) {  
   return this.propertyResolver.getProperty(key);  
}
```


## PropertyResolver 的设计

PropertyResolver是Environment的**顶层设计接口**

> Interface for resolving properties against any underlying source 

PropertyResolver是为了解析Properties而生的, 接口主要定义了如何从根据一个key来获取一个value, 可以是String类型的也可以是**给定的Class类型**

PropertyResolver提供了两类操作
- getProperty()
- resolvePlaceholders() ，给外界暴露出一个能力来解析诸如`${}`的Placeholder
 其他的操作都是这两个操作的变身。


### ConfigurablePropertyResolver
ConfigurablePropertyResolver 定义了一个配置化的PropertyResolver，主要是为了解析**占位符， 默认是${}** 的property，比如[[Spring @Value的实现机制]] 中就用到了这个Resolver

同时，ConfigurablePropertyResolver定义了[[ConversionService]] 的接口用来将value转换为目标类型

### AbstractPropertyResolver
[[AbstractPropertyResolver]] 中提供了一个方法来很方便的把value转换为目标类型 

```java
protected <T> T convertValueIfNecessary(Object value, @Nullable Class<T> targetType) {  
   if (targetType == null) {  
      return (T) value;  
   }  
   ConversionService conversionServiceToUse = this.conversionService;  
   if (conversionServiceToUse == null) {  
      // Avoid initialization of shared DefaultConversionService if  
 // no standard type conversion is needed in the first place... if (ClassUtils.isAssignableValue(targetType, value)) {  
         return (T) value;  
      }  
      conversionServiceToUse = DefaultConversionService.getSharedInstance();  
   }  
   return conversionServiceToUse.convert(value, targetType);  
}
```
AbstractPropertyResolver 中定义了，Placeholder的prefix/sufix以及valueSeparator还有**resolvePlaceholders**的策略(严格或者非严格)，严格模式不能解析的placeholder会抛出异常。



### PropertySourcesPropertyResolver

主要目的是通过遍历PropertySources中的key来
```java
protected <T> T getProperty(String key, Class<T> targetValueType, boolean resolveNestedPlaceholders) {  
   if (this.propertySources != null) {  
      for (PropertySource<?> propertySource : this.propertySources) {  
         if (logger.isTraceEnabled()) {  
            logger.trace("Searching for key '" + key + "' in PropertySource '" +  
                  propertySource.getName() + "'");  
         }  
         Object value = propertySource.getProperty(key);  
         if (value != null) {  
            if (resolveNestedPlaceholders && value instanceof String) {  
               value = resolveNestedPlaceholders((String) value);  
            }  
            logKeyFound(key, propertySource, value);  
            return convertValueIfNecessary(value, targetValueType);  
         }  
      }  
   }  
   if (logger.isTraceEnabled()) {  
      logger.trace("Could not find key '" + key + "' in any property source");  
   }  
   return null;  
}
```


## PropertySource

PropertySource代表了Key-value的Property来源：

![PropertySource.excalidraw](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20220506184157.png)

Environment的默认实现StandardEnvironment就用到了SystemEnvironmentPropertySource, 默认将操作系统中的环境变量加载到Environment中去。

如果我们需要魔改Spring容器中的配置文件属性的值，比如配置中心在运行时动态刷新key的value，这个时候就需要自己操作PropertySource，自定义一个PropertySource，然后优先级设置在系统propertySource之上，这样就可以实现动态刷新了。

### PropertySources

PropertySources此接口是PropertySource的容器，默认实现**MutablePropertySources**实现内部含有一个CopyOnWriteArrayList来存储PropertySource。


## EnvironmentAware

Spring的Aware组件是Spring容器给应用提供的一个钩子方法，实现了Aware接口，就可以在对应的组件里面设置对应的功能，比如实现了EnvironmentAware可以在组件里获得Environment的能力，实现了BeanFactoryAware就可以在组件里获得容器的BeanFactory，方便用户来进行一些自定义处理。



## References
1.  https://github.com/seaswalker/spring-analysis/blob/master/note/Spring.md
2. https://docs.spring.io/spring-framework/docs/current/reference/html/overview.html 