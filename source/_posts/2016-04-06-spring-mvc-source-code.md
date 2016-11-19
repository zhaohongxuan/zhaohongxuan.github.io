---
layout: post
title: Spring MVC源码探究
date: 2016-04-06
tags: [spring ,java]
category: spring框架
---


作为一名合格的java程序员，要多深入学习一些框架，理解框架的设计的方法，背后的原理，spring mvc框架中使用了很多设计模式，比如`策略模式`，Spring MVC中大量使用了策略模式，像HandlerMapping接口，HandlerAdapter接口,ViewResolver接口
都使用了策略模式，在执行`handler`和`Interceptor`拦截器的时候使用了`责任链模式`，在`执行handler`的时候会用到`适配器模式`等等，可以说沉淀了很多前辈的精华，想成为架构师的话，学习源码必不可少，下面就围绕着Spring MVC 的前端控制器
`DispatcherServlet`一步一步的来学习Spring MVC的源码。
### 1 web.xml中DispatcherServlet的配置

web.xml中的Spring MVC的前端控制器DispatcherServlet的配置，所有后端Controller的请求都由这个`DispatcherServlet`分发。

```xml
<servlet>
        <servlet-name>MySpringServlet</servlet-name>
        <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
        <init-param>
            <param-name>contextConfigLocation</param-name>
            <param-value>classpath:spring/spring-mvc.xml</param-value>
        </init-param>
    </servlet>
    <servlet-mapping>
        <servlet-name>MySpringServlet</servlet-name>
        <url-pattern>/</url-pattern>
    </servlet-mapping>
```
<!-- more -->

#### DispatcherServlet 类等级视图
![类等级视图](../../../static/images/spring-mvc.png)


#### DispactcherServlet 中的doService()方法

```java
/**
	 * Exposes the DispatcherServlet-specific request attributes and delegates to {@link #doDispatch}
	 * for the actual dispatching.
	 */
	@Override
	protected void doService(HttpServletRequest request, HttpServletResponse response) throws Exception {
		if (logger.isDebugEnabled()) {
			String resumed = WebAsyncUtils.getAsyncManager(request).hasConcurrentResult() ? " resumed" : "";
			logger.debug("DispatcherServlet with name '" + getServletName() + "'" + resumed +
					" processing " + request.getMethod() + " request for [" + getRequestUri(request) + "]");
		}

		// Keep a snapshot of the request attributes in case of an include,
		// to be able to restore the original attributes after the include.
		Map<String, Object> attributesSnapshot = null;
		if (WebUtils.isIncludeRequest(request)) {
			attributesSnapshot = new HashMap<String, Object>();
			Enumeration<?> attrNames = request.getAttributeNames();
			while (attrNames.hasMoreElements()) {
				String attrName = (String) attrNames.nextElement();
				if (this.cleanupAfterInclude || attrName.startsWith("org.springframework.web.servlet")) {
					attributesSnapshot.put(attrName, request.getAttribute(attrName));
				}
			}
		}

		// Make framework objects available to handlers and view objects.
		request.setAttribute(WEB_APPLICATION_CONTEXT_ATTRIBUTE, getWebApplicationContext());
		request.setAttribute(LOCALE_RESOLVER_ATTRIBUTE, this.localeResolver);
		request.setAttribute(THEME_RESOLVER_ATTRIBUTE, this.themeResolver);
		request.setAttribute(THEME_SOURCE_ATTRIBUTE, getThemeSource());

		FlashMap inputFlashMap = this.flashMapManager.retrieveAndUpdate(request, response);
		if (inputFlashMap != null) {
			request.setAttribute(INPUT_FLASH_MAP_ATTRIBUTE, Collections.unmodifiableMap(inputFlashMap));
		}
		request.setAttribute(OUTPUT_FLASH_MAP_ATTRIBUTE, new FlashMap());
		request.setAttribute(FLASH_MAP_MANAGER_ATTRIBUTE, this.flashMapManager);

		try {
		    //执行dispatch方法
			doDispatch(request, response);
		}
		finally {
			if (WebAsyncUtils.getAsyncManager(request).isConcurrentHandlingStarted()) {
				return;
			}
			// Restore the original attribute snapshot, in case of an include.
			if (attributesSnapshot != null) {
				restoreAttributesAfterInclude(request, attributesSnapshot);
			}
		}
	}
```
doService方法实现了抽象类`FrameworkServlet`的`doService`方法，在doService方法中调用了doDispatcher()方法处理分发请求

