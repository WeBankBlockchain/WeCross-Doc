# 哈希时间锁定

哈希时间锁合约（hash time lock contract，htlc）能够实现两条异构链之间资产的原子交换。WeCross提供了Solidity版和Golang版版本的htlc基类合约，基于htlc基类合约可以轻松开发适用于不同资产类型的htlc应用合约。本章节以FISCO BCOS的BAC001资产和Hyperledger Fabric的ledgerSample为例，演示如何实现两条异构链的资产互换。

**注**：Hyperledger Fabric官方暂无资产模型，此处只是一个示例账本。

## 准备工作

要完成资产互换，需要在各自链上部署资产合约以及哈希时间锁合约，然后通过WeCross[控制台]()创建跨链转账提案，router会根据提案信息自动完成跨链转账。

* 部署WeCross和控制台
- 以[组网方式]()搭建两个router
- 搭建两个WeCross[控制台]()，分别连接两个router


### FISCO BCOS前期准备

* 部署合约
- 将`conf/stubs-sample/bcos/htlc`目录下的BAC001.sol、HTLC.sol以及BACHTLC.sol文件拷贝至BCOS控制台的`contracts/solidity`

- 部署BACHTLC.sol
```shell
[group:1]> deploy BACHTLC
contract address: 0xc25825d8c0c9819e1302b1cd0019d3228686b2b1
```

* 发行资产

可借助bac工具完成资产的发现和转账授权。

```shell
git clone https://github.com/Shareong/bactool.git
cd bactool
gradle build
# 工具包需要和节点通讯，将ca.crt, sdk.crt, sdk.key 拷贝到dist/conf目录，并根据实际情况配置conf目录下的application.xml，账户用默认的pem文件即可。
# 根据金额发行资产，在dist目录下执行
java -cp 'apps/*:lib/*:conf' Application init 100000000
# 输出BAC资产地址，以及资产的拥有者                                                                        
assetAddress: 0x1796f3f195697c38bedaaaa27e424d05f359ca0f
owner: 0x55f934bcbe1e9aef8337f5551142a442fdde781c
```

* 资产授权
要完成跨链转账，资产拥有者需要将资产的转移权授权给哈希时间锁合约

```shell
# 参数：资产地址，被授权者地址，授权金额
java -cp 'apps/*:lib/*:conf' Application approve 0x1796f3f195697c38bedaaaa27e424d05f359ca0f 0xc25825d8c0c9819e1302b1cd0019d3228686b2b1 1000000
# 成功输出如下
approve successfully
amount: 1000000
```

* 哈希时间锁合约初始化
需要将资产合约的地址和对手方的哈希时间锁合约地址保存到自己的哈希时间锁合约。
```shell
# 在FISCO BCOS控制台执行，此处约定Fabric的合约名为fabric_htlc，之后将以该名称安装和初始化链码
call BACHTLC 0xc25825d8c0c9819e1302b1cd0019d3228686b2b1 init ["0x1796f3f195697c38bedaaaa27e424d05f359ca0f","fabric_htlc"]
```

### Hyperledger Fabric前期准备

* 拷贝链码
```bash
# 获取docker容器id
sudo docker ps -a|grep cli
0523418f889d  hyperledger/fabric-tools:latest
# 假设当前位于router根目录, 将链码拷贝到Fabric的chaincode目录下
 sudo docker cp conf/stubs-sample/fabric/ledger 0523418f889d:/opt/gopath/src/github.com/chaincode/ledger
 sudo docker cp conf/stubs-sample/fabric/htlc 0523418f889d:/opt/gopath/src/github.com/chaincode/htlc
```

* 部署资产合约
```shell
# 启动容器
sudo docker exec -it cli bash
# 安装链码，命名为ledgerSample
peer chaincode install -n ledgerSample -v 1.0 -p github.com/chaincode/ledger/
# 初始化
peer chaincode instantiate -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n ledgerSample -l golang -v 1.0 -c '{"Args":["init","HTLCoin","htc","100000000"]}' -P 'OR ('\''Org1MSP.peer'\'','\''Org2MSP.peer'\'')'
# 查看账户余额
peer chaincode query -C mychannel -n ledgerSample -c '{"Args":["balanceOf","Admin@org1.example.com"]}'
# 输出应该为100000000
```

* 资产授权
ledgerSample合约通过创建一个托管账户实现资产的授权。

```shell
# 该命令默认使用admin账户发交易
peer chaincode invoke -C mychannel -n ledgerSample -c '{"Args":["createEscrowAccount","1000000"]}' -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem 
```

* 部署哈希时间锁合约
```shell
# 安装链码
peer chaincode install -n fabric_htlc -v 1.0 -p github.com/chaincode/htlc/
# 初始化，需要制定对方资产合约名和对手方的哈希时间锁合约地址
peer chaincode instantiate -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n fabric_htlc -l golang -v 1.0 -c '{"Args":["init","ledgerSample","mychannel","0xc25825d8c0c9819e1302b1cd0019d3228686b2b1"]}'
# 查看当前任务
peer chaincode query -C mychannel -n fabric_htlc -c '{"Args":["getTask"]}'
# 输出应该为null
```

### router配置哈希时间锁资源

* 配置FISCO BCOS端router

- 在conf/stubs/bcos/stub.toml文件中配置htlc资源

