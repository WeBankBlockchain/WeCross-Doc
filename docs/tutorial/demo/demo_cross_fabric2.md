# 跨平台 FISCO BCOS & Fabric2

此Demo搭建了一个WeCross跨链网络，连接FISCO BCOS和Hyperledger Fabric2区块链。用户可通过WeCross控制台，对不同的链上资源进行操作。

![](../../images/tutorial/demo.png)

## 网络部署

在已下载的demo目录下进行操作

```bash
cd ~/wecross-demo

#清理旧demo环境
bash clear.sh

# 运行部署脚本，输入数据库账号密码，第一次运行需耗时10-30分钟左右
bash build_cross_fabric2.sh # 若出错，可用 bash clear.sh 清理后重试。bash build_cross_fabric2.sh -h 可查看更多用法
```

```eval_rst
.. important::
    - 若出现“command not found”， 则说明缺少依赖，请参考 `环境要求 <../env.html#id4>`_ 安装相关依赖
    - macOS用户若出现“无法打开”，“无法验证开发者”的情况，可参考 `FAQ问题3 <../../faq/faq.html#id3>`_ 的方式解决
    - 输入数据库IP时，若"127.0.0.1"无法成功，请尝试输入"localhost"
    - 若出现其它问题，请参考常见问题说明 `FAQ <../../faq/faq.html#>`_
```

部署成功后会输出Demo的网络架构，FISCO BCOS和Fabric2通过各自的WeCross Router相连。（输入Y，回车，进入WeCross控制台）

```bash
[INFO] Success! WeCross demo network is running. Framework:

            FISCO BCOS                    Fabric2
           (4node pbft)              (test-network)
          (HelloWorld.sol)              (sacc.go)
                 |                          |
                 |                          |
                 |                          |
          WeCross Router <----------> WeCross Router <----------> WeCross Account Manager
      (127.0.0.1-8250-25500)      (127.0.0.1-8251-25501)             (127.0.0.1:8340)
          /            \
         /              \
        /                \
 WeCross WebApp     WeCross Console

Start WeCross Console? [Y/n]
```

## 操作跨链资源

**登录跨链账户**

进入控制台，首先登录跨链账户。（Demo中已配置好一个账户：org1-admin，密码：123456）

``` groovy
[WeCross]> login org1-admin 123456
Result: success
=============================================================================================
Universal Account:
username: org1-admin
pubKey  : 3059301306...
uaID    : 3059301306...
```

**查看账户**

用`listAccount`命令查看此跨链账户下，向不同类型的链发送交易的链账户。

``` gr
[WeCross.org1-admin]> listAccount
Universal Account:
username: org1-admin
pubKey  : 3059301306...
uaID    : 3059301306...
chainAccounts: [
        BCOS2.0 Account:
        keyID    : 0
        type     : BCOS2.0
        address  : 0x347271c6b24cb9ee6c7c18fd258f83a03bd6d3df
        isDefault: true
        ----------
        Fabric2.0 Account:
        keyID    : 2
        type     : Fabric2.0
        MembershipID : Org2MSP
        isDefault: true
        ----------
        Fabric2.0 Account:
        keyID    : 1
        type     : Fabric2.0
        MembershipID : Org1MSP
        isDefault: false
        ----------
]
```

**查看资源**

用`listResources`命令查看WeCross跨连网络中的所有资源。可看到已经部署了多个资源：

* `payment.bcos.HelloWorld`
  * 对应于FISCO BCOS链上的HelloWorld.sol合约
* `payment.fabric2.sacc`
  * 对应于Fabric链上的[sacc.go](https://github.com/hyperledger/fabric-samples/blob/v1.4.4/chaincode/sacc/sacc.go)合约
* `payment.xxxx.WeCrossHub`
  * 每条链默认安装的Hub合约，用于接收链上合约发起的跨链调用，可参考[《合约跨链》](../../dev/interchain.html)

```bash
[WeCross.org1-admin]> listResources
path: payment.bcos.HelloWorld, type: BCOS2.0, distance: 0
path: payment.bcos.WeCrossHub, type: BCOS2.0, distance: 0
path: payment.fabric2.WeCrossHub, type: Fabric2.0, distance: 1
path: payment.fabric2.sacc, type: Fabric2.0, distance: 1
total: 4
```

**操作资源：payment.bcos.HelloWorld**

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
Txhash  : 0x7043064899fa48b6c3138f545ecf0f8d6f823d45e0783406bc2afe489061c77c
BlockNum: 6
Result  : []     // 将Tom给set进去

[WeCross.org1-admin]> call payment.bcos.HelloWorld get
Result: [Tom]    // 再次get，Tom已set
```

**操作资源：payment.fabric2.sacc**

跨链资源是对各个不同链上资源的统一和抽象，因此操作的命令是保持一致的。

- 写资源

```bash
# 调用sacc合约中的set接口
[WeCross.org1-admin]> sendTransaction payment.fabric2.sacc set a 666
Txhash  : 85dd6c2c76b959cd5d6d5c60d1f4bc509df4c84a48ef7066f6c66bd59b67c6be
BlockNum: 14
Result  : [666]
```

* 读资源

``` bash
[WeCross.org1-admin]> call payment.fabric2.sacc get a
Result: [666] // get，a的值已是666

# 退出WeCross控制台
[WeCross.org1-admin]> quit # 若想再次启动控制台，cd至WeCross-Console，执行start.sh即可
```

WeCross Console是基于WeCross Java SDK开发的跨链应用。搭建好跨链网络后，可基于WeCross Java SDK开发更多的跨链应用，通过统一的接口对各种链上的资源进行操作。

## 访问网页管理平台

浏览器访问`router-8250`的网页管理平台

``` url
http://localhost:8250/s/index.html#/login
```

用demo已配置账户进行登录：`org1-admin`，密码：`123456`

![](../../images/tutorial/page_bcos_fabric.png)

管理台中包含如下内容，点击链接进入相关操作指导。

* [登录/注册](../../manual/webApp.html#id11)
* [平台首页](../../manual/webApp.html#id12)
* [账户管理](../../manual/webApp.html#id13)
* [路由管理](../../manual/webApp.html#id14)
* [资源管理](../../manual/webApp.html#id15)
* [交易管理](../../manual/webApp.html#id16)
* [事务管理](../../manual/webApp.html#id17)

``` eval_rst
.. note::
    - 若需要远程访问，请修改router的主配置（如：~/demo/routers-payment/127.0.0.1-8250-25500/conf/wecross.toml）， 将 ``[rpc]`` 标签下的 ``address`` 修改为所需ip（如：0.0.0.0）。保存后，重启router即可。
```

## 清理 Demo

为了不影响其它章节的体验，可将搭建的Demo清理掉。

``` bash
cd ~/wecross-demo/
bash clear.sh

# 可使用脚本drop_account_database.sh删除MySQL中demo使用的数据库
bash drop_account_database.sh

# Tips: 可选用配置MySQl参数，进行无交互式部署, 详情请参考下述脚本输出
bash drop_account_database.sh -h

Drop wecross-account-manager database named wecross_account_manager.
Usage:
    -d                              [Optional] Use default db configuration: -H 127.0.0.1 -P 3306 -u root -p 123456
    -H                              [Optional] DB ip
    -P                              [Optional] DB port
    -u                              [Optional] DB username
    -p                              [Optional] DB password
    -h  call for help
e.g
    bash drop_account_database.sh -H 127.0.0.1 -P 3306 -u root -p 123456
    bash drop_account_database.sh
```

至此，恭喜你，快速体验完成！可进入[手动组网](../deploy/index.md)章节深入了解更多细节。
