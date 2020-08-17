## 控制台

[控制台](https://github.com/WeBankFinTech/WeCross-Console)是WeCross重要的交互式客户端工具，它通过[WeCross-Java-SDK](./sdk.html)与WeCross 跨链代理建立连接，实现对跨链资源的读写访问请求。控制台拥有丰富的命令，包括获取跨链资源列表，查询资源状态，以及所有的JSON-RPC接口命令。

### 控制台命令

控制台命令可分为两类，普通命令和交互式命令。

#### 普通命令
普通命令由两部分组成，即指令和指令相关的参数：   
- **指令**: 指令是执行的操作命令，包括获取跨链资源列表，查询资源状态指令等，其中部分指令调用JSON-RPC接口，因此与JSON-RPC接口同名。
**使用提示： 指令可以使用tab键补全，并且支持按上下键显示历史输入指令。**
  
- **指令相关的参数**: 指令调用接口需要的参数，指令与参数以及参数与参数之间均用空格分隔。与JSON-RPC接口同名命令的输入参数和获取信息字段的详细解释参考[JSON-RPC API](../dev/api.html)。

#### 交互式命令
WeCross控制台为了方便用户使用，还提供了交互式的使用方式，比如将跨链资源标识赋值给变量，初始化一个类，并用`.command`的方式访问方法。
详见：[交互式命令](#id14)

### 常用命令链接

#### 普通命令

* 状态查询
  * [listResources](#listresources)：查看资源列表
  * [detail](#detail)：查看资源详情
  * [listAccounts](#listaccounts)：查看账户列表
  * [supportedStubs](#supportedstubs)：查看连接的router支持接入的链类型
* 资源调用
  * [call](#call)：调用链上资源，用于查询，不触发出块
  * [sendTransaction](#sendtransaction)：发交易，用于改变链上资源，触发出块
* 资源部署
  * BCOS：[bcosDeploy](#bcosDeploy)、[bcosRegister](#bcosRegister)
  * Fabric：[fabricInstall](#fabricInstall)、[fabricInstantiate](#fabricInstantiate)、[fabricUpgrade](#fabricUpgrade)
* 跨链事务
  * [startTransaction](#starttransaction)：开始两阶段事务
  * [execTransaction](#exectransaction)：发起事务交易
  * [callTransaction](#calltransaction)：读取事务过程中的数据
  * [commitTransaction](#committransaction)：提交事务，确认事务执行过程中所有的变动
  * [rollbackTransaction](#rollbacktransaction)：撤销本次事务的所有变更时
* 跨链转账
  * [newHTLCProposal](#newhtlcproposal)：创建转账提案

#### 交互式命令

- 初始化资源实例: [WeCross.getResource](#wecross-getresource)
- 访问资源UBI接口: [\[resource\].\[command\]](#resource-command)

### 快捷键
- `Ctrl+A`：光标移动到行首
- `Ctrl+E`：光标移动到行尾
- `Ctrl+R`：搜索输入的历史命令
- &uarr;：  向前浏览历史命令
- &darr;：  向后浏览历史命令
- `tab`： 自动补全，支持命令、变量名、资源名、账户名以及其它固定参数的补全

### 控制台响应

当发起一个控制台命令时，控制台会获取命令执行的结果，并且在终端展示执行结果，执行结果分为2类：
- **正确结果:** 命令返回正确的执行结果，以字符串或是json的形式返回。       
- **错误结果:** 命令返回错误的执行结果，以字符串或是json的形式返回。 
- **状态码:** 控制台的命令调用JSON-RPC接口时，状态码[参考这里](../dev/api.html#id61)。


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
bash <(curl -sL https://github.com/WeBankFinTech/WeCross-Console/releases/download/resources/download_console.sh)
```

执行成功后，会生成`WeCross-Console`目录，结构如下：

```bash
├── apps
│   └── wecross-console.jar  # 控制台jar包
├── conf
│   ├── application-sample.toml   # 配置示例文件
│   └── log4j2.xml           # 日志配置文件
├── download_console.sh      # 获取控制台脚本
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

# 拷贝连接router所需的TLS证书，从生成的routers-payment/cert/sdk目录下拷贝
cp ~/wecross/routers-payment/cert/sdk/* conf/ # 包含：ca.crt、node.nodeid、ssl.crt、ssl.key

# 配置
vim conf/application.toml
```

配置与控制台r与某个router的连接

``` toml
[connection]
    server =  '127.0.0.1:8250' # 对应router的ip和rpc端口
    sslKey = 'classpath:ssl.key'
    sslCert = 'classpath:ssl.crt'
    caCert = 'classpath:ca.crt'
```

#### 启动控制台

在WeCross已经开启的情况下，启动控制台

```bash
cd ~/wecross/WeCross-Console
bash start.sh
# 输出下述信息表明启动成功
=============================================================================================
Welcome to WeCross console(1.0.0-rc4)!
Type 'help' or 'h' for help. Type 'quit' or 'q' to quit console.

=============================================================================================
```

### 普通命令

以下所有跨链资源相关命令的执行结果以实际配置为准，此处只是示例。

##### help
输入help或者h，查看控制台所有的命令。

```bash
[WeCross]> help
---------------------------------------------------------------------------------------------
quit                               Quit console.
supportedStubs                     List supported stubs of WeCross router.
listAccounts                       List all accounts stored in WeCross router.
listLocalResources                 List local resources configured by WeCross server.
listResources                      List all resources including remote resources.
status                             Check if the resource exists.
detail                             Get resource information.
call                               Call constant method of smart contract.
sendTransaction                    Call non-constant method of smart contract.
callTransaction                    Call constant method of smart contract during transaction.
execTransaction                    Call non-constant method of smart contract during transaction.
startTransaction                   Start a 2pc transaction.
commitTransaction                  Commit a 2pc transaction.
rollbackTransaction                Rollback a 2pc transaction.
getTransactionInfo                 Get info of specified transaction.
getTransactionIDs                  Get transaction ids of 2pc.
bcosDeploy                         Deploy contract in BCOS chain.
bcosRegister                       Register contract abi in BCOS chain.
fabricInstall                      Install chaincode in fabric chain.
fabricInstantiate                  Instantiate chaincode in fabric chain.
fabricUpgrade                      Upgrade chaincode in fabric chain.
genTimelock                        Generate two valid timelocks.
genSecretAndHash                   Generate a secret and its hash.
newHTLCProposal                    Create a htlc transfer proposal .
checkTransferStatus                Check htlc transfer status by hash.
WeCross.getResource                Init resource by path and account name, and assign it to a custom variable.
[resource].[command]               Equal to: command [path] [account name].

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

##### listAccounts
显示所有已配置的账户列表。

```bash
name: fabric_user1, type: Fabric1.4
name: fabric_default_account, type: Fabric1.4
name: bcos_user1, type: BCOS2.0
name: bcos_sender, type: BCOS2.0
name: bcos_default_account, type: BCOS2.0
total: 5
```

##### listLocalResources
显示router配置的跨链资源。

```bash
[WeCross]> listLocalResources
path: payment.bcos.htlc, type: BCOS2.0, distance: 0
path: payment.bcos.HelloWeCross, type: BCOS2.0, distance: 0
total: 2
```

##### listResources
查看WeCross跨链代理本地配置的跨链资源和所有的远程资源。

```bash
[WeCross]> listResources
path: payment.bcos.htlc, type: BCOS2.0, distance: 0
path: payment.bcos.HelloWeCross, type: BCOS2.0, distance: 0
path: payment.fabric.htlc, type: Fabric1.4, distance: 1
path: payment.fabric.abac, type: Fabric1.4, distance: 1
total: 4
```

##### status
查看跨链资源的状态，即是否存在于连接的router中。

参数：     
- path：跨链资源标识。    

```bash
[WeCross]> status payment.bcos.HelloWeCross
exists
```
##### detail

查看跨链资源的详细信息。

参数：   
- path：跨链资源标识。        

```bash
[WeCross]> detail payment.bcos.HelloWeCross
ResourceDetail{
 path='payment.bcos.HelloWeCross',
 distance=0',
 stubType='BCOS2.0',
 properties={
  BCOS_PROPERTY_CHAIN_ID=1,
  BCOS_PROPERTY_GROUP_ID=1,
  HelloWeCross=0x708133d132372727ce3848a16d47ab4daf77698c
 },
 checksum='0xb452f3d12c91b6cd93e083a518d2ea2cffbcf3d8b971221a5224f07a3be5e41a'
}

[WeCross]> detail payment.fabric.abac
ResourceDetail{
 path='payment.fabric.abac',
 distance=1',
 stubType='Fabric1.4',
 properties={
  PROPOSAL_WAIT_TIME=120000,
  CHAINCODE_TYPE=GO_LANG,
  CHANNEL_NAME=mychannel,
  CHAINCODE_NAME=mycc
 },
 checksum='c77f0ac3ead48d106d357ffe0725b9761bd55d3e27edd8ce669ad8b470a27bc8'
}
```

##### call
调用智能合约的方法，不涉及状态的更改，不发交易。

参数：   
- path：跨链资源标识。   
- accountName：交易签名账户，router上配置的账户名（`listAccounts`命令可查询）。
- method：合约方法名。
- args：参数列表。

```bash
[WeCross]> call payment.bcos.HelloWeCross bcos_user1 get
Result: [Talk is cheap, Show me the code]
```

##### sendTransaction
调用智能合约的方法，会更改链上状态，需要发交易。

参数：   
- path：跨链资源标识。   
- accountName：交易签名账户，router上配置的账户名。
- method：合约方法名。
- args：参数列表。

```bash
[WeCross]> sendTransaction payment.bcos.HelloWeCross bcos_user1 set hello wecross
Txhash  : 0x66f94d387df2b16bea26e6bcf037c23f0f13db28dc4734588de2d57a97051c54
BlockNum: 2219
Result  : [hello, wecross]
```

##### bcosDepoly

FISCO BCOS 合约部署命令，成功返回部署的合约地址，失败返回错误描述

```bash
bcosDeploy -h
---------------------------------------------------------------------------------------------
Deploy contract and register contract info to CNS in BCOS chain
Usage: bcosDeploy [Path] [Account] [Source file path] [Class name] [Version]
Path -- e.g: [zone.chain.res], specify which the path to be deployed
Account -- Choose an account to send transaction
Source file path -- The solidity source code file path, e.g: HelloWorld.sol
Class name -- The contract to be deploy
Version -- The contract version
Example:
    bcosDeploy payment.bcos.HelloWorld bcos_user1 contracts/solidity/HelloWorld.sol HelloWorld 1.0
```

参数：

* Path: 跨链资源标示，用于标记部署的合约资源
* Account: 部署合约发送交易的账户
* Source file path: 部署的合约路径，支持绝对路径/相对路径
* Class Name: 部署的合约名
* Verseion: 部署合约版本号，**注意: 同一合约版本号唯一，再次部署相同的版本号会失败**

示例：

```bash

[WeCross]> bcosDeploy payment.my_bcos_chain.HelloWorld my_bcos_account contracts/solidity/HelloWorld.sol HelloWorld 1.0
Result: 0x79a178e71dc77fbccd31d464c114c95403a31e00
```

##### bcosRegister

FISCO BCOS 注册已有合约为跨链资源，成功返回`Success`，失败返回错误描述

```shell
bcosRegister -h
---------------------------------------------------------------------------------------------
Register contract info to CNS in BCOS chain
Usage: bcosRegister [Path] [Account] [Source file path] [Contract address] [Version]
Path -- e.g: [zone.chain.res], specify which the path to be register
Account -- Choose an account to send transaction
Source file path -- The solidity source code/solidity abi file path, e.g: HelloWorld.sol or HelloWorld.abi
Contract address -- contract address
Version -- The contract version
Example:
    bcosRegister payment.bcos.HelloWorld bcos_user1 contracts/solidity/HelloWorld.sol 0x2c8595f82dc930208314030abc6f5c4ddbc8864f 1.0
    bcosRegister payment.bcos.HelloWorld bcos_user1 /data/app/HelloWorld.abi 0x2c8595f82dc930208314030abc6f5c4ddbc8864f 1.0
---------------------------------------------------------------------------------------------
```

参数：
* Path: 跨链资源标示，用于标记注册的合约资源
* Account: 注册合约发送交易的账户
* Source file path: 合约的ABI文件路径或者合约源码路径
* Contract address: 注册的合约地址
* Version: 合约版本号，**注意: 同一部署合约版本号唯一，再次部署相同版本号的合约会失败**

示例：
```shell
> bcosRegister payment.my_bcos_chain.HelloWorld my_bcos_account contracts/solidity/HelloWorld.sol 0x2c8595f82dc930208314030abc6f5c4ddbc8864f v1.0
Result: Success
```

##### fabricInstall

Fabric 安装链码命令，安装后需fabricInstantiate来启动链码

参数：

* path：跨链资源标识。   
* account：被安装链码的endorser所属机构的admin账户
* orgName：被安装链码的endorser所属的机构
* sourcePath：链码工程所在目录，支持绝对路径和WeCross-Console的conf目录内的相对路径
* version：指定一个版本，fabricInstantiate时与此版本对应
* language：指定一个链码语言，支持GO_LANG和JAVA

```bash
[WeCross]> fabricInstall payment.fabric.sacc fabric_admin_org1 Org1 contracts/chaincode/sacc 1.0 GO_LANG
Result: Success
[WeCross]> fabricInstall payment.fabric.sacc fabric_admin_org2 Org2 contracts/chaincode/sacc 1.0 GO_LANG
Result: Success
```

##### fabricInstantiate

Fabric 启动（实例化）已安装的链码。此步骤前需先用fabricInstall向指定机构安装链码。

参数：

* path：跨链资源标识。   
* account：指定一个发交易的账户
* orgNames：链码被安装的的机构列表
* sourcePath：链码工程所在目录，支持绝对路径和WeCross-Console的conf目录内的相对路径
* version：指定一个版本，与fabricInstall时的版本对应
* language：指定一个链码语言，支持GO_LANG和JAVA
* policy：指定背书策略文件，设置default为OR所有endorser
* initArgs：链码初始化参数

``` bash
[WeCross]> fabricInstantiate payment.fabric.sacc fabric_admin ["Org1","Org2"] contracts/chaincode/sacc 1.0 GO_LANG default ["a","10"]
Result: Instantiating... Please wait and use 'listResources' to check. See router's log for more information.
```

启动时间较长（1min左右），可用listResources查看是否已启动，若长时间未启动，可查看router的日志进行排查。

##### fabricUpgrade

Fabric 升级已启动的链码逻辑，不改变已上链的数据。此步骤前需先用fabricInstall向指定机构安装另一个版本的链码。

参数：

* path：跨链资源标识。   
* account：指定一个发交易的账户
* orgNames：链码被安装的的机构列表
* sourcePath：链码工程所在目录，支持绝对路径和WeCross-Console的conf目录内的相对路径
* version：指定一个版本，与fabricInstall时的版本对应
* language：指定一个链码语言，支持GO_LANG和JAVA
* policy：指定背书策略文件，设置default为OR所有endorser
* initArgs：链码初始化参数

``` bash
[WeCross]> fabricUpgrade payment.fabric.sacc fabric_admin ["Org1","Org2"] contracts/chaincode/sacc 2.0 GO_LANG default ["a","10"]
Result: Upgrading... Please wait and use 'detail' to check the version. See router's log for more information.
```

升级时间较长（1min左右），可用`detail payment.fabric.sacc`查看版本号，若长时间升级完成，可查看router的日志进行排查。

##### genTimelock

跨链转账辅助命令，根据时间差生成两个合法的时间戳。

参数：   
- interval：时间间隔   

```bash
[WeCross]> genTimelock  300
timelock0: 1586917289
timelock1: 1586916989
```

##### genSecretAndHash
跨链转账辅助命令，生成一个秘密和它的哈希。

```bash
[WeCross]> genSecretAndHash
hash  : 66ebd11ec6cc289aebe8c0e24555b1e58a5191410043519960d26027f749c54f
secret: afd1c0f9c2f8acc2c1ed839ef506e8e0d0b4636644a889f5aa8e65360420d2a9
```

##### newHTLCProposal
新建一个基于哈希时间锁合约的跨链转账提案，该命令由两条链的资金转出方分别执行。

参数：   
- path：跨链转账资源标识。   
- accountName：资产转出者在router上配置的账户名。
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
[WeCross]> newHTLCProposal payment.bcos.htlc bcos_sender 88b6cea9b5ece573c6c35cb3f1a2237bf380dfbbf9155b82d5816344cdac0185 null false Admin@org1.example.com User1@org1.example.com 200 2000010000 0x55f934bcbe1e9aef8337f5551142a442fdde781c 0x2b5ad5c4795c026514f8317c7a215e218dccd6cf  100 2000000000

Txhash: 0x244d302382d03985eebcc1f7d95d0d4eef7ff2b3d528fdf7c93effa94175e921
BlockNum: 2222
Result: [create a htlc transfer proposal successfully]
```

##### checkTransferStatus
根据提案号（Hash）查询htlc转账状态。

参数：   
- path：跨链资源标识。   
- accountName：交易签名账户，router上配置的账户名。
- method：合约方法名。
- hash：转账提案号。

```bash
[WeCross]> checkTransferStatus payment.bcos.htlc bcos_sender dcbdf73ee6fdbe6672142c7776c2d21ff7acc6f0d61975e83c3b396a364bee93
status: succeeded!
```

##### startTransaction
写接口，开始两阶段事务

参数：
- transactionID：事务ID，类型为字符串，由用户指定，作为事务的唯一标识，后续所有的事务资源操作都必须指定该事务ID
- account_1 ... account_n：用于开始事务的账号列表，由于两阶段事务可能跨越多种区块链，多种区块链会使用不同类型的账号，因此开始事务时，需要为每种区块链指定至少一个账号，WeCross会使用相应类型的账号向链上发送开始事务交易，该账号列表仅用于开始事务，事务开始后，可以使用该账号列表以外的账号来发送事务交易
- path_1 ... path_n：参与事务的资源路径列表，路径列表中的资源会被本次事务锁定，锁定后仅限本事务相关的交易才能对这些资源发起写操作，非本次事务的所有写操作都会被拒绝

```
[WeCross]> startTransaction 0001 bcos_user1 fabric_user1 payment.bcos.2pc payment.fabric.2pc
Result: success!

```

##### execTransaction
写接口，发起事务交易

参数：
- path：资源路径
- account：交易账号
- transactionID：事务ID，该资源正在参与事务的ID
- seq：事务编号，本次操作的编号，每次事务交易唯一，要求递增
- method：接口名，同sendTransaction。需要注意的是，该接口需要在合约中配套以`_revert`结尾的回滚接口。
- args：参数，同sendTransaction

```

[WeCross]> execTransaction payment.bcos.2pc bcos_user1 0001 1 newEvidence key1 evidence1
Result: [true]

[WeCross]> execTransaction payment.fabric.2pc fabric_user1 0001 1 newEvidence key1 evidence1
Result: [newEvidence success]
```

##### callTransaction
读接口，查询事务中的数据

参数：
- path：资源路径
- account：交易账号
- transactionID：事务ID，该资源正在参与事务的ID
- method：接口名，同sendTransaction。
- args：参数，同sendTransaction

```
[WeCross]> callTransaction payment.bcos.2pc bcos_user1 0002 queryEvidence key1
Result: [evidence1]
```

##### commitTransaction
写接口，提交事务，确认事务执行过程中所有的变动

参数：
- transactionID：事务ID，待提交事务的ID
- account_1 ... account_n：用于提交事务的账号列表，由于两阶段事务可能跨越多种区块链，多种区块链会使用不同类型的账号，需要为每种区块链指定至少一个账号，WeCross会使用相应类型的账号向链上发送提交事务交易
- path_1 ... path_n：用于提交事务的路径列表

```
[WeCross]> commitTransaction 0001 bcos_user1 fabric_user1 payment.bcos.2pc payment.fabric.2pc
```

##### rollbackTransaction
写接口，撤销本次事务的所有变更时

参数：
- transactionID：事务ID，待回滚事务的ID
- account_1 ... account_n：用于回滚事务的账号列表，由于两阶段事务可能跨越多种区块链，多种区块链会使用不同类型的账号，需要为每种区块链指定至少一个账号，WeCross会使用相应类型的账号向链上发送回滚事务交易
- path_1 ... path_n：用于回滚事务的路径列表

```
# 查看开始前的状态
[WeCross]> call payment.bcos.2pc bcos_user1 queryEvidence key2
Result: []

# 开始事务
[WeCross]> startTransaction 0002 bcos_user1 fabric_user1 payment.bcos.2pc payment.fabric.2pc
Result: success!

# 执行事务
[WeCross]> execTransaction payment.bcos.2pc bcos_user1 0002 1 newEvidence key2 evidence2
Result: [true]

# 读事务数据
[WeCross]> callTransaction payment.bcos.2pc bcos_user1 0002 queryEvidence key2
Result: [evidence2]

# 回滚事务
[WeCross]> rollbackTransaction 0002 bcos_user1 fabric_user1 payment.bcos.2pc payment.fabric.2pc
Result: success!

# 查看事务回滚后的状态，和开始前保持一致
[WeCross]> call payment.bcos.2pc bcos_user1 queryEvidence key2
Result: []
```
##### getTransactionInfo
读接口，查询事务信息

参数：
- transactionID：事务ID，待提交事务的ID
- account_1 ... account_n：如果涉及多条链需要多个账户
- path_1 ... path_n：参与事务的资源路径列表

```
[WeCross]> getTransactionInfo 0001 bcos_user1 fabric_user1 payment.bcos.2pc payment.fabric.2pc
XATransactionInfo{
 transactionID='0001',
 status=1,
 startTimestamp=1596962127015,
 commitTimestamp=1596962353724,
 rollbackTimestamp=0,
 paths=[
  payment.fabric.2pc,
  payment.bcos.2pc
 ],
 transactionSteps=[
  XATransactionStep{
   seq=1,
   contract='0xd6cd8179b796f0fc04718364c232723833b8ca59',
   path='payment.bcos.2pc',
   timestamp='1596962287683',
   func='newEvidence(string,
   string)',
   args='0000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000046b65793100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000965766964656e6365310000000000000000000000000000000000000000000000'
  },
  XATransactionStep{
   seq=2,
   contract='null',
   path='payment.fabric.2pc',
   timestamp='1596962314',
   func='newEvidence',
   args='{
    "args":[
     "key1",
     "evidence1"
    ]
   }'
  }
 ]
}
```

##### getTransactionIDs
读接口，查询链上的事务ID

参数：
- account：交易账户
- path：指定需要查询的链
- option：选项。0全部事务，1已完成的事务，2未完成的事务
```
[WeCross]> getTransactionIDs payment.bcos.2pc bcos_user1 0
Result: [0001, 0002]

[WeCross]> getTransactionIDs payment.bcos.2pc bcos_user1 1
Result: [0001]

[WeCross]> getTransactionIDs payment.bcos.2pc bcos_user1 2
Result: [0002]

```


### 交互式命令

##### WeCross.getResource
WeCross控制台提供了一个资源类，通过方法`getResource`来初始化一个跨链资源实例，并且赋值给一个变量。
这样调用同一个跨链资源的不同UBI接口时，不再需要每次都输入跨链资源标识。

```bash
# myResource 是自定义的变量名
[WeCross]> myResource = WeCross.getResource payment.bcos.HelloWeCross bcos_user1

# 还可以将跨链资源标识赋值给变量，通过变量名来初始化一个跨链资源实例
[WeCross]> path = payment.bcos.HelloWeCross

[WeCross]> myResource = WeCross.getResource path bcos_user1
```

##### [resource].[command]
当初始化一个跨链资源实例后，就可以通过`.command`的方式，调用跨链资源的UBI接口。

```bash
# 输入变量名，通过tab键可以看到能够访问的所有命令
[WeCross]> myResource.
myResource.call              myResource.status
myResource.detail            myResource.sendTransaction
```

##### status

```bash
[WeCross]> myResource.status
exists
```

##### detail

```bash
[WeCross]> myResource.detail
ResourceDetail{
 path='payment.bcos.HelloWeCross',
 distance=0',
 stubType='BCOS2.0',
 properties={
  BCOS_PROPERTY_CHAIN_ID=1,
  BCOS_PROPERTY_GROUP_ID=1,
  HelloWeCross=0x9bb68f32a63e70a4951d109f9566170f26d4bd46
 },
 checksum='0x888d067b77cbb04e299e675ee4b925fdfd60405241ec241e845b7e41692d53b1'
}
```

##### call

```
[WeCross]> myResource.call get
Result: [hello, wecross]
```

##### sendTransaction

```bash
[WeCross]> myResource.sendTransaction set hello world
Txhash  : 0x616a55a7817f843d81f8c7b65449963fc2b7a07398b853829bf85b2e1261516f
BlockNum: 2224
Result  : [hello, world]
```
