# WeCross Java SDK API

SDK API分为两大类型，一种是对跨链路由RPC接口调用的封装，一种是资源接口。
## API列表

* RPC封装接口

```java
    RemoteCall<StubResponse> supportedStubs();

    RemoteCall<AccountResponse> listAccount();

    RemoteCall<ResourceResponse> listResources(Boolean ignoreRemote);

    RemoteCall<ResourceDetailResponse> detail(String path);

    RemoteCall<TransactionResponse> call(String path, String method, String... args);

    RemoteCall<TransactionResponse> sendTransaction(String path, String method, String... args);

    RemoteCall<TransactionResponse> invoke(String path, String method, String... args);

    RemoteCall<TransactionResponse> callXA(
            String transactionID, String path, String method, String... args);

    RemoteCall<TransactionResponse> sendXATransaction(
            String transactionID, String path, String method, String... args);

    RemoteCall<XAResponse> startXATransaction(String transactionID, String[] paths);

    RemoteCall<XAResponse> commitXATransaction(String transactionID, String[] paths);

    RemoteCall<XAResponse> rollbackXATransaction(String transactionID, String[] paths);

    RemoteCall<XATransactionResponse> getXATransaction(String transactionID, String[] paths);

    RemoteCall<CommandResponse> customCommand(String command, String path, Object... args);

    RemoteCall<XATransactionListResponse> listXATransactions(int size);

    RemoteCall<UAResponse> register(String name, String password) throws WeCrossSDKException;

    RemoteCall<UAResponse> login(String name, String password);

    RemoteCall<UAResponse> logout();

    RemoteCall<UAResponse> addChainAccount(String type, ChainAccount chainAccount);

    RemoteCall<UAResponse> setDefaultAccount(String type, ChainAccount chainAccount);

    RemoteCall<UAResponse> setDefaultAccount(String type, Integer keyID);

    String getCurrentTransactionID();
```

* 资源接口

```java
    Resource ResourceFactory.build(WeCrossRPC weCrossRPC, String path, String account)

    boolean isActive();

    ResourceDetail detail();

    String[] call(String method);

    String[] call(String method, String... args);

    String[] sendTransaction(String method);

    String[] sendTransaction(String method, String... args);
```

## RPC封装接口解析

### supportedStubs

显示router当前支持的插件列表。

#### 参数

- 无

#### 返回值

- `StubResponse` - 响应包
   - `version`: `String` - 版本号
   - `errorCode`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `Stubs` - 支持的插件列表

#### java示例

```java
    // 初始化RPC实例
    WeCrossRPCService weCrossRPCService = new WeCrossRPCService();
    WeCrossRPC weCrossRPC = WeCrossRPCFactory.build(weCrossRPCService);

    // 调用RPC接口，目前只支持同步调用
    StubResponse response = weCrossRPC.supportedStubs().send();
```

**注**
    - 之后的java示例，会省去初始化WeCrossRPC的步骤。

### listAccount

查看当前全局账号的详细信息。
#### 参数

- 无

#### 返回值

- `AccountResponse` - 响应包
   - `version`: `String` - 版本号
   - `errorCode`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `UniversalAccount` - 账号详细信息

#### java示例

```java
    AccountResponse response = weCrossRPC.listAccount().send();
```

### listResources

显示router配置的跨链资源。

#### 参数

- `ignoreRemote`: `Boolean` - 是否忽略远程资源

#### 返回值

- `ResourceResponse` - 响应包
   - `version`: `String` - 版本号
   - `errorCode`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `Resources` - 配置的资源列表

#### java示例
```java
    ResourceResponse response = weCrossRPC.listResources(true).send();
```

### detail

获取资源详情。

#### 参数

- `path`: `String` - 跨链资源标识

#### 返回值

- `ResourceDetailResponse` - 响应包
   - `version`: `String` - 版本号
   - `errorCode`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `ResourceDetail` - 资源详情

#### java示例

```java
    ResourceDetailResponse response = weCrossRPC.detail("payment.bcos.HelloWeCross").send();
```

### call(无参数)

调用智能合约，不更改链状态，不发交易。

#### 参数

- `path`: `String` - 跨链资源标识
- `method`: `String` - 调用的方法

#### 返回值

- `TransactionResponse` - 响应包
   - `version`: `String` - 版本号
   - `errorCode`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `Receipt` - 调用结果

#### java示例

```java
    TransactionResponse transactionResponse =
        weCrossRPC
            .call(
                "payment.bcos.HelloWeCross","get")
            .send();
```

### call(带参数)

调用智能合约，不更改链状态，不发交易。

#### 参数

- `path`: `String` - 跨链资源标识
- `method`: `String` - 调用的方法
- `args` : `String...` - 可变参数列表

#### 返回值

- `TransactionResponse` - 响应包
   - `version`: `String` - 版本号
   - `errorCode`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `Receipt` - 调用结果

#### java示例

```java
    TransactionResponse transactionResponse =
        weCrossRPC
            .call(
                "payment.bcos.HelloWeCross","get","key")
            .send();
```

### sendTransaction(无参数)

调用智能合约，会改变链状态，发交易。

