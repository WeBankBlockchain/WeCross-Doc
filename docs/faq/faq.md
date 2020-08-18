# FAQ

## 问题1

下载速度太慢，下不下来。

**回答**

我们提供了多种下载方式，[点击此处查看](../version/download.md)。

## 问题2

在搭建Demo时报错

``` 
========== ERROR !!! FAILED to execute End-2-End Scenario ==========

ERROR !!!! Test failed
```

**回答**

Fabric 的demo和机器上的Fabric网络冲突了，尝试用demo目录下的`clear.sh`用脚本清理机器上已有的Fabric网络。

## 问题3

在部署demo时，**MacOS用户**若出现“**无法打开**”，“**无法验证开发者**”的情况。

**回答**

MacOS对下载的包权限要求较为严格，必须同一个进程下载的才可执行，可采用如下方法解决：

``` bash 
# 清理环境
cd ~/demo/ && bash clear.sh && cd ~ && rm -rf demo
# 将三个步骤的命令拼成一条命令执行
bash <(curl -sL https://github.com/WeBankFinTech/WeCross/releases/download/resources/download_demo.sh) && cd demo && bash build.sh
```



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



