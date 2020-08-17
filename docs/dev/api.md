# WeCross Java SDK API

SDK API分为两大类型，一种是RPC接口，一种是资源接口，其中资源接口是对RPC接口进行了封装。

## API列表

* RPC接口

    RemoteCall<StubResponse> supportedStubs();

    RemoteCall<AccountResponse> listAccounts();

    RemoteCall<ResourceResponse> listResources(Boolean ignoreRemote);

    RemoteCall<ResourceDetailResponse> detail(String path);

    RemoteCall<TransactionResponse> call(Request<TransactionRequest> request);

    RemoteCall<TransactionResponse> call(String path, String account, String method, String... args);

    RemoteCall<TransactionResponse> sendTransaction(Request<TransactionRequest> request);

    RemoteCall<TransactionResponse> sendTransaction(String path, String account, String method, String... args);

    RemoteCall<TransactionResponse> callTransaction(String transactionID, String path, String account, String method, String... args);

    RemoteCall<TransactionResponse> execTransaction(String transactionID,String seq, String path, String account, String method, String... args);

    RemoteCall<RoutineResponse> startTransaction(String transactionID, String[] accounts, String[] paths);

    RemoteCall<RoutineResponse> commitTransaction(String transactionID, String[] accounts, String[] paths);

    RemoteCall<RoutineResponse> rollbackTransaction(String transactionID, String[] accounts, String[] paths);

    RemoteCall<RoutineInfoResponse> getTransactionInfo(String transactionID, String[] accounts, String[] paths);

    RemoteCall<CommandResponse> customCommand(String command, String path, String account, Object... args);

    RemoteCall<RoutineIDResponse> getTransactionIDs(String path, String account, int option);

* 资源接口

    Resource ResourceFactory.build(WeCrossRPC weCrossRPC, String path, String account)

    boolean isActive();

    ResourceDetail detail();

    TransactionResponse call(Request<TransactionRequest> request);

    String[] call(String method);

    String[] call(String method, String... args);

    TransactionResponse sendTransaction(Request<TransactionRequest> request);

    String[] sendTransaction(String method);

    String[] sendTransaction(String method, String... args);

## RPC接口解析

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

### listAccounts
显示所有已配置的账户列表。
#### 参数        
- 无

#### 返回值   
- `AccountResponse` - 响应包
   - `version`: `String` - 版本号
   - `errorCode`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `Accounts` - 配置的账户列表
     
#### java示例
```java
    AccountResponse response = weCrossRPC.listAccounts().send();
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
- `account`: `String` - 账户名
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
- `account`: `String` - 账户名  
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
- `account`: `String` - 账户名   
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
调用智能合约，会改变链状态，发交易。

#### 参数   
- `path`: `String` - 跨链资源标识  
- `account`: `String` - 账户名   
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
            .sendTransaction(
                "payment.bcos.HelloWeCross","set","value")
            .send();
```

### callTransaction
获取事务中的状态数据，不发交易

#### 参数   
- `transactionID`:`String` - 事务ID
- `path`: `String` - 跨链资源标识  
- `account`: `String` - 账户名   
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
            .callTransaction(
                "0001","payment.bcos.2pc","queryEvidence","key1")
            .send();
```

### execTransaction
执行事务，发交易

#### 参数   
- `transactionID`:`String` - 事务ID
- `seq`:`String` - 事务序列号，需递增
- `path`: `String` - 跨链资源标识  
- `account`: `String` - 账户名   
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
            .execTransaction(
                "0001","1","payment.bcos.2pc","newEvidence","key1","evidence1")
            .send();
```

### startTransaction
开始事务，锁定事务相关资源，发交易

#### 参数   
- `transactionID`:`String` - 事务ID
- `accounts`:`String[]` - 账户列表，每条链需要一个发交易的账户
- `paths`: `String[]` - 跨链资源列表 

#### 返回值   
- `RoutineResponse` - 响应包
   - `version`: `String` - 版本号
   - `errorCode`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `int` - 调用结果
     
#### java示例
```java
    RoutineResponse routineResponse =
        weCrossRPC
            .startTransaction(
                "0001", new String[]{"bcos_user1","fabric_user1"}, new String[]{"payment.bcos.2pc", "payment.fabric.2pc"},)
            .send();
```

### commitTransaction
提交事务，释放事务相关资源，发交易

#### 参数   
- `transactionID`:`String` - 事务ID
- `accounts`:`String[]` - 账户列表，每条链需要一个发交易的账户
- `paths`: `String[]` - 跨链资源列表 

#### 返回值   
- `RoutineResponse` - 响应包
   - `version`: `String` - 版本号
   - `errorCode`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `int` - 调用结果
     
