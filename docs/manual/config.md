## 配置文件
WeCross通过配置文件管理[Stub](../introduction/introduction.html#id2)以及每个Stub中的[跨链资源](../introduction/introduction.html#id2)，启动时首先加载配置文件，根据配置去初始化各个Stub以及相应的资源，如果配置出错，则启动失败。

```eval_rst
.. note::
    - Toml是一种语义化配置文件格式，可以无二义性地转换为一个哈希表，支持多层级配置，无缩进和空格要求，配置容错率高。
```

### 配置结构

WeCross的配置分为跨链服务配置和链配置两级。

- 跨链服务配置：P2P、RPC等和WeCross服务相关的必要信息。

- 链配置：与区块链建连信息和链上资源信息。

如果链配置缺省，WeCross仍能启动成功，只是不能提供任何跨链服务。

WeCross跨链服务配置文件名为`wecross.toml`，链配置文件名为`chain.toml`，配置的目录结构如下：

``` bash
# 这是conf目录下标准的配置结构，表示配置了两条链，分别叫bcos和fabric
.
├── log4j2.xml   // 日志配置文件，无需更改
├── chains         
│   ├── bcos
│   │   └── chain.toml
│   └── fabric
│       └── chain.toml
└── wecross.toml
```

### 跨链服务配置

配置示例文件`wecross-sample.toml`位于`conf`目录，使用前需拷贝成指定文件名`wecross.toml`。

配置示例如下：

```toml
[common]
    zone = 'payment'
    visible = true

[chains]
    path = 'classpath:chains'

[server]
    address = '127.0.0.1'
    port = 8250

[p2p]
    listenIP = '0.0.0.0'
    listenPort = 25500
    caCert = 'classpath:p2p/ca.crt'
    sslCert = 'classpath:p2p/node.crt'
    sslKey = 'classpath:p2p/node.key'
    peers = ['127.0.0.1:25501','127.0.0.1:25502']

#[[htlc]]
#    selfPath = 'payment.bcos.htlc'
#    account1 = 'bcos_default_account'
#    counterpartyPath = 'payment.fabric.htlc'
#    account2 = 'fabric_default_account'

```

跨链服务配置有五个配置项，分别是`[common]`、`[chains]`、`[server]`、`[p2p]`以及`[test]`，各个配置项含义如下：

- [common] 通用配置
  - network：字符串；跨链分区标识符；通常一种跨链业务/应用为一个跨链分区
  - visible：布尔；可见性；标明当前跨链分区下的资源是否对其他跨链分区可见
- [chains] 链配置
  - path：字符串；链配置的根目录；WeCross从该目录下去加载各个链的配置
- [server] RPC配置
  - address：字符串；本机IP地址；WeCross通过Spring Boot内置的Tomcat启动Web服务
  - port：整型；WeCross服务端口；需要未被占用
- [p2p] 组网配置
  - listenIP：字符串；监听地址；一般为'0.0.0.0'
  - listenPort ：整型；监听端口；WeCross节点之间的消息端口
  - caCert ：字符串；根证书路径；拥有相同根证书的WeCross节点才能互相通讯
  - sslCert ：字符串；节点证书路径；WeCross节点的证书
  - sslKey ：字符串；节点私钥路径；WeCross节点的私钥
  - peers：字符串数组；peer列表；需要互相连接的WeCross节点列表
- [htlc] htlc配置(可选)
  - selfPath：本地配置的htlc合约资源路径
  - account1：可调用本地配置的htlc合约的账户
  - counterpartyPath：本地配置的htlc合约的对手方合约路径
  - account2：可调用对手方htlc合约的账户

**注：**  

1. WeCross启动时会把`conf`目录指定为classpath，若配置项的路径中开头为`classpath:`，则以`conf`为相对目录。
2.  `[p2p]`配置项中的证书和私钥可以通过[create_cert.sh](./scripts.md#p2p)脚本生成。
3. 若通过build_wecross.sh脚本生成的项目，那么已自动帮忙配置好了`wecross.toml`，包括P2P的配置，其中链配置的根目录默认为`chains`。

### 链配置

链配置即每个区块链连接的配置，是WeCross跨链业务的核心，配置了与区块链交互所需的信息，以及注册了各个链需要参与跨链的资源。

WeCross启动后会在`wecross.toml`中所指定的chains的根目录下去遍历所有的一级目录，目录名即为chain的名字，不同的目录代表不同的链，然后尝试读取每个目录下的`chain.toml`文件。

目前WeCross支持的Stub类型包括：[FISCO BCOS](https://github.com/FISCO-BCOS/FISCO-BCOS)和[Fabric](https://github.com/hyperledger/fabric)。

#### FISCO BCOS

配置示例如下：

```toml
[common]
    name = 'bcos' # stub must be same with directory name
    type = 'BCOS2.0' # BCOS

[chain]
    groupId = 1 # default 1
    chainId = 1 # default 1
    enableGM = false # default false

[channelService]
    caCert = 'ca.crt'
    sslCert = 'sdk.crt'
    sslKey = 'sdk.key'
    timeout = 5000  # ms, default 60000ms
    connectionsStr = ['127.0.0.1:20200']

# resources is a list
[[resources]]
    # name cannot be repeated
    name = 'HelloWeCross'
    type = 'BCOS_CONTRACT' # BCOS_CONTRACT or BCOS_SM_CONTRACT
    contractAddress = '0xdd02687ee3b20608f10d2794d5cd2e1133dad204'
```

配置方法详见[FISCO BCOS Stub配置](../stubs/bcos.html#fisco-bcos-stub)

#### Fabric

配置示例如下：

```toml
[common]
    name = 'fabric'
    type = 'Fabric1.4'

[fabricServices]
    channelName = 'mychannel'
    orgName = 'Org1'
    mspId = 'Org1MSP'
    orgUserName = 'fabric_admin'
    orgUserAccountPath = 'classpath:accounts/fabric_admin'
    ordererTlsCaFile = 'orderer-tlsca.crt'
    ordererAddress = 'grpcs://localhost:7050'

[peers]
    [peers.org1]
        peerTlsCaFile = 'org1-tlsca.crt'
        peerAddress = 'grpcs://localhost:7051'
    [peers.org2]
         peerTlsCaFile = 'org2-tlsca.crt'
         peerAddress = 'grpcs://localhost:9051'

# resources is a list
[[resources]]
    # name cannot be repeated
    name = 'ledger'
    type = 'FABRIC_CONTRACT'
    chainCodeName = 'ledgerSample'
    chainLanguage = "go"
    peers=['org1']
```

配置方法详见[Fabric Stub配置](../stubs/fabric.html#fabric-stub)

<!--

#### JDChain

配置示例如下：

```toml
[common]
name = 'jd' # stub must be same with directory name
type = 'JDCHAIN'

# jdServices is a list
[[jdServices]]
privateKey = '0000000000000000'
publicKey = '111111111111111'
password = '222222222222222'
connectionsStr = '127.0.0.1:18081'
[[jdServices]]
privateKey = '0000000000000000'
publicKey = '111111111111111'
password = '222222222222222'
connectionsStr = '127.0.0.1:18082'

# resources is a list
[[resources]]
# name must be unique
name = 'HelloWeCross'
type = 'JDCHAIN_CONTRACT'
contractAddress = '0x38735ad749aebd9d6e9c7350ae00c28c8903dc7a'
[[resources]]
name = 'HelloWorld'
type = 'JDCHAIN_CONTRACT'
contractAddress = '0x38735ad749aebd9d6e9c7350ae00c28c8903dc7a'
```

配置方法详见[JDChain Stub配置](../stubs/jd.html#jdchain-stub)
-->