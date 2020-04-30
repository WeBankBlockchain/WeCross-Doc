## WeCross Stub插件开发

本章内容介绍区块链接入WeCross的完整开发流程，用户可以根据本教程实现一个WeCross区块链`Stub`插件，通过该插件接入WeCross。

```eval_rst
.. note::
    - Java编程语言
     WeCross使用Java实现，接入的区块链需要支持Java版本的SDK，要求开发人员具备Java开发能力。
    - Gradle构建工具
     WeCross组件目前使用Gradle进行构建，因此假定用户能够使用Gradle，maven能达到相同的效果，用户可以自行探索。
```

### 创建Gradle项目
Gradle依赖分类
- Stub API定义
- Java SDK，区块链Java版的SDK
- 其他依赖，例如：toml解析工具

```shell
// Gradle 依赖示例
dependencies {
    // Stub接口定义Jar
    implementation 'com.webank:wecross-java-stub:1.0.0-rc2'
    // BCOS JavaSDK
    implementation 'org.fisco-bcos:web3sdk:2.4.0'
    // toml文件解析
    implementation 
    'com.moandjiezana.toml:toml4j:0.7.2'
    // 其他依赖
}
```

新建Gradle工程，并且在`build.gradle`中添加依赖。  

Gradle配置参考: [WeCross-BCOS-Stub build.gradle](https://github.com/WeBankFinTech/WeCross-BCOS-Stub/blob/release-rc2/build.gradle)  

### 核心组件
`Stub`插件需要实现的组件接口：
- StubFactory
- Account
- Connection
- Driver
  
#### StubFactory  
StubFactory功能
  * 添加`@Stub`注解，指定插件类型  
  * 提供Account、Connection、Driver实例化入口

```eval_rst
.. important::
只有添加@Stub注解的插件才能被Wecross Router识别加载!
```

`StubFactory`接口定义
```Java
public interface StubFactory {

    /** 创建Driver对象 */
    public Driver newDriver();

    /** 解析Connection配置stub.toml，创建Connection对象 */
    public Connection newConnection(String path);

    /** 解析Account配置account.toml，创建Account对象 */
    public Account newAccount(String name, String path);
}
```

BCOS Stub示例:
```Java
/** @Stub注解，插件类型: BCOS2.0 */
@Stub("BCOS2.0") 
public class BCOSStubFactory implements StubFactory {

    @Override
    public Driver newDriver() {
        // 创建返回BCOSDriver对象
    }

    @Override
    public Connection newConnection(String path) {
        // 解析stub.toml配置, 创建返回BCOSConnection对象
    }

    @Override
    public Account newAccount(String name, String path) {
        // 解析account.toml账户配置，创建返回BCOSAccount对象
    }
}
```  

#### Account
`Account`包含账户私钥，用于交易签名。

接口定义
```Java
public interface Account {

    /** 账户名称 */
    String getName();

    /** 账户类型 */
    String getType();

    /** 账户公钥 */
    String getIdentity();
}
```

Account由StubFactory对象`newAccount`接口创建，用户需要解析配置生成Account对象
- `Account newAccount(String name, String path)`
    * name: 账户名称
    * path: 配置文件`account.toml`所在目录路径

账户配置文件位于`conf/accounts/`目录，可以配置多个账户，每个账户置于单独的子目录。  
```shell
# 目录结构, conf/accounts/账户名称/
conf/accounts
        └── bcos # 账户名称: bcos
            ├── 0x4c9e341a015ce8200060a028ce45dfea8bf33e15.pem # BCOS私钥文件
            └── account.toml # account.toml配置文件
```

```shell
# account.toml内容
[account]
    type = "BCOS2.0" # 必须项，账户类型，与插件@Stub注解定义的类型保持一致
    accountFile = '0x4c9e341a015ce8200060a028ce45dfea8bf33e15.pem' # 配置的私钥文件名称
```

`account.toml`解析流程可以参考[BCOS Stub account.toml解析](https://github.com/WeBankFinTech/WeCross-BCOS-Stub/blob/dev/src/main/java/com/webank/wecross/stub/bcos/config/BCOSAccountConfigParser.java)

BCOS Stub示例
```Java
public class BCOSAccount implements Account {

    /** 名称 */
    private final String name;

    /** 类型 */
    private final String type;

    /** 公钥 */
    private final String publicKey;

    /** BCOS私钥对象，交易签名，加载配置的私钥文件生成 */
    private final Credentials credentials;

    public Credentials getCredentials() {
        return credentials;
    }
    /** 其他接口 */
}

```
#### Connection
Connection用于
 * 为Driver提供统一发送接口，与区块链交互
 * 获取配置的资源列表，资源在Connection初始化时从配置文件加载
  
接口定义
```Java
public interface Connection {

    /** 发送接口请求给区块链 */
    Response send(Request request);

    /** 获取资源列表，资源列表在stub.toml文件配置 */
    List<ResourceInfo> getResources();
}
```

接口列表
- getResources

获取资源列表，资源在Connection初始化时加载，表示Stub可以访问的区块链资源。
- send 

提供统一的发送请求接口给Driver使用，Driver设置请求类型并将参数序列化生成Request，调用send接口，返回Response对象，Response包含返回值、错误信息以及返回内容。

```Java
/** Request请求对象，包含请求类型与请求内容 */
public class Request {

    /** 请求类型，用户自定义，区分不同的区块链请求 */
    private int type;

    /** 请求内容，序列化的请求参数，用户自定义序列化方式 */

    private byte[] data;

    /** 请求资源 */
    private ResourceInfo resourceInfo;
}

/** Response返回值对象，包含错误码、错误描述以及返回内容 */
public class Response {

    /** 返回状态 */
    private int errorCode;

    /** 返回错误描述 */
    private String errorMessage;

    /** 返回内容，序列化的返回参数，可以反序列化为返回对象 */
    private byte[] data;
}

/** 资源对象 */
public class ResourceInfo {

    /** 资源名称 */
    private String name;

    /** 资源类型，用户自定义 */
    private String stubType;

    /** 额外属性，用户自定义 */
    private Map<Object, Object> properties = new HashMap<Object, Object>();
}
```

Connection由StubFactory对象`newConnection`接口创建，解析配置生成Connection对象
- `Connnection newConnection(String path)`
    * path: 配置文件`stub.toml`所在目录路径

插件配置`stub.toml`
  * 通用配置：插件名称、类型  
  * SDK配置：初始化JavaSDK，与区块链交互  
  * 资源列表：区块链可以访问的资源列表
  
插件配置默认位于`chains/`目录，可以配置多个stub，每个stub位于单独的子目录。

```shell
# 目录结构, conf/chains/stub名称/
conf/chains/
        └── bcos # stub名称: bcos
            └── stub.toml # stub.toml配置文件
            # 其他文件列表，比如：证书文件
```

`stub.toml`解析流程可以参考[BCOS Stub stub.toml解析](https://github.com/WeBankFinTech/WeCross-BCOS-Stub/blob/dev/src/main/java/com/webank/wecross/stub/bcos/config/BCOSStubConfigParser.java)

BCOS示例
```Java
/** Request type定义，用户自定义 */
public class BCOSRequestType {
    // call
    public static final int CALL = 1000;
    // sendTransaction
    public static final int SEND_TRANSACTION = 1001;
    // 获取区块高度
    public static final int GET_BLOCK_NUMBER = 1002;
    // 获取BlockHeader
    public static final int GET_BLOCK_HEADER = 1003;
    // 获取交易Merkle证明
    public static final int GET_TRANSACTION_PROOF = 1004;
}

public class BCOSConnection implements Connection {
    /** BCOS SDK对象，调用区块链接口 */
    private final Web3jWrapper web3jWrapper;
    /** 为Driver提供统一发送接口，根据不同请求类型分别与区块链完成交互 */
    @Override
    public Response send(Request request) {
        switch (request.getType()) {
            /** call请求 */
            case BCOSRequestType.CALL:
                /** handle call request */
            /** sendTransaction请求 */
            case BCOSRequestType.SEND_TRANSACTION:
                /** handle sendTransaction request */
            /** 获取区块头 */
            case BCOSRequestType.GET_BLOCK_HEADER:
                /** handle getBlockeHeader request */
            /** 获取块高 */
            case BCOSRequestType.GET_BLOCK_NUMBER:
                /** handle getBlockNumber request */
            /** 获取交易Merkle证明 */
            case BCOSRequestType.GET_TRANSACTION_PROOF:
                /** handle getTransactionProof request */
            default:
                /** unrecognized request type */
        }
    }

    /** 获取资源列表 */
    @Override
    public List<ResourceInfo> getResources() {
        return resourceInfoList;
    }
}
```

BCOS stub.toml示例
```shell
[common]    # 通用配置
    name = 'bcos' # 名称，必须项
    type = 'BCOS2.0' # 必须项，插件类型，与插件@Stub注解定义的类型保持一致


[chain]     # BCOS链属性配置
    groupId = 1 # default 1
    chainId = 1 # default 1

[channelService]    # BCOS JavaSDK配置
    caCert = 'ca.crt'
    sslCert = 'sdk.crt'
    sslKey = 'sdk.key'
    timeout = 300000  # ms, default 60000ms
    connectionsStr = ['127.0.0.1:20200', '127.0.0.1:20201', '127.0.0.1:20202']

[[resources]]       # 资源配置列表
    name = 'HelloWeCross' # 资源名称
    type = 'BCOS_CONTRACT' # 资源类型，BCOS合约
    contractAddress = '0x8827cca7f0f38b861b62dae6d711efe92a1e3602' # 合约地址
```

#### Driver
Driver是Stub与WeCross Router交互的入口，用途包括:
 * 发送交易
 * 编解码交易
 * 编解码区块
 * 验证交易
 * 其他功能

接口定义
```Java
public interface Driver {

    /** call或者sendTransaction请求,返回为true,其他类型返回false */
    public boolean isTransaction(Request request);

    /** 解码BlockHeader数据 */
    public BlockHeader decodeBlockHeader(byte[] data);

    /** 获取区块链当前块高 */
    public long getBlockNumber(Connection connection);

    /** 获取Block Header */
    public byte[] getBlockHeader(long blockNumber, Connection connection);

    /** 解析交易请求,请求可能为call或者sendTransaction */
    public TransactionContext<TransactionRequest> decodeTransactionRequest(byte[] data);
    
        /** 调用合约,查询请求 */
    public TransactionResponse call(
            TransactionContext<TransactionRequest> request, Connection connection);

    /** 调用合约,交易请求 */
    public TransactionResponse sendTransaction(
            TransactionContext<TransactionRequest> request, Connection connection);

        /** 获取交易,并且对交易进行验证 */
    public VerifiedTransaction getVerifiedTransaction(
            String transactionHash,
            long blockNumber,
            BlockHeaderManager blockHeaderManager,
            Connection connection);
}
```

接口列表
- isTransaction
  是否为请求交易
  * 参数列表：
    * Request request: 请求对象
  * 返回值：
    * request为call或者sendTransaction请求返回true，否则返回false
- getBlockNumber
  获取当前区块高度
  * 参数列表：
    * Connection connection: Connection对象，发送请求
  * 返回值
    * 区块高度，负值表示获取区块高度失败
  
- getBlockHeader
  获取区块头数据，区块头为序列化的二进制数据  
  * 参数列表：
    * long blockNumber: 块高
    * Connection connection: Connection对象，发送请求
  * 返回值
    * 序列化的区块头数据，返回null表示获取区块头数据失败，可以使用decodeBlockHeader获取区块头对象
- decodeBlockHeader
  解析区块头数据，返回区块头对象  
  * 参数列表：
    * byte[] data: 序列化的区块头数据
  * 返回值
    * 区块头BlockHeader对象，返回null表示解析区块头数据失败
        ```Java
        区块头对象
        public class BlockHeader {
            /** 区块高度 */
            private long number;
            /** 上一个区块hash */
            private String prevHash;
            /** 区块hash */
            private String hash;
            /** 状态根，验证状态 */
            private String stateRoot;
            /** 交易根，验证区块交易 */
            private String transactionRoot;
            /** 交易回执根，验证区块交易回执 */
            private String receiptRoot;
        }
        ```
- call
- sendTransaction
  `sendTransaction`与`call`接口类似，后者用于查询状态，前者发送交易，修改区块链状态
  * 参数列表
    * TransactionContext<TransactionRequest> request: 请求上下文，获取构造交易需要的数据，构造交易
    * Connection connection: Connection对象，发送请求
  * 返回值
    * TransactionResponse: 返回对象
  * 注意： 
    * `sendTransaction`接口要对返回交易进行验证，各个区块链的验证方式有所不同，BCOS采用Merkle证明的方式对交易及交易回执进行验证
        ```Java
        // 请求对象
        public class TransactionRequest {
            /** 接口 */
            private String method;
            /** 参数 */
            private String[] args;
        }

        // 返回对象
        public class TransactionResponse {
            // 返回状态，0表示成功，其他表示错误码
            private Integer errorCode;
            // 错误信息
            private String errorMessage;
            // 交易hash，sendTransaction时有效
            private String hash;
            // 区块高度，交易所在的区块的块高，sendTransaction时有效
            private long blockNumber;
            // 返回结果
            private String[] result;
        }

        // 交易请求上下文参数，获取构造交易需要的参数
        public class TransactionContext<TransactionRequest> {
            // 交易请求 
            private TransactionRequest data;
            // 账户，用于交易签名
            private Account account;
            // 请求资源，用于获取资源相关信息
            private ResourceInfo resourceInfo;
            // 区块头管理器，获取区块头信息
            private BlockHeaderManager blockHeaderManager;
        }

        // 区块头管理器
        public interface BlockHeaderManager {
            // 获取当前块高
            public long getBlockNumber();
            // 获取区块头，阻塞操作
            public byte[] getBlockHeader(long blockNumber);
        }
        ```
- getVerifiedTransaction
  验证交易是否合法，并且返回交易的请求与返回参数，验证交易与sendTransaction的方式保持一致。
  * 参数列表
    * String transactionHash: 交易hash
    * long blockNumber: 交易所在区块高度
    * BlockHeaderManager blockHeaderManager: 区块头管理器，获取区块头
    * Connection connection: 发送请求
  * 返回值
    * VerifiedTransaction对象
        ```Java
        public class VerifiedTransaction {
            /** 交易所在块高 */
            private long blockNumber;
            /** 交易hash */
            private String transactionHash;
            /** 交易调用的合约地址 */
            private String realAddress;
            /** 交易请求对象 */
            private TransactionRequest transactionRequest;
            /** 交易返回对象 */
            private TransactionResponse transactionResponse;
        }
        ```

BCOS示例  

这里给个完整的BCOSStub发送交易的处理流程，说明Driver与Connection的协作，以及在BCOS中如何进行交易验证。

- BCOSDriver
```Java
@Override
public TransactionResponse sendTransaction(
        TransactionContext<TransactionRequest> request, Connection connection) {

    TransactionResponse response = new TransactionResponse();

    try {
        ResourceInfo resourceInfo = request.getResourceInfo();
        /** 合约的额外属性，BCOS构造交易需要这些参数，参考BCOS Stub.toml配置 */
        Map<Object, Object> properties = resourceInfo.getProperties();
        /** 获取合约地址 */
        String contractAddress = (String) properties.get(resourceInfo.getName());
        /** 获取群组Id */
        Integer groupId = (Integer) properties.get(BCOSConstant.BCOS_RESOURCEINFO_GROUP_ID);
        /** 获取链Id */
        Integer chainId = (Integer) properties.get(BCOSConstant.BCOS_RESOURCEINFO_CHAIN_ID);
        /** 获取块高 */
        long blockNumber = request.getBlockHeaderManager().getBlockNumber();
        BCOSAccount bcosAccount = (BCOSAccount) request.getAccount();
        /** 获取私钥 参考account.toml配置 */
        Credentials credentials = bcosAccount.getCredentials();

        /** 交易签名，使用credentials对构造的交易进行签名 */
        String signTx =
                SignTransaction.sign(
                        credentials,
                        contractAddress,
                        BigInteger.valueOf(groupId),
                        BigInteger.valueOf(chainId),
                        BigInteger.valueOf(blockNumber),
                        FunctionEncoder.encode(function));

        // 构造Request参数
        TransactionParams transaction = new TransactionParams(request.getData(), signTx);
        Request req = new Request();
        /** Request类型 SEND_TRANSACTION */
        req.setType(BCOSRequestType.SEND_TRANSACTION);
        /** 参数JSON序列化 */
        req.setData(objectMapper.writeValueAsBytes(transaction));
        /** Connection send发送请求 */
        Response resp = connection.send(req);
        if (resp.getErrorCode() != BCOSStatusCode.Success) {
            /** Connection返回异常 */
            throw new BCOSStubException(resp.getErrorCode(), resp.getErrorMessage());
        }
        /** 获取返回的交易回执，回执被序列化为byte[] */
        TransactionReceipt receipt =
                objectMapper.readValue(resp.getData(), TransactionReceipt.class);

        // Merkle证明，校验交易hash及交易回执，失败抛出异常
        verifyTransactionProof(
                receipt.getBlockNumber().longValue(),
                receipt.getTransactionHash(),
                request.getBlockHeaderManager(),
                receipt);

        /** 其他逻辑，构造返回 */

    } catch (Exception e) {
        /** 异常场景 */
        response.setErrorCode(BCOSStatusCode.UnclassifiedError);
        response.setErrorMessage(" errorMessage: " + e.getMessage());
    }

    return response;
}
```

- BCOSConnection
```Java
public class BCOSConnection implements Connection {
    /** BCOS JavaSDK 实例句柄 */
    private final Web3jWrapper web3jWrapper;

    @Override
    public Response send(Request request) {
        switch (request.getType()) {
            case BCOSRequestType.SEND_TRANSACTION:
                /** type: SEND_TRANSACTION */
                return handleTransactionRequest(request);
            /** 其他case场景 */
        }
    }

    /** 发送交易请求处理 */
    public Response handleTransactionRequest(Request request) {
        Response response = new Response();
        try {
            /** 参数JSON序列化，反序列化得到请求参数*/
            TransactionParams transaction =
                    objectMapper.readValue(request.getData(), TransactionParams.class);
            /** 签名交易 */
            String signTx = transaction.getData();
            /** 调用BCOS RPC发送交易接口，获取回执以及Merkle证明 */
            TransactionReceipt receipt = web3jWrapper.sendTransactionAndGetProof(signTx);

            /** 交易回执不存在 */
            if (Objects.isNull(receipt)
                    || Objects.isNull(receipt.getTransactionHash())
                    || "".equals(receipt.getTransactionHash())) {
                throw new BCOSStubException(
                        BCOSStatusCode.TransactionReceiptNotExist,
                        BCOSStatusCode.getStatusMessage(BCOSStatusCode.TransactionReceiptNotExist));
            }

            /** 交易执行失败 */
            if (!receipt.isStatusOK()) {
                throw new BCOSStubException(
                        BCOSStatusCode.SendTransactionNotSuccessStatus,
                        StatusCode.getStatusMessage(receipt.getStatus()));
            }

            /** 交易正确执行 */
            response.setErrorCode(BCOSStatusCode.Success);
            response.setErrorMessage(BCOSStatusCode.getStatusMessage(BCOSStatusCode.Success));
            /** 返回交易回执，回执JSON方式序列化 */
            response.setData(objectMapper.writeValueAsBytes(receipt));
        } catch (Exception e) {
            /** 异常情况 */
            response.setErrorCode(BCOSStatusCode.HandleSendTransactionFailed);
            response.setErrorMessage(" errorMessage: " + e.getMessage());
        }
        return response;
    }
}
```

### 生成Jar
Stub插件需要打包生成`shadow jar`才可以被`WeCross Router`加载使用，在Gradle中引入`shadow`插件。

`shadow`插件使用: [Gradle Shadow Plugin](https://imperceptiblethoughts.com/shadow/plugins/#special-handling-of-the-java-gradle-plugin-development-plugin)

- 引入shadow插件
```shell
plugins {
    // 其他插件列表
    id 'com.github.johnrengelman.shadow' version '5.2.0'
}
```

- 添加打包task
```shell
jar.enabled = false
project.tasks.assemble.dependsOn project.tasks.shadowJar

shadowJar {
    destinationDir file('dist/apps')
    archiveName project.name + '.jar'
    // 其他打包逻辑
}
```

- 执行build操作
```shell
bash gradlew build
```
`dist/apps`目录生成`jar`文件

### 参考链接
[WeCross-BCOS-Stub](https://github.com/WeBankFinTech/WeCross-BCOS-Stub)

[WeCross-Fabric-Stub](https://github.com/WeBankFinTech/WeCross-Fabric-Stub)  

[WeCross文档](https://wecross.readthedocs.io/zh_CN/latest/)