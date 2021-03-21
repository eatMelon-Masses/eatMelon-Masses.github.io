---
layout: post
title:  "springboot自动配置初探"
date:   2021-03-21 11:10:54 +0800
categories: springboot
tag: springboot
---

* content
{:toc}
## springboot 自动配置如何实现的呢？

```java
@SpringBootApplication
	@SpringBootConfiguration
		@Configuration
	@EnableAutoConfiguration
		@AutoConfigurationPackage
			@Import(AutoConfigurationPackages.Registrar.class)//自动注册包
		@Import(AutoConfigurationImportSelector.class)//自动导入包的核心
	@ComponentScan//自动扫描的包，通过自动注册类注册包
```

###  下面我们来看看AutoConfigurationImportSelector.class这个类

1. getAutoConfigurationEntry

![getAutoConfigurationEntry](https://cvws.icloud-content.com/B/AY9InBJ_W2w4E2FXonZxjkiy-Vb6AYIOlSZkzBUO-UwR-YKbT7Giqx-r/getAutoConfigurationEntry.png?o=AmtvuPKQq35UsBOvastVClY7bDzNBQF_Qrs0z2kAEtiW&v=1&x=3&a=CAog2YZIvR-f4Vv6jabLmNU8B0PaXH1FtVCrIhDz_60pRw8SbxDRrLCXhS8Y8aPnl4UvIgEAUgSy-Vb6WgSiqx-raifKiTHcPc3kn308XoHjeDdR70UCWtAQ_T19ylEgmbKrR-4bKTrMnV1yJz3UYVsCu7Be26ESwSm-sdTw0SwSDJESseBTgGTpCaUhK-nv60rP3Q&e=1616299807&fl=&r=190b4ba8-7d99-4155-9aca-7067bdf31113-1&k=yvFetk7Y50Ctk-Qb6FXSQw&ckc=com.apple.clouddocs&ckz=com.apple.CloudDocs&p=17&s=zKSaMFuGcM0AqC6jFmxx86ABfzQ&cd=i)

2. getCandidateConfigurations

![getCandidateConfigurations](https://cvws.icloud-content.com/B/AW9UWSOT2XzYBzYVnKqKZBndAaaqAf5lQg8Y1kNbYtIGRXIpa-kKBTud/getCandidateConfigurations.png?o=Ajeh-67aVCtdppDVP28du1t2ef20dX0PqvNfTj_uk8Mb&v=1&x=3&a=CAogwASnWhUdXVwD9vb4OuqYVQ52R4QTDZ5VT8ybxx1LRuISbxDN8PaXhS8Y7eetmIUvIgEAUgTdAaaqWgQKBTudaifGNqjBgcyjyK88_W26ohZ5ygvTBx_FpBOlGQ3vVMs27OL5zR7o_PVyJ5b-Ub_QpOJ5exfzpbxnvkHfB0xJz_cQ9WMv1iIeZrZGYvulCxhbMQ&e=1616300962&fl=&r=c702df62-5267-4999-9f5d-ca6db98a7806-1&k=BLz8k49SnT5bRCIVzbCIQA&ckc=com.apple.clouddocs&ckz=com.apple.CloudDocs&p=17&s=uSStbskCE85H29958YzWQZp3LKY&cd=i)

3. 实际上是去autoconfiguration的资源目录下获取自动配置类信息

![](https://cvws.icloud-content.com/B/AdonR2Qw2fX0AZk_lctZNablHsapAaxTTn5YuNg0K7DbJeG2r8f-ScIm/spring.factories.png?o=Apc9c-IWHo2Mw9j8VZmh3YvKq1iabN0722YyZ3_yie_V&v=1&x=3&a=CAoguQ7VwfszWwWE7Xn4hBsKjeXHrBNJ7-1elWhDWSqDzD8SbxC_jomYhS8Y34XAmIUvIgEAUgTlHsapWgT-ScImaidees4xxavXqcpO6B7Ud96PF-IASuMOXXKL7rxgceI-324SdqFqFetyJzeaSc6Cm523b9HCayJEX9aQ9E14h5GIjnrEk3aU8kgGdI1Gb9ztZQ&e=1616301261&fl=&r=526d64ce-9026-48cd-a706-3ed814611bc7-1&k=HfGvE-0KOS2smFSgfVgI1w&ckc=com.apple.clouddocs&ckz=com.apple.CloudDocs&p=17&s=SU2zUFhwf98sKOM0yoZ66RGzWmY&cd=i)