# 接入 FISCO BCOS 2.0

WeCross BCOS2 Stub 是 WeCross Router的插件，让Router具备接入FISCO-BCOS 2.0的能力。关于该插件包含下列方面内容：

* 跨链合约
* 插件安装
* 账户配置
* 插件配置
* 代理合约配置

```eval_rst
.. important::
    FISCO-BCOS版本需要 >= v2.4.0
```

## 跨链合约

BCOS2 Stub支持任意类型接口的`solidity`合约。

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

在生成router时，默认安装FISCO-BCOS stub插件，安装目录为router下的`plugin`目录：
```bash
plugin/
|-- bcos2-stub-gm-xxxx.jar    # 国密插件
|-- bcos2-stub-xxxx.jar       # 非国密插件
└-- fabric-stub.jar
```

用户如有特殊需求，可以自行编译，替换`plugin`目录下的插件。

### 手动安装

**下载编译**

```shell
git clone https://github.com/WeBankFinTech/WeCross-BCOS2-Stub.git
cd WeCross-BCOS2-Stub
bash gradlew build -x test
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

``` bash
cp dist/apps/* ~/wecross/routers-payment/127.0.0.1-8250-25500/plugin/
```

**注：若router中配置了两个相同的插件，插件冲突，会导致router启动失败。**

[WeCross快速部署](../tutorial/networks.md)

## 账户配置

WeCross中账户用于交易签名，BCOS2 Stub支持`pem`和`p12`两种格式文件。

### 配置路径

WeCross Router账户配置位于`conf/accounts/`目录。每个账户使用单独目录配置，使用账户名称作为子目录名称，每个目录包含`account.toml`配置文件以及配置文件中配置的私钥文件，私钥文件可以为`pem`或者`p12`格式。  

```
// 示例
conf/accounts/
|-- bcos_pem
|   |-- 0x5399e9ca7b444afb537a7a9de2762d17c3c7f63a.pem
|   └-- account.toml
└-- bcos_p12
    |-- 0x0ed9d10e1520a502a41115a4fc8b6e3edb201940.p12
    └-- account.toml
```

上面的示例中配置了两个账户，账户名称分别为: bcos_pem、bcos_p12

### 配置格式

```
// account.toml
[account]
    type = 'BCOS2.0'
    accountFile = '0x15469c4af049c6441f6ef3f8d22d44547031ebea.p12'
    password = '123456'
```

- `type`: 账户类型，`GM_BCOS2.0`或者`BCOS2.0`，`GM_BCOS2.0`表示国密账户，`BCOS2.0`表示非国密账户
- `accountFile`: 私钥文件
- `password`: p12文件密码，pem文件时忽略

### 配置步骤

在router目录下，用`add_account.sh`直接生成账户即可，无需其他手动配置。

```bash
bash add_account.sh -h

Usage:
    -t <type>                           [Required] type of account, BCOS2.0 or GM_BCOS2.0 or Fabric1.4
    -n <name>                           [Required] name of account
    -d <dir>                            [Optional] generated target_directory, default conf/accounts/
    -h                                  [Optional] Help
e.g
    bash add_account.sh -t BCOS2.0 -n my_bcos_account
    bash add_account.sh -t GM_BCOS2.0 -n my_gm_bcos_account
    bash add_account.sh -t Fabric1.4 -n my_fabric_account
```

示例:
``` bash
cd ~/wecross/routers-payment/127.0.0.1-8250-25500/

# 举例1：生成非国密账户,-t 指定使用BCOS2.0插件（非国密插件） -n 设置一个账户名
bash add_account.sh -t BCOS2.0 -n bcos_user1

# 举例2：生成国密账户,-t 指定使用GM_BCOS2.0插件（国密插件） -n 设置一个账户名
bash add_account.sh -t GM_BCOS2.0 -n bcos_gm_user1
```

账户生成至`conf/accounts`目录下

``` bash
conf/accounts/
|-- bcos_pem
|   |-- 0x5399e9ca7b444afb537a7a9de2762d17c3c7f63a.pem
|   └-- account.toml
└-- bcos_p12
    |-- 0x0ed9d10e1520a502a41115a4fc8b6e3edb201940.p12
    └-- account.toml
```

## 接入链配置

stub插件的配置文件为`stub.toml`，作用：
- 配置资源信息
- 配置SDK连接信息，与链进行交互

### 配置路径
```
conf/chains/bcos/
|-- ca.crt
|-- sdk.crt
|-- sdk.key
└-- stub.toml
```

### 配置格式
stub插件的配置文件`stub.toml`格式以及字段含义
```shell
[common]                # 通用配置
    name = 'bcos'       # stub配置名称
    type = 'BCOS2.0'    # stub类型，`GM_BCOS2.0`或者`BCOS2.0`，`GM_BCOS2.0`国密类型，`BCOS2.0`非国密类型

[chain]                 # FISCO-BCOS 链配置
    groupId = 1         # 连接FISCO-BCOS群组id，默认为1
    chainId = 1         # 连接FISCO-BCOS链id，默认为1

[channelService]        # FISCO-BCOS 配置
    caCert = 'ca.crt'   # 根证书
    sslCert = 'sdk.crt' # sdk证书
    sslKey = 'sdk.key'  # sdk私钥
    timeout = 5000      # SDK请求超时时间
    connectionsStr = ['127.0.0.1:20200','127.0.0.2:20200']    # 连接列表

# [[resources]] 资源列表
[[resources]]
    name = 'htlc'           # 资源名称
    type = 'BCOS_CONTRACT'  # 资源类型，BCOS_CONTRACT
    contractAddress = '0x7540601cce8b0802980f9ebf7aeee22bb4d73c22'  # 合约地址
```

```eval_rst
.. important::
    - BCOS2 Stub当前只支持合约类型的资源
```

## 代理合约配置

配置完成后，在router目录下执行命令，部署代理合约，分为国密与非国密的部署。

### 非国密
```shell
Usage:
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.normal.proxy.ProxyContractDeployment check [chainName]
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.normal.proxy.ProxyContractDeployment deploy [chainName] [accountName]
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.normal.proxy.ProxyContractDeployment upgrade [chainName] [accountName]
Example:
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.normal.proxy.ProxyContractDeployment check chains/bcos
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.normal.proxy.ProxyContractDeployment deploy chains/bcos bcos_user1
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.normal.proxy.ProxyContractDeployment upgrade chains/bcos bcos_user1
```

参数：
* command
  * check: 检查代理合约是否部署
  * deploy: 部署代理合约子命令
  * upgrade: 更新大代理合约子命令，表示重新部署代理合约
* chainName: 链名称
* accountName: 发送交易的账户

### 国密
```bash
Usage:
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.guomi.proxy.ProxyContractDeployment check [chainName]
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.guomi.proxy.ProxyContractDeployment deploy [chainName] [accountName]
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.guomi.proxy.ProxyContractDeployment upgrade [chainName] [accountName]
Example:
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.guomi.proxy.ProxyContractDeployment check chains/bcos
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.guomi.proxy.ProxyContractDeployment deploy chains/bcos bcos_user1
         java -cp 'conf/:lib/*:plugin/*' com.webank.wecross.stub.bcos.guomi.proxy.ProxyContractDeployment upgrade chains/bcos bcos_user1
```

* command
  * check: 检查代理合约是否部署
  * deploy: 部署代理合约子命令
  * upgrade: 更新大代理合约子命令，表示重新部署代理合约
* chainName: 链名称
* accountName: 发送交易的账户

## 参考链接

[WeCross-BCOS2-Stub](https://github.com/WeBankFinTech/WeCross-BCOS2-Stub)  

[FISCO BCOS 环境搭建参考](https://fisco-bcos-documentation.readthedocs.io/zh_CN/latest/docs/installation.html#fisco-bcos)

[FISCO-BCOS JavaSDK文档](https://fisco-bcos-documentation.readthedocs.io/zh_CN/latest/docs/sdk/java_sdk.html)

[FISCO-BCOS Console文档](https://fisco-bcos-documentation.readthedocs.io/zh_CN/latest/docs/manual/console.html)