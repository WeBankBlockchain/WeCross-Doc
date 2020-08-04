# 手动组网

本文档介绍以手动的方式，一步步搭建一个与[Demo](./demo/demo.md)相同的跨链网络。

![](../images/tutorial/demo.png)

## 快速部署

本章指导完成[**跨链路由**](../introduction/introduction.html#id2)和[**跨链控制台**](../manual/console.md)的部署。

* **跨链路由**：与区块链节点对接，并彼此互连，形成[跨链分区](../introduction/introduction.html#id2)，负责跨链请求的转发
* **跨链控制台**：查询和发送交易的操作终端

![](../images/tutorial/routers.png)

操作以`~/wecross/`目录下为例进行。若Demo未清理，请先[清理Demo环境](../demo.html#id4)。

``` bash
mkdir -p ~/wecross/ && cd ~/wecross/
```

### 部署 WeCross Router

下载WeCross，用WeCross中的工具生成跨链路由，并启动跨链路由。

#### 下载WeCross

WeCross中包含了生成跨链路由的工具，执行以下命令进行下载（提供[三种下载方式](../version/download.html#wecross)，可根据网络环境选择合适的方式进行下载），程序下载至当前目录`WeCross/`中。

```bash
bash <(curl -sL https://github.com/WeBankFinTech/WeCross/releases/download/resources/download_wecross.sh)
```

#### 生成跨链路由

本例将构建两个跨链路由。首先创建一个`ipfile`配置文件，将需要构建的两个跨链路由信息（`ip:rpc_port:p2p_port`）按行分隔，保存到文件中。

**注**：请确保机器的`8250`，`8251`, `25500`，`25501`端口没有被占用。

```bash
cd ~/wecross
vim ipfile

# 在文件中键入以下内容
127.0.0.1:8250:25500
127.0.0.1:8251:25501
```

生成好`ipfile`文件后，使用脚本[build_wecross.sh](../manual/scripts.html#wecross)生成两个跨链路由。

```bash
# -f 表示以文件为输入
bash ./WeCross/build_wecross.sh -n payment -o routers-payment -f ipfile

# 成功输出如下信息
[INFO] Create routers-payment/127.0.0.1-8250-25500 successfully
[INFO] Create routers-payment/127.0.0.1-8251-25501 successfully
[INFO] All completed. WeCross routers are generated in: routers-payment/
```

```eval_rst
.. note::
    - -n 指定跨链分区标识符(zone id)，跨链分区通过zone id进行区分，可以理解为业务名称。
    - -o 指定输出的目录，并在该目录下生成一个跨链路由。
    - -f 指定需要生成的WeCross跨链路由的列表，包括ip地址，rpc端口，p2p端口，生成后的router已完成互联配置。
```

在routers-payment目录下生成了两个跨链路由。

``` bash
tree routers-payment/ -L 1
routers-payment/
├── 127.0.0.1-8251-25501
├── 127.0.0.1-8252-25502
└── cert
```

生成的跨链路由目录内容如下，以`127.0.0.1-8250-25500`为例。

```bash
# 已屏蔽lib目录，该目录存放所有依赖的jar包
tree routers-payment/127.0.0.1-8250-25500/ -I "lib"
routers-payment/127.0.0.1-8250-25500/
├── add_account.sh    # 账户生成脚本
├── add_chain.sh      # 区块链配置文件创建脚本
├── apps
│   └── WeCross.jar   # WeCross路由jar包
├── build_wecross.sh
├── conf              # 配置文件目录
│   ├── accounts      # 账户配置目录
│   ├── application.properties 
│   ├── chains        # 区块链配置目录，要接入不同的链，在此目录下进行配置
│   ├── log4j2.xml    
│   ├── ca.crt        # 根证书
│   ├── ssl.crt       # 跨链路由证书
│   ├── ssl.key       # 跨链路由私钥
│   ├── node.nodeid   # 跨链路由nodeid
│   └── wecross.toml  # WeCross Router主配置文件
├── create_cert.sh    # 证书生成脚本
├── download_wecross.sh
├── plugin            # 插件目录，接入相应类型链的插件
│   ├── bcos-stub-gm.jar
│   ├── bcos-stub.jar
│   └── fabric-stub.jar
├── start.sh          # 启动脚本
└── stop.sh           # 停止脚本
```

#### 启动跨链路由

```bash
# 启动 router-8250
cd ~/wecross/routers-payment/127.0.0.1-8250-25500/
bash start.sh   # 停止: bash stop.sh

# 启动 router-8251
cd ~/wecross/routers-payment/127.0.0.1-8251-25501/
bash start.sh   # 停止: bash stop.sh
```

启动成功，输出如下：

```
WeCross booting up .........
WeCross start successfully
```

如果启动失败，检查`8250, 25500`端口是否被占用。

``` bash
netstat -napl | grep 8250
netstat -napl | grep 25500
netstat -napl | grep 8251
netstat -napl | grep 25501
```

## 接入区块链

完成了WeCross的部署，如何让它和一条真实的区块链交互，相信优秀的您一定在跃跃欲试。本节包括

* 接入BCOS链：在router-8250上接入，配置交易发送账户
* 接入Fabric链：在router-8251上接入，配置交易发送账户

![](../images/tutorial/demo.png)

### 搭建区块链

在接入区块链前，先给出BCOS和Fabric链的搭建过程。

#### 搭建BCOS链

FISCO BCOS官方提供了一键搭链的教程，详见[单群组FISCO BCOS联盟链的搭建](https://fisco-bcos-documentation.readthedocs.io/zh_CN/latest/docs/installation.html)

详细步骤如下：

- 脚本建链

```bash
# 创建操作目录
mkdir -p ~/wecross/bcos && cd ~/wecross/bcos

# 下载build_chain.sh脚本
curl -LO https://github.com/FISCO-BCOS/FISCO-BCOS/releases/download/v2.5.0/build_chain.sh && chmod u+x build_chain.sh

# 搭建单群组4节点联盟链
# 在fisco目录下执行下面的指令，生成一条单群组4节点的FISCO链。请确保机器的30300~30303，20200~20203，8545~8548端口没有被占用。
# 命令执行成功会输出All completed。如果执行出错，请检查nodes/build.log文件中的错误信息。
bash build_chain.sh -l "127.0.0.1:4" -p 30300,20200,8545
```

- 启动所有节点

```bash
bash nodes/127.0.0.1/start_all.sh
```

启动成功会输出类似下面内容的响应。否则请使用`netstat -an | grep tcp`检查机器的`30300~30303，20200~20203，8545~8548`端口是否被占用。

```bash
try to start node0
try to start node1
try to start node2
try to start node3
node1 start successfully
node2 start successfully
node0 start successfully
node3 start successfully
```

#### 搭建Fabric链

为方便Fabric链的搭建，WeCross Demo包中提供了Fabric链搭建脚本。若下载较慢，可选择[更多下载方式](../version/download.html#wecross-demo)。

``` bash
mkdir -p ~/wecross/fabric && cd ~/wecross/fabric

# 下载Demo包, 拷贝其中的Fabric demo链环境
bash <(curl -sL https://github.com/WeBankFinTech/WeCross/releases/download/resources/download_demo.sh)
cp demo/fabric/* ./

# 搭建
bash build.sh # 若出错，执行 bash clear.sh 后重新 bash build.sh
```

搭建成功，查看Fabric链各个容器运行状态。

``` bash
docker ps
```

可看到各个容器的状态：

``` bash
CONTAINER ID        IMAGE                                                                                                  COMMAND                  CREATED             STATUS              PORTS                      NAMES
3b55f9681227        dev-peer1.org2.example.com-mycc-1.0-26c2ef32838554aac4f7ad6f100aca865e87959c9a126e86d764c8d01f8346ab   "chaincode -peer.add…"   13 minutes ago      Up 13 minutes                                  dev-peer1.org2.example.com-mycc-1.0
2d8d660c9481        dev-peer0.org1.example.com-mycc-1.0-384f11f484b9302df90b453200cfb25174305fce8f53f4e94d45ee3b6cab0ce9   "chaincode -peer.add…"   13 minutes ago      Up 13 minutes                                  dev-peer0.org1.example.com-mycc-1.0
b82b0b8dcc0f        dev-peer0.org2.example.com-mycc-1.0-15b571b3ce849066b7ec74497da3b27e54e0df1345daff3951b94245ce09c42b   "chaincode -peer.add…"   14 minutes ago      Up 14 minutes                                  dev-peer0.org2.example.com-mycc-1.0
441ca8a493fc        hyperledger/fabric-tools:latest                                                                        "/bin/bash"              14 minutes ago      Up 14 minutes                                  cli
de0d32730926        hyperledger/fabric-peer:latest                                                                         "peer node start"        14 minutes ago      Up 14 minutes       0.0.0.0:9051->9051/tcp     peer0.org2.example.com
ad98565bfa57        hyperledger/fabric-peer:latest                                                                         "peer node start"        14 minutes ago      Up 14 minutes       0.0.0.0:10051->10051/tcp   peer1.org2.example.com
bf0d9b0c54bf        hyperledger/fabric-peer:latest                                                                         "peer node start"        14 minutes ago      Up 14 minutes       0.0.0.0:8051->8051/tcp     peer1.org1.example.com
b4118a65f01a        hyperledger/fabric-orderer:latest                                                                      "orderer"                14 minutes ago      Up 14 minutes       0.0.0.0:7050->7050/tcp     orderer.example.com
fcf1bfe17dbe        hyperledger/fabric-peer:latest                                                                         "peer node start"        14 minutes ago      Up 14 minutes       0.0.0.0:7051->7051/tcp     peer0.org1.example.com
```

### 接入FISCO BCOS链

#### 添加账户

在router中添加用于向链上发交易的账户。账户配置好后，可通过跨链网络向相应的链发交易，交易可被router转发至对应的链上。

**添加BCOS账户**

所配置的账户可用于向`BCOS2.0`类型的链发交易。

```shell
# 切换至对应router的目录下
cd ~/wecross/routers-payment/127.0.0.1-8250-25500/

# 用脚本生成BCOS账户：账户类型（BCOS2.0），账户名（bcos_user1）
bash add_account.sh -t BCOS2.0 -n bcos_user1 
```

生成的bcos_user1文件目录如下：

``` bash
tree conf/accounts/bcos_user1/
conf/accounts/bcos_user1/
├── account.key
└── account.toml
```

**添加Fabric账户**

所配置的账户可用于向`Fabric1.4`类型的链发交易。

``` bash
# 用脚本生成Fabric账户：账户类型（Fabric1.4），账户名（fabric_user1）
bash add_account.sh -t Fabric1.4 -n fabric_user1
cp ~/wecross/fabric/certs/accounts/fabric_user1/* conf/accounts/fabric_user1/  # 拷贝 Fabric链的证书，具体说明请参考《跨链接入》章节
```

生成的fabric_user1文件目录如下：

``` bash
tree conf/accounts/fabric_user1/
conf/accounts/fabric_user1/
├── account.crt
├── account.key
└── account.toml
```

#### 配置接入FISCO BCOS链

为router添加需要接入的链配置。

**生成配置文件**

切换至跨链路由的目录，用 [add_chain.sh](../manual/scripts.html#fisco-bcos-stub) 脚本在`conf`目录下生成bcos的配置文件框架。

```bash
cd ~/wecross/routers-payment/127.0.0.1-8250-25500
 # -t 链类型，-n 指定链名字
bash add_chain.sh -t BCOS2.0 -n bcos
```

生成的目录结构如下：

```bash
tree conf/chains/bcos/
conf/chains/bcos
├── WeCrossProxy
│   └── WeCrossProxy.sol # 代理合约
└── stub.toml            # chain配置文件
```

执行成功。如果执行出错，请查看屏幕打印提示。

``` bash
Chain “bcos” config framework has been generated to “conf/chains/bcos"
```

**配置BCOS节点连接**

- 拷贝证书

```bash
cp ~/wecross/bcos/nodes/127.0.0.1/sdk/* conf/chains/bcos/
```

- 修改配置

```bash
vim conf/chains/bcos/stub.toml
```

如果搭FISCO BCOS链采用的都是默认配置，那么将会得到一条单群组四节点的链，群组ID为1，可连接至节点0的channel端口`20200`，则配置如下（[参考此处获取更详尽的配置说明](../stubs/bcos.html#id8)）：

```toml
[common]
    name = 'bcos'
    type = 'BCOS2.0' # BCOS

[chain]
    groupId = 1 # default 1
    chainId = 1 # default 1

[channelService]
    caCert = 'ca.crt'
    sslCert = 'sdk.crt'
    sslKey = 'sdk.key'
    timeout = 300000  # ms, default 60000ms
    connectionsStr = ['127.0.0.1:20200']
```

**部署代理合约**

代理合约是插件与链交互的入口，执行命令进行部署。

``` bash
cd ~/wecross/routers-payment/127.0.0.1-8250-25500

java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.normal.proxy.ProxyContractDeployment deploy chains/bcos bcos_user1 # deploy conf下的链配置位置 账户名
```

部署成功，输出

``` bash 
SUCCESS: proxy has been deployed! chain: chains/bcos
```

**启动路由**

启动跨链路由加载已配置的跨链资源。

```bash
cd ~/wecross/routers-payment/127.0.0.1-8250-25500

# 若WeCross跨链路由未停止，需要先停止
bash stop.sh

# 重新启动
bash start.sh
```

检查日志，可看到刷出已加载的跨链资源，`ctrl + c` 退出。

``` bash
tail -f logs/info.log |grep "active resources"

2020-04-24 20:07:20.966 [Thread-4] INFO  WeCrossHost() - Current active resources: payment.bcos.HelloWeCross(local)
2020-04-24 20:07:30.973 [Thread-4] INFO  WeCrossHost() - Current active resources: payment.bcos.HelloWeCross(local)
2020-04-24 20:07:40.980 [Thread-4] INFO  WeCrossHost() - Current active resources: payment.bcos.HelloWeCross(local)
```

### 接入Fabric链

#### 添加账户

在router中添加用于向链上发交易的账户。

**添加Fabric账户**

Fabric账户需配置多个

* admin账户：必配，一个admin账户，用于接入此Fabric链
* 机构admin账户：选配，每个Fabric的Org配置一个admin账户，用于在每个Org上部署chaincode，此例子中用于部署代理合约和sacc合约。
* 用户账户：选配，用于往链上发交易。

相关操作如下

``` bash
# 切换至对应router的目录下
cd ~/wecross/routers-payment/127.0.0.1-8251-25501/

# 用脚本生成Fabric账户配置：账户类型（Fabric1.4），账户名（fabric_admin）
# 接入Fabric链，需要配置一个admin账户
bash add_account.sh -t Fabric1.4 -n fabric_admin 

# 拷贝 Fabric链的证书，具体说明请参考《跨链接入》章节
cp ~/wecross/fabric/certs/accounts/fabric_admin/*  conf/accounts/fabric_admin/  

# 为Fabric链的每个Org都配置一个admin账户，此处有两个org（Org1和Org2），分别配两个账户
# 配Org1的admin
bash add_account.sh -t Fabric1.4 -n fabric_admin_org1
cp ~/wecross/fabric/certs/accounts/fabric_admin_org1/*  conf/accounts/fabric_admin_org1/  

# 配Org2的admin
bash add_account.sh -t Fabric1.4 -n fabric_admin_org2
cp ~/wecross/fabric/certs/accounts/fabric_admin_org2/*  conf/accounts/fabric_admin_org2/  

# router-8250上配置的用户账户直接拷贝也可用
cp -r ~/wecross/routers-payment/127.0.0.1-8250-25500/conf/accounts/fabric_user1 conf/accounts/
```

* 修改配置

生成的账户配置，默认的`mspid`为Org1的，需将Org2的账户的`mspid`配置为Org2的。此处只需修改`fabric_admin_org2`账户的配置。[详细配置操作说明请参考此处](../stubs/fabric.html#id3)

``` bash
vim conf/accounts/fabric_admin_org2/account.toml
```

内容为

``` toml
[account]
    type = 'Fabric1.4'
    mspid = 'Org2MSP' # 配置为Org2MSP
    keystore = 'account.key'
    signcert = 'account.crt'
```

目前配置了四个账户，若此router需要向BCOS的链发交易，也可配置BCOS的账户。账户配置与接入的链无关，router间自动转发交易至相应的链。账户目录结构如下：

```bash
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
├── fabric_admin_org2
│   ├── account.crt
│   ├── account.key
│   └── account.toml
└── fabric_user1
    ├── account.crt
    ├── account.key
    └── account.toml
```

#### 配置接入Fabric链

为router添加需要接入的链配置。

**生成配置文件**

切换至跨链路由的目录，用 [add_chain.sh](../manual/scripts.html#fisco-bcos-stub) 脚本在`conf`目录下生成Fabric的配置文件框架。

```bash
cd ~/wecross/routers-payment/127.0.0.1-8251-25501
# -t 链类型，-n 指定链名字
bash add_chain.sh -t Fabric1.4 -n fabric 
```

生成的目录结构如下：

```bash
tree conf/chains/fabric/
conf/chains/fabric
├── WeCrossProxy
│   └── proxy.go	   # 代理chaincode
└── stub.toml          # chain配置文件
```

执行成功。如果执行出错，请查看屏幕打印提示。

``` bash
SUCCESS: Chain "fabric" config framework has been generated to "conf/chains/fabric"
```

**配置Fabric节点连接**

- 拷贝证书

``` bash
# 证书具体说明请参考《跨链接入》章节
cp ~/wecross/fabric/certs/chains/fabric/* conf/chains/fabric/ 
```

- 修改配置

``` bash
vim conf/chains/fabric/stub.toml
```

相关配置项使用默认即可。（[参考此处获取更详尽的配置说明](../stubs/fabric.html#id6)）

``` toml
[common]
    name = 'fabric'
    type = 'Fabric1.4'

[fabricServices]
    channelName = 'mychannel'
    orgUserName = 'fabric_admin'
    orgUserAccountPath = 'classpath:accounts/fabric_admin'
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

**部署代理chaincode**

执行命令，部署代理chaincode

``` bash
cd ~/wecross/routers-payment/127.0.0.1-8251-25501

java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.fabric.proxy.ProxyChaincodeDeployment deploy chains/fabric # deploy conf下的链配置位置
```

部署成功

``` bash
SUCCESS: WeCrossProxy has been deployed to chains/fabric
```

**启动路由**

启动跨链路由加载配置好的跨链资源。

```bash
cd ~/wecross/routers-payment/127.0.0.1-8251-25501

# 若WeCross跨链路由未停止，需要先停止
bash stop.sh

# 重新启动
bash start.sh
```

## 部署WeCross控制台

WeCross提供了控制台，方便用户进行跨链开发和调试。可通过脚本`build_console.sh`搭建控制台。

**下载WeCross控制台**

执行如下命令进行下载（提供[三种下载方式](../version/download.html#id2)，可根据网络环境选择合适的方式进行下载），下载完成后在当前目录下生成`WeCross-Console`目录。

```bash
cd ~/wecross/
bash <(curl -sL https://github.com/WeBankFinTech/WeCross/releases/download/resources/download_console.sh)
```

**配置控制台**

```bash
cd ~/wecross/WeCross-Console
# 拷贝连接router所需的TLS证书，从生成的routers-payment/cert/sdk目录下拷贝
cp ~/wecross/routers-payment/cert/sdk/* conf/ # 包含：ca.crt、node.nodeid、ssl.crt、ssl.key
# 拷贝配置文件，并配置跨链路由RPC服务地址以及端口。此处采用默认配置，默认连接至本地8250端口。
cp conf/application-sample.toml conf/application.toml
```

```eval_rst
.. important::
    - 若搭建WeCross的IP和端口未使用默认配置，需自行更改WeCross-Console/conf/application.toml，详见 `控制台配置 <../manual/console.html#id12>`_。
```

**启动控制台**

```bash
bash start.sh
```

启动成功则输出如下信息，通过`help`可查看控制台帮助

```bash
=================================================================================
Welcome to WeCross console(v1.0.0-rc3)!
Type 'help' or 'h' for help. Type 'quit' or 'q' to quit console.
=================================================================================
```

**测试功能**

```bash
# 查看连接的router当前支持接入的链类型
[WeCross]> supportedStubs
[BCOS2.0, GM_BCOS2.0, Fabric1.4] 

# 退出控制台
[server1]> quit
```

更多控制台命令及含义详见[控制台命令](../manual/console.html#id13)。

## 部署跨链资源

WeCross支持直接通过WeCross-Console部署跨链资源。

``` bash
cd ~/wecross/WeCross-Console/
```

### 部署 Fabric 跨链资源

WeCross 支持通过 WeCross-Console 向指定的Fabric链上部署chaincode。

* 配置chaincode代码（部署sacc为例）
  * WeCross-Console的chaincode存放目录：`conf/contracts/chaincode/`
  * sacc代码放入目录：`conf/contracts/chaincode/sacc`（目录名sacc为chaincode的名字）
  * sacc目录中放置chaincode代码：sacc.go （代码名任意）

 WeCross-Console中已默认存放了sacc，目录结构如下。

``` log
tree conf/contracts/chaincode/
conf/contracts/chaincode/
└── sacc
    ├── policy.yaml
    └── sacc.go
```

* 启动控制台

部署chaincode相关的账户在router-8251，将Console配置为连接router-8251

``` bash
cd ~/wecross/WeCross-Console
vim conf/application.toml
```

配置为

``` toml
[connection]
    server =  '127.0.0.1:8251' # 连接 router 8251
    sslKey = 'classpath:ssl.key'
    sslCert = 'classpath:ssl.crt'
    caCert = 'classpath:ca.crt'
```

启动控制台

``` bash
bash start.sh
```

* 部署chaincode

为不同的Org分别安装（install）相同的chaincode

> 参数：ipath（xxx.yyy.zzz，xxx.yyy为指定的链，zzz为chaincode名），机构admin账户，机构名，chaincode代码工程目录，指定一个版本，chaincode语言

``` groovy
[WeCross]> fabricInstall payment.fabric.sacc fabric_admin_org1 Org1 contracts/chaincode/sacc 1.0 GO_LANG
Result: Success
[WeCross]> fabricInstall payment.fabric.sacc fabric_admin_org2 Org2 contracts/chaincode/sacc 1.0 GO_LANG
Result: Success
```

实例化（instantiate）指定chaincode

> 参数：ipath，admin账户，对应的几个Org，chaincode代码工程目录，指定的版本，chaincode语言，背书策略（此处用默认），初始化参数

``` groovy
[WeCross]> fabricInstantiate payment.fabric.sacc fabric_admin ["Org1","Org2"] contracts/chaincode/sacc 1.0 GO_LANG default ["a","10"]
Result: Instantiating... Please wait and use 'listResources' to check. See router's log for more information.
```

instantiate请求后，需等待1min左右。用`listResources`查看是否成功。若instantiate成功，可查询到资源`payment.fabric.sacc`。

``` groovy
[WeCross]> listResources
path: payment.fabric.sacc, type: Fabric1.4, distance: 0
total: 1

[WeCross]> quit // 退出控制台
```

### 部署 BCOS 跨链资源

WeCross 支持通过 WeCross-Console 向指定的BCOS链上部署合约。部署步骤如下。

* 配置合约代码
  * 以HelloWorld合约为例
  * WeCross-Console 的合约存放目录：`conf/contracts/solidity/`

目录下已有HelloWorld合约文件，若需部署其它合约，可将合约拷贝至相同位置。

``` bash
tree conf/contracts/solidity/
conf/contracts/solidity/
└── HelloWorld.sol
```

* 启动控制台

部署合约相关的账户在router-8250，将Console配置为连接router-8250

``` bash
cd ~/wecross/WeCross-Console
vim conf/application.toml
```

配置为

``` toml
[connection]
    server =  '127.0.0.1:8250' # 连接 router 8250
    sslKey = 'classpath:ssl.key'
    sslCert = 'classpath:ssl.crt'
    caCert = 'classpath:ca.crt'
```

启动控制台

``` bash 
cd ~/wecross/WeCross-Console/
bash start.sh
```

* 部署合约

用`bcosDeploy`命令进行部署。

> 参数：ipath，代码目录，合约名，设置一个版本号

``` groovy
[WeCross]> bcosDeploy payment.bcos.HelloWorld bcos_user1 conf/contracts/solidity/HelloWorld.sol HelloWorld 1.0
Result: 0x1b557d68ebc51ed5b12438ff1666f8111718f47a
```

用`listResources`可查看此资源已部署

``` groovy
[WeCross]> listResources
path: payment.bcos.HelloWeCross, type: BCOS2.0, distance: 0
```

## 操作跨链资源

**查看资源**

进入控制台，用`listResources`命令查看WeCross跨连网络中的所有资源。可看到有两个资源：

* `payment.bcos.HelloWorld`
  * 对应于FISCO BCOS链上的HelloWorld.sol合约
* `payment.fabric.sacc`
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
BlockNum: 6
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

恭喜，你已经完成了整个WeCross网络的体验。相信优秀的你已经对WeCross有了大致的了解。接下来，你可以基于WeCross Java SDK开发更多的跨连应用，通过统一的接口对各种链上的资源进行操作。