#### java示例
```java
    RoutineResponse routineResponse =
        weCrossRPC
            .commitTransaction(
                "0001", new String[]{"bcos_user1","fabric_user1"}, new String[]{"payment.bcos.2pc", "payment.fabric.2pc"},)
            .send();
```

### rollbackTransaction
回滚事务，释放事务相关资源，发交易

#### 参数   
- `transactionID`:`String` - 事务ID
- `accounts`:`String[]` - 账户列表，每条链需要一个发交易的账户
- `paths`: `String[]` - 跨链资源列表 

#### 返回值   
- `RoutineResponse` - 响应包
   - `version`: `String` - 版本号
   - `errorCode`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `int` - 调用结果
     
#### java示例
```java
    RoutineResponse routineResponse =
        weCrossRPC
            .rollbackTransaction(
                "0001", new String[]{"bcos_user1","fabric_user1"}, new String[]{"payment.bcos.2pc", "payment.fabric.2pc"},)
            .send();
```

### getTransactionInfo
获取事务详情，不发交易

#### 参数   
- `transactionID`:`String` - 事务ID
- `accounts`:`String[]` - 账户列表，每条链需要一个发交易的账户
- `paths`: `String[]` - 跨链资源列表 

#### 返回值   
- `RoutineInfoResponse` - 响应包
   - `version`: `String` - 版本号
   - `errorCode`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `String` - 事务信息
     
#### java示例
```java
    RoutineInfoResponse routineInfoResponse =
        weCrossRPC
            .getTransactionInfo(
                "0001", new String[]{"bcos_user1","fabric_user1"}, new String[]{"payment.bcos.2pc", "payment.fabric.2pc"},)
            .send();
```

### getTransactionIDs
获取事务ID列表，不发交易

#### 参数   
- `path`: `String` - 跨链资源标识  
- `account`: `String` - 账户名   
- `option`: `int` - 选项，0全部事务，1已完成的事务，2未完成的事务
- 
#### 返回值   
- `RoutineIDResponse` - 响应包
   - `version`: `String` - 版本号
   - `errorCode`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `String[]` - 事务ID列表
     
#### java示例
```java
    RoutineIDResponse routineIDResponse =
        weCrossRPC
            .getTransactionIDs(
                "payment.bcos.2pc", "bcos_user1", 0)
            .send();
```

### customCommand
自定义命令

#### 参数  
- `command`: `String` - 命令名称  
- `path`: `String` - 跨链资源标识  
- `account`: `String` - 账户名   
- `args`: `Object...` - 可变参数
- 
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
                "deploy", "payment.bcos.2pc", "bcos_user1")
            .send();
```

## 资源接口解析

### ResourceFactory.build
初始化一个跨链资源

#### 参数   
- `weCrossRPC` : `WeCrossRPC` - RPC实例
- `path`: `String` - 跨链资源标识     
- `account`: `String` - 账户名

#### 返回值   
- `Resource` - 跨链资源实例

#### java示例
```java
    // 初始化RPC实例
    WeCrossRPCService weCrossRPCService = new WeCrossRPCService();
    WeCrossRPC weCrossRPC = WeCrossRPCFactory.build(weCrossRPCService);

    // 初始化资源实例
    Resource resource = ResourceFactory.build(weCrossRPC, path, account);
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

### call
调用智能合约，不更改链状态，不发交易。

#### 参数  
- `request`: `Request<TransactionRequest>` - 请求体   

#### 返回值   
- `TransactionResponse` - 响应包
   - `version`: `String` - 版本号
   - `errorCode`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `Receipt` - 调用结果
     
#### java示例
```java
    TransactionResponse transactionResponse = resource.call(request);
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

### sendTransaction
调用智能合约，会改变链状态，发交易。

#### 参数  
- `request`: `Request<TransactionRequest>` - 请求体   

#### 返回值   
- `TransactionResponse` - 响应包
   - `version`: `String` - 版本号
   - `errorCode`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `Receipt` - 调用结果
     
#### java示例
```java
    TransactionResponse transactionResponse = resource.sendTransaction(request);
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

## RPC状态码

当一个RPC调用遇到错误时，返回的响应对象必须包含error错误结果字段，该字段有下列成员参数：

- errorCode: 使用数值表示该异常的错误类型，必须为整数。          
- message: 对该错误的简单描述字符串。       

标准状态码及其对应的含义如下：  

| code     | 含义            |
| :------- | :------------- |
| 0        | 执行成功        |
| 10100   | 内部错误        |
| 10201   | 版本错误        |
| 10202   | 资源标识错误     |
| 10203   | 资源不存在      |
| 10205   | 请求解码错误     |
| 10301   | htlc错误      |
| 2000x | 内部错误，结合message查看错误原因 |
| 5xxxx | 插件内错误，结合message查看错误原因 |
| 6xxxx | 两阶段事务错误，结合message查看错误原因 |
