# 脚本介绍

为了方便用户使用，WeCross提供了丰富的脚本，所有脚本编译后都位于`dist`目录，本章节将对这些脚步做详细介绍。

## 启动脚本

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

停止脚本`stop.sh`用于停止WeCross服务。

```bash
bash  stop.sh
```

## 构建WeCross脚本

构建WeCross脚本`build_wecross.sh`用于快速部署WeCross，该脚本默认从[GitHub](https://github.com/WeBankFinTech/WeCross)下载`master`分支代码进行相关环境的搭建。

`build_wecross.sh`主要完成的工作包括：下载和编译源码，生成P2P证书，帮助用户完成根配置文件`wecross.toml`的配置。

可通过-h查看帮助信息：

```bash
bash build_wecross.sh -h

Usage:
    -i [Network ID] [IP] [Port] [Port]     Init wecross project by wecross network id, ip, rpc_port and p2p_port, e.g: payment 127.0.0.1 8250 25500
    -f [Network ID] [File]                 Init wecross project by wecross network id and ip&ports file. file should be splited by line "ip rpc_port p2p_port" e.g: 127.0.0.1 8250 25500
    -h                                     Call for help
e.g
    bash build_wecross.sh -i payment 127.0.0.1 8250 25500
```

- **`i`选项:** 
用于指定跨链网络标识，RPC监听的IP和端口，以及用于P2P通讯的端口。

- **`f`选项** 
    + 参数包括跨链网络标识和文件名。
    + 用于根据配置文件生成多个WeCross项目，最后输出`tar.gz`格式的压缩文件。
    + 文件按行分割，每一行表示一个WeCross项目，格式为`[IP] [Port] [Port]`，每行内的项使用空格分割，**不可有空行**。

下面是一个配置文件的例子，每个配置项以空格分隔。

```bash
192.168.0.1 8250 25500
192.168.0.1 8251 25501
192.168.0.2 8252 25502
192.168.0.3 8253 25503
192.168.0.4 8254 25504 
```
如果执行成功，则输出如下信息，生成的五个WeCross项目互为Peer。
```bash
Create 192.168.0.1-8250-25500.tar.gz  successfully
Create 192.168.0.1-8251-25501.tar.gz  successfully
Create 192.168.0.2-8252-25502.tar.gz  successfully
Create 192.168.0.3-8253-25503.tar.gz  successfully
Create 192.168.0.4-8254-25504.tar.gz  successfully
Build Wecross successfully
```

## 创建Stubs配置脚本

创建Stubs配置脚本`create_stubs_config.sh`用于快速创建各类Stub的配置文件。

目前支持的类型包括`FISCO BCOS, Fabric, JDChain`

`build_wecross.sh`主要完成的工作包括：创建目录，根据Stub类型拷贝配置示例，然后完成stub.toml的部分配置。

可通过-h查看帮助信息：

```bash
Usage:
    -a [Root Dir] [[Stub type] [Stub name]]   Generate stub configuration by list of types and names
                                              Supported types: BCOS, FABRIC, JD
    -b [Root Dir] [Stub name]                 Generate FISCO BCOS stub configuration
    -f [Root Dir] [Stub name]                 Generate FABRIC stub configuration
    -j [Root Dir] [Stub name]                 Generate JDChain stub configuration
    -h                                        Call for help
e.g
    bash create_stubs_config.sh -a stubs BCOS bcoschain FABRIC fabricchain
```

- **`a`选项:** 
批量生成Stub配置文件。输入Stub根目录，Stub类型和跨链标识的列表。

- **`b`选项:** 
生成FISCO BCOS Stub配置文件。输入Stub根目录，以及跨链标识。已帮忙生成了FISCO BCOS的账户文件。

- **`f`选项:** 
生成Fabric Stub配置文件。输入Stub根目录，以及跨链标识。

- **`j`选项:** 
生成JDChain Stub配置文件。输入Stub根目录，以及跨链标识。

例如：
```bash
bash create_stubs_config.sh -a stubs BCOS bcoschain FABRIC fabricchain JD jdchain
```
在`stubs`目录下查看目录结构:
```bash
tree
.
├── bcos
│   └── stub-sample.toml
├── bcoschain
│   ├── 0x0ee5b8ee4af461cac320853aebb7a68d3d4858b4.pem
│   └── stub.toml
├── fabric
│   └── stub-sample.toml
├── fabricchain
│   └── stub.toml
├── jd
│   └── stub-sample.toml
└── jdchain
    └── stub.toml
```

## 创建P2P证书脚本

创建P2P证书脚本`create_cert.sh`用于创建P2P证书文件。WeCross Router之间通讯需要证书用于认证，只有具有相同`ca.crt`根证书的WeCross Router直接才能建立连接。

可通过-h查看帮助信息：

```bash
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
- **`c`选项:** 
生成ca证书，只有生成了ca证书，才能生成节点证书。

- **`n`选项:** 
生成节点证书。

- **`C`选项:** 
配合-n，指定生成节点证书的数量。

- **`D`选项:** 
配合-n，指定ca证书路径。

- **`d`选项:** 
指定输出目录。

- **`t`选项:** 
指定`cert.cnf`的路径

## 创建FISCO BCOS账户脚本

脚本`create_bcos_account.sh`用于生成FISCO BCOS的账户。

FISCO BCOS账户文件有两种类型`.pem, .p12`，其中`.p12`需要输入口令。

脚本`create_bcos_account.sh`会同时生成两种类型的账户，用户可根据需求选择使用不同的账户。
