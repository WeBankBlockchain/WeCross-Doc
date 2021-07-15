# 接入Hyperledger Fabric 2

[WeCross-Fabric2-Stub](https://github.com/WeBankBlockchain/WeCross-Fabric2-Stub)作为WeCross的插件，让跨链路由具备接入Hyperledger Fabric 2的能力。本章节将介绍如何基于Fabric插件接入Hyperledger Fabric链，内容包括：

* 搭建区块链
* 安装插件
* 配置内置账户
* 配置插件
* 部署系统合约

```eval_rst
.. important::
    - 若还未完成WeCross搭建，请参考 `部署指南 <../tutorial/deploy/index.html>`_
    - 以下教程的目录结构基于 `部署指南 <../tutorial/deploy/index.html>`_ 搭建的WeCross环境作介绍
```

WeCross-Fabric2-Stub源码访问地址：

* [GitHub访问地址](https://github.com/WeBankBlockchain/WeCross-Fabric2-Stub)
* [Gitee访问地址](https://gitee.com/WeBank/WeCross-Fabric2-Stub)

## 1. 搭建区块链

如果已存在Fabric链，不需搭建新链，可跳过本节内容。

为方便Fabric链的搭建，WeCross Demo包中提供了Fabric链搭建脚本。若下载较慢，可选择[更多下载方式](../version/download.html#wecross-demo)。

``` bash
mkdir -p ~/wecross-networks/fabric && cd ~/wecross-networks/fabric

# 下载Demo包
bash <(curl -sL https://github.com/WeBankBlockchain/wecross/releases/download/resources/download_demo.sh)

# 若出现长时间下载Demo包失败，请尝试以下命令重新下载：
bash <(curl -sL https://gitee.com/WeBank/WeCross/raw/master/scripts/download_demo.sh)

# 拷贝其中的Fabric demo链环境
cp ./wecross-demo/fabric2/* ./

# 搭链，若出错，执行 bash clear.sh 后重新 bash build.sh
bash build.sh
```

搭建成功，查看Fabric链各个容器运行状态。

``` bash
docker ps
```

可看到各个容器的状态：

``` bash
CONTAINER ID        IMAGE                                                                                                                                                                   COMMAND                  CREATED              STATUS              PORTS                                            NAMES
22355c5e1cb5        hyperledger/fabric-tools:2.3.0                                                                                                                                          "/bin/bash"              2 minutes ago        Up 2 minutes                                                         cli
43749216ed56        hyperledger/fabric-peer:2.3.0                                                                                                                                           "peer node start"        2 minutes ago        Up 2 minutes        7051/tcp, 0.0.0.0:9051->9051/tcp                 peer0.org2.example.com
5d8e86ea87d2        hyperledger/fabric-orderer:2.3.0                                                                                                                                        "orderer"                2 minutes ago        Up 2 minutes        0.0.0.0:7050->7050/tcp, 0.0.0.0:7053->7053/tcp   orderer.example.com
a510273be2fb        hyperledger/fabric-peer:2.3.0                                                                                                                                           "peer node start"        2 minutes ago        Up 2 minutes        0.0.0.0:7051->7051/tcp                           peer0.org1.example.com
```

## 2. 安装插件

基于[部署指南](../tutorial/deploy/index.html)搭建的WeCross，已完成插件的安装，位于跨链路由的`plugin`目录，可跳过本节内容。

```bash
plugin/
|-- bcos2-stub-gm-xxxx.jar    
|-- bcos2-stub-xxxx.jar  
|-- fabric1-stub-xxxx.jar     
└-- fabric2-stub-xxxx.jar     # Fabric2插件
```

用户如有特殊需求，可以自行编译，替换`plugin`目录下的插件。

### 2.1 下载编译

```shell
git clone https://github.com/WeBankBlockchain/WeCross-Fabric2-Stub.git

# 若因网络原因出现长时间拉取代码失败，请尝试以下命令：
git clone https://gitee.com/WeBank/WeCross-Fabric2-Stub.git

cd WeCross-Fabric2-Stub
bash gradlew assemble # 在 dist/apps/ 下生成 fabric2-stub-XXXXX.jar
```

### 2.2 拷贝安装
在跨链路由的主目录下创建plugin目录，然后将插件拷贝到该目录下完成安装。

``` bash
cp dist/apps/* ~/wecross-networks/routers-payment/127.0.0.1-8251-25501/plugin/
```

**注：若跨链路由中配置了两个相同的插件，插件冲突，会导致跨链路由启动失败。**

## 3. 配置内置账户

在跨链路由中需配置用于与Fabric链进行交互的内置账户。内置账户需配置多个：

- admin账户：必配，一个admin账户，用于接入此Fabric链
- 机构admin账户：选配，每个Fabric的Org配置一个admin账户，用于在每个Org上部署系统合约

### 3.1 生成账户配置框架

```shell
# 切换至对应跨链路由的主目录
cd ~/wecross-networks/routers-payment/127.0.0.1-8251-25501/

# 用脚本生成Fabric账户配置：账户类型（Fabric1.4），账户名（fabric_admin）
# 接入Fabric链，需要配置一个admin账户
bash add_account.sh -t Fabric2.0 -n fabric2_admin 


# 为Fabric链的每个Org都配置一个admin账户，此处有两个org（Org1和Org2），分别配两个账户

# 配Org1的admin
bash add_account.sh -t Fabric2.0 -n fabric2_admin_org1

# 配Org2的admin
bash add_account.sh -t Fabric2.0 -n fabric2_admin_org2
```

### 3.2 完成配置

**修改账户配置**

生成的账户配置，默认的`mspid`为Org1MSP，需将Org2的账户的`mspid`配置为Org2MSP的。此处只需修改fabric2_admin_org2账户的配置。

```shell
vim conf/accounts/fabric2_admin_org2/account.toml

# 修改mspid，将 'Org1MSP' 更改为 'Org2MSP'
```

**拷贝证书文件**

Fabric链的证书位于`organizations`目录，请参考以下命令并**根据实际情况**完成相关证书的拷贝。

```shell
cd ~/wecross-networks/routers-payment/127.0.0.1-8251-25501

# 配置fabric_admin 
# 拷贝私钥
cp xxxxxx/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/*_sk   conf/accounts/fabric2_admin/account.key
# 拷贝证书
cp xxxxxx/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem   conf/accounts/fabric2_admin/account.crt

# 配置fabric_admin_org1 
# 拷贝私钥
cp xxxxxx/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/*_sk   conf/accounts/fabric2_admin_org1/account.key
# 拷贝证书
cp xxxxxx/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem   conf/accounts/fabric2_admin_org1/account.crt

# 配置fabric_admin_org2 
# 拷贝私钥
cp xxxxxx/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/keystore/*_sk   conf/accounts/fabric2_admin_org2/account.key
# 拷贝证书
cp xxxxxx/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/signcerts/Admin@org2.example.com-cert.pem   conf/accounts/fabric2_admin_org2/account.crt
```

完成证书拷贝后，账户目录结构如下：

```shell
tree conf/accounts/
conf/accounts/
├── fabric2_admin
│   ├── account.crt
│   ├── account.key
│   └── account.toml
├── fabric2_admin_org1
│   ├── account.crt
│   ├── account.key
│   └── account.toml
└── fabric2_admin_org2
    ├── account.crt
    ├── account.key
    └── account.toml
```

## 4. 配置插件

### 4.1 生成插件配置框架

进入跨链路由的主目录，用`add_chain.sh`脚本在`conf`目录下生成Fabric链的配置框架。

```shell
cd ~/wecross-networks/routers-payment/127.0.0.1-8251-25501

 # -t 链类型，-n 指定链名字，可根据-h查看使用说明
bash add_chain.sh -t Fabric2.0 -n fabric2
```

执行成功，输出如下。如果执行出错，请查看屏幕打印提示。

```shell
SUCCESS: Chain "fabric2" config framework has been generated to "conf/chains/fabric2"
```

生成的目录结构如下：

```shell
tree conf/chains/fabric2/ -L 2
conf/chains/fabric2/
├── chaincode
│   ├── WeCrossHub   # 桥接合约代码目录
│   └── WeCrossProxy # 代理合约代码目录
└── stub.toml 		 # 插件配置文件
```

### 4.2 完成配置

**拷贝证书**

相关证书同样位于`organizations`目录，请参考以下命令并**根据实际情况**完成相关证书的拷贝。

```shell
# 假设当前位于跨链路由的主目录
# 拷贝orderer证书
cp xxxxxx/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem   conf/chains/fabric2/orderer-tlsca.crt

# 拷贝org1证书
cp xxxxxx/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt   conf/chains/fabric2/org1-tlsca.crt

# 拷贝org2证书
cp xxxxxx/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt   conf/chains/fabric2/org2-tlsca.crt
```

**编辑配置文件**

插件配置文件`stub.toml`配置项包括：

- 配置资源信息
- 配置SDK连接信息，与链进行交互

根据实际情况编辑`[fabricServices]`、`[orgs]`的各个配置项。

```toml
[common]
    name = 'fabric2'				# 指定的连接的链的名字，与该配置文件所在的目录名一致，对应path中的{zone}/{chain}/{resource}的chain
    type = 'Fabric2.0'			# 插件的类型

[fabricServices]
    channelName = 'mychannel'
    orgUserName = 'fabric2_admin' # 指定一个机构的admin账户，用于与orderer通信
    ordererTlsCaFile = 'orderer-tlsca.crt' # orderer证书名字，指向与此配置文件相同目录下的证书
    ordererAddress = 'grpcs://localhost:7050' # orderer的url

[orgs] # 机构节点列表
    [orgs.Org1] # 机构1：Org1
         tlsCaFile = 'org1-tlsca.crt' # Org1的证书
         adminName = 'fabric2_admin_org1' # Org1的admin账户，在下一步骤中配置
         endorsers = ['grpcs://localhost:7051'] # endorser的ip:port列表，可配置多个

    [orgs.Org2] # 机构2：Org2
         tlsCaFile = 'org2-tlsca.crt' # Org2的证书
         adminName = 'fabric2_admin_org2' # Org2的admin账户，在下一步骤中配置
         endorsers = ['grpcs://localhost:9051'] # endorser的ip:port列表，可配置多个
```

## 5. 部署系统合约

每个Stub需要部署两个系统合约，分别是代理合约和桥接合约，代理合约负责管理事务以及业务合约的调用，桥接合约用于记录合约跨链请求。在跨链路由主目录执行以下命令：

```shell
# 部署代理合约
bash deploy_system_contract.sh -t Fabric2.0 -c chains/fabric2 -P

# 部署桥接合约
bash deploy_system_contract.sh -t Fabric2.0 -c chains/fabric2 -H

# 若后续有更新系统合约的需求，首先更新conf/chains/fabric下的系统合约代码，在上述命令添加-u参数，执行并重启跨链路由
```

部署成功，则输出如下内容。若失败可查看提示信息和错误日志。

``` bash 
SUCCESS: WeCrossProxy has been deployed to chains/fabric2
SUCCESS: WeCrossHub has been deployed to chains/fabric2
```

重启跨链路由

``` bash
bash stop.sh
bash start.sh
```



