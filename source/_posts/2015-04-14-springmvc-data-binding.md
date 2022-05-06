---
layout: post
title: "Spring MVC 数据类型绑定"
date: 2015-04-14
category: spring框架
tags: [spring]
---
今天遇到一个问题，使用Spring MVC 从页面传递一个用户`List`到Controller，然后再后台解析List得到多个用户对象，在网上搜了很多答案感觉都不行,
后来调试代码发现，最`关键`在于:List需要绑定在对象(ActionForm),直接写在request-mapping函数的参数是不行的,更重要的一点是要创建对象(ArrayList)。

之前的`Jsp`代码是这么写的

```html
<form action="insertInsureUser.do" method="post">
		<div class="form_left">开始时间:</div>
		<div class="form_right">
		<input name="insureObject.startTime"/>
		</div>
		<div class="form_left">产品代码:</div>
		<div class="form_right">
		<input name="insureObject.productCode"/>
		<h2>投保人信息</h2>
		</div>
			<div class="form_left">姓名:</div>
		<div class="form_right">
		<input name="insureObject.insureUser[0].startTime"/>
		</div>
			<div class="form_left">身份证号:</div>
		<div class="form_right">
		<input name="insureObject.insureUser[0].idCard"/>
		</div>
			<div class="form_left">性别:</div>
		<div class="form_right">
		<input name="insureObject.insureUser[0].sex"/>
		</div>
			<div class="form_left">地址:</div>
		<div class="form_right">
		<input name="insureObject.insureUser[0].address"/>
		</div>
			<div class="form_left">邮箱:</div>
		<div class="form_right">
		<input name="insureObject.insureUser[0].email"/>
		</div>
			<div class="form_left">电话号码:</div>
		<div class="form_right">
		<input name="insureObject.insureUser[0].phone"/>
		</div>
		<h2>被保人信息</h2>
		</div>
			<div class="form_left">姓名:</div>
		<div class="form_right">
		<input name="insureObject.insureUser[1].startTime"/>
		</div>
			<div class="form_left">身份证号:</div>
		<div class="form_right">
		<input name="insureObject.insureUser[1].idCard"/>
		</div>
			<div class="form_left">性别:</div>
		<div class="form_right">
		<input name="insureObject.insureUser[1].sex"/>
		</div>
			<div class="form_left">地址:</div>
		<div class="form_right">
		<input name="insureObject.insureUser[1].address"/>
		</div>
			<div class="form_left">邮箱:</div>
		<div class="form_right">
		<input name="insureObject.insureUser[1].email"/>
		</div>
			<div class="form_left">电话号码:</div>
		<div class="form_right">
		<input name="insureObject.insureUser[1].phone"/>
		</div>

</form>
```
<!-- more -->

controller代码

```java
@RequestMapping("/insertInsureUser.do")
	public String queryAppUserGroup(HttpServletRequest request,
			HttpServletResponse response, ModelMap model,
			@ModelAttribute("insureObject") InsureUserQueryObject insureObject) throws Exception {
			logger.info("=======List类型数据绑定======");
			if(insureObject!=null&&insureObject.getInsureUsers.size()>0){
				for(InsureUser insureUser:insureObject){
					System.out.println(insureUser.getName());
				}
			}
	}
```

网上很多人都给不出答案,关键在于,List需要绑定在对象(ActionForm),直接写在request-mapping函数的参数是不行的,更重要的一点是要创建对象(ArrayList).
实体`InsureUserQueryObject`代码

```java
      public class InsureUserQueryObject {
           private String startTime;//起始时间
           private String productCode;//产品代码
           private List<InsureUser> insureUsers;//投保人被保人

           public String getStartTime() {
               return startTime;
           }

           public void setStartTime(String startTime) {
               this.startTime = startTime;
           }

           public String getProductCode() {
               return productCode;
           }

           public void setProductCode(String productCode) {
               this.productCode = productCode;
           }

           public List<InsureUser> getInsureUsers() {
               return insureUsers;
           }

           public void setInsureUsers(List<InsureUser> insureUsers) {
               this.insureUsers = insureUsers;
           }
      }
   ```

