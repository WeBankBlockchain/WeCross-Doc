# 跨平台 FISCO BCOS & Fabric

此Demo搭建了一个WeCross跨链网络，连接FISCO BCOS和Hyperledger Fabric区块链。用户可通过WeCross控制台，对不同的链上资源进行操作。

![](../../images/tutorial/demo.png)

## 网络部署

在已下载的demo目录下进行操作

```bash
cd ~/demo

#清理旧demo环境
bash clear.sh

# 运行部署脚本，第一次运行需耗时10-30分钟左右
bash build.sh # 若出错，可用 bash clear.sh 清理后重试
```

```eval_rst
.. note::
    - MacOS用户若出现“无法打开”，“无法验证开发者”的情况，可参考 `FAQ问题3 <../faq/faq.html#id3>`_ 的方式解决
```

部署成功后会输出Demo的网络架构，FISCO BCOS和Fabric通过各自的WeCross Router相连。（输入Y，回车，进入WeCross控制台）

``` 
[INFO] Success! WeCross demo network is running. Framework:

      FISCO BCOS                    Fabric
     (4node pbft)              (first-network)
    (HelloWorld.sol)              (sacc.go)
           |                          |
           |                          |
    WeCross Router <----------> WeCross Router
(127.0.0.1-8250-25500)      (127.0.0.1-8251-25501)
           |
           |
    WeCross Console
    
Start WeCross Console? [Y/n]
```

## 跨链资源操作

**查看资源**

进入控制台，用`listResources`命令查看WeCross跨连网络中的所有资源。可看到有两个资源：

* payment.bcos.HelloWorld
  * 对应于FISCO BCOS链上的HelloWorld.sol合约
* payment.fabric.sacc
  * 对应于Fabric链上的[sacc.go](https://github.com/hyperledger/fabric-samples/blob/v1.4.4/chaincode/sacc/sacc.go)合约

```bash
[WeCross]> listResources
path: payment.bcos.HelloWorld, type: BCOS2.0, distance: 0
path: payment.fabric.sacc, type: Fabric1.4, distance: 1
total: 2
```

**查看账户**

用`listAccounts`命令查看WeCross Router上已存在的账户，操作资源时用相应账户进行操作。

```bash
[WeCross]> listAccounts
name: fabric_user1, type: Fabric1.4
name: bcos_user1, type: BCOS2.0
name: bcos_default_account, type: BCOS2.0
name: fabric_default_account, type: Fabric1.4
total: 4
```

**操作资源：payment.bcos.HelloWorld**

- 读资源
  - 命令：`call path 账户名 接口名 [参数列表]`
  - 示例：`call payment.bcos.HelloWorld bcos_user1 get`
  
```bash
# 调用HelloWorld合约中的get接口
[WeCross]> call payment.bcos.HelloWorld bcos_user1 get
Result: [Hello, World!]
```

- 写资源
  - 命令：`sendTransaction path 账户名 接口名 [参数列表]`
  - 示例：`sendTransaction payment.bcos.HelloWeCross bcos_user1 set Tom`

```bash
# 调用HelloWeCross合约中的set接口
[WeCross]> sendTransaction payment.bcos.HelloWorld bcos_user1 set Tom
Txhash  : 0x7e747198f553cb2e90e729b52179533dc4321e520b0f11b83b1f0e81fa7ff716
BlockNum: 5
Result  : []     // 将Tom给set进去

[WeCross]> call payment.bcos.HelloWorld bcos_user1 get
Result: [Tom]    // 再次get，Tom已set
```

**操作资源：payment.fabric.sacc**

跨链资源是对各个不同链上资源的统一和抽象，因此操作的命令是保持一致的。

- 读资源

```bash
# 调用mycc合约中的query接口
[WeCross]> call payment.fabric.sacc fabric_user1 get a
Result: [10] // 初次get，a的值为10
```

- 写资源

```bash
# 调用sacc合约中的set接口
[WeCross]> sendTransaction payment.fabric.sacc fabric_user1 set a 666
Txhash  : eca4ecacf7b159c1499d6c190fcaf9fd7348bdb96cdbf35cd29b34ac9bd8e518
BlockNum: 7
Result  : [666]

[WeCross]> call payment.fabric.sacc fabric_user1 get a
Result: [666] // 再次get，a的值变成666

