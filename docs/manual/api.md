# JSON-RPC API

下列接口的示例中采用[curl](https://curl.haxx.se/)命令，curl是一个利用url语法在命令行下运行的数据传输工具，通过curl命令发送http请求，可以访问WeCross的JSON RPC接口。curl命令的url地址设置为WeCross根配置中的RPC监听IP和端口。为了格式化json，使用[jq](https://stedolan.github.io/jq/)工具进行格式化显示。错误码参考[RPC设计文档](#RPC错误码)。

```eval_rst
.. important::
    - 所有UBI接口的RPC API都是针对跨链资源，因此需要将跨链资源标识转换成url再进行调用。
```

## API列表
- RemoteCall<Response> status(String path);

- RemoteCall<ResourcesResponse> list(Boolean ignoreRemote);

- RemoteCall<GetDataResponse> getData(String path, String key);

- RemoteCall<SetDataResponse> setData(String path, String key, String value);

- RemoteCall<TransactionResponse> call(String path, String method, Object... args);

- RemoteCall<TransactionResponse> call(
          String path, String retTypes[], String method, Object... args);

- RemoteCall<TransactionResponse> callInt(String path, String method, Object... args);

- RemoteCall<TransactionResponse> callIntArray(String path, String method, Object... args);

- RemoteCall<TransactionResponse> callString(String path, String method, Object... args);

- RemoteCall<TransactionResponse> callStringArray(String path, String method, Object... args);

- RemoteCall<TransactionResponse> sendTransaction(String path, String method, Object... args);

- RemoteCall<TransactionResponse> sendTransaction(
          String path, String retTypes[], String method, Object... args);

- RemoteCall<TransactionResponse> sendTransactionInt(String path, String method, Object... args);

- RemoteCall<TransactionResponse> sendTransactionIntArray(
          String path, String method, Object... args);

- RemoteCall<TransactionResponse> sendTransactionString(
          String path, String method, Object... args);

- RemoteCall<TransactionResponse> sendTransactionStringArray(
          String path, String method, Object... args);

```eval_rst
.. important::
    - `call`和`sendTransaction`需要传入返回值类型列表，类型为字符串数组。
    - 目前支持的类型包括：Int(整型)，IntArray(整型数组)，String(字符串)，StringArray(字符串数组)。
```

## API解析

### status
查看跨链资源状态
#### 参数        
- `path`: `String` - 跨链资源标识

#### 返回值   
- `Response` - 相应包
   - `version`: `String` - 版本号
   - `result`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `object` - 返回的数据
     
#### java示例
```java
    WeCrossService weCrossService = new WeCrossRPCService("127.0.0.1:8250");
    WeCrossRPC weCrossRPC = WeCrossRPC.init(weCrossService);
    Response response = weCrossRPC.status("payment.bcoschain.HelloWorldContract").send();
```
**注**
    - 之后的java示例，会省去初始化WeCrossRPC的步骤。
    
#### curl示例          
``` bash
# Request
curl --data '{"version":"0.2", "path":"payment.bcoschain.HelloWorldContract", "method":"status"}' http://127.0.0.1:8250/payment/bcoschain/HelloWorldContract/status | jq

# Result
{
  "version": "0.2",
  "result": 0,
  "message": null,
  "data": "exists"
}
```

### list
获取资源列表
#### 参数        
- `ignoreRemote`: `Boolean` - `true`: 忽略远程资源，即不显示WeCross跨链代理连接的peers的资源。

#### 返回值   
- `ResourcesResponse` - 相应包
   - `version`: `String` - 版本号
   - `result`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `Resources` - 跨链资源列表
     
#### java示例
```java
    ResourcesResponse response = weCrossRPC.list(true).send();
```

#### curl示例          
``` bash
# Request
curl --data '{"version":"0.2", "path":"", "method":"list", "data": {"ignoreRemote": true}}' -H "Content-Type:application/json"  http://127.0.0.1:8250/list | jq

# Result
{
  "version": "0.2",
  "result": 0,
  "message": null,
  "data": {
    "errorCode": 0,
    "errorMessage": "",
    "resources": [
      {
        "checksum": "0x320a7e701e655cb67a3d1a5283d6083cbe228b080503d4b791fa060bf7f7d926",
        "type": "BCOS_CONTRACT",
        "distance": 0,
        "path": "payment.bcoschain.HelloWorldContract"
      },
      {
        "checksum": "0x7644243d71d1b1c154c717075da7bfe2d22bb2a94d7ed7693ab481f6cb11c756",
        "type": "TEST_RESOURCE",
        "distance": 0,
        "path": "test-network.test-stub.test-resource"
      }
    ]
  }
}
```

### getData
根据`key`获取`value`，目前只有JDChain支持该接口。

#### 参数   
- `path`: `String` - 跨链资源标识     
- `key`: `String` - 数据的键

#### 返回值   
- `GetDataResponse` - 相应包
   - `version`: `String` - 版本号
   - `result`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `GetDataResponse.StatusAndValue` - 状态和数据
     
#### java示例
```java
    GetDataResponse response = weCrossRPC.getData("payment.bcoschain.HelloWorldContract", "get").send();
```

#### curl示例          
``` bash
# Request
curl --data '{"version":"0.2", "path":"payment.bcoschain.HelloWorldContract", "method":"getData", "data": {"key": "get"}}' -H "Content-Type:application/json"  http://127.0.0.1:8250/payment/bcoschain/HelloWorldContract/getData | jq

# Result
{
  "version": "0.2",
  "result": 0,
  "message": null,
  "data": {
    "errorCode": 101,
    "errorMessage": "Not supported by BCOS_CONTRACT",
    "value": null
  }
}
```
### setData
根据`key`更新`value`，预留接口，目前没有链支持。

#### 参数   
- `path`: `String` - 跨链资源标识     
- `key`: `String` - 数据的键
- `value`: `String` - 数据的值

#### 返回值   
- `SetDataResponse` - 相应包
   - `version`: `String` - 版本号
   - `result`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `SetDataResponse.Status` - 返回的数据
     
#### java示例
```java
    GetDataResponse response = weCrossRPC.setData("payment.bcoschain.HelloWorldContract", "set", "Hello World").send();
```

#### curl示例          
``` bash
# Request
curl --data '{"version":"0.2", "path":"payment.bcoschain.HelloWorldContract", "method":"setData", "data": {"key": "set", "value":"Hello World"}}' -H "Content-Type:application/json"  http://127.0.0.1:8250/payment/bcoschain/HelloWorldContract/setData | jq

# Result
{
  "version": "0.2",
  "result": 0,
  "message": null,
  "data": {
    "errorCode": 101,
    "errorMessage": "Not supported by BCOS_CONTRACT"
  }
}
```

### call
调用智能合约，不更改链状态，不发交易，无返回值。

#### 参数   
- `path`: `String` - 跨链资源标识     
- `method`: `String` - 调用的方法
- `args` : `object[]` - 可变参数列表

#### 返回值   
- `TransactionResponse` - 相应包
   - `version`: `String` - 版本号
   - `result`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `CallContractResult` - 调用结果
     
#### java示例
```java
    TransactionResponse transactionResponseVoid =
        weCrossRPC
            .call(
                "test-network.test-stub.test-resource",
                    "test"
                    123,
                    "Hello")
            .send();
```

#### curl示例          
``` bash
# Request
curl --data '{"version":"0.2", "path":"test-network.test-stub.test-resource", "method":"call", "data": {"method": "test", "args":[123,"Hello World"]}}' -H "Content-Type:application/json"  http://127.0.0.1:8250/test-network/test-stub/test-resource/call | jq

# Result
{
  "version": "0.2",
  "result": 0,
  "message": null,
  "data": {
    "errorCode": 0,
    "errorMessage": "call test resource success",
    "hash": "010157f4",
    "extraHashes": null,
    "result": [
      {
        "sig": null,
        "retTypes": null,
        "method": "test",
        "args": [
          123,
          "Hello World"
        ]
      }
    ],
    "type": "",
    "encryptType": "",
    "blockHeader": null,
    "proofs": []
  }
}
```
### call
调用智能合约，不更改链状态，不发交易，有返回值。

#### 参数   
- `path`: `String` - 跨链资源标识  
- `retTypes`: `String[]` - 返回值类型列表   
- `method`: `String` - 调用的方法
- `args` : `object[]` - 可变参数列表

#### 返回值   
- `TransactionResponse` - 相应包
   - `version`: `String` - 版本号
   - `result`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `CallContractResult` - 调用结果
     
#### java示例
```java
    TransactionResponse transactionResponseVoid =
        weCrossRPC
            .call(
                "payment.bcoschain.HelloWorldContract",
                new String[] {"String"}
                    "get")
            .send();
```

#### curl示例          
``` bash
# Request
curl --data '{"version":"0.2", "path":"payment.bcoschain.HelloWorldContract", "method":"call", "data": {"retTypes":["String"], "method": "get", "args":[]}}' -H "Content-Type:application/json"  http://127.0.0.1:8250/payment/bcoschain/HelloWorldContract/call | jq

# Result
{
  "version": "0.2",
  "result": 0,
  "message": null,
  "data": {
    "errorCode": 0,
    "errorMessage": "success",
    "hash": null,
    "extraHashes": null,
    "result": [
      "Hello World"
    ],
    "type": "NORMAL",
    "encryptType": "NORMAL",
    "blockHeader": null,
    "proofs": null
  }
}
```
#### 衍生接口

- callInt: 调用返回值为Int类型的call
- callIntArray: 调用返回值为IntArray类型的call
- callString: 调用返回值为String类型的call
- callStringArray: 调用返回值为StringArray类型的call


### sendTransaction
调用智能合约，更改链状态，发交易，无返回值。

#### 参数   
- `path`: `String` - 跨链资源标识     
- `method`: `String` - 调用的方法
- `args` : `object[]` - 可变参数列表

#### 返回值   
- `TransactionResponse` - 相应包
   - `version`: `String` - 版本号
   - `result`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `CallContractResult` - 调用结果
     
#### java示例
```java
    TransactionResponse transactionResponseVoid =
        weCrossRPC
            .sendTransaction(
                "test-network.test-stub.test-resource",
                    "test"
                    123,
                    "Hello")
            .send();
```

#### curl示例          
``` bash
# Request
curl --data '{"version":"0.2", "path":"test-network.test-stub.test-resource", "method":"sendTransaction", "data": {"method": "test", "args":[123,"Hello World"]}}' -H "Content-Type:application/json"  http://127.0.0.1:8250/test-network/test-stub/test-resource/sendTransaction | jq

# Result
{
  "version": "0.2",
  "result": 0,
  "message": null,
  "data": {
    "errorCode": 0,
    "errorMessage": "sendTransaction test resource success",
    "hash": "010157f4",
    "extraHashes": null,
    "result": [
      {
        "sig": null,
        "retTypes": null,
        "method": "test",
        "args": [
          123,
          "Hello World"
        ]
      }
    ],
    "type": "",
    "encryptType": "",
    "blockHeader": null,
    "proofs": []
  }
}
```
### sendTransaction
调用智能合约，更改链状态，发交易，有返回值。

#### 参数   
- `path`: `String` - 跨链资源标识  
- `retTypes`: `String[]` - 返回值类型列表   
- `method`: `String` - 调用的方法
- `args` : `object[]` - 可变参数列表

#### 返回值   
- `TransactionResponse` - 相应包
   - `version`: `String` - 版本号
   - `result`: `int` - 状态码
   - `message`: `String` - 错误消息
   - `data`: `CallContractResult` - 调用结果
     
#### java示例
```java
    TransactionResponse transactionResponseVoid =
        weCrossRPC
            .sendTransaction(
                "payment.bcoschain.HelloWorldContract",
                null,
                "set",
                "Hello WeCross")
            .send();
```

#### curl示例          
``` bash
# Request
curl --data '{"version":"0.2", "path":"payment.bcoschain.HelloWorldContract", "method":"sendTransaction", "data": {"retTypes":null, "method": "set", "args":["Hello WeCross"]}}' -H "Content-Type:application/json"  http://127.0.0.1:8250/payment/bcoschain/HelloWorldContract/sendTransaction | jq

# Result
{
  "version": "0.2",
  "result": 0,
  "message": null,
  "data": {
    "errorCode": 0,
    "errorMessage": null,
    "hash": "0x4b9868f7846706006962dc88fabd3b27aaeab4187afabd0b5182e46452aa83d1",
    "result": [],
    # 以下内容在SDK中不会返回
    "extraHashes": [
      "0x229a233f58068e1502f065b45c74dcbd2f4ce6fbefe1cfbf1d0262843e4543a4"
    ],
    "type": "NORMAL",
    "encryptType": "NORMAL",
    "blockHeader": {
      "blockNumber": 13,
      "hash": "0x9c2524911aef82dee67df8b091616c9de2300271b5c34e5684c1f85c7d106adb",
      "roots": [
        "0x4c7fb20023f2a1d7c4116ccb5b6a0b427ccc7345420133968aebe6b332987ad3",
        "0x58916a5002355561ab46e5e4edb3eaa57375ccaaace797d51c129f1326aa23be",
        "0xb936177f128249b9a638ae9f8228d2876a1941e33903a48468c90c953228ba57"
      ]
    },
    "proofs": [
      {
        "root": "0x4c7fb20023f2a1d7c4116ccb5b6a0b427ccc7345420133968aebe6b332987ad3",
        "path": [
          {
            "left": [],
            "right": []
          }
        ],
        "leaf": {
          "index": "0x0",
          "leaf": "0x4b9868f7846706006962dc88fabd3b27aaeab4187afabd0b5182e46452aa83d1",
          "proof": "0x804b9868f7846706006962dc88fabd3b27aaeab4187afabd0b5182e46452aa83d1"
        }
      },
      {
        "root": "0x58916a5002355561ab46e5e4edb3eaa57375ccaaace797d51c129f1326aa23be",
        "path": [
          {
            "left": [],
            "right": []
          }
        ],
        "leaf": {
          "index": "0x0",
          "leaf": "0x229a233f58068e1502f065b45c74dcbd2f4ce6fbefe1cfbf1d0262843e4543a4",
          "proof": "0x80229a233f58068e1502f065b45c74dcbd2f4ce6fbefe1cfbf1d0262843e4543a4"
        }
      }
    ]
  }
}
```
#### 衍生接口

- sendTransactionInt: 调用返回值为Int类型的sendTransaction
- sendTransactionIntArray: 调用返回值为IntArray类型的sendTransaction
- sendTransactionString: 调用返回值为String类型的sendTransaction
- sendTransactionStringArray: 调用返回值为StringArray类型的sendTransaction


## RPC错误码

当一个RPC调用遇到错误时，返回的响应对象必须包含error错误结果字段，该字段有下列成员参数：

- result: 使用数值表示该异常的错误类型，必须为整数。          
- message: 对该错误的简单描述字符串。       

标准错误码及其对应的含义如下：  

| code     | 含义            |
| :------- | :------------- |
| 0        | 执行成功        |
| 49       | 内部错误        |
| 2001     | 版本错误        |
| 2002     | 资源标识错误     |
| 2003     | 方法不存在      |
| 2004     | 资源不存在      |
