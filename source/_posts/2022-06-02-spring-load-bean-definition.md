---
title: Spring是如何加载BeanDefinition的？
alias: Spring加载BeanDefinition源码解析
date: 2022-06-02 07:58
tags: [java/spring,源码分析]
category: 源码解析
---

Spring Bean生命周期中，BeanDefinition是最重要的部分，在初始化和实例化Bean之前，首先要把所有的需要Spring管理的Bean对应的BeanDefinition加载到Spring容器中，这一步非常关键，因为BeanDefinition是Bean关联的元数据，这一篇文章就以`AnnotationConfigApplicationContext`来分析一下Spring容器是如何加载BeanDefinition的。

## 第一阶段：扫描Class文件加载BeanDefinition

```java

public AnnotationConfigApplicationContext(String... basePackages) {  
   this();  
   scan(basePackages);  
   refresh();  
}
```
我们先以package的方式来分析，初始化`AnnotationConfigApplicationContext`的时候会scan对应的包路径，然后进行refresh

scan的动作是在`ClassPathBeanDefinitionScanner`的doScan方法中完成的,主要任务是查找classpath下面的Class文件，判断是否为Bean，然后生成BeanDefinition。

<!-- more -->

主要源码为：

```java
protected Set<BeanDefinitionHolder> doScan(String... basePackages) {  

   Set<BeanDefinitionHolder> beanDefinitions = new LinkedHashSet<>();  
   for (String basePackage : basePackages) {  
      Set<BeanDefinition> candidates = findCandidateComponents(basePackage);  
      for (BeanDefinition candidate : candidates) {  
         ScopeMetadata scopeMetadata = this.scopeMetadataResolver.resolveScopeMetadata(candidate);  
         candidate.setScope(scopeMetadata.getScopeName());  
         String beanName = this.beanNameGenerator.generateBeanName(candidate, this.registry);  
         if (candidate instanceof AbstractBeanDefinition) {  
            postProcessBeanDefinition((AbstractBeanDefinition) candidate, beanName);  
         }  
         if (candidate instanceof AnnotatedBeanDefinition) {  
            AnnotationConfigUtils.processCommonDefinitionAnnotations((AnnotatedBeanDefinition) candidate);  
         }  
         if (checkCandidate(beanName, candidate)) {  
            BeanDefinitionHolder definitionHolder = new BeanDefinitionHolder(candidate, beanName);  
            definitionHolder =  
                  AnnotationConfigUtils.applyScopedProxyMode(scopeMetadata, definitionHolder, this.registry);  
            beanDefinitions.add(definitionHolder);  
            registerBeanDefinition(definitionHolder, this.registry);  
         }  
      }  
   }  
   return beanDefinitions;  
}
```


### 查找候选Component的BeanDefinition集合

这部分代码主要在ClassPathScanningCandidateComponentProvider

1.  将包名转换为path, 通过ResourcePatternResolver来解析得到Class文件的Resource列表， 这里使用了Strategy模式来解析不同类型的资源。
2. 遍历Resource List通过ASM技术将Resource封装为MetadataReader, 这里不使用反射是为了减少内存占用，使用反射必须先将Class文件Load进JVM中，这里使用了Factory模式 来获取MetadataReader
3. 判断是不是候选Component,
	1. 首先判断是不是在excludeFilters里，如果在excludeFilters里直接返回false
	2. 判断是不是在includeFilters里，如果在includeFilters里，返回true，否则返回false		
	3. 在创建AnnotationConfigApplicationContext的时候默认加载几个DefaultIncludeFilter, 也就是有`@Component`注解或者JSR-250注解 `@javax.inject.Named` 或者`javax.annotation.ManagedBean`, 在这里@Service 和@Controller都是有@Component，所以也都会被扫描到。
	4. 创建ScannedGenericBeanDefinition 它的作用是 保存ASM 扫描出来的注解元数据信息
	5. 根据AnnotatedBeanDefinition判断是不是一个Component
		1. 独立类，不能是内部类，可以是嵌套类
		2. 非抽象类或者接口
		3. 有Lookup方法的抽象类

### 遍历符合条件的Component的BeanDefinition集合

1. 解析ScopeMetadata,默认是Singleton,ScopedProxyMode是NO，ScopedProxyMode主要是非单例的Scope上使用，可以配置使用CGlib代理或者JDK动态代理
2. 使用BeanNameGenerator生成BeanName，这里使用了Singlenton模式, 如果注解上有beanName就使用注解上的，没有的话就根据类名生成一个BeanName
3. 如果是AbstractBeanDefinition则给BeanDefinition设置默认属性
4. 如果是AnnotatedBeanDefinition则解析Component上的注解比如@Lazy，@Primary等属性到BeanDefination中
5. 检查Component, 判断容器中是不是已经存在这个Bean,如果存在，则判断对象是不是相等，如果不相等说明不合法，Spring抛出ConflictingBeanDefinitionException中断加载。
6. 创建BeanDefinitionHolder，主要是为了保存alias，默认alias为空
7. 将beanDefinition注册到容器中，如果alias不为空，给bean注册alias，这里默认不注册

## 第二阶段：refresh过程中加载BeanDefinition

