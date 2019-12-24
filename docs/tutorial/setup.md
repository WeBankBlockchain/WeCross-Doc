## 快速部署
如果环境件已准备就绪，接下来的教程将带领您快速部署WeCross。

- 创建操作目录

```bash
cd ~ && mkdir -p wecross && cd wecross
```

- 下载`build_wecross.sh`脚本

```bash
curl -LO https://raw.githubusercontent.com/WeBankFinTech/WeCross/release-0.2/scripts/build_wecross.sh
```

### 部署WeCross

在不接入何链的情况下，部署一个WeCross跨链路由，并调用其自带的测试资源，检查跨链组件是否正常运行。

#### 构建跨链路由

在`WeCross`目录下执行下面的指令，部署一个WeCross跨链路由。请确保机器的`8250, 25500`端口没有被占用。

```bash
bash build_wecross.sh -n payment -l 127.0.0.1:8250:25500 -T
```

```eval_rst
.. note::
    - -n 指定跨链网络标识符(network id)，跨链网络通过network id进行区分，可以理解为业务名称。
    - -l 指定此WeCross跨链路由的ip地址，rpc端口，p2p端口。
    - -T 启用测试资源，它不属于任何一条链，仅用户测试跨链服务是否正常运行。
    详细的使用教程详见 `Build WeCross脚本 <../manual/scripts.html#wecross>`_。
```

命令执行成功，在`wecross/routers`目录下，生成了一个跨链路由`127.0.0.1-8250-25500`，输出如下信息：

``` bash
[INFO] All completed. WeCross routers are generated in: routers/
```

生成的WeCross跨链路由目录内容如下

```bash
# 已屏蔽lib目录，该目录存放所有依赖的jar包
.
├── apps
│   └── WeCross.jar         # WeCross路由jar包
├── build_wecross.sh
├── conf                    # 配置文件目录
│   ├── application.properties	
│   ├── log4j2.xml 
│   ├── p2p                 # p2p证书目录
│   │   ├── ca.crt          # 根证书
│   │   ├── node.crt        # 跨链路由证书
│   │   ├── node.key        # 跨链路由私钥
│   │   └── node.nodeid     # 跨链路由nodeid
│   ├── stubs               # stub配置目录，要接入不同的链，在此目录下进行配置
│   └── wecross.toml        # 根配置
├── start.sh                # 启动脚本
└── stop.sh                 # 停止脚本
```

#### 启动跨链路由

```bash
cd routers/127.0.0.1-8250-25500/
bash start.sh
```
启动成功

```
WeCross booting up .........
WeCross start successfully
```
如果启动失败，检查`8250, 25500`端口是否被占用

``` shell
netstat -an | grep tcp
```

查看失败日志

```bash
cat logs/error.log
```

#### 检查服务
WeCross模拟了一个用于测试的合约资源，可通过访问测试资源的status接口，确认服务是否正常。
``` bash
curl http://127.0.0.1:8250/test-network/test-stub/test-resource/status

# 如果输出如下内容，说明跨链路由服务已完全启动
{"version":"0.2","result":0,"message":null,"data":"exists"}%  
```

#### 停止服务
通过停止脚本`stop.sh`停止跨链路由服务，该脚本也位于`127.0.0.1-8250-25500`目录。

```bash 
bash stop.sh
```

### 体验WeCross+区块链

完成了WeCross的部署，如何让它和一条真实的区块链交互，相信优秀的您一定在跃跃欲试。接下来的教程将以**接入FISCO BCOS**为例介绍如何体验WeCross+区块链。

#### 一键搭链

若已有搭建好的FISCO BCOS链，请忽略本小节。

FISCO BCOS官方提供了一键搭链的教程，详见[单群组FISCO BCOS联盟链的搭建](https://fisco-bcos-documentation.readthedocs.io/zh_CN/latest/docs/installation.html)

详细步骤如下：

- 脚本建链

```bash
# 创建操作目录
cd ~ && mkdir -p fisco && cd fisco

# 下载build_chain.sh脚本
curl -LO https://github.com/FISCO-BCOS/FISCO-BCOS/releases/download/v2.1.0/build_chain.sh && chmod u+x build_chain.sh

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

`HelloWeCross.sol`位于`~/wecross/routers/127.0.0.1-8250-25500/conf/stubs-sample/bcos/`

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

```bash
cp ~/wecross/routers/127.0.0.1-8250-25500/conf/stubs-sample/bcos/HelloWeCross.sol console/contracts/solidity/
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

#### 配置FISCO BCOS stub

完成了FISCO BCOS的搭建以及合约的部署，要完成WeCross和FISCO BCOS的交互，需要配置FISCO BCOS stub，即配置连接信息以及链上的资源。

- 生成配置文件
返回跨链路由的目录，并运行`create_bcos_stub_config.sh`脚本，在`conf`目录下生成FISCO BCOS stub的配置文件。

```bash
cd ~/wecross/routers/127.0.0.1-8250-25500
bash create_bcos_stub_config -n bcos
```

```eval_rst
.. note::
    - -n指定区块链跨链标识，即stub的名字；同时也会在-r指定的目录下生成与stub相同名字的目录来保存配置文件。
    详细的使用教程见 `Stubs配置脚本 <../manual/scripts.html#fisco-bcos-stub>`_。
```

命令执行成功会输出`[INFO] Create conf/stubs/bcos/stub.toml successfully`；如果执行出错，请查看屏幕打印提示。

生成的目录结构如下：

```bash
├── stubs
│   └── bcos
│       ├── 0x5c9505d9e2c5c5c21a33187475baf5f512e02cc1.pem
│       └── stub.toml

