# WeCross Java SDK API

SDK API分为两大类型，一种是RPC接口，一种是资源接口，其中资源接口是对RPC接口进行了封装。

## API列表

* RPC接口

    RemoteCall<StubResponse> supportedStubs();

    RemoteCall<AccountResponse> listAccounts();

    RemoteCall<ResourceResponse> listResources(Boolean ignoreRemote);

    RemoteCall<ResourceDetailResponse> detail(String path);

    RemoteCall<TransactionResponse> call(Request<TransactionRequest> request);

    RemoteCall<TransactionResponse> call(String path, String accountName, String method, String... args);

    RemoteCall<TransactionResponse> sendTransaction(Request<TransactionRequest> request);

    RemoteCall<TransactionResponse> sendTransaction(String path, String accountName, String method, String... args);

* 资源接口

    Resource ResourceFactory.build(WeCrossRPC weCrossRPC, String path, String accountName)

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
    ResourceDetailResponse response = weCrossRPC.detail("payment.bcos.hello").send();
```

### call(无参数)
调用智能合约，不更改链状态，不发交易。

#### 参数   
- `path`: `String` - 跨链资源标识     
- `accountName`: `String` - 账户名
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
                "payment.bcos.hello","get")
            .send();
```

### call(带参数)
调用智能合约，不更改链状态，不发交易。

#### 参数   
- `path`: `String` - 跨链资源标识   
- `accountName`: `String` - 账户名  
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
                "payment.bcos.hello","get","key")
            .send();
```

### sendTransaction(无参数)
调用智能合约，会改变链状态，发交易。

#### 参数   
- `path`: `String` - 跨链资源标识  
- `accountName`: `String` - 账户名   
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
                "payment.bcos.hello","set")
            .send();
```

### sendTransaction(带参数)
调用智能合约，会改变链状态，发交易。

#### 参数   
- `path`: `String` - 跨链资源标识  
- `accountName`: `String` - 账户名   
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
                "payment.bcos.hello","set","value")
            .send();
```

## 资源接口解析

### ResourceFactory.build
初始化一个跨链资源

#### 参数   
- `weCrossRPC` : `WeCrossRPC` - RPC实例
- `path`: `String` - 跨链资源标识     
- `accountName`: `String` - 账户名

#### 返回值   
- `Resource` - 跨链资源实例

#### java示例
```java
    // 初始化RPC实例
    WeCrossRPCService weCrossRPCService = new WeCrossRPCService();
    WeCrossRPC weCrossRPC = WeCrossRPCFactory.build(weCrossRPCService);

    // 初始化资源实例
    Resource resource = ResourceFactory.build(weCrossRPC, path, accountName);
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
| 1000     | 内部错误        |
| 2001     | 版本错误        |
| 2002     | 资源标识错误     |
| 2003     | 资源不存在      |
| 2005     | 请求解码错误     |
| 3001     | htlc错误      |
