---
title: 理解docker-compse中的网络连接
date: 2019-01-29 23:21:51
tags: Python Docker
category: 后端开发
---

读《Docker从入门到实践》
https://yeasy.gitbooks.io/docker_practice/compose/usage.html

中的docker-compose一章，在遇到下面一段代码：

```python
from flask import Flask
from redis import Redis

app = Flask(__name__)
redis = Redis(host='redis', port=6379)

@app.route('/')
def hello():
    count = redis.incr('hits')
    return 'Hello World! 该页面已被访问 {} 次。\n'.format(count)

if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)
```
<!--more -->
这是一段很简单的代码,但是我写的时候不小心用`host='localhost'`代替了，这段代码在本地运行的很好，打开`http://localhost:5000`时能正常计数，但是在用`docker-compse up `启动之后会报

    redis.exceptions.ConnectionError: Error 111 connecting to localhost:6379. Connection refused.

很明显是flask的应用无法访问redis的服务，但是我打开了本地的redis-cli也显示无法连接
docker-compose 日志中，很明显redis的服务是启动在了6379端口，所以肯定是hostname的问题，在docker服务内部无法找到locahost到底是谁，因为localhost是在宿主机里的host文件里面配置的，所以app里面访问locahost来连接redis失败了，这时候要找到redis启动的真正的hostname是`redis`

![image.png](https://upload-images.jianshu.io/upload_images/170138-740aca67e7fc893b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

使用docker-compose ps命令发现在`docker-compose up`启动的时候，自动创建了2个镜像实例`counter_web_1`,`counter_redis_1`
```shell
    ➜ docker-compose ps
        Name                    Command               State           Ports
    ---------------------------------------------------------------------------------
    counter_redis_1   docker-entrypoint.sh redis ...   Up      6379/tcp
    counter_web_1     python counter.py                Up      0.0.0.0:5000->5000/tcp
```

由于我们在docker-compose.yml文件里面将counter_web_1从docker端口映射到外部网络的5000端口，因此我们才能通过localhost:5000来访问页面，所以加入
我们在redis里面也加上port

```yml
version: '2'

services:
  web:
    build: .
    command: python counter.py
    ports:
     - "5000:5000"
    volumes:
     - .:/code
  redis:
    image: "redis:alpine"
    ports:
     - "6379:6379"
```
这样的话 我们就能从宿主机来访问docker里面的redis实例了。
![image.png](https://upload-images.jianshu.io/upload_images/170138-57183c67645b46e6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



