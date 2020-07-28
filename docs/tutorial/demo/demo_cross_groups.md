# 跨多群组

此Demo搭建了一个WeCross跨链网络，连接FISCO BCOS中的两个群组。用户可通过WeCross控制台，对不同群组的资源进行操作。实际情况下，WeCross接入链的场景不受限制，用户可配置接入多条各种类型的区块链。

![](../../images/tutorial/demo_cross_groups.png)

## 网络部署

在已下载的demo目录下进行操作

```bash
cd demo

#清理旧demo环境
bash clear.sh

# 运行部署脚本，第一次运行需耗时10-30分钟左右
bash build_cross_groups.sh # 若出错，可用 bash clear.sh 清理后重试
```

```eval_rst
.. note::
    - MacOS用户若出现“无法打开”，“无法验证开发者”的情况，可参考 `FAQ问题3 <../../faq/faq.html#id3>`_ 的方式解决
```

部署成功后会输出Demo的网络架构，FISCO BCOS和Fabric通过各自的WeCross Router相连。（输入Y，回车，进入WeCross控制台）

``` 
[INFO] Success! WeCross demo network is running. Framework:

                    FISCO BCOS
        Group 1                    Group 2
   (HelloWorldGroup1)         (HelloWorldGroup2)
           |                          |
           |                          |
    WeCross Router <----------> WeCross Router
(127.0.0.1-8250-25500)      (127.0.0.1-8251-25501)
           |
           |
    WeCross Console
    
Start console? [Y/n]
```

## 操作跨链资源

**查看资源**

进入控制台，用`listResources`命令查看WeCross跨连网络中的所有资源。可看到有两个资源：

* payment.group1.HelloWorldGroup1
  * 对应于Group1上的HelloWorld.sol合约
* payment.group2.HelloWorldGroup2
  * 对应于Group2上的HelloWorld.sol合约

```bash
[WeCross]> listResources
path: payment.group2.HelloWorldGroup2, type: BCOS2.0, distance: 1
path: payment.group1.HelloWorldGroup1, type: BCOS2.0, distance: 0
total: 2
```

**查看账户**

用`listAccounts`命令查看WeCross Router上已存在的账户，操作资源时用相应账户进行操作。

```bash
[WeCross]> listAccounts
name: bcos_user1, type: BCOS2.0
total: 1
```

**操作资源：payment.group1.HelloWorldGroup1**

- 读资源
  - 命令：`call path 账户名 接口名 [参数列表]`
  - 示例：`call payment.group1.HelloWorldGroup1 bcos_user1 get`
  
```bash
# 调用Group1 HelloWorld合约中的get接口
[WeCross]> call payment.group1.HelloWorldGroup1 bcos_user1 get
Result: [Hello, World!] // 初次get，值为Hello World!
```

- 写资源
  - 命令：`sendTransaction path 账户名 接口名 [参数列表]`
  - 示例：`sendTransaction payment.group1.HelloWorldGroup1 bcos_user1 set Tom`

```bash
# 调用Group1 HelloWeCross合约中的set接口
[WeCross]> sendTransaction payment.group1.HelloWorldGroup1 bcos_user1 set Tom
Txhash  : 0xae1f74b6320883600ef4c6885e0a9f9c06f367b6129cbda202cbe61cecac0ed0
BlockNum: 5
Result  : []     // 将Tom给set进去

[WeCross]> call payment.group1.HelloWorldGroup1 bcos_user1 get
Result: [Tom]    // 再次get，Tom已set
```

**操作资源：payment.group2.HelloWorldGroup2**

跨链资源是对各个不同链上资源的统一和抽象，因此操作的命令是保持一致的。

- 读资源

```bash
# 调用Group2 HelloWorld合约中的get接口
[WeCross]> call payment.group2.HelloWorldGroup2 bcos_user1 get
Result: [Hello, World!] // 初次get，值为Hello World!
```

- 写资源

```bash
# 调用Group2 HelloWeCross合约中的set接口
[WeCross]> sendTransaction payment.group2.HelloWorldGroup2 bcos_user1 set Jerry
Txhash  : 0xde7bf37a61478788727f9c5caccca96a478055fb440eee588d76e22cbc232bc5
BlockNum: 5
Result  : []     // 将Jerry给set进去

[WeCross]> call payment.group2.HelloWorldGroup2 bcos_user1 get
Result: [Jerry]    // 再次get，Jerry已set

# 检查Group1资源，不会因为Group2的资源被修改而改变
[WeCross]> call payment.group1.HelloWorldGroup1 bcos_user1 get
Result: [Tom]

# 退出WeCross控制台
[WeCross]> quit # 若想再次启动控制台，cd至WeCross-Console，执行start.sh即可
```

WeCross Console是基于WeCross Java SDK开发的跨链应用。搭建好跨链网络后，可基于WeCross Java SDK开发更多的跨链应用，通过统一的接口对各种链上的资源进行操作。

## 清理 Demo

为了不影响其它章节的体验，可将搭建的Demo清理掉。

``` bash
cd ~/demo/
bash clear.sh
```

至此，恭喜你，快速体验完成！可进入[手动组网](../networks.md)章节深入了解更多细节。

