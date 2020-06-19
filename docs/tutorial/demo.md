# 快速体验

我们提供一个Demo帮助用户快速体验并理解WeCross的原理。Demo搭建了一个WeCross跨链网络，连接FISCO BCOS和Hyperledger Fabric区块链。用户可通过WeCross控制台，对不同的链上资源进行操作。

![](../images/tutorial/demo.png)

## 搭建 Demo

- 下载

若下载较慢，可选择[更多下载方式](../version/download.html#wecross-demo)。

``` bash
cd ~
# 下载，生成demo文件夹
bash <(curl -sL https://github.com/WeBankFinTech/WeCross/releases/download/resources/download_demo.sh)
```

- 部署

```bash
cd demo
# 运行部署脚本，耗时10-30分钟左右
bash build.sh # 若出错，可用 bash clear.sh 清理后重试
```

部署成功后会输出Demo的网络架构，FISCO BCOS和Fabric通过各自的WeCross Router相连。（输入Y，回车，进入WeCross控制台）

``` 
[INFO] Success! WeCross demo network is running. Framework:

      FISCO BCOS                    Fabric
     (4node pbft)              (first-network)
   (HelloWeCross.sol)             (abac.go)
           |                          |
           |                          |
    WeCross Router <----------> WeCross Router
(127.0.0.1-8250-25500)      (127.0.0.1-8251-25501)
           | 
           | 
    WeCross Console
    
Start console? [Y/n]
```

> 在部署过程中，MacOS用户若出现“无法打开”，“无法验证开发者”的情况，可采用以下方式解决

``` bash
# 清理环境
cd ~/demo/ && bash clear.sh && cd ~ && rm -rf demo
# 将三个步骤的命令拼成一条命令执行
bash <(curl -sL https://github.com/WeBankFinTech/WeCross/releases/download/resources/download_demo.sh) && cd demo && bash build.sh
```


## 操作跨链资源

**查看资源**

进入控制台，用`listResources`命令查看WeCross跨连网络中的所有资源。可看到有两个资源：

* payment.bcos.HelloWeCross
  * 对应于FISCO BCOS链上的[HelloWeCross.sol](../stubs/bcos.html#id1)合约
* payment.fabric.abac
  * 对应于Fabric链上的[abac.go](https://github.com/hyperledger/fabric-samples/blob/v1.4.4/chaincode/abac/go/abac.go)合约

```bash
[WeCross]> listResources
path: payment.bcos.HelloWeCross, type: BCOS2.0, distance: 0
path: payment.fabric.abac, type: Fabric1.4, distance: 1
total: 2
```

**查看账户**

用`listAccounts`命令查看WeCross Router上已存在的账户，操作资源时用相应账户进行操作。

```bash
[WeCross]> listAccounts
name: fabric_user1, type: Fabric1.4
name: fabric_default_account, type: Fabric1.4
name: bcos_user1, type: BCOS2.0
name: bcos_default_account, type: BCOS2.0
total: 4
```

**操作资源：payment.bcos.HelloWeCross**

- 读资源
  - 命令：`call path 账户名 接口名 [参数列表]`
  - 示例：`call payment.bcos.HelloWeCross bcos_user1 get`
  
```bash
# 调用HelloWeCross合约中的get接口
[WeCross]> call payment.bcos.HelloWeCross bcos_user1 get
Result: [Talk is cheap, Show me the code]
```

- 写资源
  - 命令：`sendTransaction path 账户名 接口名 [参数列表]`
  - 示例：`sendTransaction payment.bcos.HelloWeCross bcos_user1 set Tom`

```bash
# 调用HelloWeCross合约中的set接口
[WeCross]> sendTransaction payment.bcos.HelloWeCross bcos_user1 set Tom
Txhash  : 0x21a412a1eb5239f2da9d40d09d11ce0107a5d82d113f1ecb315f2aa5bd3cc0cd
BlockNum: 2
Result  : [Tom]  // 将Tom给set进去

[WeCross]> call payment.bcos.HelloWeCross bcos_user1 get
Result: [Tom]    // 再次get，Tom已set
```

**操作资源：payment.fabric.abac**

跨链资源是对各个不同链上资源的统一和抽象，因此操作的命令是保持一致的。

- 读资源

```bash
# 调用abac合约中的query接口
[WeCross]> call payment.fabric.abac fabric_user1 query a
Result: [90] // 初次query，a的值为90
```

- 写资源

```bash
# 调用abac合约中的invoke接口
[WeCross]> sendTransaction payment.fabric.abac fabric_user1 invoke a b 10
Txhash  : db44b064c54d4dc97f01cdcd013cae219f7849c329f38ee102853344d8f0004d
BlockNum: 5
Result  : [] 

[WeCross]> call payment.fabric.abac fabric_user1 query a
Result: [80] // 再次query，a的值变成80

# 退出WeCross控制台
[WeCross]> quit # 若想再次启动控制台，cd至WeCross-Console，执行start.sh即可
```

WeCross Console是基于WeCross Java SDK开发的跨链应用。搭建好跨链网络后，可基于WeCross Java SDK开发更多的跨链应用，通过统一的接口对各种链上的资源进行操作。

## 跨链转账

WeCross基于[哈希时间锁合约](../routine/htlc.html)实现了异构链之间资产的原子互换，如下图所示:

![](../images/tutorial/htlc_sample.png)

**配置哈希时间锁合约**

可通过脚本`htlc_config.sh`完成相关配置，并体验跨链转账。

```bash
# 请确保demo已搭建完毕，并在demo根目录执行，耗时5分钟左右
bash htlc_config.sh
```

跨链转账涉及两条链、两个用户、四个账户，两条链上的资产转出者各自通过WeCross控制台创建一个[转账提案](../routine/htlc.html#id4)，之后router会自动完成跨链转账。

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
[WeCross]> newHTLCTransferProposal payment.bcos.htlc bcos_sender bea2dfec011d830a86d0fbeeb383e622b576bb2c15287b1a86aacdba0a387e11 9dda9a5e175a919ee98ff0198927b0a765ef96cf917144b589bb8e510e04843c true 0x55f934bcbe1e9aef8337f5551142a442fdde781c 0x2b5ad5c4795c026514f8317c7a215e218dccd6cf 700 2000010000 Admin@org1.example.com User1@org1.example.com 500 2000000000
# 输出
Txhash: a0c48eb7d1ca3a01ddf3563aeb6a1829f23dd0d778e7de2ce22406d1e84ba00f
BlockNum: 6
Result: create a htlc transfer proposal successfully
# 退出当前控制台
[WeCross]> quit 
```

- Fabric链资产转出者提交提案

BCOS链连的是router-8251，启动与该router连接的控制台。

```bash
cd ~/demo/WeCross-Console-8251
bash start.sh
# 先查看接收方余额
[WeCross]>  call payment.fabric.htlc fabric_admin balanceOf User1@org1.example.com
Result: [0]
# 创建转账提案
[WeCross]> newHTLCTransferProposal payment.fabric.htlc fabric_admin bea2dfec011d830a86d0fbeeb383e622b576bb2c15287b1a86aacdba0a387e11 null false 0x55f934bcbe1e9aef8337f5551142a442fdde781c 0x2b5ad5c4795c026514f8317c7a215e218dccd6cf 700 2000010000 Admin@org1.example.com User1@org1.example.com 500 2000000000
# 输出
Txhash: 0x40ae8e2e284de813f8b071e0261e627ddc4d91e365e63f222638db9b1a70d05a
BlockNum: 7
Result: create a htlc transfer proposal successfully
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

## 清理 Demo

为了不影响[手动组网](./networks.md)章节的体验，可将搭建的Demo清理掉。

``` bash
cd ~/demo/
bash clear.sh
```

至此，恭喜你，快速体验完成！可进入[手动组网](./networks.md)章节深入了解更多细节。

