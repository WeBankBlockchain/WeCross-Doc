# 接入Hyperledger Fabric 1.4

[WeCross-Fabric1-Stub](https://github.com/WeBankBlockchain/WeCross-Fabric1-Stub)作为WeCross的插件，让跨链路由具备接入Hyperledger Fabric 1.4的能力。关于该插件，本章将介绍以下内容：

* 插件安装
* 插件配置
* 系统合约

## 插件安装

在生成router时，默认安装Fabric 1.4插件，安装目录为router下的`plugin`目录：

``` bash
# 以demo为例
cd ~/wecross/routers-payment/127.0.0.1-8251-25501/
tree plugin/
plugin/
└── fabric1-stub-XXXXX.jar
```

用户如有特殊需求，可以自行编译，替换`plugin`目录下的插件。

### 手动安装

**下载编译**

``` bashWeBankBlockchain
git clone https://github.com/WeBankBlockchain/WeCross-Fabric1-Stub.git
cd WeCross-Fabric1-Stub
bash gradlew assemble # 在 dist/apps/下生成fabric1-stub-XXXXX.jar
```

**安装插件**
在跨链路由的主目录下创建plugin目录，然后将插件拷贝到该目录下。

``` bash
# 以demo为例
cp dist/apps/fabric1-stub-XXXXX.jar ~/wecross/routers-payment/127.0.0.1-8250-25500/plugin/
```

**注：若跨链路由中配置了两个相同的插件，插件冲突，会导致跨链路由启动失败。**

## 接入链配置

在跨链路由主目录的`conf/chains/[stubName]/`目录下创建插件的配置文件`stub.toml`。配置信息包括：

- 配置资源信息
- 配置SDK连接信息，与链进行交互

配置完成后的目录结构如下：
``` bash
chains							# 跨链路由的stub的配置目录，所有的stub都在此目录下配置
└── [stubName]			        # 此链的名字，名字可任意指定，与链类型无关
    ├── orderer-tlsca.crt		# orderer证书
    ├── org1-tlsca.crt			# 需要连接Org1的endorser的证书1，有则配
    ├── org2-tlsca.crt			# 需要连接Org2的endorser的证书2，有则配
    └── stub.toml				# stub配置文件
```

### 配置步骤

**拷贝链证书**

以[demo](../tutorial/demo/demo_cross_all.html)为例，在跨链路由的主目录`~/wecross-demo/routers-payment/127.0.0.1-8251-25501`执行下列命令

``` bash
# 拷贝 orderer证书
cp ~/wecross-demo/fabric/fabric-sample/first-network/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem conf/chains/fabric/orderer-tlsca.crt
# 拷贝 Org1 证书
cp ~/wecross-demo/fabric/fabric-sample/first-network/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt conf/chains/fabric/org1-tlsca.crt
# 拷贝 Org2 证书
cp ~/wecross-demo/fabric/fabric-sample/first-network/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt conf/chains/fabric/org2-tlsca.crt
```

**编辑配置文件**

``` bash
vim conf/chains/fabric/stub.toml
```

* 基础配置

``` toml
[common]
    name = 'fabric'				# 指定的连接的链的名字，与该配置文件所在的目录名一致，对应path中的{zone}/{chain}/{resource}的chain
    type = 'Fabric1.4'			# 插件的类型
```

* 配置链

``` toml
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

## 系统合约

每个Stub需要部署两个系统合约，分别是代理合约和桥接合约，代理合约负责管理事务以及业务合约的调用，桥接合约用于记录合约跨链请求。

配置完成后，需要在跨链路由主目录执行以下命令，以安装系统合约。

**部署代理合约**
``` bash
java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.fabric.proxy.ProxyChaincodeDeployment deploy chains/fabric
```

部署成功

``` bash
SUCCESS: WeCrossProxy has been deployed to chains/fabric
```

**部署桥接合约**

``` bash
java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.fabric.hub.HubChaincodeDeployment deploy chains/fabric
```

部署成功

``` bash
SUCCESS: WeCrossHub has been deployed to chains/fabric
```

代理合约部署完成后，即可启动跨链路由，接入链配置完成

## 部署跨链资源

用户可通过WeCross控制台部署和升级链码，相关操作见控制台说明部分：

* [fabricInstall](../manual/console.html#fabricinstall)
* [fabricInstantiate](../manual/console.html#fabricinstantiate)
* [fabricUpgrade](../manual/console.html#fabricupgrade)









