---
layout: post
title:  "DB2根据条件Update数据!"
date: 2015-04-15
category: 数据库相关
tags: db2
---
## DB2根据条件Update

```sql
UPDATE employee     
SET   salary=     
 CASE      
      WHEN workyear< THEN 0.05     
       WHEN area<20000 THEN 0.07     
     ELSE 0.09     
  END    
UPDATE properities  
SET   taxrate=  
   CASE   
       WHEN area<10000 THEN 0.05  
       WHEN area<20000 THEN 0.07  
       ELSE 0.09  
   END
```
<!-- more -->