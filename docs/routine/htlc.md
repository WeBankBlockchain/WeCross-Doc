# 哈希时间锁定

哈希时间锁合约（hash time lock contract，htlc）能够实现两条异构链之间资产的原子交换。WeCross提供了Solidity版和Golang版版本的htlc基类合约，基于htlc基类合约可以轻松开发适用于不同资产类型的htlc应用合约。本章节以FISCO BCOS的`BAC001`资产和Hyperledger Fabric的`ledgerSample`为例，演示如何实现两条异构链的资产互换。

**注**：Fabric官方暂无资产模型，此处只是一个示例账本。

## 准备工作

要完成资产互换，需要在各自链上部署资产合约以及哈希时间锁合约，然后通过WeCross控制台创建[跨链转账提案](../manual/console.html#newhtlctransferproposal)，router会根据提案信息自动完成跨链转账。

**部署WeCross和控制台**
- 以[组网方式](../tutorial/networks.html)搭建两个router
- 搭建两个WeCross[控制台](../tutorial/networks.html#id5)，分别连接两个router


### FISCO BCOS前期准备

**部署合约**

- 拷贝合约

假设当前位于router的根目录，将`conf/chains-sample/bcos/htlc`目录下的`BAC001.sol`、`HTLC.sol`以及`BACHTLC.sol`文件拷贝至BCOS控制台的`contracts/solidity`目录。

- 部署`BACHTLC.sol`

```bash
[group:1]> deploy BACHTLC
# 合约地址需要记录下来
contract address: 0xc25825d8c0c9819e1302b1cd0019d3228686b2b1
```

**发行资产**

FISCO BCOS提供了标准的资产合约`BAC001`，可借助bac工具完成资产的发行、转账和授权。

```bash
git clone https://github.com/Shareong/bactool.git
cd bactool
gradle build
# 工具包需要和节点通讯，将节点sdk目录下的证书文件ca.crt, sdk.crt, sdk.key拷贝到dist/conf目录，并根据实际情况配置conf目录下的application.xml，账户用默认的pem文件即可。
# 根据金额发行资产，在dist目录下执行
java -cp 'apps/*:lib/*:conf' Application init 100000000
# 输出BAC资产地址，以及资产的拥有者                                                                        
assetAddress: 0x1796f3f195697c38bedaaaa27e424d05f359ca0f
owner: 0x55f934bcbe1e9aef8337f5551142a442fdde781c
```

**资产授权**

要完成跨链转账，资产拥有者需要将资产的转移权授权给哈希时间锁合约。

```bash
# approve [BAC资产地址]，[被授权者地址]（此处为自己的哈希时间锁合约地址），[授权金额]
java -cp 'apps/*:lib/*:conf' Application approve 0x1796f3f195697c38bedaaaa27e424d05f359ca0f 0xc25825d8c0c9819e1302b1cd0019d3228686b2b1 1000000
# 成功输出如下
approve successfully
amount: 1000000
```

**哈希时间锁合约初始化**

需要将资产合约的地址和对手方的哈希时间锁合约地址保存到自己的哈希时间锁合约。

```bash
# 在FISCO BCOS控制台执行，此处约定Fabric的合约名为fabric_htlc，之后将以该名称安装和初始化链码
call BACHTLC 0xc25825d8c0c9819e1302b1cd0019d3228686b2b1 init ["0x1796f3f195697c38bedaaaa27e424d05f359ca0f","fabric_htlc"]

# 查看owner余额，检查是否初始化成功
call BACHTLC 0xc25825d8c0c9819e1302b1cd0019d3228686b2b1 balanceOf ["0x55f934bcbe1e9aef8337f5551142a442fdde781c"]
[100000000]
```

```eval_rst
.. important::
    - 初始化只能进行一次，所以在执行命令前务必确保相关参数都是正确的。
    - 如果初始化时传参有误，只能重新部署哈希时间锁合约，并重新做资产授权。
```

### Fabric前期准备

**拷贝链码**
```bash
# 获取docker容器id
docker ps -a|grep cli
0523418f889d  hyperledger/fabric-tools:latest
# 假设当前位于router根目录, 将链码拷贝到Fabric的chaincode目录下
docker cp conf/chains-sample/fabric/ledger 0523418f889d:/opt/gopath/src/github.com/chaincode/ledger
docker cp conf/chains-sample/fabric/htlc 0523418f889d:/opt/gopath/src/github.com/chaincode/htlc
```

**部署资产合约**
```bash
# 启动容器
docker exec -it cli bash
# 安装链码，-n指定名字，此处命名为ledgerSample
peer chaincode install -n ledgerSample -v 1.0 -p github.com/chaincode/ledger/
# 初始化
peer chaincode instantiate -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n ledgerSample -l golang -v 1.0 -c '{"Args":["init","HTLCoin","htc","100000000"]}' -P 'OR ('\''Org1MSP.peer'\'','\''Org2MSP.peer'\'')'
# 查看账户余额
peer chaincode query -C mychannel -n ledgerSample -c '{"Args":["balanceOf","Admin@org1.example.com"]}'
# 输出应该为100000000
```

**资产授权**
ledgerSample合约通过创建一个托管账户实现资产的授权。

```bash
# 该命令默认使用admin账户发交易，即admin账户完成了一次授权
peer chaincode invoke -C mychannel -n ledgerSample -c '{"Args":["createEscrowAccount","1000000"]}' -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem 
```

**部署哈希时间锁合约**

```bash
# 安装链码，命名为fabric_htlc
peer chaincode install -n fabric_htlc -v 1.0 -p github.com/chaincode/htlc/
# 初始化，需要指定己方资产合约名和对手方的哈希时间锁合约地址
# init [己方资产合约名] [channel] [对手方哈希时间锁合约地址]
peer chaincode instantiate -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n fabric_htlc -l golang -v 1.0 -c '{"Args":["init","ledgerSample","mychannel","0xc25825d8c0c9819e1302b1cd0019d3228686b2b1"]}'

# 查看admin余额，检查是否初始化成功
peer chaincode query -C mychannel -n fabric_htlc -c '{"Args":["balanceOf","Admin@org1.example.com"]}'
# 输出应该为99000000，因为有一部资产已经转到了托管账户。
```

## 哈希时间锁合约配置

**配置FISCO BCOS端router**

在插件配置文件`stub.toml`中配置htlc资源。

```toml
[[resources]]
    # name cannot be repeated
    name = 'htlc'
    type = 'BCOS_CONTRACT' # BCOS_CONTRACT or BCOS_SM_CONTRACT
    contractAddress = '0xc25825d8c0c9819e1302b1cd0019d3228686b2b1'
```

在主配置文件`wecross.toml`中配置htlc任务。

```toml
[[htlc]]
     #本地配置的哈希时间锁资源路径
    selfPath = 'payment.bcos.htlc' 

    #确保已在router的accounts目录配置了bcos_default_account账户    
    account1 = 'bcos_default_account'  

    #对手方的哈希时间锁资源路径
    counterpartyPath = 'payment.fabric.htlc' 

    #确保已在router的accounts目录配置了fabric_default_account账户    
    account2 = 'fabric_default_account'      

```

```eval_rst
.. important::
    - 主配置中的htlc资源路径以及能访问这两个资源的账户请结合实际情况配置。
```

**配置Fabric端router**

在插件配置文件`stub.toml`中配置htlc资源。

```toml
[[resources]]
    # name cannot be repeated
    name = 'htlc'
    type = 'FABRIC_CONTRACT'
    chainCodeName = 'fabric_htlc'
    chainLanguage = "go"
    peers=['org1']
```

在主配置文件`wecross.toml`中配置htlc任务。

```toml
[[htlc]]

     #本地配置的哈希时间锁资源路径
    selfPath = 'payment.fabric.htlc' 

    #确保已在router的accounts目录配置了fabric_default_account账户    
    account1 = 'fabric_default_account'  

    #对手方的哈希时间锁资源路径
    counterpartyPath = 'payment.bcos.htlc' 

    #确保已在router的accounts目录配置了bcos_default_account账户    
    account2 = 'bcos_default_account'     
```

**配置发送者账户**

两个router需要在accounts目录下配置发送者的账户，因为跨链提案只能由资产的转出者创建。

FISCO BCOS用户需要将`bactool/dist/conf`目录下的私钥文件配置到router端的accounts目录，并假设命名为bcos，配置方法详见[BCOS账户配置](../stubs/bcos.html#id4)。

Fabric用户需要将admin账户配置到router端的`accounts`目录，并假设命名为fabric，配置方法详见[Fabric账户配置](../stubs/fabric.html#id3)。

**重启两个router**

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
    - 资产转出者：0x55f934bcbe1e9aef8337f5551142a442fdde781c（和bactool初始化时返回的owner地址保持一致）
    - 资产接收者：0x2b5ad5c4795c026514f8317c7a215e218dccd6cf
- FISCO BCOS转账金额：700
- Fabric的两个账户：
    - 资产转出者：Admin@org1.example.com （admin账户）
    - 资产接收者：User1@org1.example.com
- Fabric转账金额500
- 哈希: 2afe76d15f32c37e9f219ffd0a8fcefc76d850fa9b0e0e603cbd64a2f4aa670d
- 哈希原像: e7d5c31dcc6acae547bb0d84c2af05413994c92599bff89c4abd72866f6ac5c6（协商时只有发起方知道）
- 时间戳t0：发起方的超时时间，单位s
- 时间戳t1： 参与方的超时时间，单位s

```eval_rst
.. note::
    - 哈希原像和哈希可通过控制台命令 `genSecretAndHash <../manual/console.html#gensecretandhash>`_ 生成。
    - 两个时间戳可通过控制台命令 `genTimelock <../manual/console.html#gentimelock>`_ 生成。
    - 时间戳需要满足条件：t0 > t1 + 300 > now + 300
```

**创建跨链转账提案**

两条链的**资产转出者**通过WeCross控制台创建跨链转账提案，将协商的转账信息写入各自的区块链。

- 命令介绍
    - 命令：`newHTLCTransferProposal`
    - 参数：`path`, `account`(资产转出者账户名), `hash`，`secret`， `role`，`sender0`，`receiver0`，`amount0`，`timelock0`，`sender1`，`receiver1`，`amount1`，`timelock1`

- 注意事项
    - 其中下标为0的参数是发起方信息。
    - 发起方`secret`传入哈希原像，`role`传入true；参与方`secret`传入null，`role`传入false。

- 启动控制台

```bash
# 进入控制台dist目录
bash start.sh
```

- 发起方创建转账提案

该步骤由发起方即BCOS链的资产转出者完成。

```bash
newHTLCTransferProposal payment.bcos.htlc bcos edafd70a27887b361174ba5b831777c761eb34ef23ee7343106c0b545ec1052f 049db09dd9cf6fcf69486512c1498a1f6ea11d33b271aaad1893cd590c16542a true 0x55f934bcbe1e9aef8337f5551142a442fdde781c 0x2b5ad5c4795c026514f8317c7a215e218dccd6cf 700 2000010000 Admin@org1.example.com User1@org1.example.com 500 2000000000
```

- 参与方创建转账提案

该步骤由参与方即Fabric链的资产转出者完成。

```bash
newHTLCTransferProposal payment.fabric.htlc fabric edafd70a27887b361174ba5b831777c761eb34ef23ee7343106c0b545ec1052f null false 0x55f934bcbe1e9aef8337f5551142a442fdde781c 0x2b5ad5c4795c026514f8317c7a215e218dccd6cf 700 2000010000 Admin@org1.example.com User1@org1.example.com 500 2000000000
```

**结果确认**

哈希时间锁合约提供了查询余额的接口，可通过WeCross控制台调用，查看两方的接收者是否到账。

- FISCO BCOS用户确认

```bash
[WeCross]> call payment.bcos.htlc bcos balanceOf 0x2b5ad5c4795c026514f8317c7a215e218dccd6cf
Result: [700]
```

- Fabric用户确认
```bash
[WeCross]> call payment.fabric.htlc fabric balanceOf User1@org1.example.com
Result: [500]
```
**注**：跨链转账存在交易时延，取决于两条链以及机器的性能，一般需要5~25s完成转账。
