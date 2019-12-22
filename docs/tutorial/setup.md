## 快速部署
如果环境件已准备就绪，接下来的教程将带领您快速部署WeCross。

- 创建操作目录

```bash
cd ~ && mkdir -p WeCross && cd WeCross
```

- 下载`build_wecross.sh`脚本

```bash
curl -LO https://raw.githubusercontent.com/WeBankFinTech/WeCross/release-0.2/scripts/build_wecross.sh && chmod u+x build_wecross.sh
```

### 部署WeCross

部署一个WeCross跨链路由，并调用其自带的测试资源，了解WeCross的部署和调用过程。在不接入何链的情况下，WeCross跨链路由自带了一个测试资源的调用接口，模拟了一个跨链资源，可用作测试跨链组件是否正常运行。

#### 构建WeCross

在WeCross目录下执行下面的指令，部署一个WeCross跨链路由。请确保机器的`8250, 25500`端口没有被占用。

```bash
bash build_wecross.sh -n payment -l 127.0.0.1:8250:25500 -T
```

```eval_rst
.. note::
    - -n 指定跨链网络标识符（network id），跨链网络通过network id进行区分
    - -l 指定此WeCross跨链路由的ip地址，rpc端口，p2p端口
    - -T 启用测试资源
    详细的使用教程详见[Build WeCross脚本]()。
```

命令执行成功，跨链路由生成至`wecross/`目录下，生成了一个跨链路由`127.0.0.1-8250-25500`

``` 
[INFO] All completed. WeCross routers are generated in: wecross/
wecross
├── 127.0.0.1-8250-25500
└── cert
```

生成的WeCross跨链路由目录内容如下

```bash
tree wecross/127.0.0.1-8250-25500/ -I "lib"
.
├── apps
│   └── WeCross.jar         # WeCross路由jar包
├── build_wecross.sh
├── conf                    # 配置文件目录
│   ├── application.properties	
│   ├── log4j2.xml
│   ├── p2p                 # p2p证书目录
│   │   ├── ca.crt              # 根证书
│   │   ├── node.crt            # 跨链路由证书
│   │   ├── node.key            # 跨链路由私钥
│   │   └── node.nodeid         # 跨链路由nodeid
│   ├── stubs               # stub配置目录，要接入不同的链，在此目录下进行配置
│   └── wecross.toml        # 根配置
├── start.sh                # 启动脚本
└── stop.sh                 # 停止脚本
```

#### 启动WeCross

```bash
cd wecross/127.0.0.1-8250-25500/
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

#### 启动控制台

WeCross提供了控制台，方便用户进行跨链开发和调试。

- 下载编译

```bash
cd ~
git clone https://github.com/WeBankFinTech/WeCross-Console.git
cd WeCross-Console
./gradlew assemble
```

- 配置

控制台需要配置所有连接的WeCross的IP和端口信息。

```bash
cd dist
cp conf/console-sample.xml conf/console.xml
```

```eval_rst
.. note::
    - 若搭建WeCross的IP和端口未使用默认配置，拷贝完配置文件后，需自行更改，详见[控制台配置]()
