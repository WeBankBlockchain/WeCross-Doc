## 跨链组网

如果已经体验完WeCross+区块链，接下来将教您如何搭建一个WeCross组网，实现不同的跨链代理之间的相互调用。

```eval_rst
.. important::
    - WeCross跨链路由之间采用TLS协议实现安全通讯，因此只有具有相同ca证书的跨链路由才能建立连接。
```

### 构建多个WeCross

```bash
cd ~/wecross
vi data
```

构建一个data文件，将以下内容保存到文件中：

```text
127.0.0.1:8251:25501
127.0.0.1:8252:25502
```

```bash
# -f 表示以文件为输入
# -c 指定ca证书路径，之后将基于该证书颁发各个跨链路由的节点证书
bash build_wecross.sh -n payment -f data -c ./routers/cert

# 成功输出如下信息
[INFO] Create routers/127.0.0.1-8251-25501 successfully
[INFO] Create routers/127.0.0.1-8252-25502 successfully
[INFO] All completed. WeCross routers are generated in: routers/

# routers目录下多了两个文件夹
ls routers
127.0.0.1-8250-25500 127.0.0.1-8252-25502 
127.0.0.1-8251-25501 cert
```

### 配置P2P

跨链路由之间要实现互连，需要在配置P2P信息。

```bash 
# 配置127.0.0.1-8250-25500
vi ~/wecross/routers/127.0.0.1-8250-25500/conf/wecross.toml
# 在p2p项目中设置peers
peers = ['127.0.0.1:25501','127.0.0.1:25502']

# 配置127.0.0.1-8251-25501
vi ~/wecross/routers/127.0.0.1-8251-25501/conf/wecross.toml
peers = ['127.0.0.1:25500','127.0.0.1:25502']

# 配置127.0.0.2-8251-25502
vi ~/wecross/routers/127.0.0.1-8252-25502/conf/wecross.toml
peers = ['127.0.0.1:25500','127.0.0.1:25501']
```

### 配置FISCO BCOS stub

- 部署HelloWorld合约

```bash
cd ~/fisco/console && bash start.sh

# 部署合约
[group:1]> deploy HelloWorld
contract address: 0xe51eb006c96345f8f0d431f100f0bf619f6145d4
```

- 配置stub.toml

```bash
# 配置127.0.0.1-8251-25501
cd ~/wecross/routers/127.0.0.1-8251-25501 
bash create_bcos_stub_config.sh -n bcos1
vi conf/stubs/bcos1/stub.toml
# 配置合约资源
[[resources]]
    # name must be unique
    name = 'HelloWorld'
    type = 'BCOS_CONTRACT'
    contractAddress = '0xe51eb006c96345f8f0d431f100f0bf619f6145d4'

# 配置127.0.0.1-8252-25502
cd ~/wecross/routers/127.0.0.1-8252-25502 
bash create_bcos_stub_config.sh -n bcos2
vi conf/stubs/bcos2/stub.toml
# 配置合约资源
[[resources]]
    # name must be unique
    name = 'HelloWorld'
    type = 'BCOS_CONTRACT'
    contractAddress = '0xe51eb006c96345f8f0d431f100f0bf619f6145d4'
```

- 拷贝证书

```bash
# 拷贝到127.0.0.1-8251-25501
cp ~/fisco/nodes/127.0.0.1/sdk/* ~/wecross/routers/127.0.0.1-8251-25501/conf/stubs/bcos1

# 拷贝到127.0.0.1-8252-25502
cp ~/fisco/nodes/127.0.0.1/sdk/* ~/wecross/routers/127.0.0.1-8252-25502/conf/stubs/bcos2
```

### 启动跨链路由

```bash
# 由于127.0.0.1-8250-25500更新了P2P配置，因此需要重新启动
cd ~/wecross/routers/127.0.0.1-8250-25500
bash stop.sh
bash start.sh

# 首次启动
cd ~/wecross/routers/127.0.0.1-8251-25501 
bash start.sh

# 首次启动
cd ~/wecross/routers/127.0.0.1-8250-25502 
bash start.sh
```

### 配置控制台

在控制台配置文件中增加新的跨链路由的信息。

```bash
cd ~/wecross/console
vi conf/console.xml 
# 配置map信息
<map>
    <entry key="server1" value="127.0.0.1:8250"/>
    <entry key="server2" value="127.0.0.1:8251"/>
    <entry key="server3" value="127.0.0.1:8252"/>
</map>
```

### 控制台调用

到此为止已完成了所有的准备工作，之后就可以通过控制台体验跨链代理之间的相互调用

```bash
# 查看配置的所有跨链路由
[server1]> listServers 
{server1=127.0.0.1:8250, server2=127.0.0.1:8251, server3=127.0.0.1:8252}

# 查看server1的资源列表，可以看到server1所连接的跨链路由的资源也在列表中
[server1]> listResources 
Resources{
    errorCode=0,
    errorMessage='',
    resourceList=[
        WeCrossResource{
            checksum='0xdcb8e609e025c8e091d18fe18b8d66d34836bd3051a08ce615118d27e4a29ebe',
            type='REMOTE_RESOURCE',
            distance=1,
            path='payment.bcos2.HelloWorld'
        },
        WeCrossResource{
            checksum='0xdcb8e609e025c8e091d18fe18b8d66d34836bd3051a08ce615118d27e4a29ebe',
            type='REMOTE_RESOURCE',
            distance=1,
            path='payment.bcos1.HelloWorld'
        },
        WeCrossResource{
            checksum='0xa88063c594ede65ee3c4089371a1e28482bd21d05ec1e15821c5ec7366bb0456',
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

# 调用server2的资源
[server1]> call payment.bcos1.HelloWorld String get
Receipt{
    errorCode=0,
    errorMessage='success',
    hash='null',
    result=[
        Hello,
        World!
    ]
}

# 调用server3的资源
[server1]> call payment.bcos2.HelloWorld String get
Receipt{
    errorCode=0,
    errorMessage='success',
    hash='null',
    result=[
        Hello,
        World!
    ]
}

# 切换server3
[server1]> switch server3

# server3调用server1的资源
[server3]> call payment.bcos.HelloWeCross Int getNumber
Receipt{
    errorCode=0,
    errorMessage='success',
    hash='null',
    result=[
        2019
    ]
}
````
