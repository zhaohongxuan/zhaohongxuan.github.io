---
title: Spring静态Bean的原理
date: 2022-09-21 20:46
tags: [java,spring]
category: 源码解析
---


最近遇到一个spring static bean的坑，我们知道使用Java Config的方式定义一个Bean 非常简单，只需在Configuration的method上加上 @Bean 注解即可。

但是这里有个例外，假如你的Bean不是一个普通的Bean，而是一个`BeanFactoryPostProcessor`就需要使用static方法来定义这个Bean。 否则你会得到一个警告：

` @Bean method TestConfig.customEditorConfigurer is non-static and returns an object assignable to Spring's BeanFactoryPostProcessor interface. This will result in a failure to process annotations such as @Autowired, @Resource and @PostConstruct within the method's declaring @Configuration class. Add the 'static' modifier to this method to avoid these container lifecycle issues; see @Bean javadoc for complete details.`

也就是说，如果你的bean是一个BFPP，必须定义为static，否则，使用@Autowired, @Resource and @PostConstruct 会有问题。

来看 @Bean注解源码里的注释：

```
Special consideration must be taken for @Bean methods that return Spring BeanFactoryPostProcessor (BFPP) types. 
Because BFPP objects must be instantiated very early in the container lifecycle,
they can interfere with processing of annotations such as @Autowired, @Value, and @PostConstruct within @Configuration classes. 

To avoid these lifecycle issues, mark BFPP-returning @Bean methods as static. For example:
      @Bean
      public static PropertySourcesPlaceholderConfigurer pspc() {
          // instantiate, configure and return pspc ...
      }
  
By marking this method as static, it can be invoked without causing instantiation of its declaring @Configuration class, thus avoiding the above-mentioned lifecycle conflicts. 
Note however that static @Bean methods will not be enhanced for scoping and AOP semantics as mentioned above. 
This works out in BFPP cases, as they are not typically referenced by other @Bean methods. 
As a reminder, a WARN-level log message will be issued for any non-static @Bean methods having a return type assignable to BeanFactoryPostProcessor.
```


因为BFPP都需要在在Spring容器的早期进行实例化，因为他们会干扰正常的Bean实例化中处理 @Autowired @Value @PostConstruct ，这篇Blog尝试寻找一下Static Bean背后的原理。

<!-- more -->

## 问题重现

我尝试简化一下模型来重现一下问题：

SpringBoot项目里有一个TestConfig类，在里面定义了一个特殊的Bean：customEditorConfigurer
因为CustomEditorConfigurer是一个BFPP，它的作用是注册自定义的类型转换器，Spring可以把String 转换为相对应的类型，这里我注册一个`UserEditor`，它的作用是将String转换为User对象，这样在使用@Value的时候就能实现自动类型转换，将配置文件里的字符串自动转换为一个User对象。

```java
@Configuration  
@Data  
public class TestConfig {  
  
    @Value("${test.user:hank}")  
    private User user;  
  
    @Bean  
    public CustomEditorConfigurer customEditorConfigurer() {  
        final CustomEditorConfigurer customEditorConfigurer = new CustomEditorConfigurer();  
        Map<Class<?>, Class<? extends PropertyEditor>> customEditors = new HashMap<>();  
        customEditors.put(User.class, UserEditor.class);  
        customEditorConfigurer.setCustomEditors(customEditors);  
        return customEditorConfigurer;  
    }  
}

@AllArgsConstructor  
@Data  
class User {  
    private String name;  
}

class UserEditor extends PropertyEditorSupport{  
  
    @Override  
    public void setAsText(String text) throws IllegalArgumentException {  
        User user = new User(text);  
        super.setValue(user);  
    }  
}

```

在一个Bean里依赖TestConfig 获取 user将会是null，假如我们把customEditorConfigurer()方法改为static将会能正确得拿到user信息：
```
==== get test user:User(name=hank)
```

```java
@SpringBootApplication  
public class BootDemoApplication implements ApplicationRunner {  
  
    @Autowired  
    TestConfig testConfig;  
  
    public static void main(String[] args) {  
        SpringApplication.run(BootDemoApplication.class, args);  
    }  
  
    @Override  
    public void run(ApplicationArguments args) {  
        System.out.println("==== get test user:" + testConfig.getUser();  
    }  
}
```


## 为什么BFPP需要定义成Static Bean？

### Static @Bean Definition注册

先来看下static bean和normal bean在BeanDefinition注册的有何不同，这个时候我们就需要看Spring源码了，@Bean BeanDefinition的注册是在
ConfigurationClassBeanDefinitionReader#loadBeanDefinitionsForConfigurationClass中的：

