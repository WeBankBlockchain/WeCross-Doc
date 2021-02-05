## 区块链接入开发(Stub)

本章节首先介绍`WeCross Stub`的设计原理，在此基础上给出区块链接入`WeCross`的开发流程，用户可以根据教程实现一个区块链的`WeCross Stub`插件，通过插件接入`WeCross`。

```eval_rst
.. note::
    - Java编程语言
     WeCross使用Java实现，区块链需要支持Java版本的SDK，要求开发人员具备Java开发能力。
    - Gradle构建工具
     WeCross Java组件使用Gradle构建，假定用户能够使用Gradle。
```
### Stub设计

### Stub开发
`Stub`开发分为两个部分：
- 系统合约
- Java插件

#### 系统合约

系统合约包括代理合约(WeCrossProxy)和桥接合约(WeCrossHub)，代理合约是WeCross调用该链其它合约的统一入口，桥接合约用于记录跨链调用请求，以配合跨链路由实现合约跨链调用。

##### 代理合约

功能点：

- 合约调用入口
- 事务管理

示例：

- [Solidity版](https://github.com/WeBankBlockchain/WeCross-BCOS2-Stub/blob/master/src/main/resources/WeCrossProxy.sol)
- [Golang版](https://github.com/WeBankBlockchain/WeCross-Fabric1-Stub/blob/master/src/main/resources/chaincode/WeCrossProxy/proxy.go)

以Solidity合约为例，接口列表：

```solidity

/** 读接口，调用业务合约（不需要脏读，即无事务ID，读事务中资源）
 *
 *  @param _XATransactionID  事务ID
 *  @param _path   目标资源路径
 *  @param _func   调用方法
 *  @param _args   调用参数
 *  @return 调用结果
 */ 
function constantCall(
    string memory _XATransactionID, 
    string memory _path, 
    string memory _func, 
    bytes memory _args
) public returns(bytes memory)


/** 写接口，调用业务合约
 *
 *  @param _uid  交易ID，用于去重
 *  @param _XATransactionID  事务ID
 *  @param _XATransactionSeq  事务序列号
 *  @param _path   目标资源路径
 *  @param _func   调用方法
 *  @param _args   调用参数
 *  @return 调用结果
 */ 
function sendTransaction(
    string memory _uid, 
    string memory _XATransactionID, 
    uint256 _XATransactionSeq, 
    string memory _path, 
    string memory _func, 
    bytes memory _args
) public returns(bytes memory)


/** 开启事务
 *
 *  @param _XATransactionID  事务ID
 *  @param _selfPaths  参与事务的己链资源列表
 *  @param _otherPaths 参与事务的它链资源列表
 *  @return 执行结果
 */ 
function startXATransaction(
    string memory _xaTransactionID, 
    string[] memory _selfPaths, 
    string[] memory _otherPaths
) public returns(string memory)


/** 提交事务
 *
 *  @param _XATransactionID  事务ID
 *  @return 执行结果
 */ 
function commitXATransaction(
    string memory _xaTransactionID
) public returns(string memory)


/** 回滚事务
 *
 *  @param _XATransactionID  事务ID
 *  @return 执行结果
 */ 
function rollbackXATransaction(
  string memory _xaTransactionID
) public returns(string memory)


/** 获取事务列表
 *
 *  @param _index 下标
 *  @param _size  数量
 *  @return 事务列表详情，JSON格式
 */ 
function listXATransactions(
    string memory _index, 
    uint256 _size
) public view returns (string memory)


/** 获取事务详情
 *
 *  @param _xaTransactionID 事务ID
 *  @return 事务详情，JSON格式
 */ 
function getXATransaction(
    string memory _xaTransactionID
) public view returns(string memory)

```

##### 桥接合约

功能点：

- 注册跨链调用请求
- 查询跨链调用回调结果

示例：

- [Solidity版](https://github.com/WeBankBlockchain/WeCross-BCOS2-Stub/blob/master/src/main/resources/WeCrossHub.sol)
- [Golang版](https://github.com/WeBankBlockchain/WeCross-Fabric1-Stub/blob/master/src/main/resources/chaincode/WeCrossHub/hub.go)

以Solidity合约为例，接口列表：

```solidity

/** 供业务合约调用，注册跨链调用请求
 *
 *  @param _path     目标链合约的路径
 *  @param _method   调用方法名
 *  @param _args     调用参数列表
 *  @param _callbackPath   回调的合约路径
 *  @param _callbackMethod 回调方法名
 *  @return 跨链请求的唯一ID
 */ 
function interchainInvoke(
        string memory _path, 
        string memory _method, 
        string[] memory _args, 
        string memory _callbackPath, 
        string memory _callbackMethod
) public returns(string memory uid)


/** 供跨链路由调用，获取跨链调用请求
 *
 *  @param _num   获取数量
 *  @return       请求列表，JSON格式
 */ 
funct
function getInterchainRequests(
    uint256 _num
) public view returns(string memory)


/** 供跨链路由调用，更新跨链任务处理进度
 *
 *  @param _index  新下标
 */ 
function updateCurrentRequestIndex(uint256 _index) public


/** 供跨链路由调用，注册回调结果
 *
 *  @param _uid  跨链请求的唯一ID
 *  @param _tid  事务ID
 *  @param _seq  事务序列号
 *  @param _errorCode 回调错误码
 *  @param _errorMsg  回调错误详情
 *  @param _result    回调结果
 */ 
function registerCallbackResult(
    string memory _uid, 
    string memory _tid, 
    string memory _seq, 
    string memory _errorCode, 
    string memory _errorMsg, 
    string[] memory _result
) public


/** 供用户调用，查询回调的调用结果
 *
 *  @param _uid   跨链请求的唯一ID
 *  @return       字符串数组: [事务ID, 事务Seq, 错误码, 错误消息, 回调调用结果的JSON序列化]
 */ 
function selectCallbackResult(
    string memory _uid
) public view returns(string[] memory)

```

#### Java插件

##### Java核心组件
- StubFactory
  * 组件实例化工厂类
- Account
  * 区块链账户，用于交易签名
- Connection
  * 调用区块链SDK接口，与区块链交互
- Driver
  * 交易、交易回执、区块等与区块链相关数据的编解码
  * 实现`Stub`的基础接口
  * 调用`Connection`对象的发送入口与区块链交互
  
###### StubFactory  
- 功能描述:
  * 添加`@Stub`注解，定义插件类型 
  * 提供`Account`、`Connection`、`Driver`实例化入口

```eval_rst
.. important::
  @Stub定义了插件类型，添加@Stub注解的插件才能被Wecross Router识别加载!
```

- 接口定义
```Java
public interface StubFactory {
    public Driver newDriver();
    public Connection newConnection(String path);
    public Account newAccount(Map<String, Object> properties);
}
```

- 接口列表
  * newDriver
    * 实例化`Driver`对象
  * newConnection
    * 实例化`Connection`对象
      * `path`:配置文件路径，配置文件名称默认`stub.toml`
  * newAccount
    * 实例化`Account`对象
      * `properties`:`Account`对象实例化的参数

- `FISCO-BCOS StubFactory`示例
```Java
/** @Stub注解，插件类型: BCOS2.0 */
@Stub("BCOS2.0") 
public class BCOSStubFactory implements StubFactory {
    @Override
    public Driver newDriver() {
        Driver driver = new BCOSDriver();
        /** 其他逻辑 */
        return driver;
    }
    @Override
    public Connection newConnection(String path) {
        Connection connection = new BCOSConnection();
        /** 解析配置文件，初始化 BCOSConnection */
        return connection;
    }
    @Override
    public Account newAccount(Map<String, Object> properties) {
        Account account = new BCOSAccount();
        /** 根据properties参数，初始化 BCOSAccount */
        return account;
    }
}
```

#### Account
- 功能描述
  * 交易签名
  * 链账户签名、验签

- 接口定义
```shell
public interface Account {
    String getName();
    String getType();
    String getIdentity();
    int getKeyID();
    boolean isDefault();
}
```

- 接口列表
  * getName
    * 链账户名称，自定义
  * getType
    * 链账户类型，与Stub类型保持一致
  * getIdentify
    * 链账户标记符，通常为链账户公钥
  * isDefault
    * 当前账户是否为默认链账户
  * getKeyID
    * 链账户KeyID

###### Connection
- 功能描述
  * 解析配置文件，初始化区块链`JavaSDK`，参考下面`配置文件`小节
  * 为`Driver`提供统一的发送接口，与区块链进行交互
  * 获取链上的资源列表
  
- 接口定义
```Java
public interface Connection {
    Response send(Request request);
    List<ResourceInfo> getResources();
}
```

接口列表
  * `getResources`
    * 获取区块链上的资源列表
      ```Java
      /** 资源对象 */
      public class ResourceInfo {
          /** 资源名称 */
          private String name;
          /** 资源类型，用户自定义 */
          private String stubType;
          /** 资源属性 */
          private Map<Object, Object> properties = new HashMap<Object, Object>();
      }
      ```

  * `send`
    * 发送接口
      * `Request request`: 请求对象，包括请求类型、请求内容
        ```Java
        public class Request {
            // 请求类型，自定义类型
            private int type;
            // 请求内容，序列化的请求参数
            private byte[] data;
        }
        ```
      * `Response response`: 返回对象，包括返回状态、描述信息、返回内容
        ```Java
        public class Response {
            // 返回状态码
            private int errorCode;
            // 描述信息
            private String errorMessage;
            // 返回内容，序列化的返回参数
            private byte[] data;
        }
        ```

`FISCO-BCOS BCOSConnection`示例:
```Java
// Request type定义，自定义
public class BCOSRequestType {
    // 查询操作
    public static final int CALL = 1000;
    // 发送交易
    public static final int SEND_TRANSACTION = 1001;
    // 获取块高
    public static final int GET_BLOCK_NUMBER = 1002;
    // 获取区块
    public static final int GET_BLOCK_BY_NUMBER = 1003;
    // 获取交易证明
    public static final int GET_TRANSACTION_PROOF = 1004;
}

// Connection定义各个类型消息的处理方式
public class BCOSConnection implements Connection {
    /** 发送入口，区分消息类型，调用区块链RPC接口 */
    @Override
    public Response send(Request request) {
        switch (request.getType()) {
            /** 查询 */
            case BCOSRequestType.CALL:
                /** call请求 */
                break;
            /** 发送交易 */
            case BCOSRequestType.SEND_TRANSACTION:
                /** sendTransaction请求 */
                break;
            /** 获取区块头 */
            case BCOSRequestType.GET_BLOCK_NUMBER:
                /** 获取区块高度请求 */
                break;
            /** 获取块高 */
            case BCOSRequestType.GET_BLOCK_BY_NUMBER:
                /** 获取区块 */
                break;
            /** 获取交易证明 */
            case BCOSRequestType.GET_TRANSACTION_PROOF:
                /** 获取交易证明 */
                break;
        }
    }
}
```

- 配置文件 
  配置文件主要包括区块链`JavaSDK`初始化需要的参数，也可以包含其他的一些附加信息，由用户自定义。配置默认位于`chains/`目录，可以配置多个stub，每个stub位于单独的子目录，配置文件名称`stub.toml`。

    ```shell
    # 目录结构, conf/chains/stub名称/
    conf/chains/
            └── bcos # stub名称: bcos
                └── stub.toml # stub.toml配置文件
                # 其他文件列表，比如：证书文件
    ```

`stub.toml`解析流程可以参考[FISCO-BCOS Stub stub.toml解析](https://github.com/WeBankBlockchain/WeCross-BCOS2-Stub/blob/dev/src/main/java/com/webank/wecross/stub/bcos/config/BCOSStubConfigParser.java)

FISCO-BCOS stub.toml示例
```shell
[common]    # 通用配置
    name = 'bcos' # 名称，必须项
    type = 'BCOS2.0' # 必须项，插件类型，与插件@Stub注解定义的类型保持一致


[chain]     # FISCO-BCOS 属性
    groupId = 1 # default 1
    chainId = 1 # default 1

[channelService]    # FISCO-BCOS JavaSDK配置
    caCert = 'ca.crt'
    sslCert = 'sdk.crt'
    sslKey = 'sdk.key'
    timeout = 300000  # 超时时间
    connectionsStr = ['127.0.0.1:20200', '127.0.0.1:20201', '127.0.0.1:20202'] # 连接列表
```

###### Driver
- 功能描述
   * 发送交易
   * 状态查询
   * 查询块高
   * 查询区块
   * 获取交易证明
   * 交易、区块编解码
   * 验证交易
   * 查询资源列表

- 接口定义
```Java
public interface Driver {
    interface Callback {
        void onTransactionResponse(
                TransactionException transactionException, TransactionResponse transactionResponse);
    }

    ImmutablePair<Boolean, TransactionRequest> decodeTransactionRequest(Request request);

    List<ResourceInfo> getResources(Connection connection);

    void asyncCall(
            TransactionContext context,
            TransactionRequest request,
            boolean byProxy,
            Connection connection,
            Driver.Callback callback);

    void asyncSendTransaction(
            TransactionContext context,
            TransactionRequest request,
            boolean byProxy,
            Connection connection,
            Driver.Callback callback);

    interface GetBlockNumberCallback {
        void onResponse(Exception e, long blockNumber);
    }

    void asyncGetBlockNumber(Connection connection, GetBlockNumberCallback callback);

    interface GetBlockCallback {
        void onResponse(Exception e, Block block);
    }

    void asyncGetBlock(
            long blockNumber, boolean onlyHeader, Connection connection, GetBlockCallback callback);

    interface GetTransactionCallback {
        void onResponse(Exception e, Transaction transaction);
    }

    void asyncGetTransaction(
            String transactionHash,
            long blockNumber,
            BlockManager blockManager,
            boolean isVerified,
            Connection connection,
            GetTransactionCallback callback);

    interface CustomCommandCallback {
        void onResponse(Exception error, Object response);
    }

    void asyncCustomCommand(
            String command,
            Path path,
            Object[] args,
            Account account,
            BlockManager blockManager,
            Connection connection,
            CustomCommandCallback callback);

    byte[] accountSign(Account account, byte[] message);

    boolean accountVerify(String identity, byte[] signBytes, byte[] message);
}
```

- 接口列表:
  * asyncCall
  * asyncSendTransaction
    状态查询/发送交易
    * TransactionContext context
      * 请求上下文，交易的上下文，包含交易的附属信息
    * TransactionRequest request
    * boolean byProxy
      * 是否通过代理合约查询状态/发送交易
    * Connection connection
      * 发送请求
    * Driver.Callback callback
      * 回调返回
    
  * asyncGetBlockNumber
    获取区块高度  
    * Connection connection
      * 发送请求
    * GetBlockNumberCallback callback
      * 回调返回
    
  * asyncGetBlock
    获取区块 
    * long blockNumber
      * 区块高度
    * boolean onlyHeader
      * 是否只获取区块头
    * Connection connection
      * 发送请求
    * GetBlockCallback callback
      * 回调返回
    
  * asyncGetTransaction
    获取交易，并且对交易进行合法性验证
      * String transactionHash
        * 交易hash
      * long blockNumber
        * 区块高度
      * BlockManager blockManager
        * 区块管理对象，用于获取区块信息，可以使用区块头部的状态信息校验交易是否合法
      * boolean isVerified
        * 是否校验交易
      * Connection connection
        * 发送请求
      * GetTransactionCallback callback
        * 回调返回

  * asyncCustomCommand
    用户自定义其他接口
    * String command
      * 命令
    * Path path
      * 资源
    * Object[] args
      * 参数列表
    * Account account
      * 账户
    * BlockManager blockManager
      * 区块管理对象
    * Connection connection
      * 发送请求
    * CustomCommandCallback callback
      * 回调返回

  * accountSign
    链账户`Account`对消息进行签名，返回序列化之后的签名对象
    * Account account
      * 签名账户
    * byte[] message
      * 代签名的消息
  * accountVerify
    链账户验签
    * String identity
    * byte[] signBytes
      * 签名对象，`accountSign`的返回值
    * byte[] message
      * 签名的原始消息

### 开发模板

WeCross提供一个`Java`模板工程，加快用户开发WeCross Stub的速度，用户仅需要进行少量的修改。

**获取:**
  ```shell
  git clone https://github.com/WeBankBlockchain/WeCross-Stub-Dev-Template.git
  ```

**目录结构:**
  ```shell
  WeCross-Stub-Dev-Template
  ├── README.md
  ├── build.gradle
  └── src
      ├── main
      │   ├── java
      │   │   └── wecross
      │   │       └── stub
      │   │           └── demo                  ## Java核心组件，参考上文各个组件的介绍
      │   │               ├── DemoAccount.java      # Account
      │   │               ├── DemoConnection.java   # Connection
      │   │               ├── DemoDriver.java       # Driver
      │   │               └── DemoStubFactory.java  # StubFactory
      │   └── resources
      └── test
          ├── java
          │   └── wecross
          │       └── stub
          │           └── demo
          │               └── DemoStubTest.java
          └── resources
  ```

**编译:**
  ```shell
  cd WeCross-Stub-Dev-Template
  bash gradlew build

  $ tree -L 1 dist/apps
  dist/apps
  └── WeCross-Stub-Dev-Template-1.0.0-SNAPSHOT.jar
  ```

### 参考链接
[WeCross-BCOS-Stub](https://github.com/WeBankBlockchain/WeCross-BCOS2-Stub)

[WeCross-Fabric-Stub](https://github.com/WeBankBlockchain/WeCross-Fabric1-Stub)  

[WeCross文档](https://wecross.readthedocs.io/zh_CN/latest/)