#### 参数

- `path`: `String` - 跨链资源标识
- `method`: `String` - 调用的方法

#### 返回值

- `TransactionResponse` - 响应包
   - `version`: `String` - 版本号
   - `errorCode`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `Receipt` - 调用结果

#### java示例

```java
    TransactionResponse transactionResponse =
        weCrossRPC
            .sendTransaction(
                "payment.bcos.HelloWeCross","set")
            .send();
```

### sendTransaction(带参数)

### invoke(无参数)

调用智能合约，会改变链状态，发交易；在非事务状态下，与sendTransaction接口一致；在事务状态下，与sendXATransaction接口一致。

#### 参数

- `path`: `String` - 跨链资源标识
- `method`: `String` - 调用的方法

#### 返回值

- `TransactionResponse` - 响应包
   - `version`: `String` - 版本号
   - `errorCode`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `Receipt` - 调用结果

#### java示例

```java
    TransactionResponse transactionResponse =
        weCrossRPC
            .invoke(
                "payment.bcos.HelloWeCross","set")
            .send();
```

### sendTransaction(带参数)

调用智能合约，会改变链状态，发交易。在非事务状态下，与sendTransaction接口一致；在事务状态下，与sendXATransaction接口一致。

#### 参数

- `path`: `String` - 跨链资源标识
- `method`: `String` - 调用的方法
- `args` : `String...` - 可变参数列表

#### 返回值

- `TransactionResponse` - 响应包
   - `version`: `String` - 版本号
   - `errorCode`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `Receipt` - 调用结果

#### java示例

```java
    TransactionResponse transactionResponse =
        weCrossRPC
            .invoke(
                "payment.bcos.HelloWeCross","set","value")
            .send();
```

### callXA

获取事务中的状态数据，不发交易

#### 参数

- `transactionID`:`String` - 事务ID
- `path`: `String` - 跨链资源标识  
- `method`: `String` - 调用的方法
- `args` : `String...` - 可变参数列表

#### 返回值

- `TransactionResponse` - 响应包
   - `version`: `String` - 版本号
   - `errorCode`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `Receipt` - 调用结果

#### java示例

```java
    TransactionResponse transactionResponse =
        weCrossRPC
            .callXA(
                "payment.bcos.evidence","queryEvidence","key1")
            .send();
```

### sendXATransaction

执行事务，发交易

#### 参数

- `transactionID`:`String` - 事务ID
- `path`: `String` - 跨链资源标识  
- `method`: `String` - 调用的方法
- `args` : `String...` - 可变参数列表

#### 返回值

- `TransactionResponse` - 响应包
   - `version`: `String` - 版本号
   - `errorCode`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `Receipt` - 调用结果

#### java示例

```java
    TransactionResponse transactionResponse =
        weCrossRPC
            .sendXATransaction(
                "0001","payment.bcos.evidence","newEvidence","key1","evidence1")
            .send();
```

### startXATransaction
开始事务，锁定事务相关资源，发交易

#### 参数

- `transactionID`:`String` - 事务ID
- `paths`: `String[]` - 参与该事务的链路径列表

#### 返回值

- `XAResponse` - 响应包
   - `version`: `String` - 版本号
   - `errorCode`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `int` - 调用结果

#### java示例

```java
    XAResponse xaResponse =
        weCrossRPC
            .startXATransaction(
                "0001", new String[]{"payment.bcos", "payment.fabric"})
            .send();
```

### commitXATransaction

提交事务，释放事务相关资源，发交易

#### 参数

- `transactionID`:`String` - 事务ID
- `paths`: `String[]` - 参与该事务的链路径列表

#### 返回值

- `XAResponse` - 响应包
   - `version`: `String` - 版本号
   - `errorCode`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `int` - 调用结果

#### java示例

```java
    XAResponse xaResponse =
        weCrossRPC
            .commitXATransaction(
                "0001", new String[]{"payment.bcos", "payment.fabric"})
            .send();
```

### rollbackXATransaction

回滚事务，释放事务相关资源，发交易

#### 参数

- `transactionID`:`String` - 事务ID
- `paths`: `String[]` - 参与该事务的链路径列表

#### 返回值

- `XAResponse` - 响应包
   - `version`: `String` - 版本号
   - `errorCode`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `int` - 调用结果

#### java示例

```java
    XAResponse xaResponse =
        weCrossRPC
            .rollbackXATransaction(
                "0001", new String[]{"payment.bcos", "payment.fabric"})
            .send();
```

### getXATransaction

获取事务详情，不发交易

#### 参数

- `transactionID`:`String` - 事务ID
- `paths`: `String[]` - 参与该事务的链路径列表

#### 返回值

- `XATransactionResponse` - 响应包
   - `version`: `String` - 版本号
   - `errorCode`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `String` - 事务信息

#### java示例

```java
    XATransactionResponse xaTransactionResponse =
        weCrossRPC
            .getXATransaction(
                "0001", new String[]{"payment.bcos", "payment.fabric"})
            .send();
```

### listXATransactions

获取事务列表，不发交易

#### 参数

- `size`: `int` - 获取事务个数