```java
private void loadBeanDefinitionsForConfigurationClass(  
      ConfigurationClass configClass, TrackedConditionEvaluator trackedConditionEvaluator) {  
  
	//...
   for (BeanMethod beanMethod : configClass.getBeanMethods()) {  
      loadBeanDefinitionsForBeanMethod(beanMethod);  
   }  
  
```

仔细看下loadBeanDefinitionsForBeanMethod
```java

private void loadBeanDefinitionsForBeanMethod(BeanMethod beanMethod) {
if (metadata.isStatic()) {  
   // static @Bean method  
   if (configClass.getMetadata() instanceof StandardAnnotationMetadata) {  
      beanDef.setBeanClass(((StandardAnnotationMetadata) configClass.getMetadata()).getIntrospectedClass());  
   }  
   else {  
      beanDef.setBeanClassName(configClass.getMetadata().getClassName());  
   }  
   beanDef.setUniqueFactoryMethodName(methodName);  
}  
else {  
   // instance @Bean method  
   beanDef.setFactoryBeanName(configClass.getBeanName());  
   beanDef.setUniqueFactoryMethodName(methodName);  
}
}
```
区别在于如果是static bean 会设置BeanClass而普通的Bean设置FactoryBeanName，这个在后面createBean的时候会用到。


### BeanPostProcessor Bean 的实例化

PostProcessorRegistrationDelegate的invokeBeanFactoryPostProcessors发生在所有Bean实例化之前

在BeanFactory中搜索所有BeanFactoryPostProcessor的beanName（就是上一步添加到bean dedefinition map）

```java
String[] postProcessorNames =  
      beanFactory.getBeanNamesForType(BeanFactoryPostProcessor.class, true, false);
```

然后给BFPP排序，按照实现 PriorityOrdered > Ordered > 一般 BFPP，这个时候会实例化BFPP

```java
beanFactory.getBean(postProcessorName, BeanFactoryPostProcessor.class)
```

实例化步骤和普通的Bean一样，先使用 BeanFactory.getBean(beanName) 获取Bean，这一步会触发createBean的操作
1. doCreateBean中直接调用createBeanInstance创建实例
2. createBeanInstance中instantiateUsingFactoryMethod 根据Factory Method来创建实例,委托给ConstructorResolver来进行创建，下面是关键代码：
		
```java
		String factoryBeanName = mbd.getFactoryBeanName();  
if (factoryBeanName != null) {  
   if (factoryBeanName.equals(beanName)) {  
      throw new BeanDefinitionStoreException(mbd.getResourceDescription(), beanName,  
            "factory-bean reference points back to the same bean definition");  
   }  
   factoryBean = this.beanFactory.getBean(factoryBeanName);  
   if (mbd.isSingleton() && this.beanFactory.containsSingleton(beanName)) {  
      throw new ImplicitlyAppearedSingletonException();  
   }  
   this.beanFactory.registerDependentBean(factoryBeanName, beanName);  
   factoryClass = factoryBean.getClass();  
   isStatic = false;  
}  
else {  
   // It's a static factory method on the bean class.  
   if (!mbd.hasBeanClass()) {  st
      throw new BeanDefinitionStoreException(mbd.getResourceDescription(), beanName,  
            "bean definition declares neither a bean class nor a factory-bean reference");  
   }  
   factoryBean = null;  
   factoryClass = mbd.getBeanClass();  
   isStatic = true;  
}
		```

如果factoryBeanName 不为空，说明是普通的Bean实例化, 需要先创建`FactoryBean` 可以理解成宿主Bean，如果是static factory method创建的Bean则不需要。

创建Bean之前需要先创建Factory Bean实例，在这里FactoryBean就是`testConfig` 这个实例，在创建testConfig实例的时候发现需要有依赖的@Value dependency，这个时候会去使用TypeConverter来将String转换为User，这个时候就有问题了，我们的UserEditor还没注册完成呢，testConfig是在customEditorConfigurer实例化的时候被创建的，所以这个

1. 创建customEditorConfigurer
2. 发现customEditorConfigurer不是static所以先要创建FactoryBean也就是testConfig
3. testConfig中依赖@Value，populateBean的时候需要调用UserEditor来做转换
4. UserEditor没有注册，因为customEditorConfigurer还没创建完成
5. 所以User就没有初始化，user就是null

如果是Static Bean的话就没有这个问题了，因为static bean 不需要依赖factoryBean来创建实例，而是直接调用的构造器来进行初始化的。


## References
- [Core Technologies](https://docs.spring.io/spring-framework/docs/current/reference/html/core.html#beans-java-basic-concepts)