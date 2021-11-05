## 配置

本节描述WeCross Router的配置。

### 配置结构

WeCross Router的配置位于`conf`目录下，分为：

- 主配置（`wecross.toml`）：配置Router连接等信息
- 链配置（`chains/<chain_name>/stub.toml`）：配置连接至对应区块链、链上资源
- 账户配置（`accounts/<account_name>/account.toml`）：配置可用于发交易账户的公私钥等信息
- 区块头验证配置（`verifier.toml`）：配置对应链的区块验证公钥或证书路径，**该配置为可选配置**

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
│   │   └── stub.toml     // 链配置
│   └── fabric
│       └── stub.toml     // 链配置
├── verifier.toml         // 区块头验证配置
└── wecross.toml          // 主配置
```

### 主配置

主配置为 `conf/wecross.toml`，配置示例如下：

```toml
[common]
    zone = 'payment'
    visible = true
    enableAccessControl = false

[chains]
    path = 'classpath:chains'

[rpc] # rpc ip & port
    address = '127.0.0.1'
    port = 8250
    caCert = 'classpath:ca.crt'
    sslCert = 'classpath:ssl.crt'
    sslKey = 'classpath:ssl.key'
    threadNum = 16
    threadQueueCapacity = 10000
    sslSwitch = 2  # disable ssl:2, SSL without client auth:1 , SSL with client and server auth: 0
    webRoot = 'classpath:pages'
    mimeTypesFile = 'classpath:conf/mime.types' # set the content-types of a file
    # urlPrefix = '/wecross' # v1.1.1新增配置，使用该配置可收敛所有请求URL前缀

[p2p]
    listenIP = '0.0.0.0'
    listenPort = 25500
    caCert = 'classpath:ca.crt'
    sslCert = 'classpath:ssl.crt'
    sslKey = 'classpath:ssl.key'
    peers = ['127.0.0.1:25501']
    threadNum = 16
    threadQueueCapacity = 100000
    
[account-manager]
    server =  '127.0.0.1:8250'
    admin = 'org1-admin'
    password = '123456' # This field is not used at v1.0.0, just for future
    sslKey = 'classpath:ssl.key'
    sslCert = 'classpath:ssl.crt'
    caCert = 'classpath:ca.crt'
    maxTotal = 200
    maxPerRoute = 8
    allowNameToken = false

#[[htlc]]
#    selfPath = 'payment.bcos.htlc'
#    account1 = 'bcos_default_account'
#    counterpartyPath = 'payment.fabric.htlc'
#    account2 = 'fabric_default_account'

