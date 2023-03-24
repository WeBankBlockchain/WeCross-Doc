# 接入FISCO BCOS 3.0

[WeCross-BCOS3-Stub](https://github.com/WeBankBlockchain/WeCross-BCOS3-Stub)作为WeCross的插件，让跨链路由具备接入FISCO-BCOS 3.0的能力。本章节将介绍如何基于BCOS插件接入FISCO BCOS链，内容包括：

* 搭建区块链
* 安装插件
* 配置插件
* 部署系统合约

WeCross-BCOS3-Stub 源码访问链接：
[GitHub访问链接](https://github.com/WeBankBlockchain/WeCross-BCOS3-Stub)，
[Gitee访问链接](https://gitee.com/WeBank/WeCross-BCOS3-Stub)

```eval_rst
.. important::
    - FISCO-BCOS版本需要 >= v3.0.0
    - 若还未完成WeCross搭建，请参考 `部署指南 <../tutorial/deploy/index.html>`_
    - 以下教程的目录结构基于 `部署指南 <../tutorial/deploy/index.tml>`_ 搭建的WeCross环境作介绍
```

## 1. 搭建区块链

如果已存在FISCO BCOS链，不需搭建新链，可跳过本节内容。

FISCO BCOS官方提供了一键搭链的教程，详见[搭建第一个区块链网络](https://fisco-bcos-doc.readthedocs.io/zh_CN/latest/docs/quick_start/air_installation.html)

详细步骤如下：

* 脚本建链

```bash
# 创建操作目录
mkdir -p ~/wecross-networks/bcos && cd ~/wecross-networks/bcos

# 下载build_chain.sh脚本
curl -LO https://github.com/FISCO-BCOS/FISCO-BCOS/releases/download/v3.2.1/build_chain.sh && chmod u+x build_chain.sh

# 若因为网络原因出现长时间下载失败，请尝试以下命令：
curl -LO https://gitee.com/FISCO-BCOS/FISCO-BCOS/raw/v3.2.1/tools/build_chain.sh && chmod u+x build_chain.sh

# 搭建单群组4节点联盟链
# 在fisco目录下执行下面的指令，生成一条单群组4节点的FISCO链。请确保机器的30300~30303，20200~20203端口没有被占用。
# 命令执行成功会输出All completed。如果执行出错，请检查nodes/build.log文件中的错误信息。
bash build_chain.sh -l "127.0.0.1:4" -p 30300,20200
```

* 启动所有节点

```bash
bash nodes/127.0.0.1/start_all.sh
```

启动成功会输出类似下面内容的响应。否则请使用`netstat -an | grep tcp`检查机器的`30300~30303，20200~20203`端口是否被占用。

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

## 2. 安装插件

基于[部署指南](../tutorial/deploy/index.html)搭建的WeCross，已完成插件的安装，位于跨链路由的`plugin`目录，可跳过本节内容。

```bash
plugin/
|-- bcos3-stub-xxxx.jar    # bcos3插件
|-- bcos2-stub-xxxx.jar    # bcos2插件
|-- bcos2-stub-gm-xxxx.jar    # bcos2国密插件
└-- fabric1-stub-xxxx.jar
```

用户如有特殊需求，可以自行编译，替换`plugin`目录下的插件。

### 2.1 下载编译

```shell
git clone https://github.com/WeBankBlockchain/WeCross-BCOS3-Stub.git

# 若因网络原因出现长时间下载失败，请尝试以下命令：
git clone https://gitee.com/WeBank/WeCross-BCOS3-Stub.git

cd WeCross-BCOS3-Stub
bash gradlew assemble # 在 dist/apps/ 下生成 bcos3-stub-XXXXX.jar
```

WeCross-BCOS3-Stub编译生成一个插件：

* 国密插件
* 非国密插件

```shell
dist/apps
└── bcos3-stub-xxxx.jar
```

### 2.2 拷贝安装
在跨链路由的主目录下创建plugin目录，然后将插件拷贝到该目录下完成安装。

``` bash
cp dist/apps/* ~/wecross-networks/routers-payment/127.0.0.1-8250-25500/plugin/
```

**注：若跨链路由中配置了两个相同的插件，插件冲突，会导致跨链路由启动失败。**

## 3. 配置插件

### 3.1 生成配置框架

进入跨链路由的主目录，用`add_chain.sh`脚本在`conf`目录下生成BCOS链的配置框架。

```shell
cd ~/wecross-networks/routers-payment/127.0.0.1-8250-25500

 # -t 链类型，-n 指定链名字，可根据-h查看使用说明
bash add_chain.sh -t BCOS3_ECDSA_EVM -n bcos3
```

执行成功，输出如下。如果执行出错，请查看屏幕打印提示。

```shell
Chain "bcos3" config framework has been generated to "conf/chains/bcos3"
```

生成的目录结构如下：

```shell
tree conf/chains/bcos3/
conf/chains/bcos3/
├── WeCrossHub
│   └── WeCrossHub.sol        # 桥接合约
├── WeCrossProxy              # 代理合约
│   └── WeCrossProxy.sol
├── admin                     # stub内部内置账户，部署代理合约和桥接合约的默认账户
│   ├── xxxxx_secp256k1.key
│   └── account.toml
└── stub.toml                 # 插件配置文件
```

### 3.2 完成配置

**拷贝证书**

为了能够连接BCOS链的节点，需要拷贝节点SDK的证书，证书位于节点的`nodes/127.0.0.1/sdk/`目录。

```shell
# 证书目录以实际情况为准
cp -r xxxxxx/nodes/127.0.0.1/sdk/*   ~/wecross-networks/routers-payment/127.0.0.1-8250-25500/conf/chains/bcos3/
```

**编辑配置文件**

插件配置文件`stub.toml`配置项包括：

- 配置资源信息
- 配置SDK连接信息，与链进行交互

根据实际情况编辑`[chain]`、`[service]`的各个配置项。

```toml
[common]                        # 通用配置
    name = 'bcos3'              # stub配置名称，即 [stubName] = bcos3    
    type = 'BCOS3_ECDSA_EVM'    # stub类型，`BCOS3_ECDSA_EVM`或者`BCOS3_GM_EVM`，`BCOS3_GM_EVM`国密类型，`BCOS3_ECDSA_EVM`非国密类型

[chain]                         # FISCO-BCOS 链配置    
    groupId = 'group0'          # 连接FISCO-BCOS群组id，默认group0
    chainId = 'chain0'          # 连接FISCO-BCOS链id，默认chain0

[service]                       # FISCO-BCOS 配置，以下文件在BCOS链的nodes/127.0.0.1/sdk目录下拷贝
    caCert = 'ca.crt'           # 根证书
    sslCert = 'sdk.crt'         # SDK证书    
    sslKey = 'sdk.key'          # SDK私钥

    gmCaCert = 'sm_ca.crt'      # 国密CA证书
    gmSslCert = 'sm_sdk.crt'    # 国密SDK证书
    gmSslKey = 'sm_sdk.key'     # 国密SDK密钥
    gmEnSslCert = 'sm_ensdk.crt'# 国密加密证书
    gmEnSslKey = 'sm_ensdk.key' # 国密加密密钥

    disableSsl = false          # 是否关闭ssl访问，需与节点侧对齐
    messageTimeout = 60000      # SDK请求超时时间
    connectionsStr = ['127.0.0.1:20200']    # 连接列表

    threadPoolSize = 16

# resources is a list
[[resources]]
    # name cannot be repeated
    name = 'HelloWeCross'
    type = 'BCOS_CONTRACT'
    contractAddress = '0x8827cca7f0f38b861b62dae6d711efe92a1e3602'
```

## 4. 部署系统合约

每个Stub需要部署两个系统合约，分别是代理合约和桥接合约，代理合约负责管理事务以及业务合约的调用，桥接合约用于记录合约跨链请求。在跨链路由主目录执行以下命令：

### 4.1 非国密链

```shell
# 部署代理合约
bash deploy_system_contract.sh -t BCOS3_ECDSA_EVM -c chains/bcos3 -P

# 部署桥接合约
bash deploy_system_contract.sh -t BCOS3_ECDSA_EVM -c chains/bcos3 -H

# 若后续有更新系统合约的需求，首先更新conf/chains/bcos3下的系统合约代码，在上述命令添加-u参数，执行并重启跨链路由
```

部署成功，则输出如下内容。若失败可查看提示信息和错误日志。

``` bash
SUCCESS: WeCrossProxy:xxxxxxxx has been deployed! chain: chains/bcos3
SUCCESS: WeCrossHub:xxxxxxxx has been deployed! chain: chains/bcos3
```

### 4.2 国密链

```shell

# 部署代理合约
bash deploy_system_contract.sh -t BCOS3_GM_EVM -c chains/bcos -P

# 部署桥接合约
bash deploy_system_contract.sh -t BCOS3_GM_EVM -c chains/bcos -H

# 若后续有更新系统合约的需求，首先更新conf/chains/bcos3下的系统合约代码，在上述命令添加-u参数，执行并重启跨链路由
```

部署成功，则输出如下内容。若失败可查看提示信息和错误日志。

``` bash
SUCCESS: WeCrossProxy:xxxxxxxx has been deployed! chain: chains/bcos3
SUCCESS: WeCrossHub:xxxxxxxx has been deployed! chain: chains/bcos3
```
