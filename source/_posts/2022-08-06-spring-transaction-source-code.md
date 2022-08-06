---
title: Spring @Transactional是如何工作的？
date: 2022-08-06 15:46
tags: [java,spring]
category: 源码解析
---

## Spring事务使用

Spring配置事务还是挺简单的，第一步创建事务管理器`TransactionManager`，然后在配置中增加一个`@EnableTransactionManagement`就可以启用Spring事务了，所以关键类就是`@EnableTransactionManagement`

```java
@Bean  
public DataSourceTransactionManager transactionManager() {  
    return new DataSourceTransactionManager(dataSource());  
}
```

我们可以看到`@EnableTransactionManagement` 上实际上是import了`TransactionManagementConfigurationSelector`类，在这个Selector中实际import了
两个配置类：
1.  AutoProxyRegistrar
2.  ProxyTransactionManagementConfiguration

```java

@Override  
protected String[] selectImports(AdviceMode adviceMode) {  
   switch (adviceMode) {  
      case PROXY:  
         return new String[] {AutoProxyRegistrar.class.getName(),  
               ProxyTransactionManagementConfiguration.class.getName()};  
      case ASPECTJ:  
         return new String[] {determineTransactionAspectClass()};  
      default:  
         return null;  
   }  
}

```
下面我们来根据这个入口来分析一下Spring是如何处理事务的：

<!-- more -->
### AutoProxyRegistrar 导入

AutoProxyRegistrar主要的作用是向Spring容器中注册了一个**InfrastructureAdvisorAutoProxyCreator**的Bean。
这一步位于spring aop包下面的 `AopConfigUtils#registerAutoProxyCreatorIfNecessary`方法中

`InfrastructureAdvisorAutoProxyCreator`继承了**AbstractAdvisorAutoProxyCreator**，所以这个类的主要作用就是`开启自动代理`的作用，也就是一个`BeanPostProcessor`，会在初始化后步骤中去寻找Advisor类型的Bean，并判断当前某个Bean是否有匹配的Advisor，是否需要利用动态代理产生一个代理对象。

![](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20220404210931.png)

这里**InfrastructureAdvisorAutoProxyCreator**会扫描到事务处理的`BeanFactoryTransactionAttributeSourceAdvisor`
### SpringAOP实现原理

代理对象的生成类是：`AbstractAutoProxyCreator` 实现了BeanPostProcessor接口，会在Bean初始化完成之后通过postProcessAfterInitialization生成代理对象。
来看`postProcessAfterInitialization`方法：
```java
public Object postProcessAfterInitialization(@Nullable Object bean, String beanName) {  
   if (bean != null) {  
      Object cacheKey = getCacheKey(bean.getClass(), beanName);  
      if (this.earlyProxyReferences.remove(cacheKey) != bean) {  
         return wrapIfNecessary(bean, beanName, cacheKey);  
      }  
   }  
   return bean;  
}
```

主要代码就是`wrapIfNecessary`, 主要作用是生成Proxy Bean

```java
protected Object wrapIfNecessary(Object bean, String beanName, Object cacheKey) {  
 ...  
   // Create proxy if we have advice.  
 Object[] specificInterceptors = getAdvicesAndAdvisorsForBean(bean.getClass(), beanName, null);  
   if (specificInterceptors != DO_NOT_PROXY) {  
      this.advisedBeans.put(cacheKey, Boolean.TRUE);  
      Object proxy = createProxy(  
            bean.getClass(), beanName, specificInterceptors, new SingletonTargetSource(bean));  
      this.proxyTypes.put(cacheKey, proxy.getClass());  
      return proxy;  
   }  
  
   this.advisedBeans.put(cacheKey, Boolean.FALSE);  
   return bean;  
}
```

这里 `getAdvicesAndAdvisorsForBean` 为当前的Bean寻找合适的Advices，这个方法是Abstract方法，因此需要子类去实现。

主要实现代码在`AbstractAdvisorAutoProxyCreator`中
```java
protected Object[] getAdvicesAndAdvisorsForBean(  
      Class<?> beanClass, String beanName, @Nullable TargetSource targetSource) {  
  
   List<Advisor> advisors = findEligibleAdvisors(beanClass, beanName);  
   if (advisors.isEmpty()) {  
      return DO_NOT_PROXY;  
   }  
   return advisors.toArray();  
}  
  
protected List<Advisor> findEligibleAdvisors(Class<?> beanClass, String beanName) {  
   List<Advisor> candidateAdvisors = findCandidateAdvisors();  
   List<Advisor> eligibleAdvisors = findAdvisorsThatCanApply(candidateAdvisors, beanClass, beanName);  
   extendAdvisors(eligibleAdvisors);  
   if (!eligibleAdvisors.isEmpty()) {  
      eligibleAdvisors = sortAdvisors(eligibleAdvisors);  
   }  
   return eligibleAdvisors;  
}
```

