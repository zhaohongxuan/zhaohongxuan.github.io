---
layout: post
title:  "微信OAuth2.0鉴权获取用户信息"
keywords: "wechat"
description: "网页授权获取用户的基本信息"
category: 微信开发
tags: wechat
---
在微信开发中经常需要在网页中获取用户的基本信息，和`UnionID机制`获取用户信息的方式不同,这种方式可以得到`未关注`本微信号的人的基本信息。

###首先第一步要在微信公众平台上配置`回调域名`，注意

	域名不是URL，不要包涵http://等协议头	

##开发步骤
###1.用户同意授权，获取code
在确保微信公众账号拥有授权作用域（scope参数）的权限的前提下（服务号获得高级接口后，默认拥有scope参数中的snsapi_base和snsapi_userinfo），
引导关注者打开如下页面：

	https://open.weixin.qq.com/connect/oauth2/authorize?appid=APPID&redirect_uri=REDIRECT_URI&response_type=code&scope=SCOPE&state=STATE#wechat_redirect

**redirect_uri**是授权后重定向的回调链接地址，请使用urlencode对链接进行处理
**response_type**是返回类型，请填写code
**scope**是应用授权作用域，snsapi_base （不弹出授权页面，直接跳转，只能获取用户openid），snsapi_userinfo （弹出授权页面，可通过openid拿到昵称、性别、所在地。并且，即使在未关注的情况下，只要用户授权，也能获取其信息）
**state**否重定向后会带上state参数，开发者可以填写a-zA-Z0-9的参数值，最多128字节
**#wechat_redirect**无论直接打开还是做页面302重定向时候，必须带此参数

**用户同意授权后**
如果用户同意授权，页面将跳转至 `redirect_uri/?code=CODE&state=STATE`。若用户禁止授权，则重定向后不会带上code参数，仅会带上state参数redirect_uri?state=STATE

	code说明 ：
	code作为换取access_token的票据，每次用户授权带上的code将不一样，code只能使用一次，`5分钟`未被使用自动过期。

拼接授权连接Java代码

```java
 public static String getMenuOauthUrl(String appId,String url,String state){
		String authUrl="https://open.weixin.qq.com/connect/oauth2/authorize?appid="+appId+"&redirect_uri="+url+"&response_type=code&scope=snsapi_base&state="+state+"#wechat_redirect";
		return authUrl;
	}
```
snsapi_base可以改为snsapi_userinfo可以得到用户所有的信息，否则只能获得openId
###2.通过code换取网页授权access_token
首先请注意，这里通过code换取的是一个特殊的网页授权access_token,与基础支持中的access_token（该access_token用于调用其他接口）不同。
公众号可通过下述接口来获取网页授权access_token。如果网页授权的作用域为snsapi_base，则本步骤中获取到网页授权access_token的同时，也获取到了openid，
snsapi_base式的网页授权流程即到此为止。

请求方法

获取code后，请求以下链接获取access_token： 

	https://api.weixin.qq.com/sns/oauth2/access_token?appid=APPID&secret=SECRET&code=CODE&grant_type=authorization_code

**code**填写第一步获取的code参数
**grant_type**填写为authorization_code
得到AccessToken代码

```java
 public static Map<String,String> getCodeAccessToken(String appid, String secret, String code){
        Map<String,String> map = new HashMap<String, String>();
        if (StringUtils.isBlank(appid) || StringUtils.isBlank(secret) || StringUtils.isBlank(code)) {
            return map;
        }
        StringBuilder sb = new StringBuilder("https://api.weixin.qq.com/sns/oauth2/access_token");
        sb.append("?appid=").append(appid).append("&secret=").append(secret);
        sb.append("&code="+code).append("&grant_type=authorization_code");
        String result = HttpClientUtil.getRequest(sb.toString(), "","UTF-8", "text/html");
        logger.info("result:"+result);
        if (StringUtils.isNotEmpty(result)) {
            JSONObject jo = JSON.parseObject(result);
            String errcode = jo.getString("errcode");
            String errmsg = jo.getString("errmsg");

            if (StringUtils.isNotEmpty(errcode)) {
                //出错了
                logger.info("clll wx error,errcode=" + errcode + ", errmsg=" + errmsg);
                map.put("errcode", errcode);
                map.put("errmsg",errmsg);
            } else {
                String access_token = jo.getString("access_token");//访问凭证
                String expires_in = jo.getString("expires_in");//凭证有效时间
                String refresh_token = jo.getString("refresh_token");//用户刷新access_token
                String openid = jo.getString("openid");
                String scope = jo.getString("scope"); 
                map.put("access_token",access_token);
                map.put("expires_in",expires_in);
                map.put("refresh_token",refresh_token);
                map.put("openid",openid);
                map.put("scope",scope);
            }
        }
        return map;
    }
```

如果Scope为基本信息的话，那么本步骤中获取到网页授权access_token的同时，也获取到了openid，snsapi_base式的网页授权流程即到此为止。

```java
	/**
	 * 获取openId
	 * @param request
	 * @return
	 * @throws Exception
	 */
	public String getOpenId(HttpServletRequest request) throws Exception {
		String appid = PropertiesLoader.getPropertiesByName("appId");
		String appSerect = PropertiesLoader.getPropertiesByName("secret");
		String code = this.getParameter(request, "code");
		Map<String, String> map = AccessTokenUtil.getCodeAccessToken(appid,
				appSerect, code);
		String openid = map.get("openid");
		String state = this.getParameter(request, "state");
		return openid;
	}
```

###3.拉取用户信息(需scope为 snsapi_userinfo)
如果网页授权作用域为snsapi_userinfo，则此时开发者可以通过access_token和openid拉取用户信息
请求方法
http：GET（请使用https协议）

	https://api.weixin.qq.com/sns/userinfo?access_token=ACCESS_TOKEN&openid=OPENID&lang=zh_CN

得到微信返回的报文

```java
public static String getBaseUserInfoAPI(String accessToken, String openId){
		logger.info("进入获取用户信息(snsapi_base)API方法");
		String reqUrl = WeiXinUrlUtil.getBaseUserInfoUrl(accessToken, openId);
		String resDoc = HttpClientUtil.getRequestHandler(reqUrl, "", "获取用户信息");
		return resDoc;
	}
```

将报文转换为自己需要的Object即可