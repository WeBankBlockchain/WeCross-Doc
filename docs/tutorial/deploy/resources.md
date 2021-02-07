# 资源部署与操作

整个跨链网络环境搭建完毕后，就可以基于WeCross控制台部署和操作跨链资源了。

## 部署FISCO BCOS跨链资源

WeCross支持通过控制台向BCOS链上部署合约，部署步骤如下：

- 准备合约代码（以HelloWorld为例）

控制台的合约存放目录：`conf/contracts/solidity/`，目录下已有HelloWorld合约文件，若需部署其它合约，可将合约拷贝至相同位置。

``` bash
tree conf/contracts/solidity/
conf/contracts/solidity/
└── HelloWorld.sol
```

- 启动控制台

``` bash 
cd ~/wecross-networks/WeCross-Console/
bash start.sh
```

- 部署合约

用`bcosDeploy`命令进行部署。

> 参数：ipath，代码目录，合约名，设置一个版本号

``` bash
# 登录
[WeCross]> login org1-admin 123456

# 部署
[WeCross.org1-admin]> bcosDeploy payment.bcos.HelloWorld contracts/solidity/HelloWorld.sol HelloWorld 1.0
Result: 0x953c8f97f9ea5930e6ca8d5eabbd9dfdcb142e6c
```

用`listResources`可查看此资源（`payment.bcos.HelloWorld`）已部署

``` bash
[WeCross.org1-admin]> listResources
path: payment.bcos.HelloWorld, type: BCOS2.0, distance: 0
path: payment.bcos.WeCrossHub, type: BCOS2.0, distance: 0
path: payment.fabric.WeCrossHub, type: Fabric1.4, distance: 1
total: 3
```

## 部署Hyperledger Fabric跨链资源

WeCross支持通过控制台向BCOS链上部署chaincode，部署步骤如下：


- 准备chaincode代码（以sacc为例）

控制台的chaincode存放目录：`conf/contracts/chaincode/`，其中sacc代码放入目录：`conf/contracts/chaincode/sacc`（目录名sacc为chaincode的名字），sacc目录中放置chaincode代码：sacc.go （代码名任意）。

``` bash
tree conf/contracts/chaincode/sacc
conf/contracts/chaincode/sacc
├── policy.yaml
└── sacc.go
```

- 部署chaincode

为不同的Org分别安装（install）相同的chaincode。

``` bash
# 在登录态下，查看默认链账户，可看到Fabric1.4的默认账户是Org2MSP的
[WeCross.org1-admin]> listAccount
Universal Account:
username: org1-admin
pubKey  : 3059301306...
uaID    : 3059301306...
chainAccounts: [
        BCOS2.0 Account:
        keyID    : 0
        type     : BCOS2.0
        address  : 0x4e89af80184147fcddc391c64ad673512236af67
        isDefault: true
        ----------
        Fabric1.4 Account:
        keyID    : 2
        type     : Fabric1.4
        MembershipID : Org2MSP
        isDefault: true
        ----------
        Fabric1.4 Account:
        keyID    : 1
        type     : Fabric1.4
        MembershipID : Org1MSP
        isDefault: false
        ----------
]

# 在向Org1进行install前，设置Fabric1.4的默认账户为Org1MSP，参数：setDefaultAccount Fabric1.4 keyID
[WeCross.org1-admin]> setDefaultAccount Fabric1.4 1

# 给Org1安装sacc，参数：path Org 链码位置 版本号 链码语言
[WeCross.org1-admin]> fabricInstall payment.fabric.sacc Org1 contracts/chaincode/sacc 1.0 GO_LANG
path: classpath:contracts/chaincode/sacc
Result: Success

# 在向Org2进行install前，设置Fabric1.4的默认账户为Org2MSP，参数：setDefaultAccount Fabric1.4 keyID
[WeCross.org1-admin]> setDefaultAccount Fabric1.4 2

# 给Org2安装sacc，参数：path Org 链码位置 版本号 链码语言
[WeCross.org1-admin]> fabricInstall payment.fabric.sacc Org2 contracts/chaincode/sacc 1.0 GO_LANG
path: classpath:contracts/chaincode/sacc
Result: Success
```

实例化（instantiate）指定chaincode。

> 参数：ipath，对应的几个Org，chaincode代码工程目录，指定的版本，chaincode语言，背书策略（此处用默认），初始化参数

``` bash
# fabricInstantiate 时默认Org1MSP或Org2MSP的链账户都可，此处用的Org2MSP
[WeCross.org1-admin]> fabricInstantiate payment.fabric.sacc ["Org1","Org2"] contracts/chaincode/sacc 1.0 GO_LANG default ["a","10"]
Result: Instantiating... Please wait and use 'listResources' to check. See router's log for more information.
```

