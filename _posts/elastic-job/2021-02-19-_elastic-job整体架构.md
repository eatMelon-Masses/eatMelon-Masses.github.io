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