# FAQ

## 部署问题

### 1. 问题：下载速度过慢/连接不上github

**回答**
我们提供了多种下载方式，可尝试使用国内资源下载，[点击此处查看](../version/download.md)。

### 2. 问题：Demo中Fabric报错

在搭建Demo时报错

``` bash
========== ERROR !!! FAILED to execute End-2-End Scenario ==========

ERROR !!!! Test failed
```

**回答**
Fabric 的demo和机器上的Fabric网络冲突了，尝试用demo目录下的`clear.sh`用脚本清理机器上已有的Fabric网络。

### 3. 问题：macOS用户出现“无法验证开发者”的情况

在部署demo时，**macOS用户**若出现“**无法打开**”，“**无法验证开发者**”的情况。

**回答**
macOS对下载的包权限要求较为严格，必须同一个进程下载的才可执行，可采用如下方法解决：

``` bash
# 清理环境
cd ~/wecross-demo/ && bash clear.sh && cd ~ && rm -rf demo
# 执行下载demo包
bash <(curl -sL https://github.com/WeBankBlockchain/WeCross/releases/download/resources/download_demo.sh)

# 若出现网络原因长时间无法下载，可执行以下命令下载demo包
bash <(curl -sL https://gitee.com/WeBank/WeCross/raw/master/scripts/download_demo.sh)

# 进入demo文件夹，执行构建逻辑
cd demo && bash build.sh
```

### 4. 问题：用户使用MySQL 8.0+ 社区版本时，出现WeCross-Account-Manager启动错误的情况

在部署1.0.0版本的demo时，若出现`WeCross-Account-Manager`连接不上MySQL 8.0+版本时，可能有以下原因：

- MySQL配置错误，登录账号没有本地或远程访问某个数据库的权限；
- MySQL 8.0+版本默认开启SSL验证连接导致的SSL连接问题；
- MySQL 8.0+版本使用强密码检查插件；

可以做以下检查进行规避：

- 检查MySQL配置、账号可正确访问；
- （推荐）正确配置MySQL的SSL选项；
- 尝试将MySQL的SSL插件关闭后再连接，或者修改 `WeCross-Account-Manager` 的配置文件 `conf/application.toml` 的JDBC URL后面增加关闭SSL选项L：

```toml
 #该项将在 1.1.0 版本统一使用
 url = 'jdbc:mysql://localhost:3306/wecross_account_manager?useSSL=false'
```

- 关闭强密码选项，或者尝试使用较低版本的MySQL。

### 5. 问题：macOS用户执行完wecross-demo/bulid.sh后，WeCross-Account-Manager启动出现加密包相关报错

```toml
Caused by: java.lang.ClassCastException: org.bouncycastle.asn1.DLSequence cannot be cast to org.bouncycastle.asn1.ASN1Integer
	at org.bouncycastle.asn1.pkcs.RSAPrivateKey.<init>(Unknown Source) ~[bcprov-jdk15on-1.60.jar:1.60.0]
	at org.bouncycastle.asn1.pkcs.RSAPrivateKey.getInstance(Unknown Source) ~[bcprov-jdk15on-1.60.jar:1.60.0]
	at com.webank.wecross.account.service.utils.RSAUtility.createPrivateKey(RSAUtility.java:68) ~[wecross-account-manager-1.2.1.jar:?]
	at com.webank.wecross.account.service.config.UAManagerConfig.initRSAKeyPairManager(UAManagerConfig.java:111) ~[wecross-account-manager-1.2.1.jar:?]
	at com.webank.wecross.account.service.config.UAManagerConfig.newRestRequestFilter(UAManagerConfig.java:95) ~[wecross-account-manager-1.2.1.jar:?]
	at com.webank.wecross.account.service.config.UAManagerConfig$$EnhancerBySpringCGLIB$$46a832ce.CGLIB$newRestRequestFilter$2(<generated>) ~[wecross-account-manager-1.2.1.jar:?]
 ....
```

如果出现以上错误，大概率是依赖库的版本出现问题，可以从以下几个方面排查：
- 检查是否使用了文档中推荐的JDK版本；
- MacOS默认使用LibreSSL，需要换成OpenSSL；
- 使用OpenSSL 3.x也会出现以上错误，需要使用OpenSSL 1.x；

## 非技术问题

**Q：WeCross和FISCO BCOS是什么关系？**

A：FISCO  BCOS是区块链平台，WeCross是跨链平台，WeCross可对接各种类型的区块链，包括FISCO BCOS



**Q：WeCross适用于哪些应用场景？**

A：WeCross适用于所有需要链间互操作的场景，包括数字资产跨链、司法仲裁跨域、个体数据跨域授权、物联网跨平台联动



**Q：使用WeCross跨链需要改造原有的区块链平台或应用系统吗？**

A：不需要，WeCross使用非侵入模型，不需要改造原有区块链平台和系统



**Q：WeCross支持哪些区块链平台？是否支持公链？**

A：参考本文档《跨链接入》章节



**Q：WeCross是否支持平行扩展？**

A：支持在线平行扩展



**Q：WeCross最多支持多少区块链同时参与跨链？**

A：WeCross本身不设区块链数量的硬限制，参与跨链的区块链数量仅受机器配置的限制



**Q：WeCross支持哪几种跨链模式，中继链、侧链、平行链都支持吗？**

A：中继链、侧链和平行链等模式在WeCross中均有相应方案支持



**Q：WeCross是否支持主备切换或者多活架构？**

A：WeCross默认是多活架构，支持主备架构



**Q：WeCross是否支持审计和监管？**

A：支持



**Q：WeCross支持国密吗？**

A：支持



**Q：WeCross支持哪些事务/一致性模型？**

A：参考本文档《跨链事务》章节



**Q：目前有哪些落地应用场景使用了WeCross？**

A：参考本文档《应用场景》章节



**Q：使用WeCross遇到了问题应该去哪里咨询？**

A：参考本文档《社区》章节



**Q：使用WeCross有哪些好处？**

A：WeCross完全开源，支持多种区块链平台，简单易用，性能高



**Q：WeCross跟竞品对比，有哪些优势？**

A：WeCross支持的跨链模型较多，不局限于中继链、侧链或平行链，且完全开源，支持多种区块链平台