scan这一步，加载了classpath中的BeanDefinition，但是这一步只是最基础的，Spring容器在refresh阶段也留给用户一个hook方法，让用户在生成Bean之前能够自己操作BeanDefinition，这个hook就是`BeanDefinitionRegistryPostProcessor`我们可以自己自定义一个类实现它来自定义处理BeanDefinition。
Spring内部也有一些内置的BeanDefinitionRegistryPostProcessor，比如处理`@Configuration`的ConfigurationClassPostProcessor，Configuration Class中一般都会包含不少配置信息，比如`@Import`，`@Bean`等，我们就需要在bean实例化之前加载进Spring容器。

那么Configuration Class是什么时候处理的呢？ 答案是在 `refresh`阶段的`invokeBeanFactoryPostProcessors`中，主要源代码在下面`PostProcessorRegistrationDelegate`中的`invokeBeanFactoryPostProcessors`方法中。

因为ConfigurationClassPostProcessor实现了BeanDefinitionRegistryPostProcessor接口，所以会在这一步被调用，进而对ConfigurationClass进行解析。



### ConfigurationClassPostProcessor处理BeanDefinition解析

![](https://raw.githubusercontent.com/zhaohongxuan/picgo/master/20220604082945.png)


```java
public void postProcessBeanDefinitionRegistry(BeanDefinitionRegistry registry) {  
   int registryId = System.identityHashCode(registry);  
   if (this.registriesPostProcessed.contains(registryId)) {  
      throw new IllegalStateException(  
            "postProcessBeanDefinitionRegistry already called on this post-processor against " + registry);  
   }  
   if (this.factoriesPostProcessed.contains(registryId)) {  
      throw new IllegalStateException(  
            "postProcessBeanFactory already called on this post-processor against " + registry);  
   }  
   this.registriesPostProcessed.add(registryId);  
  
   processConfigBeanDefinitions(registry);  
}
```

其中processConfigBeanDefinitions 来处理ConfigBean，最重要的逻辑代码在 `ConfigurationClassParser`的`parse` ConfigurationClassParser 解析 和`doProcessConfigurationClass`方法中, 这个方法会处理main class上面的annotation，比如Component，ComponentScan等

### processConfigBeanDefinitions

在ConfigurationClassPostProcessor#postProcessBeanDefinitionRegistry里面主要就是扫描BeanDefinitionRegistry 处理里面的有@Configuration的类。

```java

public void processConfigBeanDefinitions(BeanDefinitionRegistry registry) {

for (String beanName : candidateNames) {  
   BeanDefinition beanDef = registry.getBeanDefinition(beanName); 

//1. 校验是不是@Configuration标注的Class，是的话放入configCandidates中
 if (ConfigurationClassUtils.checkConfigurationClassCandidate(beanDef, this.metadataReaderFactory)) {  
      configCandidates.add(new BeanDefinitionHolder(beanDef, beanName));  
   }  
}

//2. 创建 Parser
ConfigurationClassParser parser = new ConfigurationClassParser(  
      this.metadataReaderFactory, this.problemReporter, this.environment,  
      this.resourceLoader, this.componentScanBeanNameGenerator, registry);


do{

//3. parse Config类
parser.parse(candidates);  
parser.validate();  
  
Set<ConfigurationClass> configClasses = new LinkedHashSet<>(parser.getConfigurationClasses());

//4.加载BeanDefinition
this.reader.loadBeanDefinitions(configClasses);


} while(!candidates.isEmpty());

}

```

主要抽象成4步
- 校验是不是@Configuration标注的Class，是的话放入configCandidates中
- 创建 ConfigurationClassParser
- parse ConfigurationClass 
- 加载BeanDefinition

### 加载BeanDefinition

源码在ConfigurationClassBeanDefinitionReader#loadBeanDefinitionsForConfigurationClass

主要步骤为
- TrackedConditionEvaluator判断是否应该skip
- 注册import的class的BeanDefinition
- 注册@Bean标注的method
- 注册imported的resources的BeanDefinition, 比如说 `importXML`等
- 注册ImportBeanDefinitionRegistrar ，比如说各种`@EnableXXX`

```java
private void loadBeanDefinitionsForConfigurationClass(  
      ConfigurationClass configClass, TrackedConditionEvaluator trackedConditionEvaluator) {  
  
   if (trackedConditionEvaluator.shouldSkip(configClass)) {  
      String beanName = configClass.getBeanName();  
      if (StringUtils.hasLength(beanName) && this.registry.containsBeanDefinition(beanName)) {  
         this.registry.removeBeanDefinition(beanName);  
      }  
      this.importRegistry.removeImportingClass(configClass.getMetadata().getClassName());  
      return;  
   }  
  
   if (configClass.isImported()) {  
      registerBeanDefinitionForImportedConfigurationClass(configClass);  
   }  
   for (BeanMethod beanMethod : configClass.getBeanMethods()) {  
      loadBeanDefinitionsForBeanMethod(beanMethod);  
   }  
  
   loadBeanDefinitionsFromImportedResources(configClass.getImportedResources());  
   loadBeanDefinitionsFromRegistrars(configClass.getImportBeanDefinitionRegistrars());  
}
```


这里就看到了Spring boot中常见的`ImportBeanDefinitionRegistrar`的身影， 一般搭配`XXXAuthConfiguration`，`@ConditionalOnClass` 实现Springboot的自动装配功能。


## References
1. [Spring Reference Core Technologies](https://docs.spring.io/spring-framework/docs/current/reference/html/core.html#beans-annotation-config)
2. [GitHub - spring-projects/spring-framework: Spring Framework](https://github.com/spring-projects/spring-framework)