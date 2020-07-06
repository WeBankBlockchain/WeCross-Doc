# 跨链SDK开发应用

WeCross router向外部暴露了所有的UBI接口，开发者可以通过SDK实现这些接口的快速调用。

## 环境要求

```eval_rst
.. important::
    - java版本
     要求 `JDK8或以上 <https://openjdk.java.net/>`_
    - WeCross服务部署
     参考 `部署指南 <../tutorial/networks.html#id2>`_
```

## Java应用引入SDK

   通过gradle或maven引入SDK到java应用

   gradle:
```bash
compile ('com.webank:wecross-java-sdk:1.0.0-rc3')
```
   maven:
``` xml
<dependency>
    <groupId>com.webank</groupId>
    <artifactId>wecross-java-sdk</artifactId>
    <version>1.0.0-rc3</version>
</dependency>
```

## 使用方法

示例代码如下：
```java
try {
    // 初始化 Service
    WeCrossRPCService weCrossRPCService = new WeCrossRPCService();

    // 初始化Resource
    WeCrossRPC weCrossRPC = WeCrossRPCFactory.build(weCrossRPCService);
    Resource resource = ResourceFactory.build(weCrossRPC, "payment.bcos.HelloWecross", "bcos_user1"); // RPC服务，资源的path，用哪个账户名操作此resource

    // 用初始化好的resource进行调用
    String[] callRet = resource.call("get");   // call 接口函数名 参数列表
    System.out.println((Arrays.toString(callRet)));

    // 用初始化好的resource进行调用
    String[] sendTransactionRet = resource.sendTransaction("set", "Tom"); // sendTransaction 接口函数名 参数列表
    System.out.println((Arrays.toString(sendTransactionRet)));

} catch (WeCrossSDKException e) {
    System.out.println("Error: " + e);
}
```
