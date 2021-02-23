---
layout: post
title:  "elastic-job 整体架构"
date:   2021-02-19 14:37:31 +0800
categories: elastic-job
tag: elastic-job
---

* content
{:toc}

# 整体架构

![整体架构](https://cvws.icloud-content.com/B/AfPsceo5AKT7jc9N03iBFLLRG4-qARbMswVX3QxJaGp7J8lXoX-Ofzvu/elastic-job整体架构.png?o=AtNfPKcLeqnwPFu1vfTP8jzN4E8tO7e59HKk1HQm2fen&v=1&x=3&a=CAogGfo_TWpFTqkB2gqQFAPd0t8lEISAn1JkcH3ya7gJXGISbxDT1P_H-y4Y88u2yPsuIgEAUgTRG4-qWgSOfzvuaifM0p7SuFtaD-_gjQj5WLsmWqP91SoZuI6lvlUZHpdSpLKvggiMtQlyJ9MZnmBt3mqnL-fAX-lknZXdSeNl2Wehb89IRY-Dq0EHGL-8T4Y86g&e=1613717415&fl=&r=eac6c80a-fe66-44ff-ab99-db1edc814f7e-1&k=RgHgoYW-I45cEKM-cPRCng&ckc=com.apple.clouddocs&ckz=com.apple.CloudDocs&p=17&s=3MzBmEeG7TrWSYOZwgYaq3adR7I&cd=i)

## 各个部分作用
- app 应用程序，内部包含任务执行业务逻辑和elastic-job-lite组件，其中执行任务需要实现elastic-job接口，完成与elastic-job-lite组件的集成，并进行任务的相关配置。应用程序可以启动多个实例，可就是出现多个任务执行实例。

- elastic-job-lite： 定位为轻量级无中心化解决方案，使用jar包的形式提供分布式任务的协调服务，此组件负责任务的调度，并产生日志及任务调度记录。
    无中心化：指的是没有调度中心这一概念，每个运行在集群重的作业服务器都是对等的，各个作业节点是自治的、平等的，节点之间通过注册中心进行分布式协调。

- registry: zookeeper 作为elastic-job 的注册中心组件，存储了执行任务的相关信息（任务执行策略、分片等信息）。同时，elastic-job利用该组件进行执行任务实例的选举。
- Console elastic-job 提供了运维平台，它通过读取zookeeper数据展现任务执行状态，或更新zookeeper数据修改全局配置 通过elastic-job-lite 组件产生的数据来查看任务执行历史记录

## elastic-job-lite 组件功能详解
1. 任务注册，通过online registter模块把任务注册到zookeeper
2. 调度策略设置，通过schedule trigger 模块设置策略
3. 当多个实例做任务调度时候，会有个leader election选举模块，通过zookeeper的选举，选举出执行实例
4. 对作业分片，Shard模块
5. 故障转移 failover模块
6. listener模块会对zookeeper模块进行监听，当多个实例执行任务时，会利用zookeeper组件进行选举，listener模块会监听选举的结果，决定是否执行任务。
7. 在任务的调度过程中会在logs模块产生日志。
8. elastic-job 提供了一个控制台，用来读取日志。用控制台的方式跟踪整个控制台的执行过程。

    在应用程序启动时，在其内嵌的elastic-job-lite组件会向zookeeper注册该实例的信息，并触发选举（此时可能以及启动了其他实例），从众多实例中国呢选举出一个leader，让其执行任务。当到达任务执行时间时，elastic-job-lite组件会调用由应用程序实现的任务业务逻辑，任务执行后会产生任务执行记录。当应用程序的某一个实例宕机时，zookeeper组件会感知到并重新触发leader选举。
## zookeeper 组件功能详解
zookeeper 是一个分布式一致性协调服务，它是apache hadoop的一个子项目，它主要是用来解决分布式应用中经常遇到的一些数据管理问题，如：统一命名服务、状态同步服务、集群管理、分布式应用配置项管理等。可以把zookeeper想象为一个特殊的数据库，它维护着一个类似文件系统的树形数据结构
![zookeeper数据结构](https://cvws.icloud-content.com/B/AQNl7Xjc6LLD-yBKubkQd7Z_cGw9ASIYlQupafMnE9JWXves3XfvAR3c/zookeeper数据结构.png?o=Armj4EdGYvPYCkyM3FlOIyDRIR_MQc1aOU_EoaFKTIsk&v=1&x=3&a=CAogNA_VjvhmOJwEBuvep0ZYHB9gQmlYHBuLr1693vOqr3ISbxDU4YDz-y4Y9Ni38_suIgEAUgR_cGw9WgTvAR3caidAC9pyh1G6LCyVmVcUlUp81sU_LQgDbXHX_PBmnY8ChvRD6162dylyJ1MElPdTFaCe4oCWbxcjjWaWjVeEuWdBKFhT-EOusTxw5c-0uWfcag&e=1613807610&fl=&r=f28c341c-8940-4f89-a0d6-922c40915ed5-1&k=49yAfmENcPyviXZAAdxZBA&ckc=com.apple.clouddocs&ckz=com.apple.CloudDocs&p=17&s=tMva9hz0ZcDbcjDsz3udDItCTMw&cd=i)

每个子目录和文件系统一样，我们都能够自由都增加、删除子节点，唯一的不同在于子节点可以存储数据。
zookeeper为什么称之为一致性协调服务呢？
因为zookeeper拥有数据监听通知机制，客户端注册监听它关心的子节点，当子node发生变化时（数据改变删除、子目录增加删除）时，zookeeper会通知所有客户端。 

zookeeper在elastic-job项目中主要有以下作用
- elastic-job 依赖zookeeper完成对执行任务信息的存储（如任务名称、任务参与实例、任务执行策略等）
- elastic-job 依赖zookeeper实现选举机制，在任务执行实例数量变化时（如在快速上手的启动新实例或停止实例），会触发选举机制来决定让哪个实例去执行该任务。
### 任务信息保存
使用ZooInspector客户端（有现成的jar包供下载）工具连接zookeeper服务器
![zooInspector客户端使用截图](https://cvws.icloud-content.com/B/AWqYfClGs4xkD9jSz0dtstC9sv0mAeOywAQ8vwVl1Ad9TWCbyg-f2c-D/zooInspector工具使用截图.png?o=AjfA-9G-tcg2yVOQlh_QXCgyMkBVDH6uMseQeqg6H5nv&v=1&x=3&a=CAogMt8CpsqQF7t07bLhJ6TdIFix_RzefX6eRXs0ShWD-nwSbxCs7Nry-y4YzOOR8_suIgEAUgS9sv0mWgSf2c-DaifS-cx407GEHrHwRqDJ8y3x5iSyjTIqiPIpkx6_enOdEaWLoKoPsSRyJwFSTJ5_NYticcoW2efEOnaJ3IQ7AMnbnZyDedsdcIwwSEe3Admkmg&e=1613806989&fl=&r=991e609e-f5bf-433c-8fc3-1222a57f2733-1&k=vyKVeWSHVCp2MmQMftEjNw&ckc=com.apple.clouddocs&ckz=com.apple.CloudDocs&p=17&s=2b3YVdj8GGe7k62yiizUExbd8jY&cd=i)

1. elastic-job-example-java : 任务的命名空间
2. config：记录了任务的配置信息
3. instances节点： 同一个任务下的elastic-job的部署实例。一台机器可以启动多个job实例，jar包。instances的命名是[ip+@-@+PID]
4. leader： 任务实例的主节点信息，通过zookeeper的主节点选举，选出来的主节点信息。下面的子节点分为election，sharding和failover三个子节点。分别用于主节点选举、分片和失效转移处理。eletion下面的instance节点显示了当前主节点的实例ID：job instance id。latch节点也是一个永久节点用于选举时候实现分布式锁。sharding节点下面有一个临时节点nessary，表示是否需要重新分片。
5. sharding： 任务的分片信息，子节点是分片序列号，从0开始，从这个节点可以看出哪个分片在哪个实例上执行
6. latch：分布式锁相关的
### 任务执行实例选举
若要了解elastic-job 使用zookeeper是如何实现选举的，就需要首先了解zookeeper的四种类型的enode

- PERSISTENT-持久化目录节点
     客户端创建该类型node，此客户端与zookeeper断开连接后该节点依旧存在，如果创建了重复的key，比如/data，第二次创建会失败。   
- PERSISTENT-SEQUENTIAL-持久化顺序编号目录节点
     客户端与zookeeper断开连接后该节点依旧存在，允许创建相同的key，zookeeper给该节点名称进行顺序编号，如zk会在后面加上一串数字比如/data/data000001，递增。
- EPHEMERAL-临时目录节点
    客户端与zookeeper断开连接后，该节点被删除，不允许重复创建相同key
- EPHEMERAL-SEQUMENTAL-临时顺序编号目录节点
    客户端与zookeeper断开连接后，该节点被删除，允许重复创建相同的key，依然采取顺序编号机制。
实例选举实现过程分析
每个elastic-job 的任务执行实例作为zookeeper的客户端来擦欧哦zookeeper的znode
1. 任意一个实例启动时首先创建一个/server 的PERSISTENGT节点
2. 多个实例同时创建/server/leader EPHEMERAL子节点
3. /server/leader子节点只能创建一个，后创建的会失败。创建成功的实例被选为leader节点，用来执行任务。
4. 所有任务实例监听/server/leader的变化，一旦节点被删除，就重新进行选举，抢占式的创建/server/leader节点，谁创建成功谁就是leader

