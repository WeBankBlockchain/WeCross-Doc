# JSON-RPC API

下列接口的示例中采用[curl](https://curl.haxx.se/)命令。curl是一个利用url语法在命令行下运行的数据传输工具，通过curl命令发送http请求，可以访问WeCross的JSON RPC接口。curl命令的url地址需要设置为WeCross跨链代理的RPC监听IP和端口。

可使用[jq](https://stedolan.github.io/jq/)工具对结果进行格式化显示。RPC状态码参考[RPC状态码](#rpc)。


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
    - 所有UBI接口的RPC API都是针对跨链资源，因此需要将跨链资源标识转换成url再进行调用。
    - `call <#id20>`_ 和 `sendTransaction <#id30>`_ 需要传入返回值类型列表，类型为字符串数组。
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
    // 初始化RPC
    WeCrossService weCrossService = new WeCrossRPCService("127.0.0.1:8250");
    WeCrossRPC weCrossRPC = WeCrossRPC.init(weCrossService);

    // 调用RPC接口，目前只支持同步调用
    Response response = weCrossRPC.status("payment.bcos.HelloWeCross").send();
```
**注**
    - 之后的java示例，会省去初始化WeCrossRPC的步骤。
    
#### curl示例          
``` bash
# Request
curl --data '{"version":"1", "path":"payment.bcos.HelloWeCross", "method":"status"}' http://127.0.0.1:8250/payment/bcos/HelloWeCross/status | jq

# Result
{
  "version": "1",
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
curl --data '{"version":"1", "path":"", "method":"list", "data": {"ignoreRemote": true}}' -H "Content-Type:application/json"  http://127.0.0.1:8250/list | jq

# Result
{
  "version": "1",
  "result": 0,
  "message": null,
  "data": {
    "errorCode": 0,
    "errorMessage": "",
    "resources": [
      {
        "checksum": "0xa88063c594ede65ee3c4089371a1e28482bd21d05ec1e15821c5ec7366bb0456",
        "type": "BCOS_CONTRACT",
        "distance": 0,
        "path": "payment.bcos.HelloWeCross"
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
    GetDataResponse response = weCrossRPC.getData("payment.bcos.HelloWeCross", "get").send();
```

#### curl示例          
``` bash
# Request
curl --data '{"version":"1", "path":"payment.bcos.HelloWeCross", "method":"getData", "data": {"key": "name"}}' -H "Content-Type:application/json"  http://127.0.0.1:8250/payment/bcos/HelloWeCross/getData | jq

# Result
{
  "version": "1",
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
    GetDataResponse response = weCrossRPC.setData("payment.bcos.HelloWeCross", "set", "Hello World").send();
```

#### curl示例          
``` bash
# Request
curl --data '{"version":"1", "path":"payment.bcos.HelloWeCross", "method":"setData", "data": {"key": "name", "value":"dou dou"}}' -H "Content-Type:application/json"  http://127.0.0.1:8250/payment/bcos/HelloWeCross/setData | jq

# Result
{
  "version": "1",
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
                "payment.bcos.HelloWeCross",
                    "getNumber")
            .send();
```

#### curl示例          
``` bash
# Request
curl --data '{"version":"1", "path":"payment.bcos.HelloWeCross", "method":"call", "data": {"method": "getNumber", "args":[]}}' -H "Content-Type:application/json"  http://127.0.0.1:8250/payment/bcos/HelloWeCross/call | jq

# Result
{
  "version": "1",
  "result": 0,
  "message": null,
  "data": {
    "errorCode": 0,
    "errorMessage": "success",
    "hash": null,
    "extraHashes": null,
    "result": [],
    "type": "NORMAL",
    "encryptType": "NORMAL",
    "blockHeader": null,
    "proofs": null
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
                "payment.bcos.HelloWeCross",
                new String[] {"String"}
                    "getMessage")
            .send();
```

#### curl示例          
``` bash
# Request
curl --data '{"version":"1", "path":"payment.bcos.HelloWeCross", "method":"call", "data": {"retTypes":["String"], "method": "getMessage", "args":[]}}' -H "Content-Type:application/json"  http://127.0.0.1:8250/payment/bcos/HelloWeCross/call | jq

# Result
{
  "version": "1",
  "result": 0,
  "message": null,
  "data": {
    "errorCode": 0,
    "errorMessage": "success",
    "hash": null,
    "extraHashes": null,
    "result": [
      "Ha Ha"
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
                "payment.bcos.HelloWeCross",
                    "setNumber"
                    123)
            .send();
```

#### curl示例          
``` bash
# Request
curl --data '{"version":"1", "path":"payment.bcos.HelloWeCross", "method":"sendTransaction", "data": {"method": "setNumber", "args":[123]}}' -H "Content-Type:application/json"  http://127.0.0.1:8250/payment/bcos/HelloWeCross/sendTransaction | jq

# Result
{
  "version": "1",
  "result": 0,
  "message": null,
  "data": {
    "errorCode": 0,
    "errorMessage": null,
    "hash": "0x5fe42cf98516c70b0b490ee8957088e341faa1382d4071cd6bbad7b704fd1870",
    "extraHashes": [
      "0x4c17d7a9ef8c244fcc864251143bcbc773632d5356086f08c84e95cb80e0f894"
    ],
    "result": [],
    "type": "NORMAL",
    "encryptType": "NORMAL",
    "blockHeader": {
      "blockNumber": 40,
      "hash": "0x2e592998b752369087c9286048e0638d606ebf20cb9964350fa9926d5c23d30d",
      "roots": [
        "0x13874fc5554d177b8739595b8ea6a97443805697238279e170d7219533fb1542",
        "0xc9a1779a4ceaf2134653f2be3468e6081cfabcd9044d602d9e9229512dc5a1b2",
        "0x767cc8d0cd30b74c42698b224cd65a46db251241aa6c74ab028f72f5f40c0afb"
      ]
    },
    "proofs": [
      {
        "root": "0x767cc8d0cd30b74c42698b224cd65a46db251241aa6c74ab028f72f5f40c0afb",
        "path": [
          {
            "left": [],
            "right": []
          }
        ],
        "leaf": {
          "index": "0x0",
          "leaf": "0x5fe42cf98516c70b0b490ee8957088e341faa1382d4071cd6bbad7b704fd1870",
          "proof": "0x805fe42cf98516c70b0b490ee8957088e341faa1382d4071cd6bbad7b704fd1870"
        }
      },
      {
        "root": "0xc9a1779a4ceaf2134653f2be3468e6081cfabcd9044d602d9e9229512dc5a1b2",
        "path": [
          {
            "left": [],
            "right": []
          }
        ],
        "leaf": {
          "index": "0x0",
          "leaf": "0x4c17d7a9ef8c244fcc864251143bcbc773632d5356086f08c84e95cb80e0f894",
          "proof": "0x804c17d7a9ef8c244fcc864251143bcbc773632d5356086f08c84e95cb80e0f894"
        }
      }
    ]
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
                "payment.bcos.HelloWeCross",
                new String[] {"Int", "String"},
                "setNumAndMsg",
                234,
                "Hello WeCross")
            .send();
```

#### curl示例          
``` bash
# Request
curl --data '{"version":"1", "path":"payment.bcos.HelloWeCross", "method":"sendTransaction", "data": {"retTypes":["Int", "String"], "method": "setNumAndMsg", "args":[234,"Hello WeCross"]}}' -H "Content-Type:application/json"  http://127.0.0.1:8250/payment/bcos/HelloWeCross/sendTransaction | jq

# Result
{
  "version": "1",
  "result": 0,
  "message": null,
  "data": {
    "errorCode": 0,
    "errorMessage": null,
    "hash": "0xc0a842c9edf35484ad7d3eb1bdb12deb7f20bd356ed9eb3c063ec9fe0de4401e",
    "extraHashes": [
      "0x58a663c23ebac75168d8e9859f0db803c926f0a452cbd537beffe0b3426f4394"
    ],
    "result": [
      234,
      "Hello WeCross"
    ],
    "type": "NORMAL",
    "encryptType": "NORMAL",
    "blockHeader": {
      "blockNumber": 42,
      "hash": "0x43956a4330ee652bbd2234894960f6c78234775a25ca66741cfcc7ddf22f9cfb",
      "roots": [
        "0xfb146b917eacedf386e40396d3b5c526576308008ebbd2f42f0cef89615ac961",
        "0x99cbcd0d1aa8742e23148db18436a120ddfecf0635dc1289129c3e0b260e323f",
        "0x3e58b5157ecd7e5024aaa66c925ca8685dd5b8444a534c0f9387d36051067a00"
      ]
    },
    "proofs": [
      {
        "root": "0x3e58b5157ecd7e5024aaa66c925ca8685dd5b8444a534c0f9387d36051067a00",
        "path": [
          {
            "left": [],
            "right": []
          }
        ],
        "leaf": {
          "index": "0x0",
          "leaf": "0xc0a842c9edf35484ad7d3eb1bdb12deb7f20bd356ed9eb3c063ec9fe0de4401e",
          "proof": "0x80c0a842c9edf35484ad7d3eb1bdb12deb7f20bd356ed9eb3c063ec9fe0de4401e"
        }
      },
      {
        "root": "0xfb146b917eacedf386e40396d3b5c526576308008ebbd2f42f0cef89615ac961",
        "path": [
          {
            "left": [],
            "right": []
          }
        ],
        "leaf": {
          "index": "0x0",
          "leaf": "0x58a663c23ebac75168d8e9859f0db803c926f0a452cbd537beffe0b3426f4394",
          "proof": "0x8058a663c23ebac75168d8e9859f0db803c926f0a452cbd537beffe0b3426f4394"
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


## RPC状态码

当一个RPC调用遇到错误时，返回的响应对象必须包含error错误结果字段，该字段有下列成员参数：

- result: 使用数值表示该异常的错误类型，必须为整数。          
- message: 对该错误的简单描述字符串。       

标准状态码及其对应的含义如下：  

| code     | 含义            |
| :------- | :------------- |
| 0        | 执行成功        |
| 49       | 内部错误        |
| 2001     | 版本错误        |
| 2002     | 资源标识错误     |
| 2003     | 方法不存在      |
| 2004     | 资源不存在      |