### 2.DipatcherServlet的doDispatcher()方法

doService方法中将请求委托给doDispatch()方法由`doDispatch()`来分发相应的请求给各个Handler(Controller),我在每一个关键步骤上标注了注释，下面还有相应的源码解释。

```java
 /**
	 * Process the actual dispatching to the handler.
	 * <p>The handler will be obtained by applying the servlet's HandlerMappings in order.
	 * The HandlerAdapter will be obtained by querying the servlet's installed HandlerAdapters
	 * to find the first that supports the handler class.
	 * <p>All HTTP methods are handled by this method. It's up to HandlerAdapters or handlers
	 * themselves to decide which methods are acceptable.
	 * @param request current HTTP request
	 * @param response current HTTP response
	 * @throws Exception in case of any kind of processing failure
	 */
	protected void doDispatch(HttpServletRequest request, HttpServletResponse response) throws Exception {
		HttpServletRequest processedRequest = request;
		HandlerExecutionChain mappedHandler = null;
		boolean multipartRequestParsed = false;

		WebAsyncManager asyncManager = WebAsyncUtils.getAsyncManager(request);

		try {
			ModelAndView mv = null;
			Exception dispatchException = null;

			try {
			    //1.检测是否是多媒体请求，比如文件上传，将HttpServletRequest包装为MultipartHttpServletRequest
				processedRequest = checkMultipart(request);
				multipartRequestParsed = processedRequest != request;

				//2.遍历所有的HandlerMapper对象根据请求的URL获得相应的HandlerExecutionChain，其中HandlerMapping是一个
				//接口，Spring给出了一个默认的实现配置在DispatcherServlet.properties文件中，如果找不到对应的HandlerMap//per，spring会给出提示 No mapping found for HTTP request with URI...
		
				mappedHandler = getHandler(processedRequest);
				if (mappedHandler == null || mappedHandler.getHandler() == null) {
					noHandlerFound(processedRequest, response);
					return;
				}

				//3.根据当前的request遍历所有的Adapter选择第一个支持的adapter，这里使用了责任链模式
				HandlerAdapter ha = getHandlerAdapter(mappedHandler.getHandler());

				// Process last-modified header, if supported by the handler.
				//4.处理 last-modified header 判断是否被handler支持
				String method = request.getMethod();
				boolean isGet = "GET".equals(method);
				if (isGet || "HEAD".equals(method)) {
					long lastModified = ha.getLastModified(request, mappedHandler.getHandler());
					if (logger.isDebugEnabled()) {
						logger.debug("Last-Modified value for [" + getRequestUri(request) + "] is: " + lastModified);
					}
					if (new ServletWebRequest(request, response).checkNotModified(lastModified) && isGet) {
						return;
					}
				}
                //5.执行handler的拦截器的preHandle方法
				if (!mappedHandler.applyPreHandle(processedRequest, response)) {
					return;
				}

				try {
					// 6.调用真正的handler，处理业务代码
					mv = ha.handle(processedRequest, response, mappedHandler.getHandler());
				}
				finally {
					if (asyncManager.isConcurrentHandlingStarted()) {
						return;
					}
				}
				applyDefaultViewName(request, mv);
				//7.执行handler的拦截器的postHandle方法
				mappedHandler.applyPostHandle(processedRequest, response, mv);
			}
			catch (Exception ex) {
				dispatchException = ex;
			}
			//8.处理返回结果视图
			processDispatchResult(processedRequest, response, mappedHandler, mv, dispatchException);
		}
		catch (Exception ex) {
			triggerAfterCompletion(processedRequest, response, mappedHandler, ex);
		}
		catch (Error err) {
			triggerAfterCompletionWithError(processedRequest, response, mappedHandler, err);
		}
		finally {
			if (asyncManager.isConcurrentHandlingStarted()) {
				// Instead of postHandle and afterCompletion
				mappedHandler.applyAfterConcurrentHandlingStarted(processedRequest, response);
				return;
			}
			// Clean up any resources used by a multipart request.
			if (multipartRequestParsed) {
				cleanupMultipart(processedRequest);
			}
		}
	}
```