```

- 启动控制台

```bash
bash start.sh
```

启动成功则输出如下信息，通过`-h`可查看控制台帮助

```bash
=================================================================================
Welcome to WeCross console(0.2)!
Type 'help' or 'h' for help. Type 'quit' or 'q' to quit console.
=================================================================================
```

#### 操作测试资源

具体的控制台命令列表与含义详见[控制台命令]()

- 查看已有资源

返回的`path='test-network.test-stub.test-resource'`是测试资源的UBI，后续通过此UBI操作测试资源

```bash
[server1]> listResources
Resources{
    errorCode=0,
    errorMessage='',
    resourceList=[
        WeCrossResource{
            checksum='0x7644243d71d1b1c154c717075da7bfe2d22bb2a94d7ed7693ab481f6cb11c756',
            type='TEST_RESOURCE',
            distance=0,
            path='test-network.test-stub.test-resource'
        }
    ]
}
```

* 操作测试资源

调用测试资源的`call`接口

``` bash
[server1]> call test-network.test-stub.test-resource String get
Receipt{
    errorCode=0,
    errorMessage='call test resource success',
    hash='010157f4',
    result=[
        {
            sig=,
            retTypes=[
                String
            ],
            method=get,
            args=[

            ]
        }
    ]
}
```

调用测试资源的`sendTransaction`接口

``` bash
[server1]> sendTransaction test-network.test-stub.test-resource String,Int set "Hello World" 12580
Receipt{
    errorCode=0,
    errorMessage='sendTransaction test resource success',
    hash='010157f4',
    result=[
        {
            sig=,
            retTypes=[
                String,
                Int
            ],
            method=set,
            args=[
                Hello World,
                12580
            ]
        }
    ]
}
```

* 退出控制台

``` shell
[server1]> quit
```

- 停止WeCross跨链路由

进入跨链路由目录，停止跨链路由

```bash 
cd ~/WeCross/wecross/127.0.0.1-8250-25500/
bash stop.sh
```

### 体验WeCross+区块链

完成了WeCross的部署，如何让它和一条真实的区块链交互，相信优秀的您一定在跃跃欲试。接下来的教程将以**接入FISCO BCOS**为例介绍如何体验WeCross+区块链。

#### 一键搭链

FISCO BCOS官方提供了一键搭链的教程，详见[单群组FISCO BCOS联盟链的搭建](https://fisco-bcos-documentation.readthedocs.io/zh_CN/latest/docs/installation.html)

#### 部署HelloWorld合约

FISCO BCOS控制台的安装和使用详见官方文档[配置及使用控制台](https://fisco-bcos-documentation.readthedocs.io/zh_CN/latest/docs/installation.html#id7)

安装完后启动并部署`HelloWorld.sol`，返回的合约地址在之后的WeCross配置中需要用到。

```bash
=============================================================================================
Welcome to FISCO BCOS console(1.0.6)!
Type 'help' or 'h' for help. Type 'quit' or 'q' to quit console.
 ________ ______  ______   ______   ______       _______   ______   ______   ______
|        |      \/      \ /      \ /      \     |       \ /      \ /      \ /      \
| $$$$$$$$\$$$$$|  $$$$$$|  $$$$$$|  $$$$$$\    | $$$$$$$|  $$$$$$|  $$$$$$|  $$$$$$\
| $$__     | $$ | $$___\$| $$   \$| $$  | $$    | $$__/ $| $$   \$| $$  | $| $$___\$$
| $$  \    | $$  \$$    \| $$     | $$  | $$    | $$    $| $$     | $$  | $$\$$    \
| $$$$$    | $$  _\$$$$$$| $$   __| $$  | $$    | $$$$$$$| $$   __| $$  | $$_\$$$$$$\
| $$      _| $$_|  \__| $| $$__/  | $$__/ $$    | $$__/ $| $$__/  | $$__/ $|  \__| $$
| $$     |   $$ \\$$    $$\$$    $$\$$    $$    | $$    $$\$$    $$\$$    $$\$$    $$
 \$$      \$$$$$$ \$$$$$$  \$$$$$$  \$$$$$$      \$$$$$$$  \$$$$$$  \$$$$$$  \$$$$$$

=============================================================================================
[group:1]> deploy HelloWorld
contract address: 0x04ae9de7bc7397379fad6220ae01529006022d1b
```

#### 配置FISCO BCOS Stub

完成了FISCO BCOS的部署，需要配置FISCO BCOS Stub，即配置连接信息以及链上的资源。

- 生成配置文件

运行`create_stubs_config.sh`脚本，生成FISCO BCOS Stub的配置文件。

```bash
bash create_stubs_config.sh -b stubs bcoschain
```

```eval_rst
.. note::
    - 其中-b代表创建FISCO BCOS Stub配置文件，参数分别表示：[配置文件根目录]，[Stub名字]即区块链标识。
    - 其中的[配置文件根目录]需要和根配置文件`wecross.toml`中的[stubs.path]保存一致。
    - 详细的使用教程详见[Build WeCross脚本]()。