```

在`conf/stubs/bcos`目录下的`.pem`文件即FISCO BCOS的账户文件，已自动配置在了`stub.toml`文件中，之后只需要配置证书、群组以及资源信息。

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
    caCert = 'classpath:/stubs/bcos/ca.crt'
    sslCert = 'classpath:/stubs/bcos/sdk.crt'
    sslKey = 'classpath:/stubs/bcos/sdk.key'
    groupId = 1
    connectionsStr = ['127.0.0.1:20200','127.0.0.1:20201','127.0.0.1:20202','127.0.0.1:20203']
```

- 配置合约资源

在前面的步骤中，已经通过FISCO BCOS控制台部署了一个`HelloWorld`合约，地址为`0x04ae9de7bc7397379fad6220ae01529006022d1b`

那么可在`stub.toml`文件中注册一条合约资源信息：

```toml 
[[resources]]
    # name cannot be repeated
    name = 'HelloWeCross'
    type = 'BCOS_CONTRACT'
    contractAddress = '0x04ae9de7bc7397379fad6220ae01529006022d1b'
```

完成了上述的步骤，那么已经完成了FISCO BCOS stub的连接配置，并注册了一个合约资源，最终的`stub.toml`文件如下：

```toml 
[common]
    stub = 'bcos' # stub must be same with directory name
    type = 'BCOS'

[smCrypto]
    # boolean
    enable = false

[account]
    accountFile = 'classpath:/stubs/bcos/0x0ee5b8ee4af461cac320853aebb7a68d3d4858b4.pem'
    password = ''  # if you choose .p12, then password is required


[channelService]
    timeout = 60000  # millisecond
    caCert = 'classpath:/stubs/bcos/ca.crt'
    sslCert = 'classpath:/stubs/bcos/sdk.crt'
    sslKey = 'classpath:/stubs/bcos/sdk.key'
    groupId = 1
    connectionsStr = ['127.0.0.1:20200','127.0.0.1:20201','127.0.0.1:20202','127.0.0.1:20203']

# resources is a list
[[resources]]
    # name must be unique
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

#### 安装WeCross控制台

WeCross提供了控制台，方便用户进行跨链开发和调试。可通过脚本`build_console.sh`搭建一个WeCross控制台。

- 下载脚本

```bash
cd ~/wecross
curl -LO https://raw.githubusercontent.com/WeBankFinTech/WeCross-Console/dev/scripts/build_console.sh
```

- 搭建控制台

控制台需要配置所有连接的WeCross的IP和端口信息。

```bash
bash build_console.sh
```

如果构建成功，将输入以下信息：
```bash
[INFO] Build WeCross console successfully
```

```eval_rst
.. important::
    - 若搭建WeCross的IP和端口未使用默认配置，需自行更改console/conf/console.xml，详见 `控制台配置 <../manual/console.html#id11>`_。
```

- 启动控制台

```bash
cd console
bash start.sh
```

启动成功则输出如下信息，通过`-h`可查看控制台帮助

```bash
=================================================================================
Welcome to WeCross console(0.2)!
Type 'help' or 'h' for help. Type 'quit' or 'q' to quit console.
=================================================================================
```

#### 控制台访问跨链资源

可以通过`listResources`命令查看当前连接的WeCross已配置的资源，可以通过`call, sendTransaction`等命令实现合约资源的调用。具体的命令列表与含义详见[控制台命令](../manual/console.html#id13)


- 查看已有资源

```bash
[server1]> listResources
Resources{
    errorCode=0,
    errorMessage='',
    resourceList=[
        WeCrossResource{
            checksum='0xee1892309d5367c1c3bf5e9d76f312b4134b3209d88048302950bf0dc9395a85',
            type='BCOS_CONTRACT',
            distance=0,
            path='payment.bcos.HelloWeCross'
        },
        WeCrossResource{
            checksum='0x7644243d71d1b1c154c717075da7bfe2d22bb2a94d7ed7693ab481f6cb11c756',
            type='TEST_RESOURCE',
            distance=0,
            path='test-network.test-stub.test-resource'
        }
    ]
}
```

- 调用`HelloWecross`合约

``` bash
# payment.bcos.HelloWeCross为跨链资源标识IPath
# String为返回值类型，多个返回值类型用逗号隔开，不能有空格
# getMessage为合约中的方法名
[server1]> call payment.bcos.HelloWeCross String getMessage
Receipt{
    errorCode=0,
    errorMessage='success',
    hash='null',
    result=[
        Hello WeCross
    ]
}

# 方法名后面是参数列表，字符串需要有单引号或者双引号
[server1]> sendTransaction payment.bcos.HelloWeCross Int,String setNumAndMsg 123 "Hello World"
Receipt{
    errorCode=0,
    errorMessage='null',
    hash='0x1905f928b980209288280c071ff3574bacc23bbc49538f24325ac07db20133b5',
    result=[
        123,
        Hello World
    ]
}

[server1]> call payment.bcos.HelloWeCross Int,IntArray,String,StringArray getAll
Receipt{
    errorCode=0,
    errorMessage='success',
    hash='null',
    result=[
        10086,
        [
            1,
            2,
            3
        ],
        Hello World,
        [
            Bei Bei,
            Jing Jing,
            Huan Huan,
            Ying Ying
        ]
    ]
}
```
