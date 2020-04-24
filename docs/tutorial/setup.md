# 快速部署

本文档指导完成[**跨链路由**](../introduction/introduction.html#id2)和[**跨链控制台**](../manual/console.md)的部署。

* **跨链路由**：与区块链节点对接，并彼此互连，形成[跨链分区](../introduction/introduction.html#id2)，负责跨链请求的转发

* **跨链控制台**：查询和发送交易的操作终端

操作以`~/wecross/`目录下为例进行

``` bash
mkdir -p ~/wecross/ && cd ~/wecross/
```

## 部署 WeCross

下载WeCross，用WeCross中的工具生成跨链路由，并启动跨链路由。

### 下载WeCross

WeCross中包含了生成跨链路由的工具，执行以下命令进行下载（提供[三种下载方式](../version/download.html#wecross)，可根据网络环境选择合适的方式进行下载），程序下载至当前目录`WeCross/`中。

```bash
bash <(curl -sL https://github.com/WeBankFinTech/WeCross/releases/download/resources/download_wecross_rc2.sh) -s -b release-rc2
```

### 生成跨链路由

用WeCross中的 [build_wecross.sh](../manual/scripts.html#wecross)生成一个跨链路由。请确保机器的`8250`, `25500`端口没有被占用。

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
├── add_account.sh    # 账户生成脚本
├── add_chain.sh      # 区块链配置文件创建脚本
├── apps
│   └── WeCross.jar   # WeCross路由jar包
├── build_wecross.sh
├── conf              # 配置文件目录
│   ├── accounts      # 账户配置目录
│   ├── application.properties 
│   ├── chains        # 区块链配置目录，要接入不同的链，在此目录下进行配置
│   ├── log4j2.xml    
│   ├── ca.crt        # 根证书
│   ├── ssl.crt       # 跨链路由证书
│   ├── ssl.key       # 跨链路由私钥
│   ├── node.nodeid   # 跨链路由nodeid
│   └── wecross.toml
├── create_cert.sh    # 证书生成脚本
├── download_wecross.sh
├── plugin            # 插件目录
│   ├── bcos-stub-gm.jar
│   ├── bcos-stub.jar
│   └── fabric-stub.jar
├── start.sh          # 启动脚本
└── stop.sh           # 停止脚本
```

### 配置账户
用户的账户统一配置在router，可根据脚本生成相应链的账户。

```bash
cd ~/wecross/routers-payment/127.0.0.1-8250-25500/
bash add_account.sh -t BCOS2.0 -n bcos_user1 -d conf/accounts
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

``` bash
netstat -napl | grep 8250
netstat -napl | grep 25500
```

查看失败日志

```bash
cat logs/error.log
```

## 部署WeCross控制台

WeCross提供了控制台，方便用户进行跨链开发和调试。可通过脚本`build_console.sh`搭建一个WeCross控制台。

* 下载WeCross控制台

执行如下命令进行下载（提供[三种下载方式](../version/download.html#id2)，可根据网络环境选择合适的方式进行下载），下载后在执行命令的目录下生成`WeCross-Console`目录。

```bash
cd ~/wecross/
bash <(curl -sL https://github.com/WeBankFinTech/WeCross-Console/releases/download/resources/download_console-rc2.sh) -s -b release-rc2
```

- 配置控制台

```bash
cd WeCross-Console
cp conf/application-sample.toml conf/application.toml  # 配置控制台连接的跨链路由地址，此处采用默认配置
# 拷贝TLS证书
cp ~/wecross/routers-payment/127.0.0.1-8250-25500/conf/ssl.crt conf
cp ~/wecross/routers-payment/127.0.0.1-8250-25500/conf/ssl.key conf
cp ~/wecross/routers-payment/127.0.0.1-8250-25500/conf/ca.crt  conf
```

```eval_rst
.. important::
    - 若搭建WeCross的IP和端口未使用默认配置，需自行更改WeCross-Console/conf/application.toml，详见 `控制台配置 <../manual/application.toml#id11>`_。
```

- 启动控制台

```bash
bash start.sh
```

启动成功则输出如下信息，通过`help`可查看控制台帮助

```bash
=================================================================================
Welcome to WeCross console(v1.0.0-rc2)!
Type 'help' or 'h' for help. Type 'quit' or 'q' to quit console.
=================================================================================
```

- 测试功能

```bash
# 查看router当前支持的stub类型
[WeCross]> supportedStubs
[BCOS2.0, GM_BCOS2.0, Fabric1.4]

# 退出控制台
[server1]> q
```

更多控制台命令及含义详见[控制台命令](../manual/console.html#id13)。
