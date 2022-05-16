# 手动多机组网

你可以基于已有（或新部署）的区块链环境，搭建一个与[Demo](../demo/demo.md)相似的跨链多机器网络。

![](../../images/tutorial/demo.png)

操作步骤分为以下4项：

- **[基础组件部署](./basic_env.md)**：部署WeCross基础组件，包括跨链路由、账户服务、控制台、网页管理台
- **[区块链接入与账户配置](./chains_config.md)**：将区块链接入WeCross跨链网络，并配置跨链账户
- **[资源部署与操作](./resources.md)**：基于搭建好的WeCross环境部署和操作跨链资源
- **[区块头验证配置](./security_config.md)**：配置区块头验证参数，完善跨链交易的验证逻辑

手动组网教程以`~/wecross-networks/`目录下为例进行:

``` bash
# 若已搭建WeCross Demo，请先关闭所有服务

# 创建手动组网的操作目录
mkdir -p ~/wecross-networks && cd ~/wecross-networks

```

## 下载WeCross

下载WeCross，用WeCross中的工具生成跨链路由，并启动跨链路由。

WeCross中包含了生成跨链路由的工具，执行以下命令进行下载（提供[三种下载方式](../../version/download.html#wecross)，可根据网络环境选择合适的方式进行下载），程序下载至`~/wecross-networks/WeCross/`中。

```bash
bash <(curl -sL https://github.com/WeBankBlockchain/WeCross/releases/download/resources/download_wecross.sh)

# 若出现长时间下载WeCross包失败，请尝试以下命令重新下载：
bash <(curl -sL https://gitee.com/WeBank/WeCross/raw/master/scripts/download_wecross.sh)
```

## 部署跨链路由

本例将构建两个跨链路由。首先创建一个`ipfile`配置文件，将需要构建的两个跨链路由信息（`ip:rpc_port:p2p_port`）按行分隔，保存到文件中。

**注**：请确保机器的`8250`， `25500`端口没有被占用。

```bash
cd ~/wecross-networks
vim ipfile

# 在文件中键入以下内容 如果需要更多路由可按需添加
196.128.0.1:8250:25500
196.128.0.2:8250:25500
```

生成好`ipfile`文件后，使用脚本[build_wecross.sh](../../manual/scripts.html#wecross)生成两个跨链路由。

```bash
# -f 表示以文件为输入
bash ./WeCross/build_wecross.sh -n payment -o routers-payment -f ipfile

# 成功输出如下信息
[INFO] Create routers-payment/196.128.0.1-8250-25500 successfully
[INFO] Create routers-payment/196.128.0.2-8250-25500 successfully
[INFO] All completed. WeCross routers are generated in: routers-payment/
```

```eval_rst
.. note::
    - -n 指定跨链分区标识符(zone id)，跨链分区通过zone id进行区分，可以理解为业务名称。
    - -o 指定输出的目录，并在该目录下生成一个跨链路由。
    - -f 指定需要生成的WeCross跨链路由的列表，包括ip地址，rpc端口，p2p端口，生成后的router已完成互联配置。
```

在routers-payment目录下生成了两个跨链路由。

``` bash
tree routers-payment/ -L 1
routers-payment/
├── 196.128.0.1-8250-25500
├── 196.128.0.2-8250-25500
└── cert
```

生成的跨链路由目录内容如下，以`196.128.0.1-8250-25500`为例。

```bash
# 已屏蔽lib和pages目录，该目录存放所有依赖的jar包
tree routers-payment/196.128.0.1-8250-25500/
routers-payment/1196.128.0.1-8250-25500/
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
│   └── wecross.toml  # WeCross Router主配置文件
├── create_cert.sh    # 证书生成脚本
├── download_wecross.sh
├── pages             # 网页管理平台页面文件
├── plugin            # 插件目录，接入相应类型链的插件
│   ├── bcos-stub-gm.jar
│   ├── bcos-stub.jar
│   └── fabric-stub.jar
├── start.sh          # 启动脚本
└── stop.sh           # 停止脚本
```

## 部署账户服务

- 下载

执行过程中需输入相应数据库的配置。


``` bash
cd ~/wecross-networks
bash <(curl -sL https://github.com/WeBankBlockchain/WeCross/releases/download/resources/download_account_manager.sh)

# 若出现长时间下载WeCross-Account-Manager包失败，请尝试以下命令重新下载：
bash <(curl -sL https://gitee.com/WeBank/WeCross/raw/master/scripts/download_account_manager.sh)
```

- 拷贝证书

``` bash
cd ~/wecross-networks/WeCross-Account-Manager/
cp ~/wecross-networks/routers-payment/cert/sdk/* conf/
```

- 生成私钥

``` bash
bash create_rsa_keypair.sh -d conf/
```

- 配置

``` bash
cp conf/application-sample.toml conf/application.toml
vim conf/application.toml
```

需配置内容包括：

``admin``：配置admin账户，此处可默认，router中的admin账户需与此处对应，用于登录账户服务

``db``：配置自己的数据库账号密码

``` toml
[service]
    address = '0.0.0.0'
    port = 8340
    sslKey = 'classpath:ssl.key'
    sslCert = 'classpath:ssl.crt'
    caCert = 'classpath:ca.crt'
    sslOn = true

[admin] 
    # admin账户配置，第一次启动时写入db，之后作为启动校验字段
    name = 'org1-admin' # admin账户名
    password = '123456' # 密码

[auth]
    # for issuring token
    name = 'org1'
    expires = 18000 # 5 h
    noActiveExpires = 600 # 10 min

[db]
    # for connect database
    url = 'jdbc:mysql://localhost:3306/wecross_account_manager'
    username = 'root' # 配置数据库账户
    password = '123456' # 配置数据库密码，不支接受空密码
[ext]
    # for image auth code, allow image auth token empty
    allowImageAuthCodeEmpty = true
```

- 启动

``` bash
bash start.sh
```

## 启动跨链路由

拷贝路由到具体机器，将 routers-payment/196.128.0.2-8250-25500 拷贝到196.128.0.2服务器(~/wecross-networks/routers-payment/……)

```bash
# 启动 router-196.128.0.1
cd ~/wecross-networks/routers-payment/196.128.0.1-8250-25500/
bash start.sh

# 启动 router-196.128.0.2
cd ~/wecross-networks/routers-payment/196.128.0.2-8250-25500/conf
#修改配置
vim wecross.toml
#修改[account-manager] server端口替换
#修改[rpc] # rpc ip & port address = 0.0.0.0
#修改[p2p] listenIP = ''0.0.0.0'
[account-manager]
    server =  '192.168.0.1:8340'
    admin = 'org1-admin'
    password = '123456'
    sslKey = 'classpath:ssl.key'
    sslCert = 'classpath:ssl.crt'
    caCert = 'classpath:ca.crt'
[rpc] # rpc ip & port
    address = '0.0.0.0'
    port = 8250
    caCert = 'classpath:ca.crt'
    sslCert = 'classpath:ssl.crt'
    sslKey = 'classpath:ssl.key'
    sslSwitch = 2  # disable ssl:2, SSL without client auth:1 , SSL with client and server auth: 0
    webRoot = 'classpath:pages'
    mimeTypesFile = 'classpath:conf/mime.types' # set the content-types of a file
[p2p]
    listenIP = '0.0.0.0'
    listenPort = 25500
    caCert = 'classpath:ca.crt'
    sslCert = 'classpath:ssl.crt'
    sslKey = 'classpath:ssl.key'
    peers = ['192.168.0.1:25000']
#修改[account-manager] server端口替换
#保存退出切换目录
cd ~/wecross-networks/routers-payment/196.128.0.2-8250-25500/
bash start.sh
```

启动成功，输出如下：

```
WeCross booting up .........
WeCross start successfully
```

如果启动失败，检查`8250, 25500`端口是否被占用。

``` bash
netstat -napl | grep 8250
netstat -napl | grep 25500

```

## 后续部署

- **[区块链接入与账户配置](./chains_config.md)**：将区块链接入WeCross跨链网络，并配置跨链账户
- **[资源部署与操作](./resources.md)**：基于搭建好的WeCross环境部署和操作跨链资源
- **[区块头验证配置](./security_config.md)**：配置区块头验证参数，完善跨链交易的验证逻辑

后续部署与单机部署接入一致。
