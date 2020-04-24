## 跨链组网

如果已完成[接入区块链](./chain.md)的体验，接下来将教您如何搭建一个WeCross跨链组网，实现不同的跨链路由之间的相互调用。请求发送至任意的跨链路由，都能够访问到正确的跨链资源。

```eval_rst
.. important::
    - WeCross跨链路由之间采用TLS协议实现安全通讯，只有持有相同ca证书的跨链路由才能建立连接。
```

### 构建多个WeCross跨链路由

```bash
cd ~/wecross
vi ipfile
```

本举例中将构造两个跨链路由，构建一个ipfile文件，将需要构建的两个跨链路由信息内容保存到文件中（按行区分：`ip地址:rpc端口:p2p端口`）：

```text
127.0.0.1:8251:25501
127.0.0.1:8252:25502
```
生成跨链路由

```bash
# -f 表示以文件为输入
bash ./WeCross/build_wecross.sh -n bill -o routers-bill -f ipfile

# 成功输出如下信息
[INFO] Create routers/127.0.0.1-8251-25501 successfully
[INFO] Create routers/127.0.0.1-8252-25502 successfully
[INFO] All completed. WeCross routers are generated in: routers-bill/
```

在routers-bill目录下生成了两个跨链路由

``` bash
tree routers-bill/ -L 1
routers-bill/
├── 127.0.0.1-8251-25501
├── 127.0.0.1-8252-25502
└── cert
```

### 跨链路由接入区块链

两个跨链路由配置同一条FISCO BCOS链的不同合约资源。

#### 配置127.0.0.1-8251-25501

让此跨链路由操作`HelloWorld`合约。

- 部署合约
```bash
cd ~/fisco/console && bash start.sh

# 部署HelloWorld合约，请将合约地址记录下来后续步骤使用
[group:1]> deploy HelloWorld
contract address: 0xe51eb006c96345f8f0d431f100f0bf619f6145d4

# 部署HelloWeCross合约，请将合约地址记录下来后续步骤使用
[group:1]> deploy HelloWeCross
contract address: 0x5854394d40e60b203e3807d6218b36d4bc0f3437

# 退出控制台
[group:1]> q
```

- 配置stub.toml

```bash
cd ~/wecross/routers-bill/127.0.0.1-8251-25501 
bash add_chain.sh -t BCOS2.0 -n bcos1
vi conf/chains/bcos1/stub.toml
# 配置哪些节点接入此链
connectionsStr = ['127.0.0.1:20201']

# 配置资源：HelloWorld合约（同时删除其他资源示例）
[[resources]]
    # name must be unique
    name = 'HelloWorld'
    type = 'BCOS_CONTRACT'
    contractAddress = '0xe51eb006c96345f8f0d431f100f0bf619f6145d4'
```

- 拷贝证书
```bash
cp ~/fisco/nodes/127.0.0.1/sdk/* ~/wecross/routers-bill/127.0.0.1-8251-25501/conf/chains/bcos1
```

- 配置账户

```bash
cd ~/wecross/routers-bill/127.0.0.1-8251-25501
bash add_account.sh -t BCOS2.0 -n bcos_user1 -d conf/accounts
```

#### 配置127.0.0.1-8252-25502

让此跨链路由操作`HelloWeCross`合约

- 配置stub.toml
```bash
cd ~/wecross/routers-bill/127.0.0.1-8252-25502 
bash add_chain.sh -t BCOS2.0 -n bcos2
vi conf/chains/bcos2/stub.toml
# 配置哪些节点接入此链
connectionsStr = ['127.0.0.1:20202']

# 配置资源：HelloWeCross合约（同时删除其他资源示例）
[[resources]]
    # name must be unique
    name = 'HelloWeCross'
    type = 'BCOS_CONTRACT'
    contractAddress = '0x5854394d40e60b203e3807d6218b36d4bc0f3437'
```

- 拷贝证书

```bash
cp ~/fisco/nodes/127.0.0.1/sdk/* ~/wecross/routers-bill/127.0.0.1-8252-25502/conf/chains/bcos2
```

#### 启动跨链路由

```bash
cd ~/wecross/routers-bill/127.0.0.1-8251-25501 
bash start.sh

cd ~/wecross/routers-bill/127.0.0.1-8252-25502 
bash start.sh
```

### 调用跨链资源

用控制台调用跨链资源，请求发到任意的跨链路由上，都可访问到跨链分区中的任意资源。

#### 拷贝控制台

为新的跨链路由拷贝一个控制台。
```bash
cd ~/wecross
cp -r WeCross-Console routers-bill/console-8251
```

#### 配置跨链控制台

```bash
# 配置console-8251
cp -f routers-bill/127.0.0.1-8251-25501/conf/*.crt console-8251/conf
cp -f routers-bill/127.0.0.1-8251-25501/conf/*.key console-8251/conf
vi console-8251/conf/application.toml
# 更新server
[connection]
    server =  '127.0.0.1:8251'
```

#### 启动跨链控制台

``` bash
cd ~/wecross/routers-bill/console-8251
bash start.sh
```

#### 跨路由访问资源

跨链路由能够进行请求转发，将调用请求正确地路由至相应的跨链资源。无论请求发至哪个跨链路由，都可正确路由至相应跨链路由配置的链上资源。

```bash
# 查看资源列表，可以看到路由127.0.0.1-8252-25502的资源
[WeCross]> listResources
path: bill.bcos1.HelloWorld, type: BCOS2.0, distance: 0
path: bill.bcos2.HelloWeCross, type: BCOS2.0, distance: 1

# 调用127.0.0.1-8252-25502的资源
[server1]> call bill.bcos2.HelloWeCross bcos_user1 get
Result: [Talk is cheap, Show me the code]

# 退出控制台
[server2]> q
````

停止跨链路由

```shell
cd ~/wecross/routers-bill/127.0.0.1-8251-25501
bash stop.sh
cd ~/wecross/routers-bill/127.0.0.1-8252-25502
bash stop.sh
```
