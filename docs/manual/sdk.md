# WeCross-SDK

WeCross向外部暴露了所有的UBI接口，开发者可以通过SDK实现这些接口的快速调用。

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
compile ('com.webank:wecross-sdk:0.2')
```
   maven:
``` xml
<dependency>
    <groupId>com.webank</groupId>
    <artifactId>wecross-sdk</artifactId>
    <version>0.2</version>
</dependency>
```

## 使用方法

### 调用SDK的[JSON-RPC API](./api.html)
示例代码如下：
```java

    // 使用IP和端口初始化WeCrossService
    WeCrossService weCrossService = new WeCrossRPCService("127.0.0.1:8250");

    // 初始化WeCrossRPC
    WeCrossRPC weCrossRPC = WeCrossRPC.init(weCrossService);

    // 调用RPC接口，send表示同步调用。
    Response response = weCrossRPC.status("payment.bcoschain.HelloWorldContract").send();
```