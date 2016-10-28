---
layout: post
title:  "使用ajaxFileUpload异步上传图片"
keywords: "js ajax"
description: "使用ajaxFileUpload异步上传图片到后台"
category: web开发
tags: ajax
---


今天是七夕，乞巧节快乐！！

虽然最近学Python很入迷，但是前端的还是不能落下,加油。

使用之前，前端需要引入`jquery`以及`ajaxfileupload.js`


前端代码

```jsp
<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Insert title here</title>

    <!-- 引用jquery -->
    <!-- 引用ajaxfileupload.js -->
    <script type="text/javascript" src="/appService/js/jquery-1.8.3.min.js"></script>
    <script type="text/javascript" src="/appService/js/ajaxfileupload.js"></script>

    <script type="text/javascript">
        $(function(){
            //选择文件之后执行上传
            $('#fileToUpload').on('click', function() {
                $.ajaxFileUpload({
                    url:'/appService/fileupload',
                    secureuri:false,
                    fileElementId:'fileToUpload',//file标签的id
                    dataType: 'json',//返回数据的类型
                    success: function (data, status) {
                        $('#image').attr('src',data.urlImage);
                    }
                });
            });


        });
    </script>

</head>
<body>
<img id="image" style="width: 200px; height: 200px" >
<input id="fileToUpload"  type="file" name="upfile"><br/>

</body>
</html>
```
后台采用的是Spring MVC处理文件的方式，需要引入`spring-web-3.2.4.RELEASE.jar`以及 `commons-fileupload-1.3.1.jar`两个包

后台处理代码：

```java
@RequestMapping("/fileupload")
	public void  deleteImg(HttpServletRequest request,HttpServletResponse response) throws IOException {
		//需要返回的fileName
		String fileName = null;

		boolean isMultipart = ServletFileUpload.isMultipartContent(request);

		if(isMultipart){
			MultipartHttpServletRequest multiRequest=(MultipartHttpServletRequest)request;
			MultipartFile file= multiRequest.getFile("upfile");
			// 获得文件名：
			String filename = file.getOriginalFilename();
			// 获得输入流：
			InputStream input = file.getInputStream();
			// 写入文件

			String realPath = this.getServletContext().getRealPath("/images");

			FileOutputStream fos = new FileOutputStream(realPath+File.separator+filename);
			byte[] b = new byte[1024];
			while((input.read(b)) != -1){
				fos.write(b);
			}
			input.close();
			fos.close();
			//返回结果
			JSONObject obj = new JSONObject();
			obj.put("urlImage", realPath+File.separator+filename);
			response.getWriter().print(obj.toString());
		}

```