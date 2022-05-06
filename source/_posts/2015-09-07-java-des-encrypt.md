---
layout: post
title:  "Java中使用DES对称加解密"
keywords: "java"
date: 2015-09-07
category: java
tags: java
---

## DES
DES(Data Encryption Standard),即数据加密算法。是IBM公司于1975年研究成功并公开发表的。DES算法的入口参数有三个:Key、Data、Mode。
其中Key为8个字节共64位,是DES算法的工作密钥;Data也为8个字节64位,是要被加密或被解密的数据;Mode为DES的工作方式,有两种:加密或解密。 

###  安卓端对请求Web服务器请求字符串进行加密

加密公共方法：

```java
package com.sz.kcygl.common.DESUtil;
import java.security.Key;
import java.security.SecureRandom;
import java.security.spec.AlgorithmParameterSpec;
import javax.crypto.Cipher;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.DESKeySpec;
import javax.crypto.spec.IvParameterSpec;
import com.sun.org.apache.xml.internal.security.utils.Base64;

public class DESUtil {
    public static final String ALGORITHM_DES = "DES/CBC/PKCS5Padding";

    /**
     * DES算法，加密
     *
     * @param data
     *            待加密字符串
     * @param key
     *            加密私钥，长度不能够小于8位
     * @return 加密后的字节数组，一般结合Base64编码使用
     * @throws CryptException
     *             异常
     */
    public static String encode(String key, String data) throws Exception {
        return encode(key, data.getBytes());
    }

    /**
     * DES算法，加密
     *
     * @param data
     *            待加密字符串
     * @param key
     *            加密私钥，长度不能够小于8位
     * @return 加密后的字节数组，一般结合Base64编码使用
     * @throws CryptException
     *             异常
     */
    public static String encode(String key, byte[] data) throws Exception {
        try {
            DESKeySpec dks = new DESKeySpec(key.getBytes());

            SecretKeyFactory keyFactory = SecretKeyFactory.getInstance("DES");
            // key的长度不能够小于8位字节
            Key secretKey = keyFactory.generateSecret(dks);
            Cipher cipher = Cipher.getInstance(ALGORITHM_DES);
            IvParameterSpec iv = new IvParameterSpec("12345678".getBytes());
            AlgorithmParameterSpec paramSpec = iv;
            cipher.init(Cipher.ENCRYPT_MODE, secretKey, paramSpec);

            byte[] bytes = cipher.doFinal(data);
            return Base64.encode(bytes);
        } catch (Exception e) {
            throw new Exception(e);
        }
    }

    /**
     * DES算法，解密
     *
     * @param data
     *            待解密字符串
     * @param key
     *            解密私钥，长度不能够小于8位
     * @return 解密后的字节数组
     * @throws Exception
     *             异常
     */
    public static byte[] decode(String key, byte[] data) throws Exception {
        try {
            SecureRandom sr = new SecureRandom();
            DESKeySpec dks = new DESKeySpec(key.getBytes());
            SecretKeyFactory keyFactory = SecretKeyFactory.getInstance("DES");
            // key的长度不能够小于8位字节
            Key secretKey = keyFactory.generateSecret(dks);
            Cipher cipher = Cipher.getInstance(ALGORITHM_DES);
            IvParameterSpec iv = new IvParameterSpec("12345678".getBytes());
            AlgorithmParameterSpec paramSpec = iv;
            cipher.init(Cipher.DECRYPT_MODE, secretKey, paramSpec);
            return cipher.doFinal(data);
        } catch (Exception e) {
            // e.printStackTrace();
            throw new Exception(e);
        }
    }

    /**
     * 获取编码后的值
     *
     * @param key
     * @param data
     * @return
     * @throws Exception
     * @throws Exception
     */
    public static String decodeValue(String key, String data) throws Exception {
        byte[] datas;
        String value = null;

        datas = decode(key, Base64.decode(data));

        value = new String(datas);
        if (value.equals("")) {
            throw new Exception();
        }
        return value;
    }

}


```
<!-- more -->

###  java后台服务器

通过一个拦截器，拦截掉所有需要拦截的路径


```java
package com.sz.kcygl.web.interceptor;

/**
 * Created by LittleXuan on 2015/8/31.
 */
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.sz.kcygl.common.DESUtil.MD5;
import com.sz.kcygl.common.DESUtil.DESUtil;
import net.sf.json.JSONObject;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;
import java.io.BufferedInputStream;

/**
 * @author 赵宏轩
 * 2015-08-31
 */
public class SignInterceptor extends HandlerInterceptorAdapter {
    protected final Log log = LogFactory.getLog(this.getClass());
    /**
     * 在业务处理器处理请求之前被调用
     * 如果返回false
     * 从当前的拦截器往回执行所有拦截器的afterCompletion(),再退出拦截器链
     * 如果返回true
     */
    @Override
    public boolean preHandle(HttpServletRequest request,
                             HttpServletResponse response, Object handler) throws Exception {
        String requestUri = request.getRequestURI();
        String contextPath = request.getContextPath();
        String url = requestUri.substring(contextPath.length());

        log.info("requestUri:" + requestUri);
        log.info("contextPath:" + contextPath);
        log.info("url:" + url);

        StringBuffer requestData=new StringBuffer();
        BufferedInputStream buf = new BufferedInputStream(request.getInputStream());
        byte[] buffer=new byte[1024];
        int iRead;
        while((iRead=buf.read(buffer))!=-1){
            requestData.append(new String(buffer,0,iRead,"utf-8"));
        }
        JSONObject jsonObject = JSONObject.fromObject(requestData.toString());

        String requestDES = jsonObject.getString("requestMessage");
        String signvalue = jsonObject.getString("sign");


        log.info("加密后的字符串："+requestDES);
        log.info("MD5签名："+signvalue);

        String afterDES="";
        if(StringUtils.isNotEmpty(requestDES)){
            afterDES = DESUtil.decodeValue("tiananapp", requestDES);
            log.info("解密后请求："+afterDES);
        }

        MD5 md5 =new MD5();
        String localSign = md5.getMD5ofStr("tiananapp"+afterDES);
        log.info("本地MD5签名："+localSign);
        if(signvalue!=null&&signvalue.equalsIgnoreCase(localSign)){
            request.setAttribute("requestMessage",afterDES); //将解密后的请求参数还原
            return true;
        }
        return false;
    }


}

```

### 在Spring MVC 配置文件添加拦截器配置

```xml
<mvc:interceptors>
		<mvc:interceptor>
			<!-- 匹配的是url路径， 如果不配置或/**,将拦截所有的Controller -->
			<mvc:mapping path="/**" />
			<mvc:exclude-mapping path="/front/**"/><!-- 匹配的是不需要拦截的url路径>
			<bean class="com.sz.kcygl.web.interceptor.SignInterceptor"></bean>
		</mvc:interceptor>
	</mvc:interceptors>
```
