# 快速部署

操作以`~`目录下为例进行

``` shell
cd ~
```

## 部署 WeCross

下载WeCross，用WeCross中的工具生成跨链路由，并启动跨链路由。

### 下载WeCross

执行如下命令进行下载（提供[三种下载方式](./download.md)，可根据网络环境选择合适的方式进行下载）

```shell
bash <(curl -s https://raw.githubusercontent.com/WeBankFinTech/WeCross/release-0.2/scripts/download_wecross.sh)
```

### 生成跨链路由

生成一个WeCross跨链路由，并调用其自带的测试资源，检查跨链组件是否正常运行。

在不接入何链的情况下，部署一个WeCross跨链路由，并调用其自带的测试资源，检查跨链组件是否正常运行。

在`WeCross`目录下执行下面的指令，请确保机器的`8250, 25500`端口没有被占用。

```bash
cd ~/WeCross
bash build_wecross.sh -n payment -l 127.0.0.1:8250:25500 -T
```

```eval_rst
.. note::
    - -n 指定跨链网络标识符(network id)，跨链网络通过network id进行区分，可以理解为业务名称。
    - -l 指定此WeCross跨链路由的ip地址，rpc端口，p2p端口。
    - -T 启用测试资源，它不属于任何一条链，仅用户测试跨链服务是否正常运行。
    详细的使用教程详见 `Build WeCross脚本 <../manual/scripts.html#wecross>`_。
```

命令执行成功，在目录下生成`routers`目录，目录中包含`127.0.0.1-8250-25500`

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

### 启动跨链路由

* 启动服务

```bash
cd routers/127.0.0.1-8250-25500/
bash start.sh
```
成功

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

* 检查服务

WeCross模拟了一个用于测试的合约资源，可通过访问测试资源的status接口，确认服务是否正常。
``` bash
curl http://127.0.0.1:8250/test-network/test-stub/test-resource/status

# 如果输出如下内容，说明跨链路由服务已完全启动
{"version":"0.2","result":0,"message":null,"data":"exists"}  
```

* 停止服务

通过停止脚本`stop.sh`停止跨链路由服务，该脚本也位于`127.0.0.1-8250-25500`目录。

```bash 
bash stop.sh
```

## 部署WeCross控制台

WeCross提供了控制台，方便用户进行跨链开发和调试。可通过脚本`build_console.sh`搭建一个WeCross控制台。

* 下载WeCross控制台

执行如下命令进行下载（提供[三种下载方式](./download.md)，可根据网络环境选择合适的方式进行下载）

```shell
bash <(curl -s https://raw.githubusercontent.com/WeBankFinTech/WeCross-Console/dev/scripts/download_console.sh)
```

- 配置控制台

```bash
cd ~/WeCross-Console/
cp conf/console-sample.xml conf/console.xml
```

```eval_rst
.. important::
    - 若搭建WeCross的IP和端口未使用默认配置，需自行更改WeCross-Console/conf/console.xml，详见 `控制台配置 <../manual/console.html#id11>`_。
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

- 测试功能

使用`listResources`命令查看WeCross管理的跨链资源列表，更多的命令以及其含义详见[控制台命令](../manual/console.html#id13)。

```bash
[server1]> listResources 
Resources{
    errorCode=0,
    errorMessage='',
    resourceList=[
        WeCrossResource{
        WeCrossResource{
            checksum='0x7644243d71d1b1c154c717075da7bfe2d22bb2a94d7ed7693ab481f6cb11c756',
            type='TEST_RESOURCE',
            distance=0,
            path='test-network.test-stub.test-resource'
        }
    ]
}

# 退出控制台
[server1]> q
```