#### 返回值

- `XATransactionListResponse` - 响应包
   - `version`: `String` - 版本号
   - `errorCode`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `String[]` - 事务信息列表

#### java示例

```java
    XATransactionListResponse xaTransactionListResponse =
        weCrossRPC
            .getTransactionIDs(
                "payment.bcos.evidence", "bcos_user1", 0)
            .send();
```

### getCurrentTransactionID

获取当前SDK正处的事务ID，不发交易

#### 参数

- 无

#### 返回值

- `String` - 当前SDK正处的事务ID

#### java示例

```java
    String transactionID = weCrossRPC.getCurrentTransactionID();
```


### customCommand

自定义命令

#### 参数

- `command`: `String` - 命令名称
- `path`: `String` - 跨链资源标识
- `args`: `Object...` - 可变参数

#### 返回值

- `CommandResponse` - 响应包
   - `version`: `String` - 版本号
   - `errorCode`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `String` - 调用结果

#### java示例

```java
    CommandResponse commandResponse =
        weCrossRPC
            .customCommand(
                "deploy", "payment.bcos.evidence", "Evidence")
            .send();
```

### register

注册一个UniversalAccount账号

#### 参数

- `name`: `String` - 账号名
- `password`: `String` - 账号密码

#### 返回值

- `UAResponse` - 响应包
   - `version`: `String` - 版本号
   - `errorCode`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `UAReceipt` - 注册账号信息

#### java示例

```java
    UAResponse uaResponse =
        weCrossRPC
            .register(
                "org1-admin", "123456").send();
```

### login

登录一个UniversalAccount账号

#### 参数

- `name`: `String` - 账号名
- `password`: `String` - 账号密码

#### 返回值

- `UAResponse` - 响应包
   - `version`: `String` - 版本号
   - `errorCode`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `UAReceipt` - 登录账号信息

#### java示例

```java
    UAResponse uaResponse =
        weCrossRPC
            .login(
                "org1-admin", "123456").send();
```

### addChainAccount

添加一个链账号。

#### 参数

- `type`: `String` - 链类型
- `chainAccount`: `ChainAccount` - 链账号

#### 返回值

- `UAResponse` - 响应包
   - `version`: `String` - 版本号
   - `errorCode`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `UAReceipt` - 添加结果

#### java示例

```java
    UAResponse uaResponse =
        weCrossRPC
            .addChainAccount(
                "BCOS2.0", chainAccount).send();
```

### setDefaultAccount

添加一个链账号。

#### 参数

- `type`: `String` - 链类型
- `keyID`: `Integer` - 链的KeyID

#### 返回值

- `UAResponse` - 响应包
   - `version`: `String` - 版本号
   - `errorCode`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `UAReceipt` - 设置结果

#### java示例

```java
    UAResponse uaResponse =
        weCrossRPC
            .setDefaultAccount(
                "BCOS2.0", 1).send();
```

## 资源接口解析

### ResourceFactory.build

初始化一个跨链资源

#### 参数
- `weCrossRPC` : `WeCrossRPC` - RPC实例
- `path`: `String` - 跨链资源标识

#### 返回值
- `Resource` - 跨链资源实例

#### java示例

```java
    // 初始化RPC实例
    WeCrossRPCService weCrossRPCService = new WeCrossRPCService();
    WeCrossRPC weCrossRPC = WeCrossRPCFactory.build(weCrossRPCService);

    // 初始化资源实例
    Resource resource = ResourceFactory.build(weCrossRPC, path);
```

**注**
    - 之后的java示例，会省去初始化Resource的步骤。

### isActive

获取资源状态，`true`:可达，`false`:不可达。

#### 参数

- 无

#### 返回值

- `bool` - 资源状态
  
#### java示例

```java
    bool status = resource.isActive();
```

### detail

获取资源详情。

#### 参数

- 无

#### 返回值

- `ResourceDetail` - 资源详情
  
#### java示例

```java
    ResourceDetail detail = resource.detail();
```

### call(无参数)

调用智能合约，不更改链状态，不发交易。

#### 参数

- `method`: `String` - 调用的方法

#### 返回值

- `String[]` - 调用结果
  
#### java示例

```java
    String[] result = resource.call("get");
```

### call(带参数)

调用智能合约，不更改链状态，不发交易。

#### 参数

- `method`: `String` - 调用的方法
- `args`: `String...` - 可变参数列表

#### 返回值

- `String[]` - 调用结果
  
#### java示例

```java
    String[] result = resource.call("get", "key");
```

### sendTransaction(无参数)

调用智能合约，会改变链状态，发交易。

#### 参数

- `method`: `String` - 调用的方法

#### 返回值

- `String[]` - 调用结果
  
#### java示例

```java
    String[] result = resource.sendTransaction("set");
```

### sendTransaction(带参数)

调用智能合约，会改变链状态，发交易。

#### 参数

- `method`: `String` - 调用的方法
- `args`: `String...` - 可变参数列表

#### 返回值

- `String[]` - 调用结果
  
#### java示例

```java
    String[] result = resource.sendTransaction("set", "value");
```