#### 1. 根据request获得所有的HandlerMapping并匹配一个合适的Handler（Controller）

AbstractHandlerMapping实现了HandlerMapping接口

```java
    1：遍历所有intercepter，取指定接口的拦截器bean
    2：根据url找到对应的hander
    3：封装成chain
    @Override
	public final HandlerExecutionChain getHandler(HttpServletRequest request) throws Exception {
		Object handler = getHandlerInternal(request);
		if (handler == null) {
			handler = getDefaultHandler();
		}
		if (handler == null) {
			return null;
		}
		// Bean name or resolved handler?
		if (handler instanceof String) {
			String handlerName = (String) handler;
			handler = getApplicationContext().getBean(handlerName);
		}
		return getHandlerExecutionChain(handler, request);
	}
	
/**
	protected HandlerExecutionChain getHandlerExecutionChain(Object handler, HttpServletRequest request) {
		HandlerExecutionChain chain = (handler instanceof HandlerExecutionChain ?
				(HandlerExecutionChain) handler : new HandlerExecutionChain(handler));
		chain.addInterceptors(getAdaptedInterceptors());

		String lookupPath = this.urlPathHelper.getLookupPathForRequest(request);
		for (MappedInterceptor mappedInterceptor : this.mappedInterceptors) {
			if (mappedInterceptor.matches(lookupPath, this.pathMatcher)) {
				chain.addInterceptor(mappedInterceptor.getInterceptor());
			}
		}

		return chain;
	}

```

AbstractUrlHandlerMapping继承了AbstractHandlerMapping重写了getHandlerInternal()抽象方法。这个方法给出了根据请求的URL获得handler的实现方法。

```java
/**
	 * Look up a handler for the URL path of the given request.
	 * @param request current HTTP request
	 * @return the handler instance, or {@code null} if none found
	 */
	@Override
	protected Object getHandlerInternal(HttpServletRequest request) throws Exception {
		String lookupPath = getUrlPathHelper().getLookupPathForRequest(request);
		Object handler = lookupHandler(lookupPath, request);
		if (handler == null) {
			// We need to care for the default handler directly, since we need to
			// expose the PATH_WITHIN_HANDLER_MAPPING_ATTRIBUTE for it as well.
			Object rawHandler = null;
			if ("/".equals(lookupPath)) {
				rawHandler = getRootHandler();
			}
			if (rawHandler == null) {
				rawHandler = getDefaultHandler();
			}
			if (rawHandler != null) {
				// Bean name or resolved handler?
				if (rawHandler instanceof String) {
					String handlerName = (String) rawHandler;
					rawHandler = getApplicationContext().getBean(handlerName);
				}
				validateHandler(rawHandler, request);
				handler = buildPathExposingHandler(rawHandler, lookupPath, lookupPath, null);
			}
		}
		if (handler != null && logger.isDebugEnabled()) {
			logger.debug("Mapping [" + lookupPath + "] to " + handler);
		}
		else if (handler == null && logger.isTraceEnabled()) {
			logger.trace("No handler mapping found for [" + lookupPath + "]");
		}
		return handler;
	}
```

#### 2.获得HandlerExecutionChain

