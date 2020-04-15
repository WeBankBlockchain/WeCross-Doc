# 跨链SDK

WeCross router向外部暴露了所有的UBI接口，开发者可以通过SDK实现这些接口的快速调用。

## 环境要求

```eval_rst
.. important::
    - java版本
     要求 `JDK8或以上 <https://openjdk.java.net/>`_
    - WeCross服务部署
     参考 `WeCross快速入门 <../tutorial/setup.html>`_
```

## Java应用引入SDK

   通过gradle或maven引入SDK到java应用

   gradle:
```bash
compile ('com.webank:wecross-java-sdk:1.0.0-rc2')
```
   maven:
``` xml
<dependency>
    <groupId>com.webank</groupId>
    <artifactId>wecross-java-sdk</artifactId>
    <version>1.0.0-rc2</version>
</dependency>
```

## 使用方法

### 调用[WeCross SDK API](./api.html)
示例代码如下：
```java

    WeCrossRPCService weCrossRPCService = new WeCrossRPCService();

    // 初始化WeCrossRPC
    WeCrossRPC weCrossRPC = WeCrossRPCFactory.build(weCrossRPCService);

    // 调用RPC接口，send表示同步调用。
    Response response = weCrossRPC.status("payment.bcos.hello").send();

    // 初始化跨链资源
    Resource resource = ResourceFactory.build(weCrossRPC, "payment.bcos.hello" "bcos_default");

    // 跨链资源调用
    String[] result = resource.sendTransaction("set", "hello", "wecross");
```
