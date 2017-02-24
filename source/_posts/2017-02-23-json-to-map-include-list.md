---
layout: post
title: Java中将JSON反序列化为泛型对象
tags: [json]
date: 2017-02-23
category: java
---



将嵌套List的Map转换为Json应该都没什么问题，使用Gson和Jackson都能实现，在Gson中使用`new Gson().toJson()`方法，在Jackson中使用`new ObjectMapper().writeValueAsString()`即可。
将json转换为形如Map<String,List<Long>>的时候遇到了一点问题，虽然返回类型是`Map<String,List<Long>>`但是，Map的value的值却并不是`List<Long>`,而是`Integer`类型的，这里面显然是有问题的，查看Jackson的源码和Gson的源码发现
将json反序列化为对象确实有两个方法，一种适用于泛型对象，一种适用于非泛型的一般对象。



### 使用Gson

在gson中将json字符串转反序列化为对象有两个方法：

```java

  /**
   * This method deserializes the specified Json into an object of the specified class. It is not
   * suitable to use if the specified class is a generic type since it will not have the generic
   * type information because of the Type Erasure feature of Java. Therefore, this method should not
   * be used if the desired type is a generic type. Note that this method works fine if the any of
   * the fields of the specified object are generics, just the object itself should not be a
   * generic type. For the cases when the object is of generic type, invoke
   * {@link #fromJson(String, Type)}. If you have the Json in a {@link Reader} instead of
   * a String, use {@link #fromJson(Reader, Class)} instead.
   *
   * @param <T> the type of the desired object
   * @param json the string from which the object is to be deserialized
   * @param classOfT the class of T
   * @return an object of type T from the string. Returns {@code null} if {@code json} is {@code null}.
   * @throws JsonSyntaxException if json is not a valid representation for an object of type
   * classOfT
   */
 public <T> T fromJson(String json, Class<T> classOfT) throws JsonSyntaxException {
    Object object = fromJson(json, (Type) classOfT);
    return Primitives.wrap(classOfT).cast(object);
  }

  /**
   * This method deserializes the specified Json into an object of the specified type. This method
   * is useful if the specified object is a generic type. For non-generic objects, use
   * {@link #fromJson(String, Class)} instead. If you have the Json in a {@link Reader} instead of
   * a String, use {@link #fromJson(Reader, Type)} instead.
   *
   * @param <T> the type of the desired object
   * @param json the string from which the object is to be deserialized
   * @param typeOfT The specific genericized type of src. You can obtain this type by using the
   * {@link com.google.gson.reflect.TypeToken} class. For example, to get the type for
   * {@code Collection<Foo>}, you should use:
   * <pre>
   * Type typeOfT = new TypeToken&lt;Collection&lt;Foo&gt;&gt;(){}.getType();
   * </pre>
   * @return an object of type T from the string. Returns {@code null} if {@code json} is {@code null}.
   * @throws JsonParseException if json is not a valid representation for an object of type typeOfT
   * @throws JsonSyntaxException if json is not a valid representation for an object of type
   */
  @SuppressWarnings("unchecked")
  public <T> T fromJson(String json, Type typeOfT) throws JsonSyntaxException {
    if (json == null) {
      return null;
    }
    StringReader reader = new StringReader(json);
    T target = (T) fromJson(reader, typeOfT);
    return target;
  }
```

<!-- more -->

观察`fromJson(String json, Class<T> classOfT)`的注释：

>It is not suitable to use if the specified class is a generic type since it will not have the generic type information because of the Type Erasure feature of Java

也就是说，由于Java泛型的擦除机制，这个方法不适用于传入泛型的类，比如`Map<String,Long>`,`List<String>`等，这个时候可以用`T fromJson(String json, Type typeOfT)`替代。

下面还有一段话：

>Note that this method works fine if the any of the fields of the specified object are generics, just the object itself should not be a generic type

** 注意：** 如果对象不是泛型的，只是字段是泛型的话这个方法是可以使用的

刚开始不太理解这句话，后来想通了，也就是`类定义`上不能带有泛型比如 `public interface Map<K,V>` 这样的就不行，但是如果是下面这样的只有域上带有的泛型是可以：

```java
static class JsonDemo{

		private List<Long> list;

		public List<Long> getList() {
			return list;
		}

		public void setList(List<Long> list) {
			this.list = list;
		}
	}

```


下面的`fromJson(String json, Type typeOfT)`就是专门提供给泛型类的对象使用的，如果你自己反序列化的对象带有泛型的话需要用这个方法。



### 使用Jackson

和gson一样，jackson也提供了两个方法，一个适用于普通的类，一个适用于泛型类，只不过jackson源码的注释没有Gson的丰富，从注释上看不出来，功能和Gson的一致。

