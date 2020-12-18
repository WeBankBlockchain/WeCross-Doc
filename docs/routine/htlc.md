# 哈希时间锁合约

哈希时间锁合约（hash time lock contract，htlc）能够实现两条异构链之间资产的原子交换，即跨链转账。

如果你想**快速体验**跨链转账可以参考[体验WeCross](../tutorial/demo/demo.html#id3)。

WeCross提供了[Solidity版本](https://github.com/WeBankBlockchain/WeCross-Console/blob/master/src/main/resources/contracts/solidity/HTLC.sol)和[Golang版本](https://github.com/WeBankBlockchain/WeCross-Console/blob/master/src/main/resources/contracts/chaincode/htlc/htlc.go)的htlc基类合约，基于htlc基类合约可以轻松开发适用于不同资产类型的htlc应用合约。

本章节以FISCO BCOS和Hyperledger Fabric的**示例资产合约**为例，演示如何实现两条异构链的资产互换。

## 准备工作

要完成资产互换，需要在各自链上部署资产合约以及哈希时间锁合约，然后通过WeCross控制台创建[跨链转账提案](../manual/console.html#newhtlcproposal)，跨链路由会根据提案信息自动完成跨链转账。

**部署WeCross和控制台**
- 以[组网方式](../tutorial/networks.html)搭建两个跨链路由
- 搭建WeCross[控制台](../tutorial/networks.html#id11)，连接跨链路由


### BCOS链前期准备

**部署合约**

假设已存在一个跨链账户`org2-admin`，且分别添加了一个BCOS2.0链账户以及Fabric1.4链账户。

进入BCOS链的WeCross控制台。

```bash
bash start.sh

# 登录
[WeCross]>login org2-admin 123456

# 发行资产，资产名为htlc，最小单位1，发行数量100000000
[WeCross.org2-admin]> bcosDeploy payment.bcos.ledger contracts/solidity/LedgerSample.sol LedgerSample 1.0 token htlc 1 100000000

# 资产合约地址需要记录下来
Result: 0xf4fdcdfe0184644f09a1cfa16a945cc71a5d44ff

# 部署htlc合约
[WeCross.org2-admin]> bcosDeploy payment.bcos.htlc contracts/solidity/LedgerSampleHTLC.sol LedgerSampleHTLC 1.0

# htlc合约地址需要记录下来
Result: 0x22a83719f748da09845d91fe1a2f44437f0ad13b
```

**资产授权**

要完成跨链转账，资产拥有者需要将资产的转移权授权给哈希时间锁合约。

进入BCOS链的WeCross控制台。

```bash
bash start.sh

# 登录
[WeCross]>login org2-admin 123456

# approve [被授权者地址]（此处为自己的哈希时间锁合约地址），[授权金额]
[WeCross.org2-admin]> sendTransaction payment.bcos.ledger approve 0x22a83719f748da09845d91fe1a2f44437f0ad13b 1000000

Txhash  : 0x718e948b0ab55697c61675253acfd580104e539c85e0fcb23c0686457ea429d4
BlockNum: 46
Result  : [true]
```

**哈希时间锁合约初始化**

需要将资产合约的地址和对手方的哈希时间锁合约地址保存到自己的哈希时间锁合约。

进入BCOS链的WeCross控制台。

```bash
bash start.sh

# 登录
[WeCross]>login org2-admin 123456

# init [己方资产合约地址] 
[WeCross.org2-admin]> sendTransaction payment.bcos.htlc init 0xf4fdcdfe0184644f09a1cfa16a945cc71a5d44ff

Txhash  : 0x7df25ce20e7db6f6bba836bf54c258bb5386873e14b57e74a2371ec367b31779
BlockNum: 51
Result  : [success]

# 查看资产发行者owner的地址
[WeCross.org2-admin]> call payment.bcos.htlc queryAddress

# 该地址需要记录下来，发起转账提案时需要
Result: [0x55f934bcbe1e9aef8337f5551142a442fdde781c]

# 查看owner余额，检查是否初始化成功
[WeCross.org2-admin]> call payment.bcos.htlc balanceOf 0x55f934bcbe1e9aef8337f5551142a442fdde781c

Result: [100000000]
```

### Fabric链前期准备

假设已存在一个跨链账户`org1-admin`，且分别添加了一个BCOS2.0链账户以及两个不同机构的Fabric1.4链账户。

进入Fabric链的WeCross控制台。

**部署合约**

```bash
bash start.sh

# 登录
[WeCross]>login org1-admin 123456

# 切换默认账户
[WeCross.org1-admin]>setDefaultAccount Fabric1.4 2

# 在机构2安装资产合约链码
[WeCross.org1-admin]> fabricInstall payment.fabric.ledger Org2 contracts/chaincode/ledger 1.0 GO_LANG

path: classpath:contracts/chaincode/ledger
Result: Success

# 在机构2安装哈希时间锁合约链码
[WeCross.org1-admin]> fabricInstall payment.fabric.htlc Org2 contracts/chaincode/htlc 1.0 GO_LANG

path: classpath:contracts/chaincode/htlc
Result: Success

# 切换默认账户
[WeCross.org1-admin]>setDefaultAccount Fabric1.4 1

# 在机构1安装资产合约链码
[WeCross.org1-admin]> fabricInstall payment.fabric.ledger Org1 contracts/chaincode/ledger 1.0 GO_LANG

path: classpath:contracts/chaincode/ledger
Result: Success

# 在机构1安装哈希时间锁合约链码
[WeCross.org1-admin]> fabricInstall payment.fabric.htlc Org1 contracts/chaincode/htlc 1.0 GO_LANG

path: classpath:contracts/chaincode/htlc
Result: Success

# 实例化链码，发行资产100000000
[WeCross.org1-admin]> fabricInstantiate payment.fabric.ledger ["Org1","Org2"] contracts/chaincode/ledger 1.0 GO_LANG default ["token","htlc","100000000"]

Result: Query success. Please wait and use 'listResources' to check.

# 用listResources确认payment.fabric.ledger已实例化完成（约1分钟）
[WeCross.org1-admin]> listResources

path: payment.fabric.ledger, type: Fabric1.4, distance: 0

# 实例化哈希时间锁合约，需要写入[己方资产合约名，channel]
[WeCross.org1-admin]> fabricInstantiate payment.fabric.htlc ["Org1","Org2"] contracts/chaincode/htlc 1.0 GO_LANG default ["ledger","mychannel",]

Result: Query success. Please wait and use 'listResources' to check.

# 用listResources确认payment.fabric.htlc已实例化完成（约1分钟）
[WeCross.org1-admin]> listResources

path: payment.fabric.htlc, type: Fabric1.4, distance: 0
```

**资产授权**

fabric的示例资产合约通过创建一个托管账户实现资产的授权。

进入Fabric链的WeCross控制台。

```bash
bash start.sh

# 登录
[WeCross]>login org1-admin 123456

# 创建一个托管账户完成授权
[WeCross.org1-admin]> sendTransaction payment.fabric.ledger createEscrowAccount 1000000

Txhash  : d6a6241cbaac9cad768465213f3462f54c62e32f168c26bcce23d060315f0751
BlockNum: 1097
Result  : [HTLCoin-Admin@org1.example.com-EscrowAccount]

# 查看资产发行者owner的地址
[WeCross.org1-admin]> call payment.fabric.htlc queryAddress

Result: [Admin@org1.example.com]

# 查看owner授权后的余额
[WeCross.org1-admin]> call payment.fabric.htlc balanceOf Admin@org1.example.com

# 通过授权的方式已转移1000000到托管账户
Result: [99000000]
```

## 哈希时间锁合约配置

**配置FISCO BCOS端跨链路由**
在主配置文件`wecross.toml`中配置htlc任务。

```toml
[[htlc]]
     #直连链的哈希时间锁资源路径
    selfPath = 'payment.bcos.htlc' 

    #对手方的哈希时间锁资源路径
    counterpartyPath = 'payment.fabric.htlc'   
```

```eval_rst
.. important::
    - htlc资源路径请结合实际情况配置。
```

**配置Fabric端跨链路由**

在主配置文件`wecross.toml`中配置htlc任务。

```toml
[[htlc]]
     #直连链的的哈希时间锁资源路径
    selfPath = 'payment.fabric.htlc' 

    #对手方的哈希时间锁资源路径
    counterpartyPath = 'payment.bcos.htlc'    
```

**重启两个跨链路由**

```bash
bash stop.sh && bash start.sh
```

## 发起跨链转账

假设跨链转账发起方是FISCO BCOS的用户，发起方选择一个`secret`，计算
$$
hash = sha256(secret)
$$
得到`hash`，然后和Fabric的用户即参与方协商好各自转账的金额、账户以及时间戳。

**协商内容**

- FISCO BCOS的两个账户：
    - 资产转出者：org2-admin(BCOS链发行资产的地址：0x55f934bcbe1e9aef8337f5551142a442fdde781c)
    - 资产接收者：org1-admin(BCOS链账户：0x2b5ad5c4795c026514f8317c7a215e218dccd6cf)
- FISCO BCOS转账金额：700
- Fabric的两个账户：
    - 资产转出者：org1-admin(Fabric链发行资产的地址：Admin@org1.example.com)
    - 资产接收者：org2-admin(Fabric链账户：User1@org2.example.com)
- Fabric转账金额500
- 哈希: 2afe76d15f32c37e9f219ffd0a8fcefc76d850fa9b0e0e603cbd64a2f4aa670d
- 哈希原像: e7d5c31dcc6acae547bb0d84c2af05413994c92599bff89c4abd72866f6ac5c6（协商时只有发起方知道）
- 时间戳t0：发起方的超时时间，单位s
- 时间戳t1： 参与方的超时时间，单位s

```eval_rst
.. note::
    - 哈希原像和哈希可通过控制台命令 `genSecretAndHash <../manual/console.html#gensecretandhash>`_ 生成。
    - 两个时间戳可通过控制台命令 `genTimelock <../manual/console.html#gentimelock>`_ 生成。
    - 时间戳需要满足条件：t0  - 300 > t1 > now + 600
```

**创建跨链转账提案**

两条链的**资产转出者**通过WeCross控制台创建跨链转账提案，将协商的转账信息写入各自的区块链。

- 命令介绍
    - 命令：`newHTLCProposal`
    - 参数：`path`, `hash`，`secret`，`role`，`sender0`，`receiver0`，`amount0`，`timelock0`，`sender1`，`receiver1`，`amount1`，`timelock1`

- 注意事项
    - 其中下标为0的参数是发起方信息。
    - 发起方`secret`传入哈希原像，`role`传入true；参与方`secret`传入null，`role`传入false。

- 启动控制台

- 发起方创建转账提案

该步骤由发起方即BCOS链的资产转出者完成。

进入BCOS链的WeCross控制台。

```bash
bash start.sh

# 登录
[WeCross]>login org2-admin 123456

[WeCross.org2-admin]> newHTLCProposal payment.bcos.htlc edafd70a27887b361174ba5b831777c761eb34ef23ee7343106c0b545ec1052f 049db09dd9cf6fcf69486512c1498a1f6ea11d33b271aaad1893cd590c16542a true 0x55f934bcbe1e9aef8337f5551142a442fdde781c 0x2b5ad5c4795c026514f8317c7a215e218dccd6cf 700 2000010000 Admin@org1.example.com User1@org2.example.com 500 2000000000
```

- 参与方创建转账提案

该步骤由参与方即Fabric链的资产转出者完成。

进入Fabric链的WeCross控制台。

```bash
bash start.sh

# 登录
[WeCross]>login org1-admin 123456

[WeCross.org1-admin]> newHTLCProposal payment.fabric.htlc edafd70a27887b361174ba5b831777c761eb34ef23ee7343106c0b545ec1052f null false 0x55f934bcbe1e9aef8337f5551142a442fdde781c 0x2b5ad5c4795c026514f8317c7a215e218dccd6cf 700 2000010000 Admin@org1.example.com User1@org2.example.com 500 2000000000
```

**结果确认**

哈希时间锁合约提供了查询余额的接口，可通过WeCross控制台调用，查看两方的接收者是否到账。

- FISCO BCOS到账确认

```bash
[WeCross.org2-admin]> call payment.bcos.htlc balanceOf 0x2b5ad5c4795c026514f8317c7a215e218dccd6cf

Result: [700]
```

- Fabric到账确认
```bash
[WeCross.org1-admin]> call payment.fabric.htlc balanceOf User1@org2.example.com

Result: [500]
```
**注**：跨链转账存在交易时延，取决于两条链以及机器的性能，一般需要5~25s完成转账。Fabric链资产转出者Admin@org1.example.com在授权的时候已经把钱转移到了托管账户，因此htlc扣的是托管账户，他的余额不会发生变化。
