# 接入Hyperledger Fabric 1.4

[WeCross-Fabric1-Stub](https://github.com/WeBankBlockchain/WeCross-Fabric1-Stub)作为WeCross的插件，让跨链路由具备接入Hyperledger Fabric 1.4的能力。本章节将介绍如何基于Fabric插件接入Hyperledger Fabric链，内容包括：

* 搭建区块链
* 安装插件
* 配置内置账户
* 配置插件
* 部署系统合约

```eval_rst
.. important::
    - 目前支持的Fabric链版本为1.4
    - 若还未完成WeCross搭建，请参考 `部署指南 <../tutorial/deploy/index.html>`_
    - 以下教程的目录结构基于 `部署指南 <../tutorial/deploy/index.html>`_ 搭建的WeCross环境作介绍
```

## 搭建区块链

如果已存在Fabric链，不需搭建新链，可跳过本节内容。

为方便Fabric链的搭建，WeCross Demo包中提供了Fabric链搭建脚本。若下载较慢，可选择[更多下载方式](../version/download.html#wecross-demo)。

``` bash
mkdir -p ~/wecross-networks/fabric && cd ~/wecross-networks/fabric

# 下载Demo包, 拷贝其中的Fabric demo链环境
bash <(curl -sL https://github.com/WeBankBlockchain/wecross-networks/releases/download/resources/download_demo.sh)
cp wecross-demo/fabric/* ./

# 搭建
bash build.sh # 若出错，执行 bash clear.sh 后重新 bash build.sh
```

搭建成功，查看Fabric链各个容器运行状态。

``` bash
docker ps
```

可看到各个容器的状态：

``` bash
CONTAINER ID        IMAGE                               COMMAND             CREATED             STATUS              PORTS                      NAMES
11c7358b5f59        hyperledger/fabric-tools:latest     "/bin/bash"         2 minutes ago       Up 2 minutes                                   cli
63bb98e16c20        hyperledger/fabric-peer:latest      "peer node start"   2 minutes ago       Up 2 minutes        0.0.0.0:10051->10051/tcp   peer1.org2.example.com
823f2c4034b7        hyperledger/fabric-peer:latest      "peer node start"   2 minutes ago       Up 2 minutes        0.0.0.0:8051->8051/tcp     peer1.org1.example.com
1468956a60c6        hyperledger/fabric-peer:latest      "peer node start"   2 minutes ago       Up 2 minutes        0.0.0.0:9051->9051/tcp     peer0.org2.example.com
1b3f50ed07ad        hyperledger/fabric-orderer:latest   "orderer"           2 minutes ago       Up 2 minutes        0.0.0.0:7050->7050/tcp     orderer.example.com
18747185608f        hyperledger/fabric-peer:latest      "peer node start"   2 minutes ago       Up 2 minutes        0.0.0.0:7051->7051/tcp     peer0.org1.example.com
```

## 安装插件

基于[部署指南](../tutorial/deploy/index.html)搭建的WeCross，已完成插件的安装，位于跨链路由的`plugin`目录，可跳过本节内容。

```bash
plugin/
|-- bcos2-stub-gm-xxxx.jar    
|-- bcos2-stub-xxxx.jar      
└-- fabric1-stub-xxxx.jar     # Fabric插件
```

用户如有特殊需求，可以自行编译，替换`plugin`目录下的插件。

### 下载编译

```shell
git clone https://github.com/WeBankBlockchain/WeCross-Fabric1-Stub.git
cd WeCross-Fabric1-Stub
bash gradlew assemble # 在 dist/apps/ 下生成 fabric1-stub-XXXXX.jar
```

### 拷贝安装
在跨链路由的主目录下创建plugin目录，然后将插件拷贝到该目录下完成安装。

``` bash
cp dist/apps/* ~/wecross-networks/routers-payment/127.0.0.1-8251-25501/plugin/
```

**注：若跨链路由中配置了两个相同的插件，插件冲突，会导致跨链路由启动失败。**

## 配置内置账户

在跨链路由中需配置用于与Fabric链进行交互的内置账户。内置账户需配置多个：

- admin账户：必配，一个admin账户，用于接入此Fabric链
- 机构admin账户：选配，每个Fabric的Org配置一个admin账户，用于在每个Org上部署系统合约

### 生成账户配置框架

```shell
# 切换至对应跨链路由的主目录
cd ~/wecross-networks/routers-payment/127.0.0.1-8251-25501/

# 用脚本生成Fabric账户配置：账户类型（Fabric1.4），账户名（fabric_admin）
# 接入Fabric链，需要配置一个admin账户
bash add_account.sh -t Fabric1.4 -n fabric_admin 


# 为Fabric链的每个Org都配置一个admin账户，此处有两个org（Org1和Org2），分别配两个账户

# 配Org1的admin
bash add_account.sh -t Fabric1.4 -n fabric_admin_org1

# 配Org2的admin
bash add_account.sh -t Fabric1.4 -n fabric_admin_org2
```

### 完成配置

**修改账户配置**

生成的账户配置，默认的`mspid`为Org1MSP，需将Org2的账户的`mspid`配置为Org2MSP的。此处只需修改fabric_admin_org2账户的配置。

```shell
vim conf/accounts/fabric_admin_org2/account.toml

# 修改mspid，将 'Org1MSP' 更改为 'Org2MSP'
```

**拷贝证书文件**

Fabric链的证书位于`crypto-config`目录，请参考以下命令并**根据实际情况**完成相关证书的拷贝。

```shell
# 假设当前位于跨链路由的主目录
# 配置fabric_admin 
# 拷贝私钥
cp xxxxxx/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/*_sk   conf/accounts/fabric_admin/account.key
# 拷贝证书
cp xxxxxx/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem   conf/accounts/fabric_admin/account.crt

# 配置fabric_admin_org1 
# 拷贝私钥
cp xxxxxx/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/*_sk   conf/accounts/fabric_admin_org1/account.key
# 拷贝证书
cp xxxxxx/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem   conf/accounts/fabric_admin_org1/account.crt


# 配置fabric_admin_org2 
# 拷贝私钥
cp xxxxxx/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/keystore/*_sk   conf/accounts/fabric_admin_org2/account.key
# 拷贝证书
cp xxxxxx/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/signcerts/Admin@org2.example.com-cert.pem   conf/accounts/fabric_admin_org2/account.crt
```

完成证书拷贝后，账户目录结构如下：

```shell
tree conf/accounts/
conf/accounts/
├── fabric_admin
│   ├── account.crt
│   ├── account.key
│   └── account.toml
├── fabric_admin_org1
│   ├── account.crt
│   ├── account.key
│   └── account.toml
└── fabric_admin_org2
    ├── account.crt
    ├── account.key
    └── account.toml
```

## 配置插件

### 生成插件配置框架

进入跨链路由的主目录，用`add_chain.sh`脚本在`conf`目录下生成Fabric链的配置框架。

```shell
cd ~/wecross-networks/routers-payment/127.0.0.1-8251-25501

 # -t 链类型，-n 指定链名字，可根据-h查看使用说明
bash add_chain.sh -t Fabric1.4 -n fabric
```

执行成功，输出如下。如果执行出错，请查看屏幕打印提示。

```shell
SUCCESS: Chain "fabric" config framework has been generated to "conf/chains/fabric"
```

生成的目录结构如下：

```shell
tree conf/chains/fabric/
conf/chains/fabric/
├── chaincode
│   ├── WeCrossHub
│   │   └── hub.go    # 桥接合约
│   └── WeCrossProxy
│       └── proxy.go  # 代理合约
└── stub.toml         # 插件配置文件
```

### 完成配置

**拷贝证书**

相关证书同样位于`crypto-config`目录，请参考以下命令并**根据实际情况**完成相关证书的拷贝。

```shell
# 假设当前位于跨链路由的主目录
# 拷贝orderer证书
cp xxxxxx/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem   conf/chains/fabric/orderer-tlsca.crt

# 拷贝org1证书
cp xxxxxx/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt   conf/chains/fabric/org1-tlsca.crt

# 拷贝org2证书
cp xxxxxx/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt   conf/chains/fabric/org2-tlsca.crt
```

**编辑配置文件**

插件配置文件`stub.toml`配置项包括：

- 配置资源信息
- 配置SDK连接信息，与链进行交互

根据实际情况编辑`[fabricServices]`、`[orgs]`的各个配置项。

```toml
[common]
    name = 'fabric'				# 指定的连接的链的名字，与该配置文件所在的目录名一致，对应path中的{zone}/{chain}/{resource}的chain
    type = 'Fabric1.4'			# 插件的类型

[fabricServices]
    channelName = 'mychannel'
    orgUserName = 'fabric_admin' # 指定一个机构的admin账户，用于与orderer通信
    ordererTlsCaFile = 'orderer-tlsca.crt' # orderer证书名字，指向与此配置文件相同目录下的证书
    ordererAddress = 'grpcs://localhost:7050' # orderer的url

[orgs] # 机构节点列表
    [orgs.Org1] # 机构1：Org1
         tlsCaFile = 'org1-tlsca.crt' # Org1的证书
         adminName = 'fabric_admin_org1' # Org1的admin账户，在下一步骤中配置
         endorsers = ['grpcs://localhost:7051'] # endorser的ip:port列表，可配置多个

    [orgs.Org2] # 机构2：Org2
         tlsCaFile = 'org2-tlsca.crt' # Org2的证书
         adminName = 'fabric_admin_org2' # Org2的admin账户，在下一步骤中配置
         endorsers = ['grpcs://localhost:9051'] # endorser的ip:port列表，可配置多个
```

## 部署系统合约

每个Stub需要部署两个系统合约，分别是代理合约和桥接合约，代理合约负责管理事务以及业务合约的调用，桥接合约用于记录合约跨链请求。在跨链路由主目录执行以下命令：

```shell
# 部署代理合约
bash deploy_system_contract.sh -t Fabric1.4 -c chains/fabric -P

# 部署桥接合约
bash deploy_system_contract.sh -t Fabric1.4 -c chains/fabric -H

# 若后续有更新系统合约的需求，首先更新conf/chains/fabric下的系统合约代码，在上述命令添加-u参数，执行并重启跨链路由
```

部署成功，则输出如下内容。若失败可查看提示信息和错误日志。

``` bash 
SUCCESS: WeCrossProxy has been deployed to chains/fabric
SUCCESS: WeCrossHub has been deployed to chains/fabric
```