# 退出WeCross控制台
[WeCross]> quit # 若想再次启动控制台，cd至WeCross-Console，执行start.sh即可
```

WeCross Console是基于WeCross Java SDK开发的跨链应用。搭建好跨链网络后，可基于WeCross Java SDK开发更多的跨链应用，通过统一的接口对各种链上的资源进行操作。

## 跨链转账

WeCross支持多种事务机制。此跨链转账的demo是哈希时间锁定机制（HTLC）的举例。WeCross基于其[HTLC框架](../../routine/htlc.html)实现了**异构链之间资产的原子互换**，如下图所示：

![](../../images/tutorial/htlc_sample.png)

**部署哈希时间锁合约**

可通过脚本`htlc_config.sh`完成相关部署，并体验跨链转账。

```bash
# 请确保demo已搭建完毕，并在demo根目录执行，耗时5分钟左右
bash htlc_config.sh
```

跨链转账涉及两条链、两个用户、四个账户，两条链上的资产转出者各自通过WeCross控制台创建一个[转账提案](../../routine/htlc.html#id4)，之后router会自动完成跨链转账。

**创建转账提案**

跨链转账需在跨链的两端都提交转账提案，提交后，router自动实现跨链转账。

- BCOS链资产转出者提交提案

BCOS链连的是router-8250，启动与该router连接的控制台。

```bash
cd ~/demo/WeCross-Console
bash start.sh
# 先查看接收方余额
[WeCross]> call payment.bcos.htlc bcos_sender balanceOf 0x2b5ad5c4795c026514f8317c7a215e218dccd6cf
Result: [0]
# 创建转账提案
[WeCross]> newHTLCProposal payment.bcos.htlc bcos_sender bea2dfec011d830a86d0fbeeb383e622b576bb2c15287b1a86aacdba0a387e11 9dda9a5e175a919ee98ff0198927b0a765ef96cf917144b589bb8e510e04843c true 0x55f934bcbe1e9aef8337f5551142a442fdde781c 0x2b5ad5c4795c026514f8317c7a215e218dccd6cf 700 2000010000 Admin@org1.example.com User1@org1.example.com 500 2000000000
# 输出
Txhash: a0c48eb7d1ca3a01ddf3563aeb6a1829f23dd0d778e7de2ce22406d1e84ba00f
BlockNum: 12
Result: create a htlc proposal successfully
# 退出当前控制台
[WeCross]> quit 
```

- Fabric链资产转出者提交提案

Fabric链连的是router-8251，启动与该router连接的控制台。

```bash
cd ~/demo/WeCross-Console-8251
bash start.sh
# 先查看接收方余额
[WeCross]>  call payment.fabric.htlc fabric_admin balanceOf User1@org1.example.com
Result: [0]
# 创建转账提案
[WeCross]> newHTLCProposal payment.fabric.htlc fabric_admin bea2dfec011d830a86d0fbeeb383e622b576bb2c15287b1a86aacdba0a387e11 null false 0x55f934bcbe1e9aef8337f5551142a442fdde781c 0x2b5ad5c4795c026514f8317c7a215e218dccd6cf 700 2000010000 Admin@org1.example.com User1@org1.example.com 500 2000000000
# 输出
Txhash: 0x40ae8e2e284de813f8b071e0261e627ddc4d91e365e63f222638db9b1a70d05a
BlockNum: 10
Result: create a htlc proposal successfully
# 退出当前控制台
[WeCross]> quit 
```

**跨链资产转移**

当两个资产转出者都创建完提案后，router开始执行调度，并完成跨链转账。一次跨链转账存在5-25s的交易时延，主要取决于两条链以及机器的性能。

**查询转账结果**

在各自的WeCross控制台查询资产是否到账。

- 查询BCOS链上资产接收者余额

```bash
cd ~/demo/WeCross-Console
bash start.sh

[WeCross]> call payment.bcos.htlc bcos_sender balanceOf 0x2b5ad5c4795c026514f8317c7a215e218dccd6cf
Result: [700]

# 退出当前控制台
[WeCross]> quit 
```

- 查询Fabric链上资产接收者余额
```bash
cd ~/demo/WeCross-Console-8251
bash start.sh

[WeCross]>  call payment.fabric.htlc fabric_admin balanceOf User1@org1.example.com
Result: [500]

# 退出当前控制台
[WeCross]> quit 
```

## 跨链存证

WeCross支持多种事务机制。此跨链转账的demo是两阶段事务机制（2PC）的举例。WeCross基于其[2PC框架](../../routine/xa.html)实现了**异构链之间证据的同时确认**，如下图所示：

![](../../images/tutorial/2pc_sample.png)

**部署跨链存证demo的合约**

用一键脚本，在FISCO BCOS和Fabric上分别部署存证跨链的两个存证demo合约

``` bash
cd ~/demo/
bash 2pc_config.sh
```

部署成功，输入Y进入控制台

``` 
[INFO] SUCCESS: 2PC evidence example has been deployed to FISCO BCOS and Fabric:

      FISCO BCOS                    Fabric
(payment.bcos.evidence)    (payment.fabric.evidence)
           |                          |
           |                          |
    WeCross Router <----------> WeCross Router
(127.0.0.1-8250-25500)      (127.0.0.1-8251-25501)
           |
           |
    WeCross Console

Start WeCross Console to try? [Y/n]
```

**发起跨链事务（start）**

发起一个跨链事务，指定事务涉及的跨链资源，此处FISCO BCOS和Fabric上各一个资源

* payment.bcos.evidence
* payment.fabric.evidence

``` bash
# 发起事务，事务号100 
[WeCross]> startTransaction 100 bcos_user1 fabric_user1 payment.bcos.evidence payment.fabric.evidence
Result: success!

