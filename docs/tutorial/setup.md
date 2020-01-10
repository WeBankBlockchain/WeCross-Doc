# 快速部署

本文档指导完成[**跨链路由**](../introduction/introduction.html#id2)和[**跨链控制台**](../manual/console.md)的部署。

* **跨链路由**：    与区块链节点对接，并彼此互连，形成[跨链分区](../introduction/introduction.html#id2)，负责跨链请求的转发
* **跨链控制台**：查询和发送交易的操作终端

操作以`~/wecross/`目录下为例进行

``` shell
mkdir -p ~/wecross/ && cd ~/wecross/
```

## 部署 WeCross

下载WeCross，用WeCross中的工具生成跨链路由，并启动跨链路由。

### 下载WeCross

WeCross中包含了生成跨链路由的工具，执行以下命令进行下载（提供[三种下载方式](../version/download.html#wecross)，可根据网络环境选择合适的方式进行下载），程序下载至当前目录`WeCross/`中。

```shell
bash <(curl -sL https://github.com/WeBankFinTech/WeCross/releases/download/resources/download_wecross.sh)
```

### 生成跨链路由

用WeCross中的 [build_wecross.sh](../manual/scripts.html#wecross) 生成一个跨链路由。请确保机器的`8250`, `25500`端口没有被占用。

```bash
bash ./WeCross/build_wecross.sh -n payment -o routers-payment -l 127.0.0.1:8250:25500 
```

```eval_rst
.. note::
    - -n 指定跨链分区标识符(zone id)，跨链分区通过zone id进行区分，可以理解为业务名称。
    - -o 指定输出的目录，并在该目录下生成一个跨链路由。
    - -l 指定此WeCross跨链路由的ip地址，rpc端口，p2p端口。
```

命令执行成功，生成`routers-payment/`目录，目录中包含一个跨链路由`127.0.0.1-8250-25500`

``` bash
[INFO] All completed. WeCross routers are generated in: routers-payment/
```

生成的跨链路由`127.0.0.1-8250-25500`目录内容如下

```bash
# 已屏蔽lib目录，该目录存放所有依赖的jar包
tree routers-payment/127.0.0.1-8250-25500/ -I "lib"
routers-payment/127.0.0.1-8250-25500/
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
cd ~/wecross/routers-payment/127.0.0.1-8250-25500/
bash start.sh 
#停止: bash stop.sh
```
成功

```
WeCross booting up .........
WeCross start successfully
```
如果启动失败，检查`8250, 25500`端口是否被占用

``` shell
netstat -napl | grep 8250
netstat -napl | grep 25500
```

查看失败日志

```bash
cat logs/error.log
```

* 检查服务

调用服务的test接口，检查服务是否启动
``` bash
curl http://127.0.0.1:8250/test && echo

# 如果输出如下内容，说明跨链路由服务已完全启动
OK！
```

## 部署WeCross控制台

WeCross提供了控制台，方便用户进行跨链开发和调试。可通过脚本`build_console.sh`搭建一个WeCross控制台。

* 下载WeCross控制台

执行如下命令进行下载（提供[三种下载方式](../version/download.html#id2)，可根据网络环境选择合适的方式进行下载），下载后在执行命令的目录下生成`WeCross-Console`目录。

```shell
cd ~/wecross/
bash <(curl -sL https://github.com/WeBankFinTech/WeCross-Console/releases/download/resources/download_console.sh)
```

- 配置控制台

```bash
cd ./WeCross-Console/
cp conf/console-sample.xml conf/console.xml  # 配置控制台连接的跨链路由地址，此处采用默认配置
```

```eval_rst
.. important::
    - 若搭建WeCross的IP和端口未使用默认配置，需自行更改WeCross-Console/conf/console.xml，详见 `控制台配置 <../manual/console.html#id11>`_。
```

- 启动控制台

```bash
bash start.sh
```

启动成功则输出如下信息，通过`help`可查看控制台帮助

```bash
=================================================================================
Welcome to WeCross console(v1.0.0-rc1)!
Type 'help' or 'h' for help. Type 'quit' or 'q' to quit console.
=================================================================================
```

- 测试功能

```bash
# 查看此控制台已连接上的跨链路由
[server1]> currentServer
[server1, 127.0.0.1:8250]

# 退出控制台
[server1]> q
```

更多控制台命令及含义详见[控制台命令](../manual/console.html#id13)。

