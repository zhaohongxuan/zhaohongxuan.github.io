---
layout: post
title:  "查询oracle中clob中的xml的节点数据"
keywords: "database"
description: "使用oracle的xmlType函数得到xml文档里的节点的值"
category: 数据库相关
tags: oracle
---
##查询oracle中clob中的xml的节点数据


###查询xmltype字段里面的内容
现在有一个`EBIZ_THIRD_TRADE(第三方交易)`表里面有一个`TRADE_REQUEST_CONTENT`返回报文字段类型为`clob`
下面的一个示例返回报文xml：

```xml
<?xml version="1.0" encoding="GBK" standalone="yes"?>
<PackageList xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <Package>
        <Header>
            <RequestType>01</RequestType>
            <UUID>55435745-11d8-44a3-addf-8ba269385446</UUID>
            <ComId>2243411990</ComId>
            <From>taobao</From>
            <SendTime>2015-04-15 11:48:41</SendTime>
            <TaoBaoSerial>10923265164636660</TaoBaoSerial>
            <ComSerial xsi:nil="true"/>
            <Asyn>0</Asyn>
            <ReturnUrl>http://service.baoxian.taobao.com/baoxian/cooperation</ReturnUrl>
            <ProductCode>17</ProductCode>
        </Header>
        <Request>
            <Order>
                <TBOrderId>10923265164636660</TBOrderId>
                <TotalPremium>200</TotalPremium>
                <PostFee xsi:nil="true"/>
                <InsBeginDate>2015-04-17 00:00:00</InsBeginDate>
                <InsEndDate>2015-04-18 00:00:00</InsEndDate>
                <InsPeriod>1D</InsPeriod>
                <ApplyNum>1</ApplyNum>
                <Item>
                    <ItemId>43574889020</ItemId>
                    <SkuRiskCode>17</SkuRiskCode>
                    <ProductCode>17</ProductCode>
                    <ProductName>平台险</ProductName>
                    <Amount xsi:nil="true"/>
                    <Premium>200</Premium>
                    <ActualPremium>200</ActualPremium>
                    <DiscountRate>10000</DiscountRate>
                </Item>
                <PolicyNo xsi:nil="true"/>
            </Order>
            <ApplyInfo>
                <Holder>
                    <CustomList>
                        <Custom key="HolderBirthday">1986-01-03</Custom>
                        <Custom key="HolderName">周燕霞</Custom>
                        <Custom key="HolderMobile">18907099975</Custom>
                        <Custom key="HolderSex">2</Custom>
                        <Custom key="HolderCardType">1</Custom>
                        <Custom key="HolderCardNo">360121198601032426</Custom>
                    </CustomList>
                </Holder>
                <InsuredInfo>
                    <IsHolder>0</IsHolder>
                    <InsuredList>
                        <Insured>
                            <CustomList>
                                <Custom key="InsuredName">万俊</Custom>
                            </CustomList>
                            <BenefitInfo>
                                <IsLegal>1</IsLegal>
                                <BenefitList/>
                            </BenefitInfo>
                        </Insured>
                    </InsuredList>
                </InsuredInfo>
                <OtherInfo>
                    <CustomList/>
                </OtherInfo>
                <RefundInfo>
                    <CustomList/>
                </RefundInfo>
            </ApplyInfo>
        </Request>
    </Package>
</PackageList>
```
要得到其中的`  <Custom key="InsuredName">万俊</Custom>`里的`万俊`名字

```sql

select THIRD_TRADE_ID,extract(xmltype(TRADE_REQUEST_CONTENT),'/PackageList/Package/Request/ApplyInfo/InsuredInfo/InsuredList/Insured/CustomList/Custom/text()').getStringVal() insurename      
    
from  EBIZ_THIRD_TRADE where third_trade_id i='10923296687106660';
```


 
