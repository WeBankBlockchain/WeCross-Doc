# 手动组网

本文档介绍以手动的方式，一步步搭建一个与[快速体验](./demo.md)中相同的跨链网络。

![](../images/tutorial/demo.png)

## 快速部署

本章指导完成[**跨链路由**](../introduction/introduction.html#id2)和[**跨链控制台**](../manual/console.md)的部署。

* **跨链路由**：与区块链节点对接，并彼此互连，形成[跨链分区](../introduction/introduction.html#id2)，负责跨链请求的转发
* **跨链控制台**：查询和发送交易的操作终端

![](../images/tutorial/routers.png)

操作以`~/wecross/`目录下为例进行

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

```bash
cd ~/wecross
vim ipfile
```

本举例中将构造两个跨链路由，构建一个ipfile文件，将需要构建的两个跨链路由信息内容保存到文件中（按行区分：`ip地址:rpc端口:p2p端口`）。请确保机器的`8250`，`8251`, `25500`，`25501`端口没有被占用。

```text
127.0.0.1:8250:25500
127.0.0.1:8251:25501
```

用WeCross中的 [build_wecross.sh](../manual/scripts.html#wecross)生成两个跨链路由。

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
    - -f 指定需要生成的WeCross跨链路由的列表，包括ip地址，rpc端口，p2p端口，生成后的router自动配置相连
```

在routers-payment目录下生成了两个跨链路由

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

成功

```
WeCross booting up .........
WeCross start successfully
```

如果启动失败，检查`8250, 25500`端口是否被占用

``` bash
netstat -napl | grep 8250
netstat -napl | grep 25500
netstat -napl | grep 8251
netstat -napl | grep 25501
```

### 部署WeCross控制台

WeCross提供了控制台，方便用户进行跨链开发和调试。可通过脚本`build_console.sh`搭建一个WeCross控制台。

**下载WeCross控制台**

执行如下命令进行下载（提供[三种下载方式](../version/download.html#id2)，可根据网络环境选择合适的方式进行下载），下载后在执行命令的目录下生成`WeCross-Console`目录。

```bash
cd ~/wecross/
bash <(curl -sL https://github.com/WeBankFinTech/WeCross-Console/releases/download/resources/download_console.sh)
```

**配置控制台**

```bash
cd ~/wecross/WeCross-Console
# 拷贝连接router所需的TLS证书，从生成的routers-payment/cert/sdk目录下拷贝
cp ~/wecross/routers-payment/cert/sdk/* conf/ # 包含：ca.crt、node.nodeid、ssl.crt、ssl.key
# 配置控制台
cp conf/application-sample.toml conf/application.toml  # 配置控制台连接的跨链路由地址，此处采用默认配置，默认连接至本地8250端口，即router的RPC端口
```

```eval_rst
.. important::
    - 若搭建WeCross的IP和端口未使用默认配置，需自行更改WeCross-Console/conf/application.toml，详见 `控制台配置 <../manual/application.toml#id11>`_。
```

**启动控制台**

```bash
bash start.sh
```

启动成功则输出如下信息，通过`help`可查看控制台帮助

```bash
=================================================================================
Welcome to WeCross console(v1.0.0-rc2)!
Type 'help' or 'h' for help. Type 'quit' or 'q' to quit console.
=================================================================================
```

**测试功能**

```bash
# 查看连接的router当前支持接入的链类型
[WeCross]> supportedStubs
[BCOS2.0, GM_BCOS2.0, Fabric1.4] 

# 退出控制台
[server1]> q
```

更多控制台命令及含义详见[控制台命令](../manual/console.html#id13)。

## 接入区块链

完成了WeCross的部署，如何让它和一条真实的区块链交互，相信优秀的您一定在跃跃欲试。本节包括

* 接入BCOS链：在router-8250上接入，配置交易发送账户
* 接入Fabric链：在router-8251上接入，配置交易发送账户

![](../images/tutorial/demo.png)

### 搭建区块链

在接入区块链前，先给出BCOS和Fabric链的搭建过程。

#### 搭建BCOS链

若已有搭建好的FISCO BCOS链，请跳过此部分，直接进入部署HelloWeCross合约部分。

FISCO BCOS官方提供了一键搭链的教程，详见[单群组FISCO BCOS联盟链的搭建](https://fisco-bcos-documentation.readthedocs.io/zh_CN/latest/docs/installation.html)

详细步骤如下：

- 脚本建链

```bash
# 创建操作目录
mkdir -p ~/wecross/bcos && cd ~/wecross/bcos

# 下载build_chain.sh脚本
curl -LO https://github.com/FISCO-BCOS/FISCO-BCOS/releases/download/v2.4.0/build_chain.sh && chmod u+x build_chain.sh

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

#### 部署HelloWeCross合约

通过FISCO BCOS控制台部署HelloWeCross合约，控制台的安装和使用详见官方文档[配置及使用控制台](https://fisco-bcos-documentation.readthedocs.io/zh_CN/latest/docs/installation.html#id7)

`HelloWeCross.sol`位于`~/wecross/routers-payment/127.0.0.1-8250-25500/conf/chains-sample/bcos/`

控制台安装配置完后启动并部署`HelloWeCross.sol`，返回的合约地址在之后的WeCross配置中需要用到。详细步骤如下：

- 安装控制台

```bash
# 获取控制台
cd ~/wecross/bcos/nodes/127.0.0.1/
bash download_console.sh

# 拷贝控制台配置文件
# 若节点未采用默认端口，请将文件中的20200替换成节点对应的channle端口。
cp -n console/conf/applicationContext-sample.xml console/conf/applicationContext.xml

# 配置控制台证书
cp ~/wecross/bcos/nodes/127.0.0.1/sdk/* console/conf/
```

- 拷贝合约文件

将`HelloWeCross`合约拷贝至控制台目录（用FISCO BCOS的控制台部署）

```bash
cp ~/wecross/routers-payment/127.0.0.1-8250-25500/conf/chains-sample/bcos/HelloWeCross.sol console/contracts/solidity/
```

- 启动控制台

```bash
bash console/start.sh
```

输出下述信息表明启动成功 否则请检查`conf/applicationContext.xml`中节点端口配置是否正确

```bash
=============================================================================================
Welcome to FISCO BCOS console(1.0.9)！
Type 'help' or 'h' for help. Type 'quit' or 'q' to quit console.
 ________  ______   ______    ______    ______         _______    ______    ______    ______
|        \|      \ /      \  /      \  /      \       |       \  /      \  /      \  /      \
| $$$$$$$$ \$$$$$$|  $$$$$$\|  $$$$$$\|  $$$$$$\      | $$$$$$$\|  $$$$$$\|  $$$$$$\|  $$$$$$\
| $$__      | $$  | $$___\$$| $$   \$$| $$  | $$      | $$__/ $$| $$   \$$| $$  | $$| $$___\$$
| $$  \     | $$   \$$    \ | $$      | $$  | $$      | $$    $$| $$      | $$  | $$ \$$    \
| $$$$$     | $$   _\$$$$$$\| $$   __ | $$  | $$      | $$$$$$$\| $$   __ | $$  | $$ _\$$$$$$\
| $$       _| $$_ |  \__| $$| $$__/  \| $$__/ $$      | $$__/ $$| $$__/  \| $$__/ $$|  \__| $$
| $$      |   $$ \ \$$    $$ \$$    $$ \$$    $$      | $$    $$ \$$    $$ \$$    $$ \$$    $$
 \$$       \$$$$$$  \$$$$$$   \$$$$$$   \$$$$$$        \$$$$$$$   \$$$$$$   \$$$$$$   \$$$$$$

=============================================================================================
```

- 部署合约

```bash
[group:1]> deploy HelloWeCross
contract address: 0x19a70c01e801d3cac241de5f11686e3aa01e463b

[group:1]> quit # 退出控制台
```

将HelloWeCross的合约地址记录下来，后续步骤中使用：

`contract address: 0x19a70c01e801d3cac241de5f11686e3aa01e463b`

#### 搭建Fabric链

为方便Fabric链的搭建，WeCross提供了Fabric链的demo搭建脚本。若下载较慢，可选择[更多下载方式](../version/download.html#wecross-demo)。

``` bash
mkdir -p ~/wecross/fabric && cd ~/wecross/fabric

# 下载Fabric链demo搭建脚本
bash <(curl -sL https://github.com/WeBankFinTech/WeCross/releases/download/resources/download_demo.sh) -t resources # 下载，生成demo文件夹
cp demo/fabric/* ./

# 搭建
bash build.sh # 若出错，执行 bash clear.sh 后重新 bash build.sh
```

搭建成功，查看Fabric链各个容器运行状态

``` bash
docker ps
```

可看到各个容器的状态

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

### 接入BCOS链

#### 添加账户

在router中添加用于向链上发交易的账户。账户配置好后，可通过跨链网络向相应的链发交易，交易可被router转发至对应的链上。

**添加BCOS账户**

所配置的账户可用于向`BCOS2.0`类型的链发交易

```shell
# 切换至对应router的目录下
cd ~/wecross/routers-payment/127.0.0.1-8250-25500/

# 用脚本生成BCOS账户：账户类型（BCOS2.0），账户名（bcos_user1）
bash add_account.sh -t BCOS2.0 -n bcos_user1 

# 查看生成目录
tree conf/accounts/bcos_user1/
```

生成的bcos_user1文件目录如下。

``` bash
conf/accounts/bcos_user1/
├── account.key
└── account.toml
```

**添加Fabric账户**

所配置的账户可用于向`Fabric1.4`类型的链发交易

``` bash
# 用脚本生成Fabric账户：账户类型（Fabric1.4），账户名（fabric_user1）
bash add_account.sh -t Fabric1.4 -n fabric_user1
cp ~/wecross/fabric/certs/accounts/fabric_user1/* conf/accounts/fabric_user1/  # 拷贝 Fabric链的证书，具体说明请参考《跨链接入》章节

# 查看生成目录
tree conf/accounts/fabric_user1/
```

生成的fabric_user1文件目录如下。

``` bash
conf/accounts/fabric_user1/
├── account.crt
├── account.key
└── account.toml
```

#### 配置接入BCOS链

为router添加需要接入的链配置。

**生成配置文件**

切换至跨链路由的目录，用 [add_chain.sh](../manual/scripts.html#fisco-bcos-stub) 脚本在`conf`目录下生成bcos的配置文件框架。

```bash
cd ~/wecross/routers-payment/127.0.0.1-8250-25500
bash add_chain.sh -t BCOS2.0 -n bcos # -t 链类型，-n 指定链名字

# 查看生成目录
tree conf/chains/bcos
```

生成的目录结构如下：

```bash
conf/chains/bcos
└── stub.toml          # chain配置文件
```

命令执行成功会输出`operator: chain type: BCOS2.0 path: conf/chains/bcos`，如果执行出错，请查看屏幕打印提示。

之后只需要配置证书、群组以及资源信息。

**配置BCOS节点连接**

从BCOS节点处拷贝sdk的证书

```bash
cp ~/wecross/bcos/nodes/127.0.0.1/sdk/* conf/chains/bcos/
```

修改配置

```bash
vim conf/chains/bcos/stub.toml
```

如果搭FISCO BCOS链采用的都是默认配置，那么将会得到一条单群组四节点的链，群组ID为1，可连接至节点0的channel端口`20200`，则配置如下：

```toml
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

**配置跨链资源**

在`stub.toml`文件中配置HelloWeCross合约资源信息，让此跨链路由能够访问此合约。**并将配置中多余无用的举例删除**。

在前面的步骤中，已经通过FISCO BCOS控制台部署了一个`HelloWeCross`合约，地址为`0x19a70c01e801d3cac241de5f11686e3aa01e463b`，将此地址填入`contractAddress`中。

```toml 
[[resources]]
    # name cannot be repeated
    name = 'HelloWeCross'
    type = 'BCOS_CONTRACT'
    contractAddress = '0x19a70c01e801d3cac241de5f11686e3aa01e463b'
```

**完整配置**

完成了上述的步骤，那么已经完成了`bcos`的连接配置，并注册了一个合约资源，最终的`stub.toml`文件如下。[参考此处获取更详尽的配置说明](../manual/scripts.html#fisco-bcos-stub)

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

# resources is a list
[[resources]]
    # name cannot be repeated
    name = 'HelloWeCross'
    type = 'BCOS_CONTRACT'
    contractAddress = '0x19a70c01e801d3cac241de5f11686e3aa01e463b'
```

**启动路由**

启动跨链路由加载配置好的跨链资源。

```bash
cd ~/wecross/routers-payment/127.0.0.1-8250-25500

# 若WeCross跨链路由未停止，需要先停止
bash stop.sh

# 重新启动
bash start.sh
```

检查日志

``` bash
tail -f logs/info.log |grep "active resources"
```

可看到刷出已加载的跨链资源，`ctrl + c` 退出

``` log
2020-04-24 20:07:20.966 [Thread-4] INFO  WeCrossHost() - Current active resources: payment.bcos.HelloWeCross(local)
2020-04-24 20:07:30.973 [Thread-4] INFO  WeCrossHost() - Current active resources: payment.bcos.HelloWeCross(local)
2020-04-24 20:07:40.980 [Thread-4] INFO  WeCrossHost() - Current active resources: payment.bcos.HelloWeCross(local)
```

### 接入Fabric链

#### 添加账户

在router中添加用于向链上发交易的账户。账户配置好后，可通过跨链网络向相应的链发交易，交易可被router转发至对应的链上。

**添加Fabric账户**

所配置的账户可用于向`Fabric1.4`类型的链发交易

``` bash
# 切换至对应router的目录下
cd ~/wecross/routers-payment/127.0.0.1-8251-25501/

# 用脚本生成Fabric账户配置：账户类型（Fabric1.4），账户名（fabric_admin）
bash add_account.sh -t Fabric1.4 -n fabric_admin # 接入Fabric链，需要配置一个admin账户
cp ~/wecross/fabric/certs/accounts/fabric_admin/*  conf/accounts/fabric_admin/  # 拷贝 Fabric链的证书，具体说明请参考《跨链接入》章节

# router-8250上配置的账户直接拷贝也可用
cp -r ~/wecross/routers-payment/127.0.0.1-8250-25500/conf/accounts/fabric_user1 conf/accounts/

# 生成至conf/accounts目录下
tree conf/accounts
```

目前配置了两个账户，若此router需要向BCOS的链发交易，也可配置BCOS的账户。账户配置与接入的链无关，router间自动转发交易至相应的链。此处省略。

``` log
conf/accounts
├── fabric_admin
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

切换至跨链路由的目录，用 [add_chain.sh](../manual/scripts.html#fisco-bcos-stub) 脚本在`conf`目录下生成fabric的配置文件框架。

```bash
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

命令执行成功会输出`operator: connection type: Fabric1.4 path: conf/chains//fabric`，如果执行出错，请查看屏幕打印提示。

**配置Fabric节点连接**

拷贝证书

``` bash
cp ~/wecross/fabric/certs/chains/fabric/* conf/chains/fabric/ # 证书具体说明请参考《跨链接入》章节
```

修改配置

``` bash
vim conf/chains/fabric/stub.toml
```

内容为（此处默认即可）

``` toml
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
```

**配置跨链资源**

``` bash
vim conf/chains/fabric/stub.toml
```

内容如下，fabric链中自带了一个名字为`mycc`的chaincode，此处将`mycc`配置为跨链资源，使其能够在WeCross网络中被调用。

``` toml
[[resources]]
    # name cannot be repeated
    name = 'abac'
    type = 'FABRIC_CONTRACT'
    chainCodeName = 'mycc'
    chainLanguage = "go"
    peers=['org1','org2']
```

**完整配置**

完成了上述的步骤，那么已经完成了`fabric`的连接配置，并注册了一个合约资源，最终的`stub.toml`文件如下。[参考此处获取更详尽的配置说明](../manual/scripts.html#fabric-stub)

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

**启动路由**

启动跨链路由加载配置好的跨链资源。

```bash
cd ~/wecross/routers-payment/127.0.0.1-8251-25501

# 若WeCross跨链路由未停止，需要先停止
bash stop.sh

# 重新启动
bash start.sh
```

检查日志

``` bash
tail -f logs/info.log |grep "active resources"
```

可看到刷出已加载的跨链资源，`ctrl + c` 退出

``` log
2020-04-24 20:30:30.444 [Thread-2] INFO  WeCrossHost() - Current active resources: payment.bcos.HelloWeCross(remote), payment.fabric.abac(local)
2020-04-24 20:30:40.458 [Thread-2] INFO  WeCrossHost() - Current active resources: payment.bcos.HelloWeCross(remote), payment.fabric.abac(local)
2020-04-24 20:30:50.469 [Thread-2] INFO  WeCrossHost() - Current active resources: payment.bcos.HelloWeCross(remote), payment.fabric.abac(local)
```

## 调用跨链资源

至此，已搭建了如图所示的跨链网络，本节将用控制台调用跨链资源。开发者也可基于WeCross Java SDK开发自己的跨链应用。

![](../images/tutorial/demo.png)

**启动控制台**

控制台连接的是`router-8250`

``` bash
cd ~/wecross/WeCross-Console

# 配置连接至 router-8250，默认已配置，直接保存退出
vim conf/application.toml

# 启动控制台
bash start.sh
```

**查看资源**

进入控制台，用`listResources`命令查看WeCross跨连网络中的所有资源。可看到有两个资源

* payment.bcos.HelloWeCross
  * 对应于**FISCO BCOS**链上的[HelloWeCross.sol](../stubs/bcos.html#id1)合约
* payment.fabric.abac
  * 对应于**Fabric**网络上的[abac.go](https://github.com/hyperledger/fabric-samples/blob/v1.4.4/chaincode/abac/go/abac.go)合约

```bash
[WeCross]> listResources
path: payment.bcos.HelloWeCross, type: BCOS2.0, distance: 0
path: payment.fabric.abac, type: Fabric1.4, distance: 1
total: 2
```

**查看账户**

用`listAccounts`命令查看WeCross Router上已存在的账户，操作资源时用相应账户进行操作

```bash
[WeCross]> listAccounts
name: fabric_user1, type: Fabric1.4
name: bcos_user1, type: BCOS2.0
total: 2
```

**操作资源：payment.bcos.HelloWeCross**

读资源：`call path 账户名 接口名 （参数列表）`

> 调用HelloWeCross合约中的get接口

```bash
[WeCross]> call payment.bcos.HelloWeCross bcos_user1 get
Result: [Talk is cheap, Show me the code]
```

写资源：`sendTransaction path 返回值类型列表 接口名 （参数列表）`

> 调用HelloWeCross合约中的set接口

```bash
[WeCross]> sendTransaction payment.bcos.HelloWeCross bcos_user1 set Tom
Txhash  : 0x21a412a1eb5239f2da9d40d09d11ce0107a5d82d113f1ecb315f2aa5bd3cc0cd
BlockNum: 2
Result  : [Tom]  // 将Tom给set进去

[WeCross]> call payment.bcos.HelloWeCross bcos_user1 get
Result: [Tom] // 再次get，Tom已set
```

**操作资源：payment.fabric.abac**

读资源：`call path 账户名 接口名 （参数列表）`

> 调用abac合约中的query接口

```bash
[WeCross]> call payment.fabric.abac fabric_user1 query a
Result: [90] // 初次query，a的值为90
```

写资源：`sendTransaction path 返回值类型列表 接口名 （参数列表）`

> 调用abac合约中的invoke接口

```bash
[WeCross]> sendTransaction payment.fabric.abac fabric_user1 invoke a b 10
Txhash  : db44b064c54d4dc97f01cdcd013cae219f7849c329f38ee102853344d8f0004d
BlockNum: 5
Result  : [] 

[WeCross]> call payment.fabric.abac fabric_user1 query a
Result: [80] // 再次query，a的值变成80
```

恭喜，你已经完成了整个WeCross网络的体验。相信优秀的你已经对WeCross有了大致的了解。接下来，你可以基于WeCross Java SDK开发更多的跨连应用，通过统一的接口对各种链上的资源进行操作。