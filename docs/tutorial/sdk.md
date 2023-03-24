# WeCross Java SDK开发应用

WeCross 跨链路由向外部暴露了所有的UBI接口，开发者可以通过SDK实现这些接口的快速调用。

## 环境要求

```eval_rst
.. important::
    - java版本
     要求 `JDK8或以上 <https://openjdk.java.net/>`_
    - WeCross服务部署
     参考 `部署指南 <../tutorial/deploy/index.html#id2>`_
```

## Java应用引入SDK

通过gradle或maven引入SDK到java项目

- gradle:

```gradle
compile ('com.webank:wecross-java-sdk:1.3.0')
```

- maven:

``` xml
<dependency>
    <groupId>com.webank</groupId>
    <artifactId>wecross-java-sdk</artifactId>
    <version>1.3.0</version>
</dependency>
```

## 配置SDK

WeCorss Java SDK 主要包括以下配置选项：

- 路由网络配置
- SSL连接配置

### 配置步骤
1. 将跨链路由`router-${zone}/cert/sdk/`目录下的证书和密钥拷贝到项目的`classpath`目录；
3. 在项目的`classpath`目录下新建文件 `application.toml`，默认配置如下：

```toml
[connection]
    server =  '127.0.0.1:8250'
    sslKey = 'classpath:ssl.key'
    sslCert = 'classpath:ssl.crt'
    caCert = 'classpath:ca.crt'
    sslSwitch = 2 # disable ssl:2, SSL without client auth:1 , SSL with client and server auth: 0
```

4. 修改`application.toml`中`server`，使用跨链路由实际监听的IP和端口。

### 配置解读

在`application.toml`配置文件中，`[connection]`配置跨链路由的连接信息，具体包括以下配置项：

- `server`: 跨链路由监听的IP和端口；
- `sslKey`: 客户端私钥路径
- `sslCert`: 客户端证书路径
- `caCert`: CA证书路径
- `sslSwitch`: SSL的模式开关，0: 双向验证；1: 只验证服务端；2: 关闭SSL。

## 使用方法

示例代码如下：

```java
try {
    // 初始化 Service
    WeCrossRPCService weCrossRPCService = new WeCrossRPCService();

    // 初始化Resource
    WeCrossRPC weCrossRPC = WeCrossRPCFactory.build(weCrossRPCService);

    weCrossRPC.login("username", "password").send(); // 需要有登录态才能进一步操作
    Resource resource = ResourceFactory.build(weCrossRPC, "payment.bcos.HelloWecross"); // RPC服务，资源的path

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
