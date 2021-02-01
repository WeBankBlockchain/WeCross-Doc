# 接入FISCO BCOS 2.0

[WeCross-BCOS2-Stub](https://github.com/WeBankBlockchain/WeCross-BCOS2-Stub)作为WeCross的插件，让跨链路由具备接入FISCO-BCOS 2.0的能力。本章节将介绍如何基于BCOS插件接入FISCO BCOS链，内容包括：

* 搭建区块链
* 安装插件
* 配置插件
* 部署系统合约

```eval_rst
.. important::
    - FISCO-BCOS版本需要 >= v2.6.0
    - 若还未完成WeCross搭建，请参考 `部署指南 <../tutorial/networks.html>`_
    - 以下教程的目录结构基于 `部署指南 <../tutorial/networks.html>`_ 搭建的WeCross环境作介绍
```

## 搭建区块链

如果已存在FISCO BCOS链，不需搭建新链，可跳过本节内容。

FISCO BCOS官方提供了一键搭链的教程，详见[单群组FISCO BCOS联盟链的搭建](https://fisco-bcos-documentation.readthedocs.io/zh_CN/latest/docs/installation.html)

详细步骤如下：

- 脚本建链

```bash
# 创建操作目录
mkdir -p ~/wecross/bcos && cd ~/wecross/bcos

# 下载build_chain.sh脚本
curl -LO https://github.com/FISCO-BCOS/FISCO-BCOS/releases/download/v2.7.1/build_chain.sh && chmod u+x build_chain.sh

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

## 安装插件

基于[部署指南](../tutorial/networks.html)搭建的WeCross，已完成插件的安装，位于跨链路由的`plugin`目录，可跳过本节内容。

```bash
plugin/
|-- bcos2-stub-gm-xxxx.jar    # 国密插件
|-- bcos2-stub-xxxx.jar       # 非国密插件
└-- fabric1-stub-xxxx.jar
```

用户如有特殊需求，可以自行编译，替换`plugin`目录下的插件。

### 下载编译

```shell
git clone https://github.com/WeBankBlockchain/WeCross-BCOS2-Stub.git
cd WeCross-BCOS2-Stub
bash gradlew assemble # 在 dist/apps/ 下生成 bcos2-stub-XXXXX.jar 和 bcos2-stub-gm-xxxx.jar
```

WeCross-BCOS2-Stub编译生成两个插件：

- 国密插件
- 非国密插件

```shell
dist/apps
├── bcos2-stub-gm-xxxx.jar    # 国密插件
└── bcos2-stub-xxxx.jar       # 非国密插件
```

### 拷贝安装
在跨链路由的主目录下创建plugin目录，然后将插件拷贝到该目录下完成安装。

``` bash
cp dist/apps/* ~/wecross/routers-payment/127.0.0.1-8250-25500/plugin/
```

**注：若跨链路由中配置了两个相同的插件，插件冲突，会导致跨链路由启动失败。**


## 配置插件

### 生成配置框架

进入跨链路由的主目录，用`add_chain.sh`脚本在`conf`目录下生成BCOS链的配置框架。

```shell
cd ~/wecross/routers-payment/127.0.0.1-8250-25500

 # -t 链类型，-n 指定链名字，可根据-h查看使用说明
bash add_chain.sh -t BCOS2.0 -n bcos
```

执行成功，输出如下。如果执行出错，请查看屏幕打印提示。

```shell
Chain "bcos" config framework has been generated to "conf/chains/bcos"
```

生成的目录结构如下：

```shell
tree conf/chains/bcos/
conf/chains/bcos/
├── WeCrossHub
│   └── WeCrossHub.sol        # 桥接合约
├── WeCrossProxy              # 代理合约
│   └── WeCrossProxy.sol
├── admin                     # stub内部内置账户，部署代理合约和桥接合约的默认账户
│   ├── xxxxx_secp256k1.key
│   └── account.toml
└── stub.toml                 # 插件配置文件
```

### 完成配置

**拷贝证书**

为了能够连接BCOS链的节点，需要拷贝节点SDK的证书，证书位于节点的`nodes/127.0.0.1/sdk/`目录。

```shell
# 证书目录以实际情况为准
cp xxxxxx/nodes/127.0.0.1/sdk/*   ~/wecross/routers-payment/127.0.0.1-8250-25500/conf/chains/bcos/
```

**编辑配置文件**

插件配置文件`stub.toml`配置项包括：

- 配置资源信息
- 配置SDK连接信息，与链进行交互

根据实际情况编辑`[chain]`、`[channelService]`的各个配置项。

```toml
[common]                # 通用配置
    name = 'bcos'       # stub配置名称，即 [stubName] = bcos
    type = 'BCOS2.0'    # stub类型，`GM_BCOS2.0`或者`BCOS2.0`，`GM_BCOS2.0`国密类型，`BCOS2.0`非国密类型

[chain]                 # FISCO-BCOS 链配置
    groupId = 1         # 连接FISCO-BCOS群组id，默认为1
    chainId = 1         # 连接FISCO-BCOS链id，默认为1

[channelService]        # FISCO-BCOS 配置，以下文件在BCOS链的nodes/127.0.0.1/sdk目录下拷贝
    caCert = 'ca.crt'   # 根证书
    sslCert = 'sdk.crt' # sdk证书
    sslKey = 'sdk.key'  # sdk私钥
    timeout = 5000      # SDK请求超时时间
    connectionsStr = ['127.0.0.1:20200']    # 连接列表

# [[resources]] 资源列表，配置链已有的资源
# [[resources]]
    #name = 'htlc'           # 资源名称
    #type = 'BCOS_CONTRACT'  # 资源类型，BCOS_CONTRACT
    #contractAddress = '0x7540601cce8b0802980f9ebf7aeee22bb4d73c22'  # 合约地址

#[sealers]        # 可信验证，不配则不验证
   #pubKey = []   # 验证者公钥列表
```

## 部署系统合约

每个Stub需要部署两个系统合约，分别是代理合约和桥接合约，代理合约负责管理事务以及业务合约的调用，桥接合约用于记录合约跨链请求。在跨链路由主目录执行以下命令：

### 非国密链

```shell
# 部署代理合约
java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.normal.preparation.ProxyContractDeployment deploy chains/bcos

# 部署桥接合约
java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.normal.preparation.HubContractDeployment deploy chains/bcos

# 若后续有更新系统合约的需求，首先更新conf/chains/bcos下的系统合约代码，然后将上述命令的 deploy 替换为 upgrade，执行并重启跨链路由
```

部署成功，则输出如下内容。若失败可查看提示信息和错误日志。

``` bash 
SUCCESS: WeCrossProxy:xxxxxxxx has been deployed! chain: chains/bcos
SUCCESS: WeCrossHub:xxxxxxxx has been deployed! chain: chains/bcos
```

### 国密链

```shell

# 部署代理合约
java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.guomi.preparation.ProxyContractDeployment deploy chains/bcos

# 部署桥接合约
java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.guomi.preparation.HubContractDeployment deploy chains/bcos

# 若后续有更新系统合约的需求，首先更新conf/chains/bcos下的系统合约代码，然后将上述命令的 deploy 替换为 upgrade，执行并重启跨链路由
```

部署成功，则输出如下内容。若失败可查看提示信息和错误日志。

``` bash 
SUCCESS: WeCrossProxy:xxxxxxxx has been deployed! chain: chains/bcos
SUCCESS: WeCrossHub:xxxxxxxx has been deployed! chain: chains/bcos
```