```

命令执行成功会输出`Create stubs/bcoschain/stub.toml successfully`，并生成文件`conf/stubs/bcoschain/stub.toml`。如果执行出错，请查看屏幕打印提示。

在`conf/stubs/bcoschain`目录下的`.pem`文件即FISCO BCOS的账户文件，已自动配置在了`stub.toml`文件中，之后只需要配置证书、群组以及资源信息。

- 配置证书

进入FISCO BCOS节点的证书目录`127.0.0.1/sdk`，将该目录下的`ca.crt, sdk.key, sdk.crt`文件拷贝到`bcoschain`目录下。

- 配置群组

```bash
vi conf/stubs/bcoschain/stub.toml
```

如果搭FISCO BCOS链采用的都是默认配置，那么将会得到一条单群组四节点的链，群组ID为1，各个节点的channel端口分别为`20200, 20201, 20202, 20203`，则将[channelService.connectionsStr]设置为['127.0.0.1:20200','127.0.0.1:20201','127.0.0.1:20202','127.0.0.1:20203']。

- 配置合约资源

在前面的步骤中，已经通过FISCO BCOS控制台部署了一个`HelloWorld`合约，地址为`0x04ae9de7bc7397379fad6220ae01529006022d1b`

那么可在配置文件中注册一条合约资源信息：

```toml 
[[resources]]
    # name cannot be repeated
    name = 'HelloWorldContract'
    type = 'BCOS_CONTRACT'
    contractAddress = '0x04ae9de7bc7397379fad6220ae01529006022d1b'
```

完成了上述的步骤，那么已经完成了FISCO BCOS Stub的连接配置，并注册了一个合约资源，最终的`stub.toml`文件如下：

```toml 
[common]
    stub = 'bcoschain' # stub must be same with directory name
    type = 'BCOS'

[smCrypto]
    # boolean
    enable = false

[account]
    accountFile = 'classpath:/stubs/bcoschain/0x0ee5b8ee4af461cac320853aebb7a68d3d4858b4.pem'
    password = ''  # if you choose .p12, then password is required


[channelService]
    timeout = 60000  # millisecond
    caCert = 'classpath:/stubs/bcoschain/ca.crt'
    sslCert = 'classpath:/stubs/bcoschain/sdk.crt'
    sslKey = 'classpath:/stubs/bcoschain/sdk.key'
    groupId = 1
    connectionsStr = ['127.0.0.1:20200','127.0.0.1:20201','127.0.0.1:20202','127.0.0.1:20203']

# resources is a list
[[resources]]
    # name cannot be repeated
    name = 'HelloWorldContract'
    type = 'BCOS_CONTRACT'
    contractAddress = '0x04ae9de7bc7397379fad6220ae01529006022d1b'
```

#### 启动并测试

```bash
bash start.sh
```
如果启动不成功，那么请检查FISCO BCOS Stub的配置是否正确。

```bash
curl http://127.0.0.1:8250/payment/bcoschain/HelloWorldContract/status
```

如果得到如下输出，则代表跨链服务已成功启动，并且通过配置文件注册的跨链资源也成功加载了。

```bash
{"version":"0.2","result":0,"message":null,"data":"exists"}
```

#### 控制台调用

启动WeCross控制台，调用`HelloWorld`合约

``` bash
[server1]> call payment.bcoschain.HelloWorldContract String get
Receipt{
    errorCode=0,
    errorMessage='success',
    hash='null',
    result=[
        Hello, World!
    ]
}
[server1]> sendTransaction payment.bcoschain.HelloWorldContract Void set "Hello WeCross!"
Receipt{
    errorCode=0,
    errorMessage='null',
    hash='0x0f87fc4588d38cce2fbaff2b6d1bbe6c627dd31200f6b95334e69fd367b0b3ec',
    result=[

    ]
}
[server1]> call payment.bcoschain.HelloWorldContract String get
Receipt{
    errorCode=0,
    errorMessage='success',
    hash='null',
    result=[
        Hello WeCross!
    ]
}
```
