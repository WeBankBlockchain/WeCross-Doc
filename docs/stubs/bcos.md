# 接入FISCO BCOS 2.0

[WeCross-BCOS2-Stub](https://github.com/WeBankFinTech/WeCross-BCOS2-Stub)作为WeCross的插件，让跨链路由具备接入FISCO-BCOS 2.0的能力。关于该插件，本章将介绍以下内容：

* 跨链合约
* 插件安装
* 插件配置
* 系统合约

```eval_rst
.. important::
    FISCO-BCOS版本需要 >= v2.6.0
```

## 跨链合约

WeCross-BCOS2-Stub支持任意类型接口的`solidity`合约。

`HelloWorld`合约示例:

```solidity
pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

contract HelloWorld {
    string s = "Hello World!";

    function set(string memory _s) public returns (string memory) {
        s = _s;
        return s;
    }

    function get() public constant returns(string memory) {
        return s;
    }
}
```

## 插件安装

在构建跨链路由时，默认安装WeCross-BCOS2-Stub插件，位于跨链路由的`plugin`目录：
```bash
plugin/
|-- bcos2-stub-gm-xxxx.jar    # 国密插件
|-- bcos2-stub-xxxx.jar       # 非国密插件
└-- fabric1-stub-xxxx.jar
```

用户如有特殊需求，可以自行编译，替换`plugin`目录下的插件。

### 手动安装

**下载编译**

```shell
git clone https://github.com/WeBankFinTech/WeCross-BCOS2-Stub.git
cd WeCross-BCOS2-StubWeBankBlockchain
bash gradlew assemble
```

WeCross-BCOS2-Stub编译生成两个插件 

- 国密插件
- 非国密插件

```shell
dist/apps
├── bcos2-stub-gm-xxxx.jar    # 国密插件
└── bcos2-stub-xxxx.jar       # 非国密插件
```

**安装插件**
在跨链路由的主目录下创建plugin目录，然后将插件拷贝到该目录下。

``` bash
# 以demo为例
cp dist/apps/* ~/wecross/routers-payment/127.0.0.1-8250-25500/plugin/
```

**注：若跨链路由中配置了两个相同的插件，插件冲突，会导致跨链路由启动失败。**

## 接入链配置

在跨链路由主目录的`conf/chains/[stubName]/`目录下创建插件的配置文件`stub.toml`。配置信息包括：

- 配置资源信息
- 配置SDK连接信息，与链进行交互

### 目录结构
```
conf/chains/[stubName]/
|-- ca.crt
|-- sdk.crt
|-- sdk.key
└-- stub.toml
```

### 配置格式
stub插件的配置文件`stub.toml`格式以及字段含义
```shell
[common]                # 通用配置
    name = 'bcos'       # stub配置名称，即 [stubNmae] = bcos
    type = 'BCOS2.0'    # stub类型，`GM_BCOS2.0`或者`BCOS2.0`，`GM_BCOS2.0`国密类型，`BCOS2.0`非国密类型

[chain]                 # FISCO-BCOS 链配置
    groupId = 1         # 连接FISCO-BCOS群组id，默认为1
    chainId = 1         # 连接FISCO-BCOS链id，默认为1

[channelService]        # FISCO-BCOS 配置，以下文件在BCOS链的nodes/127.0.0.1/sdk目录下拷贝
    caCert = 'ca.crt'   # 根证书
    sslCert = 'sdk.crt' # sdk证书
    sslKey = 'sdk.key'  # sdk私钥
    timeout = 5000      # SDK请求超时时间
    connectionsStr = ['127.0.0.1:20200','127.0.0.2:20200']    # 连接列表

# [[resources]] 资源列表，配置链已有的资源
[[resources]]
    name = 'htlc'           # 资源名称
    type = 'BCOS_CONTRACT'  # 资源类型，BCOS_CONTRACT
    contractAddress = '0x7540601cce8b0802980f9ebf7aeee22bb4d73c22'  # 合约地址

[sealers]        # 可信验证，不配则不验证
    pubKey = []  # 验证者公钥列表
```

```eval_rst
.. important::
    - BCOS2 Stub当前只支持合约类型的资源
```

## 系统合约

每个Stub需要部署两个系统合约，分别是[代理合约]()和[桥接合约]()，代理合约负责管理事务以及业务合约的调用，桥接合约用于记录合约跨链请求。

配置完成后，需要在跨链路由主目录执行以下命令，以安装系统合约。

### 非国密链

**部署代理合约**
```shell
Usage:
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.normal.preparation.ProxyContractDeployment deploy [chainName] [accountName(optional)]
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.normal.preparation.ProxyContractDeployment upgrade [chainName] [accountName(optional)]
Example:
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.normal.preparation.ProxyContractDeployment deploy chains/bcos
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.normal.preparation.ProxyContractDeployment deploy chains/bcos admin
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.normal.preparation.ProxyContractDeployment upgrade chains/bcos
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.normal.preparation.ProxyContractDeployment upgrade chains/bcos admin

```
参数：
* command
  * deploy: 部署代理合约
  * upgrade: 更新代理合约，表示重新部署
* chainName: 链名称
* accountName: 发送交易的账户

**部署桥接合约**

```shell
Usage:
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.normal.preparation.HubContractDeployment deploy [chainName] [accountName(optional)]
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.normal.preparation.HubContractDeployment upgrade [chainName] [accountName(optional)]
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.normal.preparation.HubContractDeployment getAddress [chainName]
Example:
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.normal.preparation.HubContractDeployment deploy chains/bcos
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.normal.preparation.HubContractDeployment deploy chains/bcos admin
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.normal.preparation.HubContractDeployment upgrade chains/bcos
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.normal.preparation.HubContractDeployment upgrade chains/bcos admin
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.normal.preparation.HubContractDeployment getAddress chains/bcos
```

参数：
* command
  * deploy: 部署桥接合约
  * upgrade: 更新桥接合约，表示重新部署
  * getAddress: 获取桥接合约地址
* chainName: 链名称
* accountName: 发送交易的账户

### 国密链

- 部署代理合约

```shell
Usage:
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.guomi.preparation.ProxyContractDeployment deploy [chainName] [accountName(optional)]
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.guomi.preparation.ProxyContractDeployment upgrade [chainName] [accountName(optional)]
Example:
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.guomi.preparation.ProxyContractDeployment deploy chains/bcos
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.guomi.preparation.ProxyContractDeployment deploy chains/bcos admin
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.guomi.preparation.ProxyContractDeployment upgrade chains/bcos
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.guomi.preparation.ProxyContractDeployment upgrade chains/bcos admin

```

- 部署桥接合约

```shell
Usage:
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.guomi.preparation.HubContractDeployment deploy [chainName] [accountName(optional)]
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.guomi.preparation.HubContractDeployment upgrade [chainName] [accountName(optional)]
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.guomi.preparation.HubContractDeployment getAddress [chainName]
Example:
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.guomi.preparation.HubContractDeployment deploy chains/bcos
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.guomi.preparation.HubContractDeployment deploy chains/bcos admin
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.guomi.preparation.HubContractDeployment upgrade chains/bcos
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.guomi.preparation.HubContractDeployment upgrade chains/bcos admin
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.guomi.preparation.HubContractDeployment getAddress chains/bcos
```

## 参考链接

[WeCross-BCOS2-Stub](https://github.com/WeBankFinTech/WeCross-BCOS2-Stub)  

[FISCO BCOS 环境搭建参考](https://fisco-bcos-documentation.readthedocs.io/zh_CN/latest/docs/installation.html#fisco-bcos)

[FISCO-BCOS JavaSDK文档](https://fisco-bcos-documentation.readthedocs.io/zh_CN/latest/docs/sdk/java_sdk.html)

[FISCO-BCOS Console文档](https://fisco-bcos-documentation.readthedocs.io/zh_CN/latest/docs/manual/console.html)WeBankBlockchain