```toml
[[resources]]
    # name cannot be repeated
    name = 'htlc'
    type = 'BCOS_CONTRACT' # BCOS_CONTRACT or BCOS_SM_CONTRACT
    contractAddress = '0xc25825d8c0c9819e1302b1cd0019d3228686b2b1'
```

- 在conf/wecross.toml文件中配置htlc任务

```toml
[[htlc]]
    selfPath = 'payment.bcos.htlc' #本地配置的哈希时间锁资源路径
    account1 = 'bcos_default_account'   #确保已在router的accounts目录配置了bcos_default_account账户
    counterpartyPath = 'payment.fabric.htlc' #对手方的哈希时间锁资源路径
    account2 = 'fabric_default_account' #确保已在router的accounts目录配置了fabric_default_account账户
```

* 配置Hyperledger Fabric端router

```toml
[[resources]]
    # name cannot be repeated
    name = 'htlc'
    type = 'FABRIC_CONTRACT'
    chainCodeName = 'fabric_htlc'
    chainLanguage = "go"
    peers=['org1']
```

- 在conf/wecross.toml文件中配置htlc任务

```toml
[[htlc]]
    selfPath= 'payment.fabric.htlc' #对手方的哈希时间锁资源路径
    account1 = 'fabric_default_account' #确保已在router的accounts目录配置了fabric_default_account账户
    counterpartyPath = 'payment.bcos.htlc' #本地配置的哈希时间锁资源路径
    account2 = 'bcos_default_account'   #确保已在router的accounts目录配置了bcos_default_account账户
```

* 配置发送者账户

两个router需要在accounts目录下配置发送者的账户，因为跨链提案只能有资金的转出者创建。

FISCO BCOS用户需要将bactool/dist/conf目录下的私钥文件配置到router端的accounts目录，并假设命名为bcos。

Hyperledger Fabric用户需要将admin账户配置到router端的accounts目录，并假设命名为fabric。


* 重启两个router
```shell
bash stop.sh && bash start.sh
```

### 发起跨链转账

假设有一个线下过程，发起方是FISCO BCOS的用户，选择一个secret，计算sha256(secret)得到hash，然后和Hyperledger Fabric的用户协商好各自转账的金额，账户，以及时间戳。

* 协商内容

- FISCO BCOS的两个账户：
    - sender：0x55f934bcbe1e9aef8337f5551142a442fdde781c（和bactool初始化时返回的owner地址保持一致）
    - receiver：0x2b5ad5c4795c026514f8317c7a215e218dccd6cf（receiver随便一个合法地址就行）
- FISCO BCOS转账金额：700
- Hyperledger Fabric的两个账户：
    - sender：Admin@org1.example.com （admin账户名）
    - receiver：User1@org1.example.com
- Hyperledger Fabric转账金额500
- hash: 2afe76d15f32c37e9f219ffd0a8fcefc76d850fa9b0e0e603cbd64a2f4aa670d
- secret: e7d5c31dcc6acae547bb0d84c2af05413994c92599bff89c4abd72866f6ac5c6（协商时只有发起方知道）
- 时间戳t0，发起方的超时时间，单位s
- 时间戳t1, 参与方的超时时间，单位s

**注**：时间戳需要满足条件`t0 > t1 + 300 > now + 300`

* 创建跨链转账提案

通过WeCross控制台创建跨链转账提案，命令为`newHTLCTransferProposal`，参数包括：`path`, `account`（发起方账户名）, `hash`，`secret`, `role`(bool, true代表创建者是发起方)，`sender0`，`receiver0`，`amount0`，`timelock0`，`sender1`，`receiver1`，`amount1`，`timelock1`。

**注**：其中下标为0的参数是发起方信息。

- 启动控制台

```shell
# 进入控制台dist目录
bash start.sh
```

- FISCO BCOS用户（发起方）创建转账提案

```shell
newHTLCTransferProposal payment.bcos.htlc bcos edafd70a27887b361174ba5b831777c761eb34ef23ee7343106c0b545ec1052f 049db09dd9cf6fcf69486512c1498a1f6ea11d33b271aaad1893cd590c16542a true 0x55f934bcbe1e9aef8337f5551142a442fdde781c 0x2b5ad5c4795c026514f8317c7a215e218dccd6cf 700 2000010000 Admin@org1.example.com User1@org1.example.com 500 2000000000
```

- Hyperledger Fabric用户（参与方）创建转账提案

```shell
newHTLCTransferProposal payment.fabric.htlc fabric edafd70a27887b361174ba5b831777c761eb34ef23ee7343106c0b545ec1052f null false 0x55f934bcbe1e9aef8337f5551142a442fdde781c 0x2b5ad5c4795c026514f8317c7a215e218dccd6cf 700 2000010000 Admin@org1.example.com User1@org1.example.com 500 2000000000
```
**注**：参与方`secret`传入null，`tool`传入false。

* 结果确认

哈希时间锁合约提供了查询余额的接口，可通过WeCross控制台调用，查看两方的接收者是否到账。

- FISCO BCOS用户确认

```shell
[WeCross]> call payment.bcos.htlc bcos balanceOf 0x2b5ad5c4795c026514f8317c7a215e218dccd6cf
Result: [700]
```

- Hyperledger Fabric用户确认
```shell
[WeCross]> call payment.fabric.htlc fabric balanceOf User1@org1.example.com
Result: [500]
```
**注**：跨链转账存在交易时延，取决于两条链的性能，一般需要5~25s完成转账。