findEligibleAdvisors 会通过一个工具类在BeanFactory中查合适的Advisor，findAdvisorsThatCanApply会过滤可以被Apply的Advisor,  主要是看目标类和Advisor之间的关系来判断，这里主要由AOP的代码来实现。

![](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20220404192144.png)

### ProxyTransactionManagementConfiguration导入

**ProxyTransactionManagementConfiguration** 是一个配置类，它又定义了另外三个bean：

1.  BeanFactoryTransactionAttributeSourceAdvisor：一个Advisor
2.  AnnotationTransactionAttributeSource：相当于`BeanFactoryTransactionAttributeSourceAdvisor`中的`Pointcut`
3.  TransactionInterceptor：相当于`BeanFactoryTransactionAttributeSourceAdvisor`中的 Advice

`AnnotationTransactionAttributeSource` 就是用来判断某个类上是否存在@Transactional注解， 或者判断某个方法上是否存在`@Transactional`注解的。`TransactionInterceptor`就是代理逻辑，当某个类中存在`@Transactional`注解时，到时就产生一个 代理对象作为Bean，代理对象在执行某个方法时，最终就会进入到`TransactionInterceptor`的 `invoke()`方法。


## Spring事务拦截

PlatformTransactionManager
![](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20220404183802.png)
## @Transactional处理

### Transactional 解析

@Transactional的处理主要是交给`TransactionAttributeSourceAdvisor`完成的，TransactionAttributeSourceAdvisor实现了`Advisor`接口，因此在Spring创建Bean的时候查找Advisor的时候，只要classpath中有加载到tx相关的jar包，并且Enable相关Transactional的配置了就会执行执行这个Advice增强功能。

TransactionAttributeSourceAdvisor中包含了一个`TransactionInterceptor`,也是一个Advice，因此最终 `@Transactional`就会最终实现事务的增强功能。
- 
## 事务执行原理

![](https://cdn.jsdelivr.net/gh/zhaohongxuan/picgo@master/20220404183527.png)

一个Bean在执行Bean的创建生命周期时，会经过 `InfrastructureAdvisorAutoProxyCreator` 的初始化后的方法，会判断当前当前Bean对象是否和 `BeanFactoryTransactionAttributeSourceAdvisor` 匹配。

匹配逻辑为判断该Bean的类上是否存在 `@Transactional` 注解，或者类中的某个方法上是否存在 `@Transactional`注解，如果存在则表示该Bean需要进行动态代理产生一个代理对象作为Bean对象。

该代理对象在执行某个方法时，会再次判断当前执行的方法是否和`BeanFactoryTransactionAttributeSourceAdvisor`匹配，如果匹配则执行该Advisor中的 TransactionInterceptor的invoke()方法，执行基本流程为：

1.  利用所配置的`PlatformTransactionManager`事务管理器新建一个数据库连接
2.  修改数据库连接的`autocommit`为false
3.  执行`MethodInvocation.proceed()`方法，简单理解就是执行业务方法，其中就会执行sql
4.  如果没有抛异常，则提交
5.  如果抛了异常，则回滚


TransactionInterceptor构造函数传入了一个TransactionManager 来管理事务

```java
public TransactionInterceptor(TransactionManager ptm, TransactionAttributeSource tas) {  
   setTransactionManager(ptm);  
   setTransactionAttributeSource(tas);  
}
```

调用Advice的 invoke方法之后最终调用的是父类TransactionAspectSupport的invokeWithinTransaction来进行实际处理
```java
public Object invoke(MethodInvocation invocation) throws Throwable {  
   // Work out the target class: may be {@code null}.  
 // The TransactionAttributeSource should be passed the target class // as well as the method, which may be from an interface. Class<?> targetClass = (invocation.getThis() != null ? AopUtils.getTargetClass(invocation.getThis()) : null);  
  
   // Adapt to TransactionAspectSupport's invokeWithinTransaction...  
 return invokeWithinTransaction(invocation.getMethod(), targetClass, new CoroutinesInvocationCallback() {  
      @Override  
 @Nullable public Object proceedWithInvocation() throws Throwable {  
         return invocation.proceed();  
      }  
      @Override  
 public Object getTarget() {  
         return invocation.getThis();  
      }  
      @Override  
 public Object[] getArguments() {  
         return invocation.getArguments();  
      }  
   });  
}
```



## References
1.  https://zhuanlan.zhihu.com/p/54067384
2. https://juejin.cn/post/7018541168635936775
