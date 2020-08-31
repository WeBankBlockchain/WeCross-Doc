# 接入 Fabric 1.4

WeCross Fabric Stub 是 WeCross Router的插件，让Router具备接入Fabric 1.4的链的能力。其要点包括：

* 插件安装
* 接入配置：用于接入相应的Fabric 1.4链
* 账户配置：用于用相应账户发交易

## 插件安装

在生成router时，默认安装Fabric 1.4插件，安装目录为router下的`plugin`目录：

``` bash
cd ~/wecross/routers-payment/127.0.0.1-8251-25501/
tree plugin/
plugin/
└── fabric1-stub-XXXXX.jar
```

用户如有特殊需求，可以自行编译，替换`plugin`目录下的插件。

### 手动安装

**下载编译**

``` bash
git clone https://github.com/WeBankFinTech/WeCross-Fabric1-Stub.git
cd WeCross-Fabric1-Stub
bash gradlew assemble # 在 dist/apps/下生成fabric1-stub-XXXXX.jar
```

**安装插件**

``` bash
cp dist/apps/fabric1-stub-XXXXX.jar ~/wecross/routers-payment/127.0.0.1-8250-25500/plugin/
```

**注：若router中配置了两个相同的插件，插件冲突，会导致router启动失败。**



## 账户配置

在router中配置Fabric账户，用户可在sdk中指定router用相应的账号发交易。

### 完整配置

配置完成的账户如下，在`accounts`目录中

``` bash
accounts/						# router的账户目录，所有账户的文件夹放在此目录下
└── fabric_admin       			# 目录名即为此账户名，SDK发交易时，指定的即为处的账户名
    ├── account.toml			# 账户配置文件
    ├── user.crt				# Fabric的用户证书
    └── user.key				# Fabric的用户私钥
```

其中 `account.toml `为账户配置文件

``` toml
[account]
    type = 'Fabric1.4'			# 采用插件的名字
    mspid = 'Org1MSP'			# 账户对应机构的MSP ID
    keystore = 'user.key'		# 账户私钥文件名字，指向与此文件相同目录下的私钥文件
    signcert = 'user.crt'		# 账户证书名字，指向与此文件相同目录下的证书文件
```

### 配置步骤

**生成配置文件**

为router生成某个账户的配置，在router目录下执行

``` bash
cd ~/wecross/routers-payment/127.0.0.1-8251-25501/

# 举例1：生成名字为fabric_admin的账户配置 -t 指定使用Fabric1.4插件生成 -n 设置一个账户名
bash add_account.sh -t Fabric1.4 -n fabric_admin

# 举例2：生成名字为fabric_user1的账户配置 -t 指定使用Fabric1.4插件生成 -n 设置一个账户名
bash add_account.sh -t Fabric1.4 -n fabric_user1 
```

生成后，`conf/accounts`目录下出现对应名字的账户目录，接下来需将相关账户文件拷贝入目录中。

**拷贝账户文件**

以`fabric-sample/first-network`的`crypto-config`为例，配置其中一个账户即可

* 若配置 Org1 的 Admin

``` bash
# 拷贝用户私钥，命名为 user.key
cp ~/demo/fabric/fabric-sample/first-network/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/*_sk accounts/fabric_admin/user.key
# 拷贝用户证书，命名为 user.crt
cp ~/demo/fabric/fabric-sample/first-network/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/*.pem accounts/fabric_admin/user.crt 
```

* 若配置 Org1的 User1

``` bash
# 拷贝用户私钥，命名为 user.key
cp ~/demo/fabric/fabric-sample/first-network/crypto-config/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp/keystore/*_sk accounts/fabric_user1/user.key 
# 拷贝用户证书，命名为 user.crt
cp ~/demo/fabric/fabric-sample/first-network/crypto-config/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp/signcerts/*.pem accounts/fabric_user1/user.crt 
```

**编辑配置文件**

编辑 `account.toml`

``` bash
vim conf/accounts/<account_name>/account.toml
```

内容为

