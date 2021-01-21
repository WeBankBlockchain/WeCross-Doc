## 终端控制台

[控制台](https://github.com/WeBankBlockchain/WeCross-Console)是WeCross重要的客户端工具，它基于[WeCross-Java-SDK](../dev/sdk.html)与WeCross跨链路由建立连接，实现对跨链资源的读写访问请求。控制台拥有丰富的命令，包括获取跨链资源列表，调用跨链资源，发起事务等等。

### 控制台命令

控制台命令可分为两类，普通命令和交互式命令。

#### 普通命令

普通命令由两部分组成，即指令和指令相关的参数：

- **指令：**指令是执行的操作命令。**使用提示: 指令可以使用tab键补全，并且支持按上下键显示历史输入指令。**
  
- **指令相关的参数：**指令调用接口需要的参数，指令与参数以及参数与参数之间均用空格分隔。
#### 交互式命令

WeCross控制台为了方便用户使用，还提供了交互式的使用方式，比如将跨链资源路径赋值给变量，初始化一个类，并用`.command`的方式访问方法。
详见：[交互式命令](#id15)

### 常用命令链接

#### 普通命令

- 账号操作
  - [login](#login)：在当前控制台登录全局账号
  - [logout](#logout)：控制台登出
  - [registerAccount](#registeraccount)：注册全局账号
  - [addChainAccount](#addchainaccount)：在当前全局账号添加一个链账号
  - [setDefaultAccount](#setdefaultaccount)：设定某个账号为这个链类型的交易发送默认账号
  - [listAccount](#listaccount)：查看当前全局账号的详细信息
- 状态查询
  - [listResources](#listresources)：查看资源列表
  - [detail](#detail)：查看资源详情
  - [supportedStubs](#supportedstubs)：查看连接的router支持接入的链类型
- 资源调用
  - [call](#call)：调用链上资源，用于查询，不触发出块
  - [sendTransaction](#sendtransaction)：发交易，用于改变链上资源，触发出块
  - [invoke](#invoke)：功能等同[sendTransaction](#sendtransaction)，在跨链事务时自动转化为命令[execTransaction](#exectransaction)
- 资源部署
  - BCOS：[bcosDeploy](#bcosdeploy)、[bcosRegister](#bcosregister)
  - Fabric：[fabricInstall](#fabricinstall)、[fabricInstantiate](#fabricinstantiate)、[fabricUpgrade](#fabricupgrade)
- 跨链事务
  - [startTransaction](#starttransaction)：开始两阶段事务
  - [execTransaction](#exectransaction)：发起事务交易
  - [callTransaction](#calltransaction)：读取事务过程中的数据
  - [commitTransaction](#committransaction)：提交事务，确认事务执行过程中所有的变动
  - [rollbackTransaction](#rollbacktransaction)：撤销本次事务的所有变更时
  - [loadTransaction](#loadtransaction)：恢复到某个正在执行的事务上下文
- 跨链转账
  - [newHTLCProposal](#newhtlcproposal)：创建转账提案

#### 交互式命令

- 初始化资源实例: [WeCross.getResource](#wecross-getresource)
- 访问资源UBI接口: [\[resource\].\[command\]](#resource-command)

### 快捷键

- `Ctrl+A`：光标移动到行首
- `Ctrl+E`：光标移动到行尾
- `Ctrl+R`：搜索输入的历史命令
- &uarr;：  向前浏览历史命令
- &darr;：  向后浏览历史命令
- `tab`： 自动补全，支持命令、变量名、资源名以及其它固定参数的补全

### 控制台响应

当发起一个控制台命令时，控制台会获取命令执行的结果，并且在终端展示执行结果，执行结果分为2类：

- **正确结果:** 命令返回正确的执行结果，以字符串或是json的形式返回。       
- **错误结果:** 命令返回错误的执行结果，以字符串或是json的形式返回。 
- **状态码:** 控制台的命令调用JSON-RPC接口时，状态码[参考这里](../dev/rpc.html#id1)。

### 控制台配置与运行

```eval_rst
.. important::
    前置条件：部署WeCross请参考 `快速部署 <../tutorial/networks.html#wecross-router>`_。
```

#### 获取控制台

可通过脚本`download_console.sh`获取控制台。

```bash
cd ~ && mkdir -p wecross && cd wecross
# 获取控制台
bash <(curl -sL https://github.com/WeBankBlockchain/WeCross-Console/releases/download/resources/download_console.sh)
```
WeBankBlockchain
执行成功后，会生成`WeCross-Console`目录，结构如下：

```bash
├── apps
│   └── wecross-console-xxx.jar  # 控制台jar包
├── conf
│   ├── application-sample.toml   # 配置示例文件
│   └── log4j2.xml           # 日志配置文件
├── lib                      # 相关依赖的jar包目录
├── logs                     # 日志文件
└── start.sh                 # 启动脚本
```

#### 配置控制台

控制台配置文件为 `conf/application-toml`，启动控制台前需配置

``` bash
cd ~/wecross/WeCross-Console
# 拷贝配置sample
cp conf/application-sample.toml conf/application.toml

# 拷贝连接跨链路由所需的证书
cp ~/wecross/routers-payment/cert/sdk/* conf/ # 包含：ca.crt、node.nodeid、ssl.crt、ssl.key

# 配置
vim conf/application.toml
```

配置控制台与某个router的连接

```toml
[connection]
    server =  '127.0.0.1:8250' # 对应router的ip和rpc端口
    sslKey = 'classpath:ssl.key'
    sslCert = 'classpath:ssl.crt'
    caCert = 'classpath:ca.crt'
    sslSwitch = 2 # disable ssl:2, SSL without client auth:1 , SSL with client and server auth: 0
# 可配置全局账号密码，执行命令`login`时可不输入账号密码
[login]
    username = 'username'
    password = 'password'
```

#### 启动控制台

在跨链路由已经启动的情况下，启动控制台

```bash
cd ~/wecross/WeCross-Console
bash start.sh
# 输出下述信息表明启动成功
=============================================================================================
Welcome to WeCross console(v1.0.0)!
Type 'help' or 'h' for help. Type 'quit' or 'q' to quit console.

=============================================================================================
```

### 普通命令

**注：** 以下所有跨链资源相关命令的执行结果以实际配置为准，此处只是示例。

##### help

输入help或者h，查看控制台所有的命令。

```bash
[WeCross]> help
---------------------------------------------------------------------------------------------
quit                             Quit console.
registerAccount                  Register a Universal Account.
login                            Login SDK if you have already registered.
logout                           Logout SDK.
addChainAccount                  Add a Chain Account to your Universal Account.
setDefaultAccount                Set the chain account to be the default account to send transaction.
supportedStubs                   List supported stubs of WeCross router.
listAccount                      List your Universal Account's information.
listLocalResources               List local resources configured by WeCross server.
listResources                    List all resources including remote resources.
status                           Check if the resource exists.
detail                           Get resource information.
call                             Call constant method of smart contract.
invoke                           Call non-constant method of smart contract, will auto-transfer to command execTransaction during transaction.
sendTransaction                  Call non-constant method of smart contract.
callTransaction                  Call constant method of smart contract during transaction.
execTransaction                  Call non-constant method of smart contract during transaction.
startTransaction                 Start an xa transaction.
commitTransaction                Commit an xa transaction.
rollbackTransaction              Rollback an xa transaction.
loadTransaction                  Load a specified transaction context.
getXATransaction                 Get info of specified XA transaction.
listXATransactions               List XA transactions in route.
bcosDeploy                       Deploy contract in BCOS chain.
bcosRegister                     Register contract abi in BCOS chain.
fabricInstall                    Install chaincode in fabric chain.
fabricInstantiate                Instantiate chaincode in fabric chain.
fabricUpgrade                    Upgrade chaincode in fabric chain.
genTimelock                      Generate two valid timelocks.
genSecretAndHash                 Generate a secret and its hash.
newHTLCProposal                  Create a htlc transfer proposal .
checkTransferStatus              Check htlc transfer status by hash.
getCurrentTransactionID          Get Current xa Transaction ID.
WeCross.getResource              Init resource by path, and assign it to a custom variable.
[resource].[command]             Equal to: command [path].

---------------------------------------------------------------------------------------------
```

**注：**

- help显示每条命令的含义是：命令 命令功能描述
- 查看具体命令的使用介绍说明，输入命令 -h或\--help查看。例如：

```bash
[WeCross]> detail -h
---------------------------------------------------------------------------------------------
Get the resource information
Usage: detail [path]
---------------------------------------------------------------------------------------------
```

##### supportedStubs

显示router当前支持的插件列表。

```bash
[WeCross]> supportedStubs
[BCOS2.0, GM_BCOS2.0, Fabric1.4]
```

#### login

在当前控制台登录全局账号。

参数：

- username：(可选) 已注册的全局账号。
- password：(可选) 账号密码。

```bash
[WeCross]> login org1-admin 123456
Result: success
=============================================================================================
Universal Account:
username: org1-admin
pubKey  : 3059301306...
uaID    : 3059301306...

# 当在conf/application.toml已经配置[login]，可直接输入login命令进行登录，无需参数
[WeCross]> login
Result: success
=============================================================================================
Universal Account:
username: org1-admin
pubKey  : 3059301306...
uaID    : 3059301306...

# 当在conf/application.toml未配置[login]，也可直接输入login命令进行登录，逐行输入账号密码
[WeCross]> login
username: org1-admin
password:
Result: success
=============================================================================================
Universal Account:
username: org1-admin
pubKey  : 3059301306...
uaID    : 3059301306...

# 登录成功后WeCross控制台的Prompt将会加上当前登录的账号名
[WeCross.org1-admin]>
```

#### logout

在当前控制台登出账号。

```bash
[WeCross.org1-admin]> logout
Result: success
```

#### registerAccount

注册全局账号。

参数：

- username：(可选) 已注册的全局账号。
- password：(可选) 账号密码。

```bash
[WeCross]> registerAccount org2-admin 123456
Result: success

# 也可直接输入registerAccount命令进行登录，逐行输入账号密码
[WeCross]> registerAccount
tips: username can contain alphabet, digit and some special characters: [-_]
      and the length is in range [4,16].
username: test1
tips: password can contain alphabet, digit and some special characters: [@+!%*#?]
      and the length is in range [1,16].
password:
Result: success
```

#### addChainAccount

在当前全局账号添加一个链账号。

参数：

- chainType：链类型，目前包括 [Fabric1.4, BCOS2.0, GM_BCOS2.0] 三种类型。
- firstKeyPath：第一个密钥/证书路径，以填入的链类型进行区分：
  - 若是FISCO BCOS类型的链账号，第一个密钥路径则是BCOS链账号的公钥（绝对/相对）路径；
  - 若是Hyperledger Fabric类型的链账号，第一个证书路径则是Fabric链账号的证书（绝对/相对）路径；
- secondKeyPath：第二个密钥路径，以填入的链类型进行区分：
  - 若是FISCO BCOS类型的链账号，第二个密钥路径则是BCOS链账号的私钥（绝对/相对）路径；
  - 若是Hyperledger Fabric类型的链账号，第二个密钥路径则是Fabric链账号的密钥（绝对/相对）路径；
- extraData：额外数据，以填入的链类型进行区分：
  - 若是FISCO BCOS类型的链账号，额外数据则是BCOS链账号的地址（address）；
  - 若是Hyperledger Fabric类型的链账号，额外数据则是Fabric链账号所属的机构；
- isDefault：是否将新的链账号作为该类型的默认账号。

```bash
# 添加BCOS链账号
[WeCross.org1-admin]> addChainAccount BCOS2.0 conf/accounts/bcos_user/0xd06636e57de535c8d148662189cb6c3d16e7a47b.public.pem  conf/accounts/bcos_user/0xd06636e57de535c8d148662189cb6c3d16e7a47b.pem 0xd06636e57de535c8d148662189cb6c3d16e7a47b false
Result: success
Universal Account info has been changed, now auto-login again.
Result: success
=============================================================================================
Universal Account:
username: org1-admin
pubKey  : 3059301306...
uaID    : 3059301306...

#添加Fabric链账号
[WeCross.org1-admin]> addChainAccount Fabric1.4 conf/accounts/fabric_admin/account.crt conf/accounts/fabric_admin/account.key Org1 true
Universal Account info has been changed, now auto-login again.
Result: success
=============================================================================================
Universal Account:
username: org1-admin
pubKey  : 3059301306...
uaID    : 3059301306...
```

#### setDefaultAccount

设定某个账号为这个链类型的交易发送默认账号。

参数：

- chainType：链类型，目前包括 [Fabric1.4, BCOS2.0, GM_BCOS2.0] 三种类型。
- keyID：指定账号的ID，可通过[listAccount](#listAccount)命令获取。

```bash
[WeCross.org1-admin]> setDefaultAccount Fabric1.4 2
Result: success
Universal Account info has been changed, now auto-login again.
Result: success
=============================================================================================
Universal Account:
username: org1-admin
pubKey  : 3059301306...
uaID    : 3059301306...
```

#### listAccount

查看当前全局账号的详细信息。

参数：

- -d：(可选) 可返回全局账号的更加详细的信息，包括链账号公钥/证书信息，全局账号公钥信息

```bash
[WeCross.org1-admin]> listAccount
Universal Account:
username: org1-admin
pubKey  : 3059301306...
uaID    : 3059301306...
chainAccounts: [
  BCOS2.0 Account:
  keyID    : 0
  type     : BCOS2.0
  address  : 0xe6a68370212863821a5c209c5b66f4ba40e7c80e
  isDefault: true
  ----------
  Fabric1.4 Account:
  keyID    : 1
  type     : Fabric1.4
  MembershipID : Org1MSP
  isDefault: true
  ----------
  Fabric1.4 Account:
  keyID    : 3
  type     : Fabric1.4
  MembershipID : Org1MSP
  isDefault: false
  ----------
  Fabric1.4 Account:
  keyID    : 2
  type     : Fabric1.4
  MembershipID : Org2MSP
  isDefault: false
  ----------
]

# 加上`-d`
[WeCross.org1-admin]> listAccount -d
Universal Account:
username: org1-admin
pubKey  : 3059301306072a8648ce3d020106082a811ccf5501822d03420004a313bc3d08a93a837d81b8d38fb9172fa34c1c71d7693f8ba80dbc46435bd0dec56de813d348aa134edd2cf929f74192368d3e86aade1dd3340dabbcf0b2f01b
uaID    : 3059301306072a8648ce3d020106082a811ccf5501822d03420004a313bc3d08a93a837d81b8d38fb9172fa34c1c71d7693f8ba80dbc46435bd0dec56de813d348aa134edd2cf929f74192368d3e86aade1dd3340dabbcf0b2f01b
chainAccounts: [
  BCOS2.0 Account:
  keyID    : 0
  type     : BCOS2.0
  pubKey   : -----BEGIN PUBLIC KEY-----
MFYwEAYHKoZIzj0CAQYFK4EEAAoDQgAEdf3y930w4P/licg+X0qhrK7DOpCwzugj
ZS+aX511oBYULVeSihr5dnsl0uNHpIhG6q6TSYDnKF0UxqccbZKy/g==
-----END PUBLIC KEY-----

  address  : 0xe6a68370212863821a5c209c5b66f4ba40e7c80e
  isDefault: true
  ----------
  Fabric1.4 Account:
  keyID    : 1
  type     : Fabric1.4
  cert     : -----BEGIN CERTIFICATE-----
MIICKTCCAdCgAwIBAgIRAPlePqCuLU5YTOpmfTIIkicwCg... #省略
-----END CERTIFICATE-----

  MembershipID : Org1MSP
  isDefault: true
  ----------
  Fabric1.4 Account:
  keyID    : 3
  type     : Fabric1.4
  cert     : -----BEGIN CERTIFICATE-----
MIICKzCCAdGgAwIBAgIRAN44JEay7bkhHKCbD9n0kKUwCg... #省略
-----END CERTIFICATE-----

  MembershipID : Org1MSP
  isDefault: false
  ----------
  Fabric1.4 Account:
  keyID    : 2
  type     : Fabric1.4
  cert     : -----BEGIN CERTIFICATE-----
MIICKTCCAdCgAwIBAgIRAPyuc+VKfnYg+HTl5PvUn9EwCg... #省略
-----END CERTIFICATE-----

  MembershipID : Org2MSP
  isDefault: false
  ----------
]

```

#### listLocalResources

显示router配置的跨链资源。

```bash
[WeCross.org1-admin]> listLocalResources
path: payment.bcos.HelloWorld, type: BCOS2.0, distance: 0
path: payment.bcos.htlc, type: BCOS2.0, distance: 0
path: payment.bcos.WeCrossHub, type: BCOS2.0, distance: 0
path: payment.bcos.evidence, type: BCOS2.0, distance: 0
path: payment.bcos.ledger, type: BCOS2.0, distance: 0
path: payment.bcos.asset, type: BCOS2.0, distance: 0
total: 6
```

#### listResources

查看WeCross跨链代理本地配置的跨链资源和所有的远程资源。

```bash
[WeCross.org1-admin]> listResources
path: payment.fabric.WeCrossHub, type: Fabric1.4, distance: 1
path: payment.bcos.htlc, type: BCOS2.0, distance: 0
path: payment.fabric.ledger, type: Fabric1.4, distance: 1
path: payment.bcos.WeCrossHub, type: BCOS2.0, distance: 0
path: payment.fabric.htlc, type: Fabric1.4, distance: 1
path: payment.bcos.evidence, type: BCOS2.0, distance: 0
path: payment.bcos.ledger, type: BCOS2.0, distance: 0
path: payment.fabric.sacc, type: Fabric1.4, distance: 1
path: payment.fabric.evidence, type: Fabric1.4, distance: 1
path: payment.bcos.asset, type: BCOS2.0, distance: 0
path: payment.bcos.HelloWorld, type: BCOS2.0, distance: 0
path: payment.fabric.asset, type: Fabric1.4, distance: 1
total: 12
```

#### status

判断跨链资源是否存在。

参数：

- path：跨链资源标识。

```bash
[WeCross.org1-admin]> status payment.bcos.HelloWorld
exists
```

#### detail

查看跨链资源的详细信息。

参数：

- path：跨链资源标识。

```bash
[WeCross.org1-admin]> detail payment.bcos.HelloWorld
ResourceDetail{
 path='payment.bcos.HelloWorld',
 distance=0',
 stubType='BCOS2.0',
 properties={
  BCOS_PROPERTY_CHAIN_ID=1,
  BCOS_PROPERTY_GROUP_ID=1
 },
 checksum='c77f0ac3ead48d106d357ffe0725b9761bd55d3e27edd8ce669ad8b470a27bc8'
}

[WeCross.org1-admin]> detail payment.fabric.sacc
ResourceDetail{
 path='payment.fabric.sacc',
 distance=1',
 stubType='Fabric1.4',
 properties={
  ORG_NAMES=[
   Org1,
   Org2
  ],
  PROPOSAL_WAIT_TIME=300000,
  CHAINCODE_VERSION=1.0,
  CHANNEL_NAME=mychannel,
  CHAINCODE_NAME=sacc
 },
 checksum='058b239a9f10dc2b1154e28910861053c376be61cbbfd539b71f354b85ed309b'
}
```

#### call

调用智能合约的方法，不涉及状态的更改，不发交易。

参数：

- path：跨链资源标识。
- method：合约方法名。
- args：参数列表。

```bash
[WeCross.org1-admin]> call payment.bcos.HelloWorld get
Result: [Hello, World!]
# 在事务状态下，call命令可自动转变成命令 callTransaction
[Transaction running: 575905db7aab412bb476db8b89a4c042]
[WeCross.org1-admin]> call payment.bcos.HelloWorld get
Result: [test2]
```

#### sendTransaction

调用智能合约的方法，会更改链上状态，需要发交易。

参数：

- path：跨链资源标识。
- method：合约方法名。
- args：参数列表。

```bash
[WeCross.org1-admin]> sendTransaction payment.bcos.HelloWorld set "Hello, WeCross!"
Txhash  : 0x4e3fe01371cf2a304b0782b554399bf8643cd50e5ea9c522d9c846ee38ec00dd
BlockNum: 16
Result  : []
```

#### invoke

在非事务状态时，与命令[sendTransaction](#sendtransaction)功能一致；在事务状态时，与命令[execTransaction](#exectransaction)功能一致

参数：

- path：跨链资源标识。
- method：合约方法名。
- args：参数列表。

```bash
# 非事务状态时，invoke相当于命令 sendTransaction
[WeCross.org1-admin]> invoke payment.bcos.HelloWorld set test1
Txhash  : 0x5b925655f1668357845c1846450b47ab92bbe1f96cdeaf9e2db98aa834536da1
BlockNum: 35
Result  : []

[WeCross.org1-admin]> startTransaction payment.bcos.HelloWorld
Result: success!
Transaction ID is: 575905db7aab412bb476db8b89a4c042
# 事务状态时，invoke相当于命令 execTransaction
[Transaction running: 575905db7aab412bb476db8b89a4c042]
[WeCross.org1-admin]> invoke payment.bcos.HelloWorld set test2
Txhash  : 0x3d22c863570696c9eed121f94bd6794865286ac85c5c9778b14777b2a8338bff
BlockNum: 37
Result  : []

[Transaction running: 575905db7aab412bb476db8b89a4c042]
[WeCross.org1-admin]> callTransaction payment.bcos.HelloWorld get
Result: [test2]
```

#### bcosDeploy

FISCO BCOS 合约部署命令，成功返回部署的合约地址，失败返回错误描述

参数：

- Path: 跨链资源标示，用于标记部署的合约资源
- Source file path: 部署的合约路径，支持绝对路径/相对路径
- Class Name: 部署的合约名
- Verseion: 部署合约版本号，**注意: 同一合约版本号唯一，再次部署相同的版本号会失败**

示例：

```bash
[WeCross.org1-admin]> bcosDeploy payment.bcos.HelloWorld contracts/solidity/HelloWorld.sol HelloWorld 2.0
Result: 0xc3c72dce00c1695e8f50696f22310375e3348e1e
```

#### bcosRegister

FISCO BCOS 注册已有合约为跨链资源，成功返回`Success`，失败返回错误描述

参数：

- Path: 跨链资源标示，用于标记注册的合约资源
- Source file path: 合约的ABI文件路径或者合约源码路径
- Contract address: 注册的合约地址
- Version: 合约版本号，**注意: 同一部署合约版本号唯一，再次部署相同版本号的合约会失败**

示例：

```shell
[WeCross.org1-admin]> bcosRegister payment.bcos.HelloWorld contracts/solidity/HelloWorld.sol 0xc3c72dce00c1695e8f50696f22310375e3348e1e HelloWorld 3.0
Result: success
```

#### fabricInstall

Fabric 安装链码命令，安装后需fabricInstantiate来启动链码

参数：

- path：跨链资源标识。
- sourcePath：链码工程所在目录，支持绝对路径和WeCross-Console的conf目录内的相对路径
- version：指定一个版本，fabricInstantiate时与此版本对应
- language：指定一个链码语言，支持GO_LANG和JAVA

```bash
# 在Org1中部署sacc合约
[WeCross.org1-admin]> fabricInstall payment.fabric.sacc Org1 contracts/chaincode/sacc 2.0 GO_LANG
path: classpath:contracts/chaincode/sacc
Result: Success

# 将Fabric的默认账号切换至Org2-admin的账号，以便于我们部署合约到Org2中
# 注意：此示例中，Org2-admin账号的keyID为2，可通过listAccount命令查询
[WeCross.org1-admin]> setDefaultAccount Fabric1.4 2
Result: success
Universal Account info has been changed, now auto-login again.
Result: success
=============================================================================================
Universal Account:
username: org1-admin
pubKey  : 3059301306...
uaID    : 3059301306...

# 在Org2中部署sacc合约
[WeCross.org1-admin]> fabricInstall payment.fabric.sacc Org2 contracts/chaincode/sacc 2.0 GO_LANG
path: classpath:contracts/chaincode/sacc
Result: Success
```

#### fabricInstantiate

Fabric 启动（实例化）已安装的链码。此步骤前需先用fabricInstall向指定机构安装链码。

参数：

- path：跨链资源标识。
- orgNames：链码被安装的的机构列表
- sourcePath：链码工程所在目录，支持绝对路径和WeCross-Console的conf目录内的相对路径
- version：指定一个版本，与fabricInstall时的版本对应
- language：指定一个链码语言，支持GO_LANG和JAVA
- policy：指定背书策略文件，设置default为所有endorser以OR相接
- initArgs：链码初始化参数

``` bash
[WeCross.org1-admin]> fabricInstantiate payment.fabric.sacc ["Org1","Org2"] contracts/chaincode/sacc 1.0 GO_LANG default ["a","10"]
Result: Instantiating... Please wait and use 'listResources' to check. See router's log for more information.
```

启动时间较长（1min左右），可用listResources查看是否已启动，若长时间未启动，可查看router的日志进行排查。

#### fabricUpgrade

Fabric 升级已启动的链码逻辑，不改变已上链的数据。此步骤前需先用`fabricInstall`向指定机构安装另一个版本的链码。

参数：

- path：跨链资源标识。
- orgNames：链码被安装的的机构列表
- sourcePath：链码工程所在目录，支持绝对路径和WeCross-Console的conf目录内的相对路径
- version：指定一个版本，与fabricInstall时的版本对应
- language：指定一个链码语言，支持GO_LANG和JAVA
- policy：指定背书策略文件，设置default为OR所有endorser
- initArgs：链码初始化参数

``` bash
[WeCross.org1-admin]> fabricUpgrade payment.fabric.sacc ["Org1","Org2"] contracts/chaincode/sacc 2.0 GO_LANG default ["a","10"]
Result: Upgrading... Please wait and use 'detail' to check the version. See router's log for more information.
```

升级时间较长（1min左右），可用`detail payment.fabric.sacc`查看版本号，若长时间升级完成，可查看router的日志进行排查。

#### genTimelock

跨链转账辅助命令，根据时间差生成两个合法的时间戳。

参数：
- interval：时间间隔   

```bash
[WeCross.org1-admin]> genTimelock 300
timelock0: 1607245965
timelock1: 1607245665
```

#### genSecretAndHash
跨链转账辅助命令，生成一个秘密和它的哈希。

```bash
[WeCross.org1-admin]> genSecretAndHash
hash  : cdbfc235be9aff715967119a25b03f49e7103480fec459a610d2efe51ff35fad
secret: 266a85d058afbf743c541f8da4add95d54f02cad27acd90d8b2155947524d303
```

#### newHTLCProposal
新建一个基于哈希时间锁合约的跨链转账提案，该命令由两条链的资金转出方分别执行。

参数：

- path：跨链转账资源标识。
- args：提案信息，包括两条链的转账信息。
  - hash： 唯一标识，提案号，
  - secret： 提案号的哈希原像
  - role： 身份，发起方-true，参与方-false。发起方需要传入secret，参与方secret传null。
  - sender0：发起方的资金转出者在对应链上的地址
  - receiver0：发起方的资金接收者在对应链上的地址
  - amount0：发起方的转出金额
  - timelock0：发起方的超时时间
  - sender1：参与方的资金转出者在对应链上的地址
  - receiver1：参与方的资金接收者在对应链上的地址
  - amount1：参与方的转出金额
  - timelock1：参与方的超时时间，小于发起方的超时时间

```bash
[WeCross.org1-admin]> newHTLCProposal payment.bcos.htlc bea2dfec011d830a86d0fbeeb383e622b576bb2c15287b1a86aacdba0a387e11 9dda9a5e175a919ee98ff0198927b0a765ef96cf917144b589bb8e510e04843c true 0x4305196480b029bbecb071b4b68e95dfef36a7b7 0x2b5ad5c4795c026514f8317c7a215e218dccd6cf 700 2000010000 Admin@org1.example.com User1@org1.example.com 500 2000000000

Txhash: 0xf9b50871c0b05830af9c251d786d2ea93e6f98282e33b6d4c530ed0fddde2f25
BlockNum: 18
Result: create a htlc proposal successfully
```

#### checkTransferStatus

根据提案号（Hash）查询htlc转账状态。

参数：

- path：跨链资源标识。
- method：合约方法名。
- hash：转账提案号。

```bash
[WeCross.org1-admin]> checkTransferStatus payment.bcos.htlc bea2dfec011d830a86d0fbeeb383e622b576bb2c15287b1a86aacdba0a387e11
status: ongoing!
```

#### startTransaction

写接口，开始两阶段事务。

参数：

- path_1 ... path_n：参与事务的资源路径列表，路径列表中的资源会被本次事务锁定，锁定后仅限本事务相关的交易才能对这些资源发起写操作，非本次事务的所有写操作都会被拒绝。

```bash
[WeCross.org1-admin]> startTransaction payment.bcos.evidence payment.fabric.evidence
Result: success!
Transaction ID is: 024f0ff81cda4b938a0b48805be9eb61
# 系统自动生成一串事务ID，并在下次Prompt加上事务标识表示事务正在进行中

[Transaction running: 024f0ff81cda4b938a0b48805be9eb61]
[WeCross.org1-admin]>
```

#### execTransaction

写接口，发起事务交易。

参数：

- path：资源路径。
- method：接口名，同sendTransaction。需要注意的是，该接口需要在合约中配套以`_revert`结尾的回滚接口。
- args：参数，同sendTransaction。

```bash
[Transaction running: 024f0ff81cda4b938a0b48805be9eb61]
[WeCross.org1-admin]> execTransaction payment.bcos.evidence newEvidence evidence1 Jerry
Txhash  : 0xcb4ee8b1b83f6855e7583c75bec35c29004ee446c93a7bcfe92b5d7156572235
BlockNum: 28
Result  : [true]

[Transaction running: 024f0ff81cda4b938a0b48805be9eb61]
[WeCross.org1-admin]> execTransaction payment.fabric.evidence newEvidence evidence2 Tom
Txhash  : bb955ee814b12ebc19a068c8d3c10afbc7aadc6c62225dac51fc5c496049c36d
BlockNum: 14
Result  : [Success]
```

#### callTransaction

读接口，查询事务中的数据。

参数：

- path：资源路径。
- method：接口名，同sendTransaction。
- args：参数，同sendTransaction。

```bash
[Transaction running: 024f0ff81cda4b938a0b48805be9eb61]
[WeCross.org1-admin]> call payment.bcos.evidence queryEvidence evidence1
Result: [Jerry]
```

#### commitTransaction

写接口，提交事务，确认事务执行过程中所有的变动。

参数：

- path_1 ... path_n：(可选) 用于提交事务的路径列表。

```bash
[WeCross.org1-admin]> commitTransaction payment.bcos.evidence payment.fabric.evidence

# 也可以直接输入`commitTransaction`命令，输入y提交这次事务，输入n则取消
[Transaction running: 024f0ff81cda4b938a0b48805be9eb61]
[WeCross.org1-admin]> commitTransaction
Transaction running now, transactionID is: 024f0ff81cda4b938a0b48805be9eb61
Are you sure commit it now?(y/n)  y
Committing transaction: 024f0ff81cda4b938a0b48805be9eb61...

Result: success!
# 结束事务后，Prompt不再显示事务标识
[WeCross.org1-admin]>
```

#### rollbackTransaction

写接口，撤销本次事务的所有变更时。

参数：

- path_1 ... path_n：用于回滚事务的路径列表。

```bash
# 查看开始前的状态
[WeCross.org1-admin]> call payment.bcos.evidence queryEvidence evidence0
Result: []

# 开始事务
[WeCross.org1-admin]> startTransaction payment.bcos.evidence
Result: success!
Transaction ID is: e27ddd9fc4564256b20e6329f9ce9969

# 执行事务
[Transaction running: e27ddd9fc4564256b20e6329f9ce9969]
[WeCross.org1-admin]> execTransaction payment.bcos.evidence newEvidence evidence0 WeCross
Txhash  : 0x5851a927a33b673f76b9fe3a57767ddd3d920230d54d7fee92400789a0bd551c
BlockNum: 31
Result  : [true]

# 读事务数据
[Transaction running: e27ddd9fc4564256b20e6329f9ce9969]
[WeCross.org1-admin]> callTransaction payment.bcos.evidence queryEvidence evidence0
Result: [WeCross]

# 回滚事务
# 可以直接输入`rollbackTransaction`命令，输入y回滚这次事务，输入n则取消，也可以输入全资源路径
[Transaction running: e27ddd9fc4564256b20e6329f9ce9969]
[WeCross.org1-admin]> rollbackTransaction
Transaction running now, transactionID is: e27ddd9fc4564256b20e6329f9ce9969
Are you sure rollback transaction now?(y/n)  y
Rollback transaction: e27ddd9fc4564256b20e6329f9ce9969...

Result: success!

# 查看事务回滚后的状态，和开始前保持一致
[WeCross.org1-admin]> call payment.bcos.evidence queryEvidence evidence0
Result: []
```

#### getXATransaction

读接口，查询事务信息。

参数：

- transactionID：事务ID，待提交事务的ID
- path_1 ... path_n：参与事务的资源路径列表

```bash
[WeCross.org1-admin]> getXATransaction 024f0ff81cda4b938a0b48805be9eb61 payment.fabric.evidence
XATransactionResponse{
 xaTransactionID='024f0ff81cda4b938a0b48805be9eb61',
 username='org1-admin',
 status='committed',
 startTimestamp=1607246930,
 commitTimestamp=1607247480,
 rollbackTimestamp=0,
 paths=[
  payment.fabric.evidence,
  payment.bcos.evidence
 ],
 xaTransactionSteps=[
  XATransactionStep{
   xaTransactionSeq=1607247002498,
   username='org1-admin',
   path='payment.fabric.evidence',
   timestamp=1607247002,
   method='newEvidence',
   args='[
    "evidence2",
    "Tom"
   ]'
  }
 ]
}
```

#### listXATransactions

读接口，查询所给个数的最新的事务。

参数：

- size：指定查询个数，范围在[1-1024]

```bash
[WeCross.org1-admin]> listXATransactions 4
Result: [ {
  "xaTransactionID" : "e27ddd9fc4564256b20e6329f9ce9969",
  "username" : "org1-admin",
  "status" : "rolledback",
  "timestamp" : 1607247643,
  "paths" : [ "payment.bcos.evidence" ]
}, {
  "xaTransactionID" : "024f0ff81cda4b938a0b48805be9eb61",
  "username" : "org1-admin",
  "status" : "committed",
  "timestamp" : 1607246930,
  "paths" : [ "payment.bcos.evidence", "payment.fabric.evidence" ]
}, {
  "xaTransactionID" : "65aaedc68bc24126ad48a794e08bb7d1",
  "username" : "org1-admin",
  "status" : "committed",
  "timestamp" : 1607246797,
  "paths" : [ "payment.bcos.evidence" ]
}, {
  "xaTransactionID" : "46299d812d2f42eaad64989daf94fe6f",
  "username" : "org1-admin",
  "status" : "committed",
  "timestamp" : 1607246405,
  "paths" : [ "payment.bcos.HelloWorld" ]
} ]
```

#### loadTransaction

恢复到某个正在执行的事务上下文。

参数：

- transactionID：恢复的事务ID。
- path_1 ... path_n：正在执行的事务中资源路径列表。

```bash
# 查询最新事务，事务正处于进行中
[WeCross.org1-admin]> listXATransactions 1
Result: [ {
  "xaTransactionID" : "0a359201499047f8a99a6a978b9a7f77",
  "username" : "org1-admin",
  "status" : "processing",
  "timestamp" : 1607249155,
  "paths" : [ "payment.bcos.HelloWorld" ]
} ]

[WeCross.org1-admin]> loadTransaction 0a359201499047f8a99a6a978b9a7f77 payment.bcos.HelloWorld
Load transaction success!
# 恢复到事务上下文
[Transaction running: 0a359201499047f8a99a6a978b9a7f77]
[WeCross.org1-admin]>
```

#### getCurrentTransactionID

获取当前控制台的事务ID

```bash
[Transaction running: 0a359201499047f8a99a6a978b9a7f77]
[WeCross.org1-admin]> getCurrentTransactionID
There is a Transaction running now, ID is: 0a359201499047f8a99a6a978b9a7f77.
```

### 交互式命令

#### WeCross.getResource

WeCross控制台提供了一个资源类，通过方法`getResource`来初始化一个跨链资源实例，并且赋值给一个变量。
这样调用同一个跨链资源的不同UBI接口时，不再需要每次都输入跨链资源标识。

```bash
# myResource 是自定义的变量名
[WeCross.org1-admin]> myResource = WeCross.getResource payment.bcos.HelloWeCross

# 还可以将跨链资源标识赋值给变量，通过变量名来初始化一个跨链资源实例
[WeCross.org1-admin]> path = payment.bcos.HelloWeCross

[WeCross.org1-admin]> myResource = WeCross.getResource path
```

#### [resource].[command]

当初始化一个跨链资源实例后，就可以通过`.command`的方式，调用跨链资源的UBI接口。

```bash
# 输入变量名，通过tab键可以看到能够访问的所有命令
[WeCross.org1-admin]> myResource.
myResource.call              myResource.status
myResource.detail            myResource.sendTransaction
```

#### status

```bash
[WeCross.org1-admin]> myResource.status
exists
```

#### detail

```bash
[WeCross.org1-admin]> myResource.detail
ResourceDetail{
 path='payment.bcos.HelloWorld',
 distance=0',
 stubType='BCOS2.0',
 properties={
  BCOS_PROPERTY_CHAIN_ID=1,
  BCOS_PROPERTY_GROUP_ID=1,
  HelloWorld=0x9bb68f32a63e70a4951d109f9566170f26d4bd46
 },
 checksum='0x888d067b77cbb04e299e675ee4b925fdfd60405241ec241e845b7e41692d53b1'
}
```

#### call

```bash
[WeCross.org1-admin]> myResource.call get
Result: [Hello, World!]
```

#### sendTransaction

```bash
[WeCross.org1-admin]> myResource.sendTransaction set "Hello, WeCross!"
Result: []

[WeCross.org1-admin]> myResource.call get
Result: [Hello, WeCross!]
```