```java
  /**
     * Method to deserialize JSON content from given JSON content String.
     * 
     * @throws IOException if a low-level I/O problem (unexpected end-of-input,
     *   network error) occurs (passed through as-is without additional wrapping -- note
     *   that this is one case where {@link DeserializationFeature#WRAP_EXCEPTIONS}
     *   does NOT result in wrapping of exception even if enabled)
     * @throws JsonParseException if underlying input contains invalid content
     *    of type {@link JsonParser} supports (JSON for default case)
     * @throws JsonMappingException if the input JSON structure does not match structure
     *   expected for result type (or has other mismatch issues)
     */
   @SuppressWarnings("unchecked")
    public <T> T readValue(String content, Class<T> valueType)
        throws IOException, JsonParseException, JsonMappingException
    {
        return (T) _readMapAndClose(_jsonFactory.createParser(content), _typeFactory.constructType(valueType));
    } 

    /**
     * Method to deserialize JSON content from given JSON content String.
     * 
     * @throws IOException if a low-level I/O problem (unexpected end-of-input,
     *   network error) occurs (passed through as-is without additional wrapping -- note
     *   that this is one case where {@link DeserializationFeature#WRAP_EXCEPTIONS}
     *   does NOT result in wrapping of exception even if enabled)
     * @throws JsonParseException if underlying input contains invalid content
     *    of type {@link JsonParser} supports (JSON for default case)
     * @throws JsonMappingException if the input JSON structure does not match structure
     *   expected for result type (or has other mismatch issues)
     */
    @SuppressWarnings({ "unchecked", "rawtypes" })
    public <T> T readValue(String content, TypeReference valueTypeRef)
        throws IOException, JsonParseException, JsonMappingException
    {
        return (T) _readMapAndClose(_jsonFactory.createParser(content), _typeFactory.constructType(valueTypeRef));
    } 
```
### 简单实验

使用两种方式反序列一个json，使用Class来反序列化泛型类型的对象，在`printType`的时候会出现`ClassCastException`类型转换异常。

```java
package org.xuan;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.collect.Maps;
import com.google.common.reflect.TypeToken;
import com.google.gson.Gson;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

/**
 * Created by zhaohongxuan
 */
public class JsonTest {
	private static ObjectMapper mapper = new ObjectMapper();
	private static Gson gson = new Gson();
	public static void main(String[] args) throws IOException {
		Map<String, List<Long>> map = Maps.newHashMap();
		map.put("one", Arrays.asList(10001L, 10002L, 10003L, 10004L));
		map.put("two", Arrays.asList(20001L, 20002L, 20003L, 20004L));
		map.put("three", Arrays.asList(30001L, 30002L, 30003L, 30004L));
		map.put("four", Arrays.asList(40001L, 40002L, 40003L, 40004L));

		String json = new Gson().toJson(map);
		System.err.println("=======================错误示范=====================");
		//Gson
		Map<String, List<Long>> mapResult  = gson.fromJson(json,Map.class);
		System.out.println("通过Gson转换...");
//		printType(mapResult);
		System.out.println(mapResult);
		//Json
		Map<String, List<Long>> jsonMapResult = mapper.readValue(json,Map.class);
		System.out.println("通过Jackson转换...");
//		printType(jsonMapResult);

		System.out.println(jsonMapResult);
		System.out.println("=======================正确做法=====================");
		//Gson
		Map<String, List<Long>> mapResult1  = gson.fromJson(json,new TypeToken<Map<String, List<Long>>>(){}.getType());
		System.out.println("通过Gson转换...");
		printType(mapResult1);
		System.out.println(mapResult1);
		//Json
		ObjectMapper mapper = new ObjectMapper();
		Map<String, List<Long>> jsonMapResult1 = mapper.readValue(json,new TypeReference< Map<String,List<Long>>>() {});
		System.out.println("通过Jackson转换...");
		printType(jsonMapResult1);

		System.out.println(jsonMapResult1);

	}

	public static void printType(Map<String, List<Long>> map){
		for (Map.Entry<String, List<Long>> entry: map.entrySet()){
			System.out.println("key 类型:"+entry.getKey().getClass()+", value类型:"
			+entry.getValue().getClass()+", List中元素类型"+entry.getValue().get(0).getClass());
		}

	}
}


```

### 总 结
在Gson中：
如果使用`fromJson(String json, Class<T> classOfT)`来反序列化Map的话，不会造成编译错误，返回的类型就会变化，Long类型变成了Double类型,使用的时候就会出现异常，例如在遍历Map的entrySet的时候就会出现异常。

```
    java.lang.ClassCastException: java.lang.Double cannot be cast to java.lang.Long

```


因此：
1. 反序列化`泛型对象`如Map<K,V>等需要使用 `fromJson(String json, Type typeOfT)`
2. 一般对象使用`fromJson(String json, Class<T> classOfT)`
在Jackson中：
如果使用`T readValue(String content, Class<T> valueType)`来反序列化Map的话，返回的类型就会由Long类型变成了Integer类型。
1. 反序列化`泛型对象`如Map<K,V>等需要使用 `T readValue(String content, TypeReference valueTypeRef)`
2. 一般对象使用`T readValue(String content, Class<T> valueType)`