``` bash
[account]
    type = 'Fabric1.4'			# 采用插件的名字
    mspid = 'Org1MSP'			# 账户对应机构的MSP ID
    keystore = 'user.key'		# 账户私钥文件名字，指向与此文件相同目录下的私钥文件
    signcert = 'user.crt'		# 账户证书名字，指向与此文件相同目录下的证书文件
```

## 接入链配置

在router中配置需接入的链，访问链上资源。

### 完整配置

配置完成如下，在`chains`目录中

``` bash
chains							# router的stub的配置目录，所有的stub都在此目录下配置
└── fabric						# 此链的名字，名字可任意指定，与链类型无关
    ├── orderer-tlsca.crt		# orderer证书
    ├── org1-tlsca.crt			# 需要连接Org1的endorser的证书1，有则配
    ├── org2-tlsca.crt			# 需要连接Org2的endorser的证书2，有则配
    └── stub.toml				# stub配置文件
```

其中，`stub.toml` 为接入的链的配置文件

``` toml
[common]
    name = 'fabric'
    type = 'Fabric1.4'

[fabricServices]
    channelName = 'mychannel'
    orgUserName = 'fabric_admin'
    ordererTlsCaFile = 'orderer-tlsca.crt'
    ordererAddress = 'grpcs://localhost:7050'

[orgs]
    [orgs.Org1]
        tlsCaFile = 'org1-tlsca.crt'
        adminName = 'fabric_admin_org1'
        endorsers = ['grpcs://localhost:7051']

    [orgs.Org2]
        tlsCaFile = 'org2-tlsca.crt'
        adminName = 'fabric_admin_org2'
        endorsers = ['grpcs://localhost:9051']
```

### 配置步骤

**生成配置文件**

``` bash
cd ~/wecross/routers-payment/127.0.0.1-8251-25501
bash add_chain.sh -t Fabric1.4 -n fabric # -t 链类型，-n 指定链名字

# 查看生成目录
tree conf/chains/fabric
```

生成的目录结构如下：

```bash
conf/chains/fabric
└── stub.toml          # chain配置文件
```

**拷贝链证书**

以`fabric-sample/first-network`的`crypto-config`为例

``` bash
# 拷贝 orderer证书
cp ~/demo/fabric/fabric-sample/first-network/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem conf/chains/fabric/orderer-tlsca.crt
# 拷贝 Org1 证书
cp ~/demo/fabric/fabric-sample/first-network/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt conf/chains/fabric/org1-tlsca.crt
# 拷贝 Org2 证书
cp ~/demo/fabric/fabric-sample/first-network/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt conf/chains/fabric/org2-tlsca.crt
```

**编辑配置文件**

``` bash
vim conf/chains/fabric/stub.toml
```

* 基础配置

``` toml
[common]
    name = 'fabric'				# 指定的连接的链的名字，对应path中的{zone}/{chain}/{resource}的chain
    type = 'Fabric1.4'			# 采用插件的名字
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

**配相关账户**

`stub.toml`中涉及三个账户，采用账户配置给出的步骤配置入conf/accounts目录即可：

* fabric_admin：fabricServices的admin账户，用于与orderer通信，此处选择一个Org的admin账户作为此账户即可
* fabric_admin_org1：与Org1的endorser通信的账户，需配置Org1的admin
* fabric_admin_org2：与Org2的endorser通信的账户，需配置Org2的admin，**注意生成账户后需手动将默认的mspid改为 Org2MSP**

**部署代理合约**

配置完成后，在router目录下执行命令，部署代理合约

``` bash
java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.fabric.proxy.ProxyChaincodeDeployment deploy chains/fabric # deploy conf下的链配置位置
```

部署成功

``` bash
SUCCESS: WeCrossProxy has been deployed to chains/fabric
```

代理合约部署完成后，即可启动router，接入链配置完成

## 部署跨链资源

用户可通过WeCross控制台部署和升级链码，相关操作见控制台说明部分：

* [fabricInstall](../manual/console.html#fabricInstall)
* [fabricInstantiate](../manual/console.html#fabricInstantiate)
* [fabricUpgrade](../manual/console.html#fabricUpgrade)









