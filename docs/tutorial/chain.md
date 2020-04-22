## 接入区块链

完成了WeCross的部署，如何让它和一条真实的区块链交互，相信优秀的您一定在跃跃欲试。接下来的教程将以**接入FISCO BCOS**为例介绍如何体验WeCross+区块链。

#### 搭链FISCO BCOS链

若已有搭建好的FISCO BCOS链，请忽略本小节。

FISCO BCOS官方提供了一键搭链的教程，详见[单群组FISCO BCOS联盟链的搭建](https://fisco-bcos-documentation.readthedocs.io/zh_CN/latest/docs/installation.html)

详细步骤如下：

- 脚本建链

```bash
# 创建操作目录
cd ~ && mkdir -p fisco && cd fisco

# 下载build_chain.sh脚本
curl -LO https://github.com/FISCO-BCOS/FISCO-BCOS/releases/download/v2.2.0/build_chain.sh && chmod u+x build_chain.sh

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

`HelloWeCross.sol`位于`~/wecross/routers-payment/127.0.0.1-8250-25500/conf/stubs-sample/bcos/`

控制台安装配置完后启动并部署`HelloWeCross.sol`，返回的合约地址在之后的WeCross配置中需要用到。详细步骤如下：

- 安装控制台

```bash
# 获取控制台并回到fisco目录
cd ~/fisco && bash <(curl -s https://raw.githubusercontent.com/FISCO-BCOS/console/master/tools/download_console.sh)

# 拷贝控制台配置文件
# 若节点未采用默认端口，请将文件中的20200替换成节点对应的channle端口。
cp -n console/conf/applicationContext-sample.xml console/conf/applicationContext.xml

# 配置控制台证书
cp nodes/127.0.0.1/sdk/* console/conf/
```
- 拷贝合约文件

将`HelloWeCross`合约拷贝至控制台目录（用控制台部署）

```bash
cp ~/wecross/routers-payment/127.0.0.1-8250-25500/conf/chains-sample/bcos/HelloWeCross.sol console/contracts/solidity/
```

- 启动控制台
```bash
cd ~/fisco/console && bash start.sh
```

输出下述信息表明启动成功 否则请检查`conf/applicationContext.xml`中节点端口配置是否正确
```bash
=============================================================================================
Welcome to FISCO BCOS console(1.0.3)！
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
contract address: 0x04ae9de7bc7397379fad6220ae01529006022d1b
```

将HelloWeCross的合约地址记录下来，后续步骤中使用：`contract address: 0x04ae9de7bc7397379fad6220ae01529006022d1b`

#### 配置FISCO BCOS Connection

完成了FISCO BCOS的搭建以及合约的部署，要完成WeCross和FISCO BCOS的交互，需要配置FISCO BCOS connection，即配置连接信息以及链上的[资源](../introduction/introduction.html#id2)。

- 生成stub配置文件

切换至跨链路由的目录，用 [generate_connection.sh](../manual/scripts.html#fisco-bcos-stub) 脚本在`conf`目录下生成FISCO BCOS connection的配置文件框架。

```bash
cd ~/wecross/routers-payment/127.0.0.1-8250-25500
bash generate_connection.sh -t BCOS2.0 -n bcos
```

```eval_rst
.. note::
    - -n指定connection的名字（即此链在跨链分区中的名字），默认在跨链路由的conf/stubs目录下生成相关的配置框架。
```

命令执行成功会输出`operator: connection type: BCOS2.0 path: conf/stubs//bcos`；如果执行出错，请查看屏幕打印提示。

生成的目录结构如下：

```bash
my_bcos_connection/
└── stub.toml          # 连接配置文件
```

之后只需要配置证书、群组以及资源信息。

- 配置证书

将FISCO BCOS节点的证书目录`127.0.0.1/sdk`下的`ca.crt, sdk.key, sdk.crt`文件拷贝到`conf/stubs/bcos`目录下。

```bash
cp ~/fisco/nodes/127.0.0.1/sdk/* conf/stubs/bcos/
```

- 配置群组

```bash
vi conf/stubs/bcos/stub.toml
```

如果搭FISCO BCOS链采用的都是默认配置，那么将会得到一条单群组四节点的链，群组ID为1，各个节点的channel端口分别为`20200, 20201, 20202, 20203`，则配置如下：
```toml
[channelService]
    timeout = 60000  # millisecond
    caCert = 'ca.crt'
    sslCert = 'sdk.crt'
    sslKey = 'sdk.key'
    groupId = 1
    connectionsStr = ['127.0.0.1:20200','127.0.0.1:20201','127.0.0.1:20202','127.0.0.1:20203']
```

- 配置合约资源

在`stub.toml`文件中配置HelloWeCross合约资源信息，让此跨链路由能够访问此合约。**并将配置中多余无用的举例删除**。

在前面的步骤中，已经通过FISCO BCOS控制台部署了一个`HelloWeCross`合约，地址为`0x04ae9de7bc7397379fad6220ae01529006022d1b`

```toml 
[[resources]]
    # name cannot be repeated
    name = 'HelloWeCross'
    type = 'BCOS_CONTRACT'
    contractAddress = '0x04ae9de7bc7397379fad6220ae01529006022d1b'
```

完成了上述的步骤，那么已经完成了FISCO BCOS stub的连接配置，并注册了一个合约资源，最终的`stub.toml`文件如下。[参考此处获取更详尽的配置说明](../manual/scripts.html#fisco-bcos-stub)

```toml
[common]
    name = 'bcos' # stub must be same with directory name
    type = 'BCOS2.0' # BCOS

[chain]
    groupId = 1 # default 1
    chainId = 1 # default 1
    enableGM = false # default false

[channelService]
    caCert = 'ca.crt'
    sslCert = 'sdk.crt'
    sslKey = 'sdk.key'
    timeout = 300000  # ms, default 60000ms
    connectionsStr = ['127.0.0.1:20200','127.0.0.1:20201','127.0.0.1:20202','127.0.0.1:20203']

# resources is a list
[[resources]]
    # name cannot be repeated
    name = 'HelloWeCross'
    type = 'BCOS_CONTRACT'
    contractAddress = '0x04ae9de7bc7397379fad6220ae01529006022d1b'
```

- 重新启动跨链路由
启动跨链路由加载配置好的跨链资源。

```bash
# 若WeCross跨链路由未停止，需要先停止
bash stop.sh

# 重新启动
bash start.sh
```

#### 控制台访问跨链资源

- 启动控制台

```bash
cd ~/wecross/WeCross-Console
bash start.sh
```

可以通过`listResources`命令查看当前连接的WeCross已配置的资源，可以通过`call, sendTransaction`等命令实现合约资源的调用。

具体的命令列表与含义详见[控制台命令](../manual/console.html#id13)。

- 查看已有资源

可查看到，[跨链分区](../introduction/introduction.html#id2)中有一个[跨链资源](../introduction/introduction.html#id2)，其跨链资源标识[path](../introduction/introduction.html#id2)是`payment.bcos.HelloWeCross`

```bash
[server1]> listResources
path: payment.bcos.HelloWeCross, type: BCOS2.0, distance: 0
```

- 调用 [HelloWeCross.sol](https://github.com/WeBankFinTech/WeCross/blob/master/src/main/resources/stubs-sample/bcos/HelloWeCross.sol) 合约

用[path](../introduction/introduction.html#id2)调用部署到链上的HelloWeCross合约

``` bash
# payment.bcos.HelloWeCross为跨链资源标识
[server1]> call payment.bcos.HelloWeCross bcos_user1 get
Result: [Talk is cheap, Show me the code]

# 方法名后面是参数列表，字符串需要有单引号或者双引号
[WeCross]> sendTransaction payment.bcos.HelloWeCross bcos_user1 set hello wecross
Txhash  : 0x66f94d387df2b16bea26e6bcf037c23f0f13db28dc4734588de2d57a97051c54
BlockNum: 2219
Result  : [hello, wecross]
```

#### 退出控制台
[server1]> q
```

停止跨链路由

``` bash
cd ~/wecross/routers-payment/127.0.0.1-8250-25500
bash stop.sh
```