```

跨链服务配置有五个配置项，分别是`[common]`、`[chains]`、`[rpc]`、`[p2p]`以及`[test]`，各个配置项含义如下：

- `[common]` 通用配置
  - zone：字符串；跨链分区标识符；通常一种跨链业务/应用为一个跨链分区
  - visible：布尔；可见性；标明当前跨链分区下的资源是否对其他跨链分区可见
  - enableAccessControl：布尔；是否开启权限控制，开启后，仅admin账户可访问所有资源，普通账户需admin账户在网页管理台中为其授权后才可访问相应资源
- `[chains]` 链配置
  - path：字符串；链配置的根目录；WeCross从该目录下去加载各个链的配置
- `[rpc]` RPC配置
  - address：字符串；RPC服务监听地址，通常设置为本机IP地址
  - port：整型；WeCross Router的RPC端口；WeCross Java SDK调用Router的端口
  - caCert：字符串；WeCross Router根证书路径
  - sslCert：字符串；WeCross Router证书路径
  - sslKey：字符串；WeCross Router私钥路径
  - threadNum（可选）：整型，rpc线程数，默认16
  - threadQueueCapacity（可选）：整型，任务队列容量，默认10000
  - sslSwitch：整型，SL加密配置，0：双向验证，1：验Router证书，0：无验证
  - webRoot：字符串，网页管理平台页面存放位置
  - mimeTypesFile：字符串网页管理平台的content-type映射文件存放位置
  - urlPrefix: 用于收敛请求URL，若不配置则默认为空，若配置则必须配置正确，支持数字英文和特殊符号( -, _ )，长度1-18
    - 若需要进行控制台/网页管理平台访问修改URL前置的跨链路由router，可参考[控制台配置](./console.html#id12)中的`urlPrefix`字段，参考[网页管理平台配置](./webApp.html#url)中的配置方法。
- `[p2p]` 组网配置
  - listenIP：字符串；P2P服务监听地址；一般为'0.0.0.0'
  - listenPort ：整型；P2P服务监听端口；WeCross Router之间交换消息的端口
  - caCert ：字符串；WeCross Router根证书路径
  - sslCert ：字符串；WeCross Router证书路径
  - sslKey ：字符串；WeCross Router私钥路径
  - peers：字符串数组；peer列表；需要互相连接的WeCross Router列表
  - threadNum（可选）：p2p线程数，默认16
  - threadQueueCapacity（可选）：任务队列容量，默认10000
- `[account-manager]` 跨链账户服务配置
  - server：字符串，需要连接的Account Manager的IP:Port
  - admin：字符串，此Router连接的Account Manager的admin账户名，需与Account Manager中的配置保持一致
  - password：字符串保留字段，目前无用
  - sslKey：字符串；WeCross Router根证书路径
  - sslCert：字符串；WeCross Router证书路径
  - caCert：字符串；WeCross Router私钥路径
  - maxTotal（可选）：整型，连接Account Manager的连接池maxTotal参数，默认200
  - maxPerRoute（可选）：整型，连接Account Manager的连接池maxPerRoute参数，默认8
  - allowNameToken (可选)：布尔类型，用于适配外部登录系统，设置为true后router取消对登录token的校验，此时删除header中的Authorization，在url中加上`&wecross-name-token=xxx`，即可直接将xxx作为登陆者id，在大多数场景下此配置应为false
- `[htlc]` htlc配置（可选）
  - selfPath：本地配置的htlc合约资源路径
  - account1：可调用本地配置的htlc合约的账户
  - counterpartyPath：本地配置的htlc合约的对手方合约路径
  - account2：可调用对手方htlc合约的账户

**注：**  

1. WeCross启动时会把`conf`目录指定为classpath，若配置项的路径中开头为`classpath:`，则以`conf`为相对目录。
2. `[p2p]` 配置项中的证书和私钥可以通过[create_cert.sh](./scripts.html#p2p)脚本生成。
3. 若通过build_wecross.sh脚本生成的项目，那么已自动帮忙配置好了`wecross.toml`，包括P2P的配置，其中链配置的根目录默认为`chains`。

### 链配置

链配置是Router连接每个区块链的配置：

- 指定链名

在`chains/<chain_name>/stub.toml`目录下，通过目录名`<chain_name>`指定链名。

- 区块链链接信息

在`stub.toml`中配置与区块链交互所需链接的信息。

- 跨链资源（可选）

在`stub.toml`中配置需要参与跨链的资源。

WeCross启动后会在`wecross.toml`中所指定的`chains`的根目录下去遍历所有的一级目录，目录名即为chain的名字，不同的目录代表不同的链，然后尝试读取每个目录下的`stub.toml`文件。

目前WeCross支持的Stub类型包括：FISCO BCOS 和Hyperledger Fabric。

FISCO BCOS访问链接：
[GitHub访问链接](https://github.com/FISCO-BCOS/FISCO-BCOS)，
[Gitee访问链接](https://github.com/FISCO-BCOS/FISCO-BCOS)

Hyperledger Fabric访问链接：
[GitHub访问链接](https://github.com/hyperledger/fabric)，
[Gitee访问链接](https://gitee.com/mirrors/hyperledger-fabric)

**配置FISCO BCOS**

请参考：[FISCO BCOS 2.0插件配置](../stubs/bcos.html#id4)

**配置Fabric**

请参考：[Fabric 1.4插件配置](../stubs/fabric.html#id3)

### 区块头验证配置

区块头验证配置为 `conf/verifier.toml`，配置示例如下：

```toml
[verifiers]
    [verifiers.payment.bcos-group1]
        chainType = 'BCOS2.0'
        # 填写所有共识节点的公钥
        pubKey = [
            'b949f25fa39a6b3797ece30a2a9e025...',
            '...'
        ]
    [verifiers.payment.bcos-group2]
        chainType = 'BCOS2.0'
        # 填写所有共识节点的公钥
        pubKey = [
            'b949f25fa39a6b3797ece3132134fa3...',
            '...'
        ]
    [verifiers.payment.bcos-gm]
        chainType = 'GM_BCOS2.0'
        pubKey = [
            'ecc094f00b11a0a5cf616963e313218...'
        ]
    [verifiers.payment.fabric-mychannel]
        chainType = 'Fabric1.4'
        # 填写所有机构CA的证书路径
        [verifiers.payment.fabric-mychannel.endorserCA]
            Org1MSP = 'classpath:verifiers/org1CA/ca.org1.example.com-cert.pem'
            Org2MSP = 'classpath:verifiers/org2CA/ca.org2.example.com-cert.pem'
        [verifiers.payment.fabric-mychannel.ordererCA]
            OrdererMSP = 'classpath:verifiers/ordererCA/ca.example.com-cert.pem'
```

区块头验证配置有一个主要配置项：

- `[verifiers]`：定义文件Map入口
  - `[verifiers.zone.chain]`：`zone.chain`为指定某个待验证的链类型，若配置该链则必须配置全；
    - chainType ：字符串；定义为待验证的链的类型，若配置错误会报错；
    - 其余字段：根据链类型，配置不同的字段

  - pubKey：字符串数组；仅适用于`BCOS2.0`和`GM_BCOS2.0`类型的链，填入该链类型的共识节点公钥数组，配置必须符合以下条件：
    - 公钥均以字符串形式填入数组中
    - 必须包含所有共识节点的公钥信息
  - `[verifiers.zone.chain.endorserCA]`：Map类型；仅适用于`Fabric1.4`类型的链，填入该类型链的所有机构CA的MSP签名证书路径，其中Map的key是各个机构的MSPID，value是证书路径
  - `[verifiers.zone.chain.ordererCA]`：Map类型；仅适用于`Fabric1.4`类型的链，填入该类型链的所有Orderer机构颁发的MSP签名证书路径，其中Map的key是各个Orderer的MSPID，value是证书路径

**区块头验证配置注意事项：**

- 若未写`verifier.toml`文件，则默认不进行所有链的区块头验证；
- 若已配置`verifier.toml`文件，但未设置某条链的验证配置，则默认不进行该链的区块头验证；
- Fabric链的`endorserCA`和`ordererCA`必须同时配置；
- 若配置中漏了某个公钥和证书，则会导致验证不通过。