List中要用到的InsureUser代码如下

```java
public class InsureUser {
    private String name;//姓名
    private String idCard;//身份证号
    private String sex;//性别
    private String address;//地址
    private String email;//邮箱
    private String phone;//电话号码

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getIdCard() {
        return idCard;
    }

    public void setIdCard(String idCard) {
        this.idCard = idCard;
    }

    public String getSex() {
        return sex;
    }

    public void setSex(String sex) {
        this.sex = sex;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }
}

```
后来发现，控制台报属性不存在异常，查资料后发现，Spring MVC 数据绑定和struts是不一样的，o(╯□╰)o，表单前面不需要添加实体对象
`insureObject`,把insureObject删除掉更改过后的jsp代码为：

```html
<form action="insertInsureUser.do" method="post">
		<div class="form_left">开始时间:</div>
		<div class="form_right">
		<input name="startTime"/>
		</div>
		<div class="form_left">产品代码:</div>
		<div class="form_right">
		<input name="productCode"/>
		<h2>投保人信息</h2>
		</div>
			<div class="form_left">姓名:</div>
		<div class="form_right">
		<input name="insureUser[0].startTime"/>
		</div>
			<div class="form_left">身份证号:</div>
		<div class="form_right">
		<input name="insureUser[0].idCard"/>
		</div>
			<div class="form_left">性别:</div>
		<div class="form_right">
		<input name="insureUser[0].sex"/>
		</div>
			<div class="form_left">地址:</div>
		<div class="form_right">
		<input name="insureUser[0].address"/>
		</div>
			<div class="form_left">邮箱:</div>
		<div class="form_right">
		<input name="insureUser[0].email"/>
		</div>
			<div class="form_left">电话号码:</div>
		<div class="form_right">
		<input name="insureUser[0].phone"/>
		</div>
		<h2>被保人信息</h2>
		</div>
			<div class="form_left">姓名:</div>
		<div class="form_right">
		<input name="insureUser[1].startTime"/>
		</div>
			<div class="form_left">身份证号:</div>
		<div class="form_right">
		<input name="insureUser[1].idCard"/>
		</div>
			<div class="form_left">性别:</div>
		<div class="form_right">
		<input name="insureUser[1].sex"/>
		</div>
			<div class="form_left">地址:</div>
		<div class="form_right">
		<input name="insureUser[1].address"/>
		</div>
			<div class="form_left">邮箱:</div>
		<div class="form_right">
		<input name="insureUser[1].email"/>
		</div>
			<div class="form_left">电话号码:</div>
		<div class="form_right">
		<input name="insureUser[1].phone"/>
		</div>

	</form>
```

但是发现更改过后还是有异常，数组越界异常啊摔，原来是页面在向InsureUserQueryObject的对象写数据时发现List列表是空的，于是在
InsureUserQueryObject中给List赋一个`ArrayList`的初值，添加一个默认构造函数，在构造函数中向列表中添加一个两个InsureUser用来存储页面传过
来的InsureUser对象 大功告成！！修改过后的`InsureUserQueryObject`

```java
      public class InsureUserQueryObject {
           private String startTime;//起始时间
           private String productCode;//产品代码
           private List<InsureUser> insureUsers = new ArrayList<InsureUser>();//投保人被保人
		   public InsureUserQueryObject() {
				InsureUser user1=new InsureUser();
				InsureUser user2=new InsureUser();
				insureUsers.add(user1);//添加投保人
				insureUsers.add(user2);//添加被保人
		   }
           public String getStartTime() {
               return startTime;
           }

           public void setStartTime(String startTime) {
               this.startTime = startTime;
           }

           public String getProductCode() {
               return productCode;
           }

           public void setProductCode(String productCode) {
               this.productCode = productCode;
           }

           public List<InsureUser> getInsureUsers() {
               return insureUsers;
           }

           public void setInsureUsers(List<InsureUser> insureUsers) {
               this.insureUsers = insureUsers;
           }
      }
   ```
