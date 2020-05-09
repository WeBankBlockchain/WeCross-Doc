## 配置文件
本节描述WeCross Router的配置。

### 配置结构

WeCross Router的配置位于`conf`目录下，分为：

- 主配置（`wecross.toml`）：配置Router连接等信息
- 链配置（`chains/<chain_name>/stub.toml`）：配置连接至对应区块链、链上资源
- 账户配置（`accounts/<account_name>/account.toml`）：配置可用于发交易账户的公私钥等信息

配置的目录结构如下：

``` bash
# 这是conf目录下标准的配置结构，Router配置连接了两条链，分别叫bcos和fabric
.
├── log4j2.xml   // 日志配置文件，无需更改
├── accounts
│   ├── bcos_user1
│   │   └── account.toml  // 账户配置
│   └── fabric_user1
│       └── account.toml  // 账户配置
├── chains         
│   ├── bcos
│   │   └── stub.toml	  // 链配置
│   └── fabric
│       └── stub.toml     // 链配置
└── wecross.toml		  // 主配置
```

### 主配置

主配置为 `conf/wecross.toml`，配置示例如下：

```toml
[common]
    zone = 'payment'
    visible = true

[chains]
    path = 'classpath:chains'

[rpc] # rpc ip & port
    address = '127.0.0.1'
    port = 8250
    caCert = 'classpath:ca.crt'
    sslCert = 'classpath:ssl.crt'
    sslKey = 'classpath:ssl.key'

[p2p]
    listenIP = '0.0.0.0'
    listenPort = 25500
    caCert = 'classpath:ca.crt'
    sslCert = 'classpath:ssl.crt'
    sslKey = 'classpath:ssl.key'
    peers = ['127.0.0.1:25501']
    threadNum = 500


#[[htlc]]
#    selfPath = 'payment.bcos.htlc'
#    account1 = 'bcos_default_account'
#    counterpartyPath = 'payment.fabric.htlc'
#    account2 = 'fabric_default_account'

```

跨链服务配置有五个配置项，分别是`[common]`、`[chains]`、`[rpc]`、`[p2p]`以及`[test]`，各个配置项含义如下：

- `[common] `通用配置
  - zone：字符串；跨链分区标识符；通常一种跨链业务/应用为一个跨链分区
  - visible：布尔；可见性；标明当前跨链分区下的资源是否对其他跨链分区可见
- `[chains]` 链配置
  - path：字符串；链配置的根目录；WeCross从该目录下去加载各个链的配置
- `[rpc] `RPC配置
  - address：字符串；RPC服务监听地址，通常设置为本机IP地址
  - port：整型；WeCross Router的RPC端口；WeCross Java SDK调用Router的端口
  - caCert ：字符串；WeCross Router根证书路径
  - sslCert ：字符串；WeCross Router证书路径
  - sslKey ：字符串；WeCross Router私钥路径
- `[p2p]` 组网配置
  - listenIP：字符串；P2P服务监听地址；一般为'0.0.0.0'
  - listenPort ：整型；P2P服务监听端口；WeCross Router之间交换消息的端口
  - caCert ：字符串；WeCross Router根证书路径
  - sslCert ：字符串；WeCross Router证书路径
  - sslKey ：字符串；WeCross Router私钥路径
  - peers：字符串数组；peer列表；需要互相连接的WeCross Router列表
  - threadNum：p2p线程数，默认500
- `[htlc] `htlc配置(可选)
  - selfPath：本地配置的htlc合约资源路径
  - account1：可调用本地配置的htlc合约的账户
  - counterpartyPath：本地配置的htlc合约的对手方合约路径
  - account2：可调用对手方htlc合约的账户

**注：**  

1. WeCross启动时会把`conf`目录指定为classpath，若配置项的路径中开头为`classpath:`，则以`conf`为相对目录。
2.  `[p2p]`配置项中的证书和私钥可以通过[create_cert.sh](./scripts.md#p2p)脚本生成。
3. 若通过build_wecross.sh脚本生成的项目，那么已自动帮忙配置好了`wecross.toml`，包括P2P的配置，其中链配置的根目录默认为`chains`。

### 链配置

链配置是Router连接每个区块链的配置：

* 指定链名

在`chains/<chain_name>/stub.toml`目录下，通过目录名`<chain_name>`指定链名。

* 区块链链接信息

在`stub.toml`中配置与区块链交互所需链接的信息。

* 跨链资源

在`stub.toml`中配置需要参与跨链的资源。

WeCross启动后会在`wecross.toml`中所指定的`chains`的根目录下去遍历所有的一级目录，目录名即为chain的名字，不同的目录代表不同的链，然后尝试读取每个目录下的`stub.toml`文件。

目前WeCross支持的Stub类型包括：[FISCO BCOS](https://github.com/FISCO-BCOS/FISCO-BCOS)和[Fabric](https://github.com/hyperledger/fabric)。

**配置FISCO BCOS**

请参考：[FISCO BCOS 2.0插件配置](../stubs/bcos.html#id8)

**配置Fabric**

请参考：[Fabric 1.4插件配置](../stubs/fabric.html#id3)

### 账户配置

在Router中配置账户，与链进行交互。配置操作包括：

* 指定账户名（`accounts/<account_name>/account.toml`下，通过目录名`<account_name>`指定账户名）
* 指定账户类型（用于BCOS、Fabric等，在`account.toml`中配置）
* 指定账户其它信息（密钥等，在`account.toml`中配置）

WeCross启动后会在`accounts`的根目录下去遍历所有的一级目录，目录名即为账户的名字，不同的目录代表不同的链，然后尝试读取每个目录下的`account.toml`文件。

配置不同类型的账户，与不同类型的链进行操作。目前WeCross支持的类型包括：[FISCO BCOS](https://github.com/FISCO-BCOS/FISCO-BCOS)和[Fabric](https://github.com/hyperledger/fabric)。

**配置FISCO BCOS**

请参考：[FISCO BCOS 2.0账户配置](../stubs/bcos.html#id6)

**配置Fabric**

请参考：[Fabric 1.4账户配置](../stubs/fabric.html#id4)
