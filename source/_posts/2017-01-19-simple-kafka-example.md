---
layout: post
title: Kafka入门
tags: [kafka]
date: 2017-01-19
category: java
---
## 1.环境配置
kafka依赖zookeeper来调度，以及选举leader，因此需要先安装zookeeper
### 1.1 安装zookeeper
点击[下载zookeeper](http://zookeeper.apache.org/releases.html)下载合适版本的zookeeper，当前最新的稳定版本是`3.4.9`创建好数据目录,命名为data，下一步配置用到

```shell
$ cd opt/ && tar -zxf zookeeper-3.4.6.tar.gz  && cd zookeeper-3.4.6
$ mkdir data
```
#### 1.2 配置zookeeper

```shell
$ vi conf/zoo.cfg
tickTime=2000
dataDir=/path/to/zookeeper/data
clientPort=2181
initLimit=5
syncLimit=2
```
#### 1.3 启动zookeeper
```shell
$ bin/zkServer.sh start
```
相应的停止zookeeper的命令为：
 
```shell
 $ bin/zkServer.sh stop
```
#### 1.4 启动zookeeper CLI

```shell
$ bin/zkCli.sh
```
<!-- more -->
## 1.2 安装kafka

### 1.2.1 下载并解压
[点击下载](https://www.apache.org/dyn/closer.cgi?path=/kafka/0.10.1.0/kafka_2.11-0.10.1.0.tgz)kafka的压缩包
```shell
$ cd opt/
$ tar -zxf kafka_2.11-0.10.1.0.tgz
$ cd kafka_2.11-0.10.1.0
```

### 1.3.1 启动和关闭Kafka
启动kafka
```shell
$ bin/kafka-server-start.sh config/server.properties

```
关闭kafka

```shell
$ bin/kafka-server-stop.sh config/server.properties

```

## 2.测试单broker
我的kafka服务创建在Linux虚拟机上，IP地址为：192.168.61.131（按需替换成自己的IP地址），在这里需要配置`server.properties`文件，将advertised.host.name设置为虚拟机的IP地址 `advertised.host.name=192.168.61.131`，否则在宿主机上无法访问虚拟机上面的服务

###2.1 使用Shell命令测试topic
#### 2.1.1 创建topic

在命令行界面kafka目录，输入下面命令：

```shell
bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic page_visits

```
#### 2.1.2 测试发布者

输入以下命令，打开发布消息CLI
```shell
bin/kafka-console-producer.sh --broker-list localhost:9092 --topic page_visits

```

在CLI界面输入，两行测试消息

    Hello kafka
    你好吗？

#### 2.1.3 测试订阅者
输入一下命令打开订阅者CLI

```shell
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --zookeeper localhost:2181 --from-beginning --topic page_visits

```
如果执行正确，会显示刚才发布者发送的两行消息

###2.2 使用Java代码创建Client来发布订阅消息

需要先在pom中添加kafka依赖：

```xml
     <dependencies>
             <dependency>
                 <groupId>org.apache.kafka</groupId>
                 <artifactId>kafka_2.9.2</artifactId>
                 <version>0.8.1.1</version>
                 <scope>compile</scope>
                 <exclusions>
                     <exclusion>
                         <artifactId>jmxri</artifactId>
                         <groupId>com.sun.jmx</groupId>
                     </exclusion>
                     <exclusion>
                         <artifactId>jms</artifactId>
                         <groupId>javax.jms</groupId>
                     </exclusion>
                     <exclusion>
                         <artifactId>jmxtools</artifactId>
                         <groupId>com.sun.jdmk</groupId>
                     </exclusion>
                 </exclusions>
             </dependency>
             <dependency>
                 <groupId>org.apache.kafka</groupId>
                 <artifactId>kafka-clients</artifactId>
                 <version>0.9.0.0</version>
             </dependency>
     
         </dependencies>

```

#### 2.2.1 创建发布者发布消息
下面一段代码，会每隔3秒中发布一个测试消息

```java
  public class MyProducer {
      private final static String TOPIC = "page_visits";
  
      public static void main(String[] args) throws InterruptedException {
          long events = 100;
          Properties properties = new Properties();
          properties.put("metadata.broker.list", "192.168.61.131:9092");
          properties.put("serializer.class", "kafka.serializer.StringEncoder");
  
          ProducerConfig config = new ProducerConfig(properties);
          Producer<String, String> producer = new Producer<String, String>(config);
          for (long nEvent = 0; nEvent< events; nEvent++){
              SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
              KeyedMessage<String,String> data = new KeyedMessage<String, String>(TOPIC,String.valueOf(nEvent),"Test message from java program " + sdf.format(new Date()));
              Thread.sleep(3000);
              producer.send(data);
          }
          producer.close();
  
  
      }
  }

```

#### 2.2.2 创建订阅者订阅消息

下面的代码会绑定到虚拟机长的kafka服务，当发布者发布消息时，订阅者会不断地打印发布者发布的消息：

```java
public class MyConsumer {
    private final static String TOPIC = "page_visits";

    public static void main(String[] args) {
        Properties properties = new Properties();
        properties.put("bootstrap.servers","192.168.61.131:9092");
        properties.put("enable.auto.commit", "true");
        properties.put("group.id", "test");
        properties.put("auto.commit.interval.ms", "1000");
        properties.put("session.timeout.ms", "30000");
        properties.put("key.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
        properties.put("value.deserializer","org.apache.kafka.common.serialization.StringDeserializer");

        KafkaConsumer<String,String> consumer = new KafkaConsumer<String, String>(properties);
        consumer.subscribe(Arrays.asList(TOPIC));
        System.out.println("Subscribe to topic "+TOPIC);
        while (true){
            ConsumerRecords<String,String> consumerRecords = consumer.poll(100);
            for(ConsumerRecord<String,String> record: consumerRecords){
                System.out.printf("offset = %d,key = %s,value = %s\n",record.offset(),record.key(),record.value());
            }
        }

    }
}
```

![运行结果](https://ooo.0o0.ooo/2017/01/19/58807b900a087.png)





 

