## 控制台

[控制台](https://github.com/WeBankFinTech/WeCross-Console)是WeCross重要的交互式客户端工具，它通过[WeCross-Java-SDK](./sdk.html)与WeCross 跨链代理建立连接，实现对跨链资源的读写访问请求。控制台拥有丰富的命令，包括获取跨链资源列表，查询资源状态，以及所有的JSON-RPC接口命令。


### 控制台命令

控制台命令可分为两类，普通命令和交互式命令。

#### 普通命令
普通命令由两部分组成，即指令和指令相关的参数：   
- **指令**: 指令是执行的操作命令，包括获取跨链资源列表，查询资源状态指令等，其中部分指令调用JSON-RPC接口，因此与JSON-RPC接口同名。
**使用提示： 指令可以使用tab键补全，并且支持按上下键显示历史输入指令。**
  
- **指令相关的参数**: 指令调用接口需要的参数，指令与参数以及参数与参数之间均用空格分隔。与JSON-RPC接口同名命令的输入参数和获取信息字段的详细解释参考[JSON-RPC API](./api.html)。

#### 交互式命令
WeCross控制台为了方便用户使用，还提供了交互式的使用方式，比如将跨链资源标识赋值给变量，初始化一个类，并用`.command`的方式访问方法。
详见：[交互式命令](#id14)

### 常用命令链接

#### 普通命令

* 合约调用
- call(不发交易): [call](#call)
- sendTransaction(发交易)): [sendTransaction](#sendtransaction)

* 跨链转账
- newHTLCTransferProposal(创建转账提案): [newHTLCTransferProposal](#newHTLCTransferProposal)

* 状态查询
- detail(查看资源详情): [detail](#detail)
- listResources(查看资源列表): [listResources](#listResources)
- listAccounts(查看账户列表): [call](#listAccounts)

#### 交互式命令

- 初始化资源实例: [WeCross.getResource](#wecross-getresource)
- 访问资源UBI接口: [\[resource\].\[command\]](#resource-command)

### 快捷键
- `Ctrl+A`：光标移动到行首
- `Ctrl+E`：光标移动到行尾
- `Ctrl+R`：搜索输入的历史命令
- &uarr;：  向前浏览历史命令
- &darr;：  向后浏览历史命令
- `table`： 自动补全，支持命令、变量名、资源名以及其它固定参数的补全


### 控制台响应
当发起一个控制台命令时，控制台会获取命令执行的结果，并且在终端展示执行结果，执行结果分为2类：
- **正确结果:** 命令返回正确的执行结果，以字符串或是json的形式返回。       
- **错误结果:** 命令返回错误的执行结果，以字符串或是json的形式返回。 
- **状态码:** 控制台的命令调用JSON-RPC接口时，状态码[参考这里](./api.html#rpc)。


### 控制台配置与运行

```eval_rst
.. important::
    前置条件：部署WeCross请参考 `快速部署 <../tutorial/setup.html>`_。
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

配置前需要将`application-sample.toml`拷贝成`application.toml`，再配置`console.toml`文件。

控制台需要配置router的连接信息，包括router地址以及TLS证书，控制台的证书和私钥可以从router端拷贝。

``` toml
[connection]
    server =  '127.0.0.1:8250'
    sslKey = 'classpath:ssl.key'
    sslCert = 'classpath:ssl.crt'
    caCert = 'classpath:ca.crt'
```

#### 启动控制台

在WeCross服务已经开启的情况下，启动控制台：

```bash
cd ~/wecross/WeCross-Console
bash start.sh
# 输出下述信息表明启动成功
=============================================================================================
Welcome to WeCross console(1.0.0-rc2)!
Type 'help' or 'h' for help. Type 'quit' or 'q' to quit console.

=============================================================================================
```

### 普通命令

以下所有跨链资源相关命令的执行结果以实际配置为准，此处只是示例。

**help**
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
genTimelock                        Generate two valid timelocks.
genSecretAndHash                   Generate a secret and its hash.
newHTLCTransferProposal            Create a htlc transfer agreement.
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
**supportedStubs**
显示router当前支持的插件列表。

```bash
[WeCross]> supportedStubs
[BCOS2.0, GM_BCOS2.0, Fabric1.4]
```

**listAccounts**
显示所有已配置的账户列表。

```bash
[WeCross]> listAccounts
[
 {
  name=fabric_default,
  type=Fabric1.4
 },
 {
  name=bcos_default,
  type=BCOS2.0
 }
]
```

**listLocalResources**
显示router配置的跨链资源。

```bash
[WeCross]> listLocalResources
path: payment.bcos.htlc, type: BCOS2.0, distance: 0
path: payment.bcos.HelloWeCross, type: BCOS2.0, distance: 0
```

**listResources**
查看WeCross跨链代理本地配置的跨链资源和所有的远程资源。

```bash
[WeCross]> listResources
path: payment.bcos.htlc, type: BCOS2.0, distance: 0
path: payment.fabric.ledger, type: Fabric1.4, distance: 1
path: payment.fabric.htlc, type: Fabric1.4, distance: 1
path: payment.bcos.HelloWeCross, type: BCOS2.0, distance: 0
```

**status**
查看跨链资源的状态，即是否存在于连接的router中。

参数：     
- path：跨链资源标识。    

```bash
[WeCross]> status payment.bcos.HelloWeCross
exists
```
**detail**
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
  HelloWeCross=0x6215f04619eb0f6d40c7d15c8efc025751fbce85
 },
 checksum='0x8c72de0e0d4a5e74afcdaed1fa6322c15a7cebfddb893df0339af7c5441f05fe'
}
```

**call**
调用智能合约的方法，不涉及状态的更改，不发交易。

参数：   
- path：跨链资源标识。   
- accountName：交易签名账户。
- method：合约方法名。
- args：参数列表。

```bash
[WeCross]> call payment.bcos.HelloWeCross bcos_default get
Result: [Talk is cheap, Show me the code]
```

**sendTransaction**
调用智能合约的方法，会更改链上状态，需要发交易。

参数：   
- path：跨链资源标识。   
- accountName：交易签名账户。
- method：合约方法名。
- args：参数列表。

```bash
[WeCross]> sendTransaction payment.bcos.HelloWeCross bcos_default set hello wecross
Txhash  : 0x66f94d387df2b16bea26e6bcf037c23f0f13db28dc4734588de2d57a97051c54
BlockNum: 2219
Result  : [hello, wecross]
```

**genTimelock**
跨链转账辅助命令，根据时间差生成两个合法的时间戳。

参数：   
- interval：时间间隔   

```bash
[WeCross]> genTimelock  300
timelock0: 1586917289
timelock1: 1586916989
```

**genSecretAndHash**
跨链转账辅助命令，生成一个秘密和它的哈希。

```bash
[WeCross]> genSecretAndHash
secret: afd1c0f9c2f8acc2c1ed839ef506e8e0d0b4636644a889f5aa8e65360420d2a9
hash  : 66ebd11ec6cc289aebe8c0e24555b1e58a5191410043519960d26027f749c54f
```

**newHTLCTransferProposal**
新建一个基于哈希时间锁合约的跨链转账提案，该命令由两条链的资金转出方分别执行。

参数：   
- path：跨链转账资源标识。   
- accountName：返回值类型列表。
- args：提案信息，包括两条链的转账信息。
    - hash： 唯一标识，提案号，
    - secret： 提案号的哈希原像
    - role： 身份，发起方-true，参与方-false。发起方需要传入secret，参与方secret传null。
    - sender0：发起方的资金转出者
    - receiver0：发起方的资金接收者
    - amount0：发起方的转出金额
    - timelock0：发起方的超时时间
    - sender1：参与方的资金转出者
    - receiver1：参与方的资金接收者
    - amount1：参与方的转出金额
    - timelock1：参与方的超时时间，小于发起方的超时时间

```bash
[WeCross]> newHTLCTransferProposal payment.bcos.htlc bcos_sender 88b6cea9b5ece573c6c35cb3f1a2237bf380dfbbf9155b82d5816344cdac0185 null false Admin@org1.example.com User1@org1.example.com 200 2000010000 0x55f934bcbe1e9aef8337f5551142a442fdde781c 0x2b5ad5c4795c026514f8317c7a215e218dccd6cf  100 2000000000

Txhash: 0x244d302382d03985eebcc1f7d95d0d4eef7ff2b3d528fdf7c93effa94175e921
BlockNum: 2222
Result: [create a htlc transfer proposal successfully]
```

**checkTransferStatus**
根据提案号（Hash）查询htlc转账状态。

参数：   
- path：跨链资源标识。   
- accountName：交易签名账户。
- method：合约方法名。
- hash：转账提案号。

```bash
[WeCross]> checkTransferStatus payment.bcos.htlc bcos_sender dcbdf73ee6fdbe6672142c7776c2d21ff7acc6f0d61975e83c3b396a364bee93
status: succeeded!
```


### 交互式命令

**WeCross.getResource**
WeCross控制台提供了一个资源类，通过方法`getResource`来初始化一个跨链资源实例，并且赋值给一个变量。
这样调用同一个跨链资源的不同UBI接口时，不再需要每次都输入跨链资源标识。

```bash
# myResource 是自定义的变量名
[WeCross]> myResource = WeCross.getResource payment.bcos.HelloWeCross bcos_default

# 还可以将跨链资源标识赋值给变量，通过变量名来初始化一个跨链资源实例
[WeCross]> path = payment.bcos.HelloWeCross

[WeCross]> myResource = WeCross.getResource path bcos_default
```

**[resource].[command]**
当初始化一个跨链资源实例后，就可以通过`.command`的方式，调用跨链资源的UBI接口。

```bash
# 输入变量名，通过table键可以看到能够访问的所有命令
[WeCross]> myResource.
myResource.call              myResource.status
myResource.detail            myResource.sendTransaction
```

**status**
```bash
[WeCross]> myResource.status
exists
```

**detail**
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

**call**
```
[WeCross]> myResource.call get
Result: [hello, wecross]
```

**sendTransaction**
```bash
[WeCross]> myResource.sendTransaction set hello world
Txhash  : 0x616a55a7817f843d81f8c7b65449963fc2b7a07398b853829bf85b2e1261516f
BlockNum: 2224
Result  : [hello, world]
```