```java
/**
	 * Return the HandlerExecutionChain for this request.
	 * <p>Tries all handler mappings in order.
	 * @param request current HTTP request
	 * @return the HandlerExecutionChain, or {@code null} if no handler could be found
	 */
	protected HandlerExecutionChain getHandler(HttpServletRequest request) throws Exception {
		for (HandlerMapping hm : this.handlerMappings) {
			if (logger.isTraceEnabled()) {
				logger.trace(
						"Testing handler map [" + hm + "] in DispatcherServlet with name '" + getServletName() + "'");
			}
			HandlerExecutionChain handler = hm.getHandler(request);
			if (handler != null) {
				return handler;
			}
		}
		return null;
	}
```

HandlerExecutionChain是由一系列的Handler和HandlerInterceptor组成的责任链，下面是HandlerExecutionChain中的成员变量

```java
private static final Log logger = LogFactory.getLog(HandlerExecutionChain.class);

	private final Object handler;

	private HandlerInterceptor[] interceptors;

	private List<HandlerInterceptor> interceptorList;

	private int interceptorIndex = -1;
```


#### 3.根据相应的handler去获得合适的HandlerAdapter

HandlerAdapter

```java

package org.springframework.web.servlet;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public interface HandlerAdapter {


	boolean supports(Object handler);


	ModelAndView handle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception;


	long getLastModified(HttpServletRequest request, Object handler);

}

```

HandlerAdapter的实现类HttpRequestHandlerAdapter，在`DispatcherServlet.properties`文件配置的默认实现的其中之一，在HandlerAdapter中执行Handler（Controller）的方法，并且给前端控制器`DispatcherServlet`返回一个`ModelAndView`


```java
/*
 * Copyright 2002-2012 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.springframework.web.servlet.mvc;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.web.HttpRequestHandler;
import org.springframework.web.servlet.HandlerAdapter;
import org.springframework.web.servlet.ModelAndView;

/**
 * Adapter to use the plain {@link org.springframework.web.HttpRequestHandler}
 * interface with the generic {@link org.springframework.web.servlet.DispatcherServlet}.
 * Supports handlers that implement the {@link LastModified} interface.
 */
public class HttpRequestHandlerAdapter implements HandlerAdapter {

    //判断是否适配当前adapter
	@Override
	public boolean supports(Object handler) {
		return (handler instanceof HttpRequestHandler);
	}

	@Override
	public ModelAndView handle(HttpServletRequest request, HttpServletResponse response, Object handler)
			throws Exception {

		((HttpRequestHandler) handler).handleRequest(request, response);
		return null;
	}

	@Override
	public long getLastModified(HttpServletRequest request, Object handler) {
		if (handler instanceof LastModified) {
			return ((LastModified) handler).getLastModified(request);
		}
		return -1L;
	}

}

```

HttpRequestHandler接口的实现类ResourceHttpRequestHandler,handleRequest()方法用来处理请求返回结果，数据转化，数据校验，格式化等操作都是在这一步进行。比如自动将Json数据转换为对应的实体等。

```java

	/**
	 * Processes a resource request.
	 * <p>Checks for the existence of the requested resource in the configured list of locations.
	 * If the resource does not exist, a {@code 404} response will be returned to the client.
	 * If the resource exists, the request will be checked for the presence of the
	 * {@code Last-Modified} header, and its value will be compared against the last-modified
	 * timestamp of the given resource, returning a {@code 304} status code if the
	 * {@code Last-Modified} value  is greater. If the resource is newer than the
	 * {@code Last-Modified} value, or the header is not present, the content resource
	 * of the resource will be written to the response with caching headers
	 * set to expire one year in the future.
	 */
	@Override
	public void handleRequest(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		checkAndPrepare(request, response, true);

		// check whether a matching resource exists
		Resource resource = getResource(request);
		if (resource == null) {
			logger.debug("No matching resource found - returning 404");
			response.sendError(HttpServletResponse.SC_NOT_FOUND);
			return;
		}

		// check the resource's media type
		MediaType mediaType = getMediaType(resource);
		if (mediaType != null) {
			if (logger.isDebugEnabled()) {
				logger.debug("Determined media type '" + mediaType + "' for " + resource);
			}
		}
		else {
			if (logger.isDebugEnabled()) {
				logger.debug("No media type found for " + resource + " - not sending a content-type header");
			}
		}

		// header phase
		if (new ServletWebRequest(request, response).checkNotModified(resource.lastModified())) {
			logger.debug("Resource not modified - returning 304");
			return;
		}
		setHeaders(response, resource, mediaType);

		// content phase
		if (METHOD_HEAD.equals(request.getMethod())) {
			logger.trace("HEAD request - skipping content");
			return;
		}
		writeContent(response, resource);
	}
```