instantiate请求后，需等待1分钟左右。用`listResources`查看是否成功。若instantiate成功，可查询到资源`payment.fabric.sacc`。

``` bash
[WeCross.org1-admin]> listResources
path: payment.bcos.HelloWorld, type: BCOS2.0, distance: 0
path: payment.fabric.WeCrossHub, type: Fabric1.4, distance: 1
path: payment.bcos.WeCrossHub, type: BCOS2.0, distance: 0
path: payment.fabric.sacc, type: Fabric1.4, distance: 1
total: 4

[WeCross.org1-admin]> quit # 退出控制台
```

## 操作跨链资源

### 查看跨链资源

- 登录

用默认的跨链账户登录：org1-admin，密码：123456。（默认账户在WeCross-Account-Manager/conf/application.toml配置）

``` bash
[WeCross]> login org1-admin 123456
Result: success
=============================================================================================
Universal Account:
username: org1-admin
pubKey  : 3059301306...
uaID    : 3059301306...
```

- 获取资源列表

用`listResources`命令查看WeCross跨链网络中的所有资源。可看到有多个资源：

`payment.bcos.HelloWorld`：对应于FISCO BCOS链上的HelloWorld.sol合约。

`payment.fabric.sacc`：对应于Fabric链上的[sacc.go](https://github.com/hyperledger/fabric-samples/blob/v1.4.4/chaincode/sacc/sacc.go)合约。

`payment.xxxx.WeCrossHub`：每条链默认安装的Hub合约，用于接收链上合约发起的跨链调用。可参考[《合约跨链》](../../dev/interchain.html)

```bash
[WeCross.org1-admin]> listResources
path: payment.bcos.HelloWorld, type: BCOS2.0, distance: 0
path: payment.fabric.WeCrossHub, type: Fabric1.4, distance: 1
path: payment.bcos.WeCrossHub, type: BCOS2.0, distance: 0
path: payment.fabric.sacc, type: Fabric1.4, distance: 1
total: 4
```

### 操作payment.bcos.HelloWorld

- 读资源
  - 命令：`call path 接口名 [参数列表]`
  - 示例：`call payment.bcos.HelloWorld get`

```bash
# 调用HelloWorld合约中的get接口
[WeCross.org1-admin]> call payment.bcos.HelloWorld get
Result: [Hello, World!]
```

- 写资源
  - 命令：`sendTransaction path 接口名 [参数列表]`
  - 示例：`sendTransaction payment.bcos.HelloWeCross set Tom`

```bash
# 调用HelloWeCross合约中的set接口
[WeCross.org1-admin]> sendTransaction payment.bcos.HelloWorld set Tom
Txhash  : 0xd9cefb8c3ba28084583ba340e1d73a37574e1661926c3116729b1ec029f59828
BlockNum: 6
Result  : []     // 将Tom给set进去

[WeCross.org1-admin]> call payment.bcos.HelloWorld get
Result: [Tom]    // 再次get，Tom已set
```

### 操作payment.fabric.sacc

跨链资源是对各个不同链上资源的统一和抽象，因此操作的命令是保持一致的。

- 读资源

```bash
# 调用mycc合约中的query接口
[WeCross.org1-admin]> call payment.fabric.sacc get a
Result: [10] // 初次get，a的值为10
```

- 写资源

```bash
# 调用sacc合约中的set接口
[WeCross.org1-admin]> sendTransaction payment.fabric.sacc set a 666
Txhash  : aa3a7cd62d4b4c56b486f11fae2d903b7f07c2a3fa315ee2b44d5f5c43f5a8dc
BlockNum: 8
Result  : [666]

[WeCross.org1-admin]> call payment.fabric.sacc get a
Result: [666] // 再次get，a的值变成666

# 退出WeCross控制台
[WeCross.org1-admin]> quit # 若想再次启动控制台，cd至WeCross-Console，执行start.sh即可
```

## 访问网页管理平台

除了控制台，还可以通过浏览器访问WeCross网页管理台，实现跨链管理和资源调用。

``` url
http://localhost:8250/s/index.html#/login
```

用demo已配置账户进行登录：`org1-admin`，密码：`123456`

![](../../images/tutorial/page_bcos_fabric.png)

管理台中包含如下内容，点击链接进入相关操作指导。

* [登录/注册](../../manual/webApp.html#id10)
* [平台首页](../../manual/webApp.html#id11)
* [账户管理](../../manual/webApp.html#id12)
* [路由管理](../../manual/webApp.html#id13)
* [资源管理](../../manual/webApp.html#id14)
* [交易管理](../../manual/webApp.html#id15)
* [事务管理](../../manual/webApp.html#id16)

``` eval_rst
.. note::
    - 若需要远程访问，请在router的conf/wecross.toml中，修改[rpc]标签下的address为所需ip（如：0.0.0.0）。保存后，重启router即可。
```
