# 脚本介绍

为了方便用户使用，WeCross提供了丰富的脚本，所有脚本编译后都位于`dist`目录，本章节将对这些脚步做详细介绍。

## 启动脚本

**start.sh**

启动脚本`start.sh`用于启动WeCross服务，启动过程中的完整信息记录在start.out中。

```bash
bash start.sh
```

成功输出：
```bash
Wecross start successfully
```

失败输出：
```bash
WeCross start failed 
See logs/error.log for details 
```

## 停止脚本

**stop.sh**

停止脚本`stop.sh`用于停止WeCross服务。

```bash
bash  stop.sh
```

## 构建WeCross脚本

**build_wecross.sh**

生成WeCross跨链路由网络

```
Usage:
    -n  [Network id]                [Required] Set network ID
    -l  [ip:rpc-port:p2p-port]      [Optional] "ip:rpc-port:p2p-port" e.g:"127.0.0.1:8250:25500"
    -f  [ip list file]              [Optional] split by line, every line should be "ip:rpc-port:p2p-port". eg "127.0.0.1:8250:25500"
    -o  [Output dir]                Default ./wecross/
    -z  [Generate tar packet]       Default no
    -T  [Enable test mode]          Default no. Enable test resource.
    -h  Help
e.g
    bash build_wecross.sh -n payment -l 127.0.0.1:8250:25500
    bash build_wecross.sh -n payment -f ipfile
```

- **`-n`**：指定跨链网络标识
- **`-l`**：指定生成一个跨链路由，与`-f`二选一，单行，如：`192.168.0.1:8250:25500`
- **`-f`**：指定生成多个跨链路由，与`-l`二选一，多行，**不可有空行**，例如：

    ```
    192.168.0.1:8250:25500
    192.168.0.1:8251:25501
    192.168.0.2:8252:25502
    192.168.0.3:8253:25503
    192.168.0.4:8254:25504 
    ```
* **`-o`**：指定跨链路由生成目录，默认`wecross/`
* **`-z`**：若设置，则生成跨链路由的压缩包，方便拷贝至其它机器
* **`-T`**：若设置，生成的跨链路由开启测试资源
* **`-h`**：打印Usage

## 创建FISCO BCOS stub配置文件脚本

脚本`create_bcos_stub_config.sh`用于快速创建FISCO BCOS stub的配置文件。

可通过-h查看帮助信息：

```
Usage:
    default                             use pem as bcos account type
    -r  [Root Dir]        [Required]    specify the stubs root dir
    -n  [stub name]       [Required]    specify the name of stub
    -p  [password]        [Optional]    password for p12
    -h  Call for help
e.g
    bash create_bcos_stub_config.sh -r stubs -n bcoschain -p 123456
```

- **`-r`**： 
指定配置文件根目录，需要和根配置文件`wecross.toml`中的[stubs.path]保存一致。

- **`-n`**：
指定区块链跨链标识，即stub的名字。

- **`-p`**：
表示使用`p.12`格式的账户文件，并指定口令。默认是`pem`格式，无需口令。

例如：
```bash
bash create_bcos_stub_config.sh -r stubs -n bcoschain -p 123456
```
在`stubs`目录下查看目录结构:
```bash
tree
.
├── bcoschain
│   ├── 0x0ee5b8ee4af461cac320853aebb7a68d3d4858b4.pem
│   └── stub.toml
```

## 创建Fabric stub配置文件脚本

脚本`create_fabric_stub_config.sh`用于快速创建Fabric stub的配置文件。

可通过-h查看帮助信息：

```
Usage:
    -r  [Root Dir]        [Required]    specify the stubs root dir
    -n  [stub name]       [Required]    specify the name of stub
    -h  Call for help
e.g
    bash create_fabric_stub_config.sh -r stubs -n fabricchain
```

- **`-r`**： 
指定配置文件根目录，需要和根配置文件`wecross.toml`中的[stubs.path]保存一致。

- **`-n`**：
指定区块链跨链标识，即stub的名字。

例如：
```bash
bash create_fabric_stub_config.sh -r stubs -n fabricchain
```
在`stubs`目录下查看目录结构:
```bash
tree
.
└── fabricchain
    └── stub.toml
```

## 创建JDChain stub配置文件脚本

脚本`create_jdchain_config.sh`用于快速创建JDChain stub的配置文件。

可通过-h查看帮助信息：

```
Usage:
    -r  [Root Dir]        [Required]    specify the stubs root dir
    -n  [stub name]       [Required]    specify the name of stub
    -h  Call for help
e.g
    bash create_jdchain_stub_config.sh -r stubs -n jdchain
```

- **`-r`**： 
指定配置文件根目录，需要和根配置文件`wecross.toml`中的[stubs.path]保存一致。

- **`-n`**：
指定区块链跨链标识，即stub的名字。

例如：
```bash
bash create_jdchain_stub_config.sh -r stubs -n jdchain
```
在`stubs`目录下查看目录结构:
```bash
tree
.
└── jdchain
    └── stub.toml
```

## 创建P2P证书脚本

**create_cert.sh**

创建P2P证书脚本`create_cert.sh`用于创建P2P证书文件。WeCross Router之间通讯需要证书用于认证，只有具有相同`ca.crt`根证书的WeCross Router直接才能建立连接。

可通过-h查看帮助信息：

```
Usage:
    -c                                  [Optional] generate ca certificate
    -C <number>                         [Optional] the number of node certificate generated, work with '-n' opt, default: 1
    -D <dir>                            [Optional] the ca certificate directory, work with '-n', default: './'
    -d <dir>                            [Required] generated target_directory
    -n                                  [Optional] generate node certificate
    -t                                  [Optional] cert.cnf path, default: cert.cnf
    -h                                  [Optional] Help
e.g
    bash create_cert.sh -c -d ./ca
    bash create_cert.sh -n -D ./ca -d ./ca/node
    bash create_cert.sh -n -D ./ca -d ./ca/node -C 10
```
- **`c`**： 
生成ca证书，只有生成了ca证书，才能生成节点证书。

- **`n`**：
生成节点证书。

- **`C`**：
配合-n，指定生成节点证书的数量。

- **`D`**：
配合-n，指定ca证书路径。

- **`d`**：
指定输出目录。

- **`t`**：
指定`cert.cnf`的路径