#### 4.处理返回结果视图

处理异常视图

```java
/**
	 * Handle the result of handler selection and handler invocation, which is
	 * either a ModelAndView or an Exception to be resolved to a ModelAndView.
	 */
	private void processDispatchResult(HttpServletRequest request, HttpServletResponse response,
			HandlerExecutionChain mappedHandler, ModelAndView mv, Exception exception) throws Exception {

		boolean errorView = false;

		if (exception != null) {
			if (exception instanceof ModelAndViewDefiningException) {
				logger.debug("ModelAndViewDefiningException encountered", exception);
				mv = ((ModelAndViewDefiningException) exception).getModelAndView();
			}
			else {
				Object handler = (mappedHandler != null ? mappedHandler.getHandler() : null);
				//处理异常视图
				mv = processHandlerException(request, response, handler, exception);
				errorView = (mv != null);
			}
		}

		// Did the handler return a view to render?
		if (mv != null && !mv.wasCleared()) {
			render(mv, request, response);
			if (errorView) {
				WebUtils.clearErrorRequestAttributes(request);
			}
		}
		else {
			if (logger.isDebugEnabled()) {
				logger.debug("Null ModelAndView returned to DispatcherServlet with name '" + getServletName() +
						"': assuming HandlerAdapter completed request handling");
			}
		}

		if (WebAsyncUtils.getAsyncManager(request).isConcurrentHandlingStarted()) {
			// Concurrent handling started during a forward
			return;
		}

		if (mappedHandler != null) {
			mappedHandler.triggerAfterCompletion(request, response, null);
		}
	}
	

```


渲染指定的 ModelAndView
	
```java
/**
 * Render the given ModelAndView.
 * <p>This is the last stage in handling a request. It may involve resolving the view by name.
 * @param mv the ModelAndView to render
 * @param request current HTTP servlet request
 * @param response current HTTP servlet response
 * @throws ServletException if view is missing or cannot be resolved
 * @throws Exception if there's a problem rendering the view
 */
protected void render(ModelAndView mv, HttpServletRequest request, HttpServletResponse response) throws Exception {
	// Determine locale for request and apply it to the response.
	Locale locale = this.localeResolver.resolveLocale(request);
	response.setLocale(locale);

	View view;
	if (mv.isReference()) {
		// We need to resolve the view name.
		view = resolveViewName(mv.getViewName(), mv.getModelInternal(), locale, request);
		if (view == null) {
			throw new ServletException("Could not resolve view with name '" + mv.getViewName() +
					"' in servlet with name '" + getServletName() + "'");
		}
	}
	else {
		// No need to lookup: the ModelAndView object contains the actual View object.
		view = mv.getView();
		if (view == null) {
			throw new ServletException("ModelAndView [" + mv + "] neither contains a view name nor a " +
					"View object in servlet with name '" + getServletName() + "'");
		}
	}

	// Delegate to the View object for rendering.
	if (logger.isDebugEnabled()) {
		logger.debug("Rendering view [" + view + "] in DispatcherServlet with name '" + getServletName() + "'");
	}
	try {
		view.render(mv.getModelInternal(), request, response);
	}
	catch (Exception ex) {
		if (logger.isDebugEnabled()) {
			logger.debug("Error rendering view [" + view + "] in DispatcherServlet with name '" +
					getServletName() + "'", ex);
		}
		throw ex;
	}
}
```

