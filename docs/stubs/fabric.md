# 接入 Fabric 1.4

WeCross Fabric Stub 是 WeCross Router的插件，让Router具备接入Fabric 1.4的链的能力。其要点包括：

* 插件安装
* 接入配置：用于接入相应的Fabric 1.4链
* 账户配置：用于用相应账户发交易

## 插件安装

### 自动安装

在生成router时，默认安装Fabric 1.4插件，安装目录为router下的`plugin`目录：

``` bash
cd ~/wecross/routers-payment/127.0.0.1-8251-25501/
tree plugin/
plugin/
└── fabric1-stub-XXXXX.jar
```

### 手动安装

下载插件

``` bash
git clone https://github.com/WeBankFinTech/WeCross-Fabric1-Stub.git
cd WeCross-Fabric1-Stub
bash gradlew assemble # 在 dist/apps/下生成fabric1-stub-XXXXX.jar
```

安装插件

``` bash
cp dist/apps/fabric1-stub-XXXXX.jar ~/wecross/routers-payment/127.0.0.1-8250-25500/plugin/
```

**注：若router中配置了两个相同的插件，插件冲突，会导致启动失败。**



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



## 接入配置

在router中配置需接入的链，访问链上资源。

### 完整配置

配置完成如下，在`chains`目录中

``` bash
chains							# router的stub的配置目录，所有的stub都在此目录下配置
└── fabric						# 此链的名字，名字可任意指定，与链类型无关
    ├── orderer-tlsca.crt		# orderer证书
    ├── org1-tlsca.crt			# 需要连接的peer的证书1，有则配
    ├── org2-tlsca.crt			# 需要连接的peer的证书2，有则配
    └── stub.toml				# stub配置文件
```

其中，`stub.toml` 为接入的链的配置文件

``` toml
[common]
    name = 'fabric'
    type = 'Fabric1.4'

[fabricServices]
    channelName = 'mychannel'
    orgName = 'Org1'
    mspId = 'Org1MSP'
    orgUserName = 'fabric_admin'
    orgUserAccountPath = 'classpath:accounts/fabric_admin'
    ordererTlsCaFile = 'orderer-tlsca.crt'
    ordererAddress = 'grpcs://localhost:7050'

[peers]
    [peers.org1]
        peerTlsCaFile = 'org1-tlsca.crt'
        peerAddress = 'grpcs://localhost:7051'
    [peers.org2]
         peerTlsCaFile = 'org2-tlsca.crt'
         peerAddress = 'grpcs://localhost:9051'

# resources is a list
[[resources]]
    # name cannot be repeated
    name = 'abac'
    type = 'FABRIC_CONTRACT'
    chainCodeName = 'mycc'
    chainLanguage = "go"
    peers=['org1','org2']
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
# 拷贝 peer.org1 证书
cp ~/demo/fabric/fabric-sample/first-network/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt conf/chains/fabric/org1-tlsca.crt
# 拷贝 peer.org2 证书
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
    orgName = 'Org1'				# 指定一个机构机构名
    mspId = 'Org1MSP'				# 相应的机构MSP ID
    orgUserName = 'fabric_admin'	# 机构的 admin 账户名
    orgUserAccountPath = 'classpath:accounts/fabric_admin'# 账户配置步骤已配置好的admin账户目录
    ordererTlsCaFile = 'orderer-tlsca.crt' # orderer证书名字，指向与此配置文件相同目录下的证书
    ordererAddress = 'grpcs://localhost:7050'	# orderer的url

[peers]	# peers列表
    [peers.org1]
        peerTlsCaFile = 'org1-tlsca.crt'	# peer.org1证书名，指向与此配置文件相同目录下的证书	
        peerAddress = 'grpcs://localhost:7051'						# peer.org1的URL
    [peers.org2]
         peerTlsCaFile = 'org2-tlsca.crt'	# peer.org2证书名，指向与此配置文件相同目录下的证书	
         peerAddress = 'grpcs://localhost:9051'						# peer.org2的URL
```

* 配置跨链资源

``` toml
# resources is a list
[[resources]]
    # name cannot be repeated
    name = 'HelloWeCross'		# 资源名，对应path中的{zone}/{chain}/{resource}中的resource
    type = 'FABRIC_CONTRACT'	# 合约类型，默认即可
    chainCodeName = 'mycc'		# chaincode名字
    chainLanguage = "go"		# chaincode编程语言
    peers=['org1','org2']		# 此chaincode对应的peers列表，在[peers]中需
    
[[resources]]					# 另一个资源的配置
    name = 'HelloWorld'
    type = 'FABRIC_CONTRACT'
    chainCodeName = 'mygg'
    chainLanguage = "go"
    peers=['org1','org2']
```