# 查看当前存证evidence0的内容
[WeCross]> call payment.bcos.evidence bcos_user1 queryEvidence evidence0
Result: [] # 未存入，空

[WeCross]> call payment.fabric.evidence fabric_user1 queryEvidence evidence0
Result: [] # 未存入，空
```

**发送事务交易（exec）**

事务开始后，通过execTransaction发送事务交易至向此事务涉及的资源，交易会被缓存入事务交易队列，在下一步commit时让所有交易同时被确认。

``` bash
# 在FISCO BCOS链上进行存证，事务号100，序列号1，证据名：evidence0，内容：I'm Tom
[WeCross]> execTransaction payment.bcos.evidence bcos_user1 100 1 newEvidence evidence0 "I'm Tom"
Result: [true]

# 在Fabric链上进行存证，事务号100，序列号1，证据名：evidence0，内容：I'm Jerry
[WeCross]> execTransaction payment.fabric.evidence fabric_user1 100 1 newEvidence evidence0 "I'm Jerry"
Result: [newEvidence success]

# 可发送更多的操作
```

**确认跨链事务（commit）**

在此事务下缓存了一些列的事务交易后，通过commitTransaction让所有事务交易同时被确认，结束此事务。

``` bash 
# 确认事务，事务结束
[WeCross]> commitTransaction 100 bcos_user1 fabric_user1 payment.bcos.evidence payment.fabric.evidence
Result: success!

# 查看当前存证内容，两条链都已完成存证
[WeCross]> call payment.bcos.evidence bcos_user1 queryEvidence evidence0
Result: [I'm Tom]

[WeCross]> call payment.fabric.evidence fabric_user1 queryEvidence evidence0
Result: [I'm Jerry]
```

**回滚跨链事务（rollback）**

在commit前，若不想让事务发生，则用rollbackTransaction回滚此事务，所有缓存的事务交易被丢弃，链上数据回退到事务发起前状态，事务结束。（每个事务要么commit，要么rollback）

``` bash
# 查看当前存证evidence1的内容
[WeCross]> call payment.bcos.evidence bcos_user1 queryEvidence evidence1
Result: [] # 未存入，空

[WeCross]> call payment.fabric.evidence fabric_user1 queryEvidence evidence1
Result: [] # 未存入，空

# 发起另一个事务，事务号101
[WeCross]> startTransaction 101 bcos_user1 fabric_user1 payment.bcos.evidence payment.fabric.evidence
Result: success!

# 向FISCO BCOS链发送事务交易，设置evidence1，内容为I'm TomGG
[WeCross]> execTransaction payment.bcos.evidence bcos_user1 101 1 newEvidence evidence1 "I'm TomGG"
Result: [true]

# 向Fabric链发送事务交易，设置evidence1，内容为I'm JerryMM
[WeCross]> execTransaction payment.fabric.evidence fabric_user1 101 1 newEvidence evidence1 "I'm JerryMM"
Result: [newEvidence success]

# 查看当前事务状态下的数据
[WeCross]> call payment.bcos.evidence bcos_user1 queryEvidence evidence1
Result: [I'm TomGG]

# 查看当前事务状态下的数据
[WeCross]> call payment.fabric.evidence fabric_user1 queryEvidence evidence1
Result: [I'm JerryMM]

# 尝试发送普通交易修改此事务下的资源，由于此资源处在事务状态中，被锁定，不可修改
[WeCross]> sendTransaction payment.bcos.evidence bcos_user1 newEvidence evidence1 "I'm TomDD"
Error: code(2031), message(payment.bcos.evidence is locked by unfinished transaction: 101)

# 查看当前事务状态下的数据，未变化，普通交易修改失败，符合预期
[WeCross]> call payment.bcos.evidence bcos_user1 queryEvidence evidence1
Result: [I'm TomGG]

# 回滚操作！假设此事务不符合预期，需回滚至事务开始前状态，执行如下命令进行回滚，事务结束
[WeCross]> rollbackTransaction 101 bcos_user1 fabric_user1 payment.bcos.evidence payment.fabric.evidence
Result: success!

# 再次查看当前存证evidence1的内容
[WeCross]> call payment.bcos.evidence bcos_user1 queryEvidence evidence1
Result: [] # 已回滚至开始状态

[WeCross]> call payment.fabric.evidence fabric_user1 queryEvidence evidence1
Result: [] # 已回滚至开始状态

# 退出当前控制台
[WeCross]> quit 
```

此demo基于[2PC框架](../../routine/xa.html)实现，用户可根据业务需要基于框架开发自己的跨链应用，实现链间的原子操作。

## 清理 Demo

为了不影响其它章节的体验，可将搭建的Demo清理掉。

``` bash
cd ~/demo/
bash clear.sh
```

至此，恭喜你，快速体验完成！可进入[手动组网](../networks.md)章节深入了解更多细节。