### 3.DispatcherServlet.properties

DispatcherServlet.properties中配置的一些DispatcherServlet的一些策略模式接口的实现，包括HandlerMapping，HandlerAdapter，ViewResolver等

```java
# Default implementation classes for DispatcherServlet's strategy interfaces.
# Used as fallback when no matching beans are found in the DispatcherServlet context.
# Not meant to be customized by application developers.

org.springframework.web.servlet.LocaleResolver=org.springframework.web.servlet.i18n.AcceptHeaderLocaleResolver

org.springframework.web.servlet.ThemeResolver=org.springframework.web.servlet.theme.FixedThemeResolver

org.springframework.web.servlet.HandlerMapping=org.springframework.web.servlet.handler.BeanNameUrlHandlerMapping,\
	org.springframework.web.servlet.mvc.annotation.DefaultAnnotationHandlerMapping

org.springframework.web.servlet.HandlerAdapter=org.springframework.web.servlet.mvc.HttpRequestHandlerAdapter,\
	org.springframework.web.servlet.mvc.SimpleControllerHandlerAdapter,\
	org.springframework.web.servlet.mvc.annotation.AnnotationMethodHandlerAdapter

org.springframework.web.servlet.HandlerExceptionResolver=org.springframework.web.servlet.mvc.annotation.AnnotationMethodHandlerExceptionResolver,\
	org.springframework.web.servlet.mvc.annotation.ResponseStatusExceptionResolver,\
	org.springframework.web.servlet.mvc.support.DefaultHandlerExceptionResolver

org.springframework.web.servlet.RequestToViewNameTranslator=org.springframework.web.servlet.view.DefaultRequestToViewNameTranslator

org.springframework.web.servlet.ViewResolver=org.springframework.web.servlet.view.InternalResourceViewResolver

org.springframework.web.servlet.FlashMapManager=org.springframework.web.servlet.support.SessionFlashMapManager
```


### 4.总结
下图是Spring MVC 工作流程的时序图

![Spring MVC 工作流程的时序图](../../../static/images/1365825551_8302.png)



    1. 用户向服务器发送请求，请求被Spring 前端控制Servelt DispatcherServlet捕获；
    2. DispatcherServlet对请求URL进行解析，得到请求资源标识符（URI）。然后根据该URI，调用HandlerMapping获得该Handler配置的所有相关的对象（包括Handler对象以及Handler对象对应的拦截器），最后以HandlerExecutionChain对象的形式返回；
    3. DispatcherServlet 根据获得的Handler，选择一个合适的HandlerAdapter。（附注：如果成功获得HandlerAdapter后，此时将开始执行拦截器的preHandler(...)方法）
    4. 提取Request中的模型数据，填充Handler入参，开始执行Handler（Controller)。 在填充Handler的入参过程中，根据你的配置，Spring将帮你做一些额外的工作：
          HttpMessageConveter： 将请求消息（如Json、xml等数据）转换成一个对象，将对象转换为指定的响应信息
          数据转换：对请求消息进行数据转换。如String转换成Integer、Double等
          数据根式化：对请求消息进行数据格式化。 如将字符串转换成格式化数字或格式化日期等
          数据验证： 验证数据的有效性（长度、格式等），验证结果存储到BindingResult或Error中
    5.  Handler执行完成后，向DispatcherServlet 返回一个ModelAndView对象；
    6.  根据返回的ModelAndView，选择一个适合的ViewResolver（必须是已经注册到Spring容器中的ViewResolver)返回给DispatcherServlet ；
    7.  ViewResolver 结合Model和View，来渲染视图
    8.  将渲染结果返回给客户端